public class LexisNexisManager {

    public static ApplicationDB applicationDBInstance = new ApplicationDB();
    public static AccountDB accountDBInstance = new AccountDB();
    public static PartyDB partyDBInstance = new PartyDB();
    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    public static CreditReportDetailDB creditReportDetailDBInstance = new CreditReportDetailDB();
    public static ContactDB contactDBInstance = new ContactDB();
    public static UnderWriterTaskDB underWriterTaskDBInstance = new UnderWriterTaskDB();

    public static void requestLexisNexisBIIDCheck(List<genesis__Applications__c> listOfApplications) {
        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>(listOfApplications);
        Map<Id, Id> applicationIdToAccountId = new Map<Id, Id>();
        Map<Id, Id> contactIdToAccountId = new Map<Id, Id>();
        Map<Id, String> contactIdToPartyType = new Map<Id, String>();
        List<Credit_Report_Detail__c> reportList = new List<Credit_Report_Detail__c>();
        Map<Id, Map<String, String>> responseMapByCreditReportDetail = new Map<Id, Map<String, String>>();
        Map<String, String> businessResponseMap = new Map<String, String>();

        Set<String> taskNames = new Set<String> {
            LexisNexiss.TASK_TYPE_PROOF_OF_OWNERSHIP, LexisNexiss.TASK_TYPE_LEGAL_NAME,
            LexisNexiss.TASK_TYPE_LEGAL_ADDRESS, LexisNexiss.TASK_TYPE_PRIOR_CAN_HISTORY, LexisNexiss.TASK_TYPE_BUSINESS_PHONE
        };

        Set<String> allBeneficialParties = new Set<String> ();

        List<clcommon__Party__c> partyList = partyDBInstance.getBorrowerGuarantorsAndContactBeneficialOwnersByApplicationIds(
            applicationMap.keySet()
        );
        for(clcommon__Party__c party : partyList) {
            if(party.clcommon__Type__c == OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BORROWER)) {
                applicationIdToAccountId.put(party.genesis__Application__c, party.clcommon__Account__c);
            } else {
                contactIdToAccountId.put(party.clcommon__Contact__c, party.genesis__Application__r.genesis__Account__c);
                String partyType = party.clcommon__isPrimary__c ? LexisNexiss.PARTY_TYPE_PRIMARY_GUARANTOR :
                    ((party.clcommon__Type__c == OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_GUARANTOR)) ?
                        LexisNexiss.PARTY_TYPE_ADDITIONAL_GUARANTORS : LexisNexiss.PARTY_TYPE_BENEFICIAL_OWNER
                    );
                contactIdToPartyType.put(party.clcommon__Contact__c, partyType);
            }
        }

        Map<Id, Account> accountMap = new Map<Id, Account> (accountDBInstance.getAccountByIds(
            new Set<Id> (applicationIdToAccountId.values()))
        );

        Map<Id, Map<String, List<Contact>>> contactListToPartyTypeByAccountId = new Map<Id, Map<String, List<Contact>>>();

        List<Contact> contactList = (contactDBInstance.getContactsByIds(new Set<Id> (contactIdToAccountId.keySet())));

        for (Contact contactRecord : contactList) {
            Id borrowerAccountId = contactIdToAccountId.get(contactRecord.Id);
            String partyType = contactIdToPartyType.get(contactRecord.Id);
            if(contactListToPartyTypeByAccountId.containsKey(borrowerAccountId)) {
                if(contactListToPartyTypeByAccountId.get(borrowerAccountId).containsKey(partyType)) {
                    contactListToPartyTypeByAccountId.get(borrowerAccountId).get(partyType).add(contactRecord);
                } else {
                    contactListToPartyTypeByAccountId.get(borrowerAccountId).put(partyType, new List<Contact> {contactRecord} );
                }
            } else {
                contactListToPartyTypeByAccountId.put(borrowerAccountId,
                    new Map<String, List<Contact>> {partyType => new List<Contact> {contactRecord} });
            }

            taskNames.add(contactRecord.FirstName.toUpperCase() + ' ' + contactRecord.LastName.toUpperCase());
            allBeneficialParties.add(contactRecord.FirstName.toUpperCase() + ' ' + contactRecord.LastName.toUpperCase());
        }

        Map<Id, Credit_Report_Detail__c> creditReportByApplicationId = new Map<Id, Credit_Report_Detail__c>();
        for (Credit_Report_Detail__c existingReport :
                creditReportDetailDBInstance.getLexisNexisCreditReportByApplicationIds((applicationMap.keySet()))
        ) {
            creditReportByApplicationId.put(existingReport.Application__c, existingReport);
        }

        Map<String, UnderWriter_Task__c> underWriterTaskByApplicationIdTaskName = new Map<String, UnderWriter_Task__c>();
        for (UnderWriter_Task__c uwTask :
            underWriterTaskDBInstance.getUnderWriterTaskByApplicationIdsAndTaskNames(applicationMap.keySet(), taskNames)
        ) {
            underWriterTaskByApplicationIdTaskName.put(uwTask.Application__c + uwTask.Task_Name__c, uwTask);
        }

        for (genesis__Applications__c application : listOfApplications) {
            genesis__Applications__c applicationShell = new genesis__Applications__c(Id = application.Id, Is_Manual_Score_Run__c = application.Is_Manual_Score_Run__c);
            Account accountDetail = accountMap.get(applicationIdToAccountId.get(application.Id));
            Map<String, List<Contact>> contactListForRelatedAccount = contactListToPartyTypeByAccountId.get(accountDetail.Id);

            Map<String, Object> businessInstantIdProfile;
            HttpResponse businessInstantIdProfileFullResponse;
            LexisNexisCallOutParser parser = new LexisNexisCallOutParser(accountDetail, contactListForRelatedAccount, null, 'BID');

            try {
                businessInstantIdProfileFullResponse = LexisNexisCallOut.requestBusinessInstantIDCheck(accountDetail, contactListForRelatedAccount);
                businessInstantIdProfile = parser.businessInstantIdResponseParse(businessInstantIdProfileFullResponse);

                Credit_Report_Detail__c creditReport = LexisNexiss.createLexisNexisBIIDCreditReportDetail(
                    businessInstantIdProfile, accountDetail, creditReportByApplicationId,
                    underWriterTaskByApplicationIdTaskName, application, allBeneficialParties
                );
                String lexisNexisReportResponse = businessInstantIdProfileFullResponse.getBody();
                businessResponseMap.put('lexisNexisReport', lexisNexisReportResponse);
                responseMapByCreditReportDetail.put(application.Id, businessResponseMap);

                if(creditReport != null) {
                    reportList.add(creditReport);
                }

                applicationShell.genesis__Status__c = Applications.STATUS_INDUSTRY_CHECK;
                applicationDBInstance.addUpdate(applicationShell);

            } catch (Exception e) {
                applicationShell.genesis__Status__c = Applications.STATUS_LEXISNEXIS_CHECK_FAILED;
                Error_Log__c errorLog = ErrorLogs.createErrorLog('LexisNexis BIID Check', e, applicationShell.Id, false);
                errorLogDBInstance.addInsert(errorLog);
                applicationDBInstance.addUpdate(applicationShell);
            }
        }

        accountDBInstance.executeUpdates();
        if(!reportList.isEmpty()) {
            creditReportDetailDBInstance.addUpserts(reportList).executeUpserts();
        }
        underWriterTaskDBInstance.addUpdates(underWriterTaskByApplicationIdTaskName.values()).executeUpdates();
        applicationDBInstance.executeUpdates();
        errorLogDBInstance.executeInserts();

        if(!reportList.isEmpty()) {
            new QueueableJobHandler().executeSFTPScoringRawDataQueueableJob(
                reportList, responseMapByCreditReportDetail, applicationIdToAccountId
            );
        }

    }

    public static void requestLexisNexisFraudScoreCheck(List<genesis__Applications__c> listOfApplications) {
        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>(listOfApplications);
        Map<Id, Id> applicationIdToAccountId = new Map<Id, Id>();
        Map<Id, Id> contactIdToAccountId = new Map<Id, Id>();
        Set<String> taskNames = new Set<String> { LexisNexiss.TASK_TYPE_FRAUD_POINT_SCORE };
        Map<Id, Map<String, String>> responseMapByCreditReportDetail = new Map<Id, Map<String, String>>();
        Map<String, String> fraudScoreResponseMap = new Map<String, String>();
        List<Credit_Report_Detail__c> reportList = new List<Credit_Report_Detail__c>();

        List<clcommon__Party__c> partyList = partyDBInstance.getBorrowerAndPrimanyGuarantorByApplicationIds(applicationMap.keySet());
        for(clcommon__Party__c party : partyList) {
            if(party.clcommon__Type__c == OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BORROWER)) {
                applicationIdToAccountId.put(party.genesis__Application__c, party.clcommon__Account__c);
            } else {
                contactIdToAccountId.put(party.clcommon__Contact__c, party.genesis__Application__r.genesis__Account__c);
            }
        }

        Map<Id, Account> accountMap = new Map<Id, Account> (accountDBInstance.getAccountByIds(
            new Set<Id> (applicationIdToAccountId.values()))
        );

        Map<Id, Credit_Report_Detail__c> creditReportByApplicationId = new Map<Id, Credit_Report_Detail__c>();
        for (Credit_Report_Detail__c existingReport :
                creditReportDetailDBInstance.getLexisNexisCreditReportByApplicationIds((applicationMap.keySet()))
        ) {
            creditReportByApplicationId.put(existingReport.Application__c, existingReport);
        }

        Map<Id, List<Contact>> contactListByAccountId = new Map<Id, List<Contact>>();

        List<Contact> contactList = (contactDBInstance.getContactsByIds(new Set<Id> (contactIdToAccountId.keySet())));

        for (Contact contactRecord : contactList) {
            Id borrowerAccountId = contactIdToAccountId.get(contactRecord.Id);
            if(contactListByAccountId.containsKey(borrowerAccountId)) {
                contactListByAccountId.get(borrowerAccountId).add(contactRecord);
            }else {
                contactListByAccountId.put(borrowerAccountId, new List<Contact> { contactRecord });
            }
        }

        Map<String, UnderWriter_Task__c> underWriterTaskByApplicationIdTaskName = new Map<String, UnderWriter_Task__c>();
        for (UnderWriter_Task__c uwTask :
            underWriterTaskDBInstance.getUnderWriterTaskByApplicationIdsAndTaskNames(applicationMap.keySet(), taskNames)
        ) {
            underWriterTaskByApplicationIdTaskName.put(uwTask.Application__c + uwTask.Task_Name__c, uwTask);
        }

        for (genesis__Applications__c application : listOfApplications) {
            genesis__Applications__c applicationShell = new genesis__Applications__c(Id = application.Id);
            Account accountDetail = accountMap.get(applicationIdToAccountId.get(application.Id));
            List<Contact> contactListForRelatedAccount = contactListByAccountId.get(accountDetail.Id);
            HttpResponse fraudPointProfileFullResponse;
            Map<String, Object> fraudPointProfile;
            LexisNexisCallOutParser parser = new LexisNexisCallOutParser(accountDetail, null, contactList, 'FraudPoint');

            try {
                fraudPointProfileFullResponse = LexisNexisCallOut.requestFraudPointCheck(accountDetail, contactListForRelatedAccount);
                fraudPointProfile = parser.fraudPointResponseParse(fraudPointProfileFullResponse);

                Credit_Report_Detail__c creditReport = LexisNexiss.createLexisNexisFraudScoreCreditReportDetail(
                    fraudPointProfile, creditReportByApplicationId, underWriterTaskByApplicationIdTaskName, application
                );

                String lexisNexisReportResponse = fraudPointProfileFullResponse.getBody();
                fraudScoreResponseMap.put('fraudScoreReport', lexisNexisReportResponse);
                responseMapByCreditReportDetail.put(application.Id, fraudScoreResponseMap);

                if(creditReport != null) {
                    reportList.add(creditReport);
                }
                applicationShell.genesis__Status__c = Applications.STATUS_BANK_STATEMENT_UPLOAD;
                applicationDBInstance.addUpdate(applicationShell);
            }  catch (Exception e) {
                applicationShell.genesis__Status__c = Applications.STATUS_LEXISNEXIS_CHECK_FAILED;
                Error_Log__c errorLog = ErrorLogs.createErrorLog('LexisNexis Fraud Score Check', e, applicationShell.Id, false);
                errorLogDBInstance.addInsert(errorLog);
                applicationDBInstance.addUpdate(applicationShell);
            }
        }

        accountDBInstance.executeUpdates();
        if(!reportList.isEmpty()) {
            creditReportDetailDBInstance.addUpdates(reportList).executeUpdates();
        }
        underWriterTaskDBInstance.addUpdates(underWriterTaskByApplicationIdTaskName.values()).executeUpdates();
        applicationDBInstance.executeUpdates();
        errorLogDBInstance.executeInserts();

        if(!reportList.isEmpty()) {
            new QueueableJobHandler().executeSFTPScoringRawDataQueueableJob(
                reportList, responseMapByCreditReportDetail, applicationIdToAccountId
            );
        }
    }

    private class LexisNexisManagerException extends Exception {}
}