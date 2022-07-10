public class BusinessRuleManager {
    @TestVisible
    private static PartyDB partyDBInstance = new PartyDB();
    @TestVisible
    private static AccountDB accountDBInstance = new AccountDB();
    @TestVisible
    private static CreditReportDetailDB creditReportDetailDBInstance = new CreditReportDetailDB();
    @TestVisible
    private static STIPSChecklistDB stipsDBInstance = new STIPSChecklistDB();
    @TestVisible
    private static OcrolusReportDB ocrolusReportDBInstance = new OcrolusReportDB();
    @TestVisible
    private static CLContractDB clContractDBInstance = new CLContractDB();
    @TestVisible
    private static OpportunityDB opportunityDBInstance = new OpportunityDB();
    @TestVisible
    private static UnderWriterTaskDB underWriterTaskDBInstance = new UnderWriterTaskDB();
    @TestVisible
    private static ApplicationDB applicationDBInstance = new ApplicationDB();
    @TestVisible
    private static ContactDB contactDBInstance = new ContactDB();
    @TestVisible
    private static DataMerchNoteDB dataMerchNoteDBInstance = new DataMerchNoteDB();

    public static void runSTIPSAndUWTasksVerificationRules(List<genesis__Applications__c> applicationList) {

        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>(applicationList);
        Set<String> taskNames = new Set<String> {
            BusinessRules.TASK_NAME_OCR_FRAUD_ALERT, BusinessRules.TASK_NAME_EXPERIAN_FRAUD_ALERT
        };
        Map<Id, Id> applicationIdByContactAndAccountId = new Map<Id, Id>();
        Map<Id, String> allBeneficialPartiesByApplicationId = new Map<Id, String>();
        for(genesis__Applications__c application : applicationList) {
            applicationIdByContactAndAccountId.put(application.Primary_Guarantor__c, application.Id);
            applicationIdByContactAndAccountId.put(application.genesis__Account__c, application.Id);
        }

        List<clcommon__Party__c> partyList = partyDBInstance.getGuarantorsAndContactBeneficialOwnersByApplicationIds(
            applicationMap.keySet()
        );

        for(clcommon__Party__c party : partyList) {
            if(allBeneficialPartiesByApplicationId.containsKey(party.genesis__Application__c)) {
                allBeneficialPartiesByApplicationId.put( party.genesis__Application__c,
                    allBeneficialPartiesByApplicationId.get(party.genesis__Application__c) + ', '
                        + party.clcommon__Contact__r.FirstName + ' ' + party.clcommon__Contact__r.LastName
                );
            } else {
                allBeneficialPartiesByApplicationId.put(party.genesis__Application__c,
                    party.clcommon__Contact__r.FirstName + ' ' + party.clcommon__Contact__r.LastName
                );
            }
        }

        Map<Id, Account> accountMap = new Map<Id, Account>(accountDBInstance.getAccountByIds(applicationIdByContactAndAccountId.keySet()));

        List<Credit_Report_Detail__c> creditReportDetailList = creditReportDetailDBInstance.getAllReportByApplicationIdOrAccountIdOrContactId(
            applicationIdByContactAndAccountId.keySet(), applicationMap.keySet()
        );

        Map<Id, Map<String, Credit_Report_Detail__c>> creditReportDetailByApplicationId = new Map<Id, Map<String, Credit_Report_Detail__c>>();

        for(Credit_Report_Detail__c creditReportDetail : creditReportDetailList) {
            Id applicationId;
            if(creditReportDetail.Contact__c != null) {
                applicationId = applicationIdByContactAndAccountId.get(creditReportDetail.Contact__c);
            } else if(creditReportDetail.Application__c != null) {
                applicationId = creditReportDetail.Application__c;
            } else {
                applicationId = applicationIdByContactAndAccountId.get(creditReportDetail.Account__c);
            }

            if(creditReportDetailByApplicationId.containsKey(applicationId)){
                creditReportDetailByApplicationId.get(applicationId).put(creditReportDetail.Type__c, creditReportDetail);
            } else {
                creditReportDetailByApplicationId.put(
                    applicationId, new Map<String, Credit_Report_Detail__c> { creditReportDetail.Type__c => creditReportDetail}
                );
            }
        }

        List<CAN_Ocrolus_Report__c> ocrolusReportList = ocrolusReportDBInstance.getCANOcrolusReportByApplicationIDs(applicationMap.keySet());

        Map<Id, CAN_Ocrolus_Report__c> ocrolusReportByApplicationId = new Map<Id, CAN_Ocrolus_Report__c>();

        for(CAN_Ocrolus_Report__c ocrolusReportDetail : ocrolusReportList) {
            ocrolusReportByApplicationId.put(ocrolusReportDetail.Application__c, ocrolusReportDetail);
        }

        List<STIPS_Checklist__c> stipsList = stipsDBInstance.getSTIPSCheckListByApplicationIds(applicationMap.keySet());

        Map<Id, STIPS_Checklist__c> stipsByApplicationId = new Map<Id, STIPS_Checklist__c>();

        for(STIPS_Checklist__c stipsDetail : stipsList) {
            stipsByApplicationId.put(stipsDetail.Application__c, stipsDetail);
        }

        Map<String, UnderWriter_Task__c> underWriterTaskByApplicationIdTaskName = new Map<String, UnderWriter_Task__c>();
        for (UnderWriter_Task__c uwTask : underWriterTaskDBInstance.getUnderWriterTaskByApplicationIdsAndTaskNames(
            applicationMap.keySet(), taskNames)
        ) {
            underWriterTaskByApplicationIdTaskName.put(uwTask.Application__c + uwTask.Task_Name__c, uwTask);
        }

        for(genesis__Applications__c application : applicationList) {
            STIPS_Checklist__c stipsDetail = stipsByApplicationId.get(application.Id);
            setSTIPSAndUWTasksVerifications(application, accountMap.get(application.genesis__Account__c),
                creditReportDetailByApplicationId.get(application.Id), ocrolusReportByApplicationId, stipsDetail,
                underWriterTaskByApplicationIdTaskName, allBeneficialPartiesByApplicationId.get(application.Id)
            );
            stipsDBInstance.addUpdate(stipsDetail);
        }

        stipsDBInstance.executeUpdates();
        underWriterTaskDBInstance.addUpdates(underWriterTaskByApplicationIdTaskName.values()).executeUpdates();
        applicationDBInstance.executeUpdates();
    }

    public static void setSTIPSAndUWTasksVerifications(
        genesis__Applications__c application, Account accountRecord, Map<String, Credit_Report_Detail__c> creditReportMap,
        Map<Id, CAN_Ocrolus_Report__c> ocrolusReportByApplicationId, STIPS_Checklist__c stipsDetail,
        Map<String, UnderWriter_Task__c> underWriterTaskByApplicationIdTaskName, String allBeneficialParties
    ) {
        Credit_Report_Detail__c businessCreditReport = creditReportMap.get(GeneralConstants.CREDIT_REPORT_TYPE_EXPERIAN_BUSINESS);
        Credit_Report_Detail__c lexisNexisCreditReport = creditReportMap.get(GeneralConstants.CREDIT_REPORT_TYPE_LEXIS_NEXIS);
        Credit_Report_Detail__c consumerCreditReport = creditReportMap.get(GeneralConstants.CREDIT_REPORT_TYPE_EXPERIAN_CONSUMER);
        CAN_Ocrolus_Report__c ocrolusReport = ocrolusReportByApplicationId.get(application.Id);

        STIPSChecklists.setDefaultSTIPSChecklistValues(stipsDetail);

        if(lexisNexisCreditReport != null) {
            stipsDetail.Proof_of_Ownership__c = (
                !lexisNexisCreditReport.Is_Proof_Of_Ownership_Verified__c || !lexisNexisCreditReport.Is_Guarantor_Identity_Verified__c
            );
            stipsDetail.Identification__c = !lexisNexisCreditReport.Is_Guarantor_Identity_Verified__c;
            stipsDetail.Guarantors_Whose_Identity_Not_Verified__c = lexisNexisCreditReport.Guarantors_Whose_Identity_Not_Verified__c;
        } else {
            stipsDetail.Proof_of_Ownership__c = true;
            stipsDetail.Identification__c = true;
            stipsDetail.Guarantors_Whose_Identity_Not_Verified__c = allBeneficialParties;
        }

        if(application.Business_Type__c != GeneralConstants.LEGAL_TYPE_SOLE_PROP && accountRecord.Business_Tax_ID__c == null) {
            stipsDetail.Federal_Tax_ID__c = true;
        }

        if(businessCreditReport != null && businessCreditReport.Financial_Services_Charge_off__c) {
            stipsDetail.Borrower_Interview__c = true;
        }

        if(ocrolusReport != null) {
            if(ocrolusReport.Primary_Bank_Account_Number__c != null) {
                stipsDetail.Voided_Check__c = true;
                stipsDetail.Last_Four_Bank_Account_Number__c = ocrolusReport.Primary_Bank_Account_Number__c.right(4);
            }
            if(ocrolusReport.Number_Of_Competitors__c > 0 && ocrolusReport.Competitor_Names__c != null) {
                stipsDetail.Competitors__c = true;
                stipsDetail.Competitor_Names__c = ocrolusReport.Competitor_Names__c;
            }
            if(ocrolusReport.Is_Potential_Fraud__c == true) {
                stipsDetail.Bank_Verification_Call__c = true;
            }

            /** Month to Date Bank Statement stipulation requirements
            For New Contract Type: If Max Funding Amount > $50,000 OR Number of Competitors > 0 then "Month to Date Bank Statement" else Null

            For Renewal Contract Type: If Max Funding Amount > $100,000 OR Number of Competitors > 0 then "Month to Date Bank Statement" else Null
            We need to check if a OCrolus Report is available or not.
            */
            if ((application.Type__c == 'New'
                    && (application.Maximum_Funding_Amount__c > 50000 || ocrolusReport.Number_Of_Competitors__c > 0)
                )
                || (application.Type__c == 'Renewal'
                    && (application.Maximum_Funding_Amount__c > 100000 || ocrolusReport.Number_Of_Competitors__c > 0)
                )
            ) {
                stipsDetail.Month_to_Date_Bank_Statement__c = true;
            }
        }

        if(application.Maximum_Funding_Amount__c > 150000 && ocrolusReport.Number_Of_Bank_Statements__c < 12) {
            stipsDetail.Additional_Banks__c = true;
        }

        if(consumerCreditReport != null && consumerCreditReport.Credit_Statement__c != null
            && (consumerCreditReport.Credit_Statement__c.contains(BusinessRules.FRAUD_ALERT_FRAUD_STATEMENT)
                || consumerCreditReport.Credit_Statement__c.contains(BusinessRules.FRAUD_ALERT_SECURITY_STATEMENT))
        ) {
            stipsDetail.experian_fraud_check__c = true;
        }

        if(application.Maximum_Funding_Amount__c >= 175000) {
            stipsDetail.Verification_Call__c = true;
        }

        BusinessRules.setUnderWriterTasksVerification(
            underWriterTaskByApplicationIdTaskName, ocrolusReport, consumerCreditReport, application
        );

        applicationDBInstance.addUpdate(
            BusinessRules.runAutoAcceptExceptionEligible(application, accountRecord, businessCreditReport, consumerCreditReport)
        );
    }

    public static void runGeneralDeclineRules(List<genesis__Applications__c> listOfApplications) {
        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>(listOfApplications);

        Map<Id, loan__Loan_Account__c> clContractByAccountId = new Map<Id, loan__Loan_Account__c>();
        Set<Id> contractIds = new Set<Id>();
        Map<Id, Id> accountIdToApplicationId = new Map<Id, Id>();
        Set<Id> fraudFlagApplicationIds = new Set<Id>();
        Map<Id, genesis__Applications__c> recentDeclinedApplicationByAccountId = new Map<Id, genesis__Applications__c>();

        for (genesis__Applications__c application : listOfApplications) {
            if(application.genesis__Status__c != Applications.STATUS_DECLINED) {
                contractIds.add(application.Renewal_Concurrent_LoanAccount__c);
                accountIdToApplicationId.put(application.genesis__Account__c, application.Id);
            }
        }

        if(accountIdToApplicationId.isEmpty()) {
            return;
        }

        for (loan__Loan_Account__c clContract : clContractDBInstance.getLoanAccountsByIds(contractIds)) {
            clContractByAccountId.put(clContract.loan__Account__c, clContract);
        }
        Map<Id, Account> accountMap = new Map<Id, Account> (accountDBInstance.getAccountByIds(accountIdToApplicationId.keySet()));

        Set<Id> partyBorrowerAndGuarantorIds = new Set<Id>();
        partyBorrowerAndGuarantorIds.add(OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_GUARANTOR));
        partyBorrowerAndGuarantorIds.add(OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BORROWER));

        for(clcommon__Party__c party : partyDBInstance.getPartiesByApplicationIdsAndPartyTypeIds(applicationMap.keySet(), partyBorrowerAndGuarantorIds)) {
            if ((party.clcommon__Type__c == OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BORROWER)
                    && party.clcommon__Account__r.Confirmed_Fraud_Flag__c)
                || (party.clcommon__Type__c == OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_GUARANTOR)
                    && party.clcommon__Contact__r.Confirmed_Fraud_Flag__c)
            ) {
                fraudFlagApplicationIds.add(party.genesis__Application__c);
            }
        }

        for(genesis__Applications__c application :applicationDBInstance.getDeclineApplicationByDeclineUntilAndBorrowerIds(accountIdToApplicationId.keySet())) {
            recentDeclinedApplicationByAccountId.put(application.genesis__Account__c, application);
        }

        for (genesis__Applications__c application : listOfApplications) {
            Id accountId = application.genesis__Account__c;
            if(recentDeclinedApplicationByAccountId.containsKey(accountId)) {
                Applications.cloneDeclineReasons(application, recentDeclinedApplicationByAccountId.get(accountId));
            } else {
                loan__Loan_Account__c clContract = clContractByAccountId.get(accountId);
                Account accountDetail = accountMap.get(accountId);
                application.Confirmed_Fraud_Flag__c = fraudFlagApplicationIds.contains(application.Id);
                BusinessRules.generalDeclineRules(application, clContract, accountDetail);
            }
        }
    }

    public static void runExperianConsumerDeclineRules(List<genesis__Applications__c> listOfApplications) {
        Map<Id, genesis__Applications__c> applicationByContactId = new Map<Id, genesis__Applications__c>();
        for (genesis__Applications__c application : listOfApplications) {
            applicationByContactId.put(application.Primary_Guarantor__c, application);
        }

        Map<Id, Credit_Report_Detail__c> creditReportDetailByContactId = new Map<Id, Credit_Report_Detail__c> ();
        for (Credit_Report_Detail__c report : creditReportDetailDBInstance.getConsumerCreditReportByContactIds(
            applicationByContactId.keySet())
        ) {
            creditReportDetailByContactId.put(report.Contact__c, report);
        }

        for (genesis__Applications__c application : listOfApplications) {
            Credit_Report_Detail__c creditReport = creditReportDetailByContactId.get(application.Primary_Guarantor__c);
            BusinessRules.experianConsumerDeclineRules(application, creditReport);
        }
    }

    public static void runExperianBusinessDeclineRules(List<genesis__Applications__c> listOfApplications) {
        Map<Id, Id> applicationIdByAccountId = new Map<Id, Id>();
        for(genesis__Applications__c application : listOfApplications) {
            applicationIdByAccountId.put(application.genesis__Account__c, application.Id);
        }

        Map<Id, Credit_Report_Detail__c> creditReportDetailByAccountId = new Map<Id, Credit_Report_Detail__c> ();
        for (Credit_Report_Detail__c report : creditReportDetailDBInstance.getBusinessCreditReportByAccountIds(
            applicationIdByAccountId.keySet())
        ) {
            creditReportDetailByAccountId.put(report.Account__c, report);
        }

        for (genesis__Applications__c application : listOfApplications) {
            Credit_Report_Detail__c creditReport = creditReportDetailByAccountId.get(application.genesis__Account__c);
            BusinessRules.experianBusinessDeclineRules(application, creditReport);
        }
    }

    public static List<genesis__Applications__c> runIndustryCheckDeclineRulesAndUWTask(List<genesis__Applications__c> listOfApplications) {
        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>(listOfApplications);
        List<genesis__Applications__c> applicationAfterUpdate = new List<genesis__Applications__c>();

        for (genesis__Applications__c application : listOfApplications) {
            genesis__Applications__c applicationAfterDeclineCheck = BusinessRules.industryDeclineRulesAndUWTask(application);
            applicationAfterUpdate.add(applicationAfterDeclineCheck);
        }

        return applicationAfterUpdate;
    }

    public static void runCanScoringDeclineRules(List<genesis__Applications__c> listOfApplications) {
        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>(listOfApplications);

        Map<Id, Credit_Report_Detail__c> creditReportByApplicationId = new Map<Id, Credit_Report_Detail__c>();
        for (Credit_Report_Detail__c report :  creditReportDetailDBInstance.getCanScoringReportByApplicationIds(applicationMap.keySet())
        ) {
            creditReportByApplicationId.put(report.Application__c, report);
        }

        for (genesis__Applications__c application : listOfApplications) {
            Credit_Report_Detail__c creditReport = creditReportByApplicationId.get(application.Id);
            BusinessRules.canScoringDeclineRules(application, creditReport);
        }
    }

    public static void runOcrolusDeclineRules(
        Map<Id, genesis__Applications__c> applicationMap, List<CAN_Ocrolus_Report__c> ocrolusReportList
    ) {
        for (CAN_Ocrolus_Report__c ocrolusReport :ocrolusReportList) {
            genesis__Applications__c application = applicationMap.get(ocrolusReport.Application__c);
            BusinessRules.ocrolusDeclineRules(application, ocrolusReport);
        }
    }

    public static void declineDuplicateApplicationForBorrower(Map<Id, genesis__Applications__c> borrowerIdToApplication) {
        for(loan__Loan_Account__c loanAccount : clContractDBInstance.getActiveLoanAccountsByBorrowerIds(borrowerIdToApplication.keySet())) {
            genesis__Applications__c newApplication = borrowerIdToApplication.get(loanAccount.loan__Account__c);
            Applications.setDenialReasons(newApplication, BusinessRules.DENIAL_REASON_ACTIVE_APPLICATION_OR_CONTRACT);
        }
    }

    public static void runDeclineRulesForExclusivityPeriod(
        Map<Id, genesis__Applications__c> borrowerIdToApplication, Set<Id> brokerContactIds
    ) {
        Map<Id, Contact> brokerContactMap = new Map<Id, Contact>(contactDBInstance.getContactsByIds(brokerContactIds));
        for(Account accountRecord : accountDBInstance.getBrokerDetailsByBorrowerAccountIds(borrowerIdToApplication.keySet())) {
            genesis__Applications__c application = borrowerIdToApplication.get(accountRecord.Id);
            Contact brokerContact = brokerContactMap.get(application.Broker_Contact__c);
            if(accountRecord.Is_Exclusivity__c ) {
                if((brokerContact != null && accountRecord.Broker_Account__c != brokerContact.AccountId)
                    || (brokerContact == null && accountRecord.Broker_Account__c != null)
                ) {
                    Applications.setDenialReasons(application, BusinessRules.DENIAL_REASON_ACTIVE_APPLICATION_OR_CONTRACT);
                }
            }
        }
    }

    public static void declineDuplicateEISApplicationForBorrower(
        List<genesis__Applications__c> listOfApplications, Map<Id, Account> accountMap
    ) {
        for(genesis__Applications__c application : listOfApplications) {
            Account accountDetail = accountMap.get(application.genesis__Account__c);
            if(accountDetail.Legacy_Active_Contract__c) {
                Applications.setDenialReasons(application, BusinessRules.DENIAL_REASON_ACTIVE_APPLICATION_OR_CONTRACT);
            }
        }
    }

    public static void runAutoDeclineForSameBorrowerRules(List<genesis__Applications__c> listOfApplications) {
        Map<Id, genesis__Applications__c> applicationByAccountId = new Map<Id, genesis__Applications__c>();

        for (genesis__Applications__c application : listOfApplications) {
            applicationByAccountId.put(application.genesis__Account__c, application);
        }

        for(genesis__Applications__c appToAutoDeclineCheck : applicationDBInstance.getInProgressApplicationsByAccountIds(applicationByAccountId.keySet())) {
            genesis__Applications__c currentApplication = applicationByAccountId.get(appToAutoDeclineCheck.genesis__Account__c);
            if (appToAutoDeclineCheck.Id != currentApplication.Id) {
                if (!applications.APP_STATUSES_FOR_AUTO_DECLINE_CHECK.contains(appToAutoDeclineCheck.genesis__Status__c) &&
                    applications.APP_STATUSES_FOR_AUTO_DECLINE_CHECK.contains(currentApplication.genesis__Status__c) )
                {
                    Applications.setDenialReasons(appToAutoDeclineCheck, BusinessRules.DENIAL_REASON_ACTIVE_APPLICATION_OR_CONTRACT);
                    applicationDBInstance.addUpdate(appToAutoDeclineCheck);
                } else if (applications.APP_STATUSES_FOR_AUTO_DECLINE_CHECK.contains(appToAutoDeclineCheck.genesis__Status__c)){
                    Applications.setDenialReasons(currentApplication, BusinessRules.DENIAL_REASON_ACTIVE_APPLICATION_OR_CONTRACT);
                }
            }
        }

        applicationDBInstance.executeUpdates();
    }

    public static void runDataMerchDeclineRules(List<genesis__Applications__c> listOfApplications) {
        Map<Id, Id> applicationIdByAccountId = new Map<Id, Id>();
        for(genesis__Applications__c application : listOfApplications) {
            applicationIdByAccountId.put(application.genesis__Account__c, application.Id);
        }

        Map<Id, Map<Id, Data_Merch_Note__c>> dataMerchNotesByAccountId = new Map<Id, Map<Id, Data_Merch_Note__c>> ();
        for (Data_Merch_Note__c note : dataMerchNoteDBInstance.getDataMerchNotesByAccountIds(
            applicationIdByAccountId.keySet())
        ) {
            dataMerchNotesByAccountId.put(note.Account__c, new Map<Id, Data_Merch_Note__c> {note.Id => note});
        }

        for (genesis__Applications__c application : listOfApplications) {
            if (dataMerchNotesByAccountId.containsKey(application.genesis__Account__c)) {
                Map<Id, Data_Merch_Note__c> reportNotesMap = dataMerchNotesByAccountId.get(application.genesis__Account__c);
                BusinessRules.dataMerchDeclineRules(application, reportNotesMap.values());
            }
        }
    }
}