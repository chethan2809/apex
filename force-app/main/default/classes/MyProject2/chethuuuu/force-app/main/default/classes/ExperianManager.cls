public class ExperianManager {

    @TestVisible
    private static ApplicationDB applicationDBInstance = new ApplicationDB();
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    @TestVisible
    private static PartyDB partyDBInstance = new PartyDB();
    @TestVisible
    private static ContactDB contactDBInstance = new ContactDB();
    @TestVisible
    private static AccountDB accountDBInstance = new AccountDB();
    @TestVisible
    private static CreditReportDetailDB creditReportDetailDBInstance = new CreditReportDetailDB();
    @TestVisible
    private static EmailTemplateDB emailTemplateDBInstance = new EmailTemplateDB();
    @TestVisible
    private static EmailDB emailDBInstance = new EmailDB();
    @TestVisible
    private static ContentVersionDB contentVersionDBInstance = new ContentVersionDB();
    @TestVisible
    private static AttachmentDB attachmentDBInstance = new AttachmentDB();
    @TestVisible
    private static DocumentDB documentDBInstance = new DocumentDB();

    public static boolean runForceCreditReport = false;

    public static void requestBusinessCreditCheck(List<genesis__Applications__c> listOfApplications) {

        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>(listOfApplications);
        Set<Id> accountIds = new Set<Id>();
        for(genesis__Applications__c application : listOfApplications) {
            accountIds.add(application.genesis__Account__c);
        }

        Map<Id, Account> accountMap = new Map<Id, Account> (accountDBInstance.getAccountByIds(accountIds));
        List<Credit_Report_Detail__c> reportList = new List<Credit_Report_Detail__c>();
        Map<Id, Map<String, String>> responseMapByCreditReportDetail = new Map<Id, Map<String, String>>();
        Map<String, String> businessResponseMap = new Map<String, String>();
        Map<Id, Id> accountIdToApplicationId = new Map<Id, Id>();

        Map<Id, Credit_Report_Detail__c> creditReportByAccountId = new Map<Id, Credit_Report_Detail__c>();
        for(Credit_Report_Detail__c existingReport : creditReportDetailDBInstance.getBusinessCreditReportByAccountIds(accountIds)) {
            creditReportByAccountId.put(existingReport.Account__c, existingReport);
        }

        Map<Id, String> accountIdToCreditProfilePdf = new Map<Id, String>();
        String businessAccessToken;
        List<genesis__Applications__c> listOfApplicationShell = new List<genesis__Applications__c>();

        for (genesis__Applications__c application : listOfApplications) {
            Account accountDetail = accountMap.get(application.genesis__Account__c);
            ExperianCalloutParser parser = new ExperianCalloutParser(null, accountDetail);
            accountIdToApplicationId.put(application.genesis__Account__c, application.Id);
            genesis__Applications__c applicationShell = new genesis__Applications__c(Id = application.Id, Is_Manual_Score_Run__c = application.Is_Manual_Score_Run__c);
            if(accountDetail.Last_Business_Credit_Pull__c == null
                || accountDetail.Last_Business_Credit_Pull__c.daysBetween(GeneralHelper.currentSystemDate) > 30
            ) {
                Map<String, Object> accountBusinessSearch;
                Map<String, Object> accountCreditPremierProfile;
                HttpResponse accountCreditAggregatesFullResponse;
                HttpResponse accountCreditPremierProfileFullResponse;
                Map<String, Object> accountCreditAggregates;
                Account accountShell = new Account(Id = accountDetail.Id);

                try {
                    if(businessAccessToken == null) {
                        API_Detail__mdt apiDetails = Experians.experianBusinessAPIDetails;
                        businessAccessToken = 'Bearer '+ ExperianCallOut.getAccessToken(apiDetails);
                    }
                    accountBusinessSearch = ExperianCallOut.requestExperianBusinessSearch(
                        accountDetail, businessAccessToken
                    );

                    if(accountBusinessSearch.get('bin') !=  null) {
                        accountCreditPremierProfileFullResponse = ExperianCallOut.requestExperianBusinessPremierProfileCreditCheck(
                        accountDetail, accountBusinessSearch, businessAccessToken
                        );
                        accountCreditPremierProfile = parser.businessPremierProfilesResponseBody(accountCreditPremierProfileFullResponse);

                        accountCreditAggregatesFullResponse = ExperianCallOut.requestExperianBusinessAggregates(
                            accountDetail, accountBusinessSearch, businessAccessToken
                        );
                        accountCreditAggregates = parser.businessAggregatesResponseBody(accountCreditAggregatesFullResponse);

                        accountIdToCreditProfilePdf.put(
                            accountDetail.Id, ExperianCallOut.requestExperianBusinessPremierProfilePdfCreditCheck(
                                accountDetail, accountBusinessSearch, businessAccessToken
                            )
                        );

                        Credit_Report_Detail__c creditReport = Experians.createBusinessCreditReportDetail(
                            accountBusinessSearch, accountCreditPremierProfile, accountCreditAggregates, accountDetail,
                            creditReportByAccountId
                        );
                        reportList.add(creditReport);
                        String businessAggregateReportResponse = accountCreditAggregatesFullResponse.getBody();
                        String businessPremierProfileReportResponse = accountCreditPremierProfileFullResponse.getBody();

                        businessResponseMap.put('BusinessAggregateResponse', businessAggregateReportResponse);
                        businessResponseMap.put('BusinessPremierProfileResponse', businessPremierProfileReportResponse);
                        responseMapByCreditReportDetail.put(creditReport.Account__c, businessResponseMap);
                        creditReportDetailDBInstance.addUpserts(reportList);

                    } else if(accountBusinessSearch.get('responseMessage') != null
                        && !String.valueOf(accountBusinessSearch.get('responseMessage')).contains('Your search did not match any records')
                    ) {
                        throw new ExperianManagerException(String.valueOf(accountBusinessSearch.get('responseMessage')));
                    } else {
                        Credit_Report_Detail__c creditReport = Experians.setExperianBusinessDefaultReport(
                            accountDetail.Id, creditReportByAccountId
                        );
                        reportList.add(creditReport);
                        creditReportDetailDBInstance.addUpserts(reportList);
                    }

                    applicationShell.genesis__Status__c = Applications.STATUS_CAN_SCORING;
                    applicationShell.genesis__Account__c = application.genesis__Account__c;
                    applicationShell.Type__c = application.Type__c;
                    applicationShell.Decline_Reasons__c = application.Decline_Reasons__c;
                    listOfApplicationShell.add(applicationShell);
                    accountShell.Last_Business_Credit_Pull__c = GeneralHelper.currentSystemDate;
                    accountDBInstance.addUpdate(accountShell);

                } catch (Exception e) {
                    applicationShell.genesis__Status__c = Applications.STATUS_BUSINESS_CREDIT_CHECK_FAILED;
                    Error_Log__c errorLog = ErrorLogs.createErrorLog('Experian Business Credit Check', e, applicationShell.Id, false);
                    applicationDBInstance.addUpdate(applicationShell);
                    errorLogDBInstance.addInsert(errorLog);
                }
            } else {
                applicationShell.genesis__Status__c = Applications.STATUS_CAN_SCORING;
                applicationShell.genesis__Account__c = application.genesis__Account__c;
                applicationShell.Type__c = application.Type__c;
                applicationShell.Decline_Reasons__c = application.Decline_Reasons__c;
                listOfApplicationShell.add(applicationShell);
            }
        }
        errorLogDBInstance.executeInserts();

        creditReportDetailDBInstance.executeUpserts();
        BusinessRuleManager.runExperianBusinessDeclineRules(listOfApplicationShell);
        applicationDBInstance.addUpdates(listOfApplicationShell);
        applicationDBInstance.executeUpdates();
        accountDBInstance.executeUpdates();

        if(!accountIdToCreditProfilePdf.isEmpty()) {
            createExperianBusinessCreditReportDocument(accountIdToCreditProfilePdf);
        }

        if(!Test.isRunningTest()) {
            new QueueableJobHandler().executeSFTPScoringRawDataQueueableJob(reportList, responseMapByCreditReportDetail, accountIdToApplicationId);
        }
    }

    public static void requestConsumerCreditCheck(List<genesis__Applications__c> listOfApplications) {
        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>(
            applicationDBInstance.getApplicationsByIds(new Map<Id, genesis__Applications__c>(listOfApplications).keySet())
        );
        Set<Id> partyBrokerAndGuarantorIds = new Set<Id>();
        partyBrokerAndGuarantorIds.add(OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_GUARANTOR));
        partyBrokerAndGuarantorIds.add(OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BROKER));

        List<clcommon__Party__c> partyList = partyDBInstance.getPartiesByApplicationIdsAndPartyTypeIds(
            applicationMap.keySet(), partyBrokerAndGuarantorIds
        );
        Map<Id, Set<Id>> applicationIdToContactIds = new Map<Id, Set<Id>>();
        Map<Id, Id> contactIdToApplicationId = new Map<Id, Id>();
        Map<Id, clcommon__Party__c> partyByContactId = new Map<Id, clcommon__Party__c>();
        Map<Id, clcommon__Party__c> brokerPartyByApplicationId = new Map<Id, clcommon__Party__c>();
        Set<Id> accountIds = new Set<Id>();

        for(genesis__Applications__c application : applicationMap.values()) {
            accountIds.add(application.genesis__Account__c);
        }

        for(clcommon__Party__c party : partyList) {
            if(party.clcommon__Type__r.Name == GeneralConstants.PARTY_TYPE_GUARANTOR) {
                if(applicationIdToContactIds.containsKey(party.genesis__Application__c)) {
                    applicationIdToContactIds.get(party.genesis__Application__c).add(party.clcommon__Contact__c);
                }else {
                    applicationIdToContactIds.put(party.genesis__Application__c, new Set<Id> { party.clcommon__Contact__c });
                }
                contactIdToApplicationId.put(party.clcommon__Contact__c, party.genesis__Application__c);
                partyByContactId.put(party.clcommon__Contact__c, party);
            }
            else if(party.clcommon__Type__r.Name == GeneralConstants.PARTY_TYPE_BROKER) {
                brokerPartyByApplicationId.put(party.genesis__Application__c, party);
            }
        }

        Map<Id, String> accountIdToCreditProfileTTY = new Map<Id, String>();
        Map<Id, Credit_Report_Detail__c> creditReportByContactId = new Map<Id, Credit_Report_Detail__c>();

        for(Credit_Report_Detail__c existingReport :
            creditReportDetailDBInstance.getConsumerCreditReportByContactIds(contactIdToApplicationId.keySet())
        ) {
            creditReportByContactId.put(existingReport.Contact__c, existingReport);
        }

        Map<Id, Account> accountMap = new Map<Id, Account> (accountDBInstance.getAccountByIds(accountIds));
        Map<Id, Contact> contactMap = new Map<Id, Contact> (contactDBInstance.getContactsByIds(contactIdToApplicationId.keySet()));
        Map<Id, Object> scoringIssueEmailDetailsByContactId = new Map<Id, Object>();
        Set<Id> contactIdsForUpdate = new Set<Id>();
        Map<Id, String> applicationIdByState = new Map<Id, String>();
        String consumerAccessToken;
        List<genesis__Applications__c> listOfApplicationShell = new List<genesis__Applications__c>();

        List<Credit_Report_Detail__c> reportList = new List<Credit_Report_Detail__c>();
        Map<Id, Map<String, String>> responseMapByCreditReportDetail = new Map<Id, Map<String, String>>();
        Map<String, String> businessResponseMap = new Map<String, String>();
        Map<Id, String> contactIdToCreditStatement = new Map<Id, String>();
        for(Id contactId : contactIdToApplicationId.keySet()) {
            Contact contactDetail = contactMap.get(contactId);
            Id applicationId = contactIdToApplicationId.get(contactId);
            genesis__Applications__c applicationDetail = applicationMap.get(applicationId);
            clcommon__Party__c brokerParty = brokerPartyByApplicationId.get(applicationId);

            if(runForceCreditReport == true || contactDetail.Last_Consumer_Credit_Pull__c == null
                || contactDetail.Last_Consumer_Credit_Pull__c.date().daysBetween(GeneralHelper.currentSystemDate) > 30
            ) {
                Map<String, Object> contactCreditProfile;
                HttpResponse contactCreditProfileFullResponse;
                Contact contactShell = new Contact(Id = contactDetail.Id);
                Account accountDetail = accountMap.get(applicationDetail.genesis__Account__c);
                try {
                    if(consumerAccessToken == null) {
                        API_Detail__mdt apiDetails = Experians.experianConsumerAPIDetails;
                        consumerAccessToken = 'Bearer '+ ExperianCallOut.getAccessToken(apiDetails);
                    }

                    contactCreditProfileFullResponse = ExperianCallOut.requestExperianConsumerCreditCheck(contactDetail, consumerAccessToken);
                    ExperianCalloutParser parser = new ExperianCalloutParser(contactDetail, null);
                    contactCreditProfile = parser.responseParse(contactCreditProfileFullResponse);

                    Credit_Report_Detail__c creditReport = Experians.createConsumerCreditReportDetail(
                        contactCreditProfile, contactDetail, creditReportByContactId
                    );
                    if((creditReport != null && creditReport.Credit_Statement__c != null
                        && (creditReport.Credit_Statement__c.contains('FILE FROZEN') || creditReport.Credit_Statement__c.contains('FILE LOCKED')))
                        || (contactCreditProfile != null && contactCreditProfile.containsKey('message'))
                    ) {
                        if(contactCreditProfile != null && contactCreditProfile.containsKey('message')){
                            contactShell.Credit_Report_Message__c = String.valueOf(contactCreditProfile.get('message'));
                            contactIdToCreditStatement.put(contactShell.Id, String.valueOf(contactCreditProfile.get('message')));
                        }
                        else{
                            contactShell.Credit_Report_Message__c = creditReport != null ? creditReport.Credit_Statement__c : null ;
                            contactIdToCreditStatement.put(contactShell.Id, creditReport.Credit_Statement__c);
                        }
                        contactShell.Last_Date_of_Inquiry__c = GeneralHelper.currentSystemDateTime;
                        if(applicationDetail.Credit_Pull_Notification_Date__c == null
                            && !(applicationDetail.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL
                                && applicationDetail.Auto_Renewed__c == true)
                        ) {
                            Map<String, Map<String, String>> scoringIssueEmailDetails = Experians.getCreditFreezeContactDetails(
                                contactDetail, accountDetail, String.valueOf(GeneralHelper.currentSystemDate.addDays(30)),
                                brokerParty, contactShell.Credit_Report_Message__c, applicationDetail
                            );
                            scoringIssueEmailDetailsByContactId.put(contactDetail.Id, scoringIssueEmailDetails);
                        }
                        applicationIdByState.put(applicationId, Applications.STATUS_GUARANTOR_CREDIT_CHECK);
                        contactDBInstance.addUpdate(contactShell);

                    } else {
                        contactShell.Credit_Report_Message__c = null;
                        contactShell.Last_Consumer_Credit_Pull__c = GeneralHelper.currentSystemDateTime;
                        contactShell.FICO_MKT__c = creditReport.Personal_FICO_Score__c;
                        contactDBInstance.addUpdate(contactShell);
                        reportList.add(creditReport);
                        String consumerReportResponse = contactCreditProfileFullResponse.getBody();
                        businessResponseMap.put('consumerReport', consumerReportResponse);
                        responseMapByCreditReportDetail.put(creditReport.Contact__c, businessResponseMap);

                        creditReportByContactId.put(contactId, creditReport);
                        creditReportDetailDBInstance.addUpsert(creditReport);

                        if(contactCreditProfile.containsKey('ttyResponse')) {
                            String ttyResponse = contactDetail.Name + '<<RES>>' + String.valueOf(contactCreditProfile.get('ttyResponse'));
                            accountIdToCreditProfileTTY.put(contactDetail.AccountId, ttyResponse);
                        }
                    }
                } catch (Exception e) {
                    creditReportByContactId.remove(contactId);
                    applicationIdByState.put(applicationId, Applications.STATUS_GUARANTOR_CREDIT_CHECK_FAILED);
                    Error_Log__c errorLog = ErrorLogs.createErrorLog('Experian Consumer Credit Check', e, applicationId, false);
                    errorLogDBInstance.addInsert(errorLog);
                }
            }
        }

        for(Id applicationId : applicationIdToContactIds.keySet()) {
            genesis__Applications__c applicationShell = new genesis__Applications__c(Id = applicationId);
            genesis__Applications__c applicationDetail = applicationMap.get(applicationId);

            Credit_Report_Detail__c creditReport = Experians.findHighestScoreReport(
                applicationIdToContactIds.get(applicationId), creditReportByContactId, partyByContactId
            );

            if (applicationIdByState.containsKey(applicationId)) {
                if(applicationIdByState.get(applicationId) == Applications.STATUS_GUARANTOR_CREDIT_CHECK) {
                    Experians.prepareCreditReportMessage(
                        applicationIdToContactIds.get(applicationId), contactIdToCreditStatement, partyByContactId
                    );
                    if(applicationDetail.Credit_Pull_Notification_Date__c == null) {
                        applicationShell.Credit_Pull_Notification_Date__c = GeneralHelper.getNBusinessDate(GeneralHelper.currentSystemDate, 5);
                    }
                }
                applicationShell.genesis__Status__c = applicationIdByState.get(applicationId);
                applicationDBInstance.addUpdate(applicationShell);
            } else {
                applicationShell.genesis__Status__c = Applications.STATUS_BUSINESS_CREDIT_CHECK;
                applicationShell.Type__c = applicationDetail.Type__c;
                applicationShell.Decline_Reasons__c = applicationDetail.Decline_Reasons__c;
                if(creditReport != null) {
                    applicationShell.Primary_Guarantor__c = creditReport.Contact__c;
                }
                listOfApplicationShell.add(applicationShell);
            }
        }
        partyDBInstance.addUpdates(partyByContactId.values());

        sendScoringIssueNotification(scoringIssueEmailDetailsByContactId);
        creditReportDetailDBInstance.executeUpserts();
        partyDBInstance.executeUpdates();
        BusinessRuleManager.runExperianConsumerDeclineRules(listOfApplicationShell);
        applicationDBInstance.addUpdates(listOfApplicationShell);
        applicationDBInstance.executeUpdates();
        contactDBInstance.executeUpdates();
        errorLogDBInstance.executeInserts();

        if(!accountIdToCreditProfileTTY.isEmpty()) {
            createExperianConsumerCreditReportDocument(accountIdToCreditProfileTTY);
        }

        if(!Test.isRunningTest()) {
            new QueueableJobHandler().executeSFTPScoringRawDataQueueableJob(reportList, responseMapByCreditReportDetail, contactIdToApplicationId);
        }
    }

    public static void sendScoringIssueNotification(Map<Id, Object> scoringIssueEmailDetailsByContactId) {
        if(scoringIssueEmailDetailsByContactId.isEmpty()) {
            return;
        }

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> templates = emailTemplateDBInstance.getTemplatesByName(new Set<String>{Experians.EXPERIAN_TEMPLATE_NAME});
        List<Document> documents = documentDBInstance.getDocumentByDeveloperName(Experians.CAN_CAPITAL_LOGO);

        for (Id contactId : scoringIssueEmailDetailsByContactId.keySet()) {
            Map<String, Map<String, String>> scoringIssueDetail = (Map<String, Map<String, String>>) scoringIssueEmailDetailsByContactId.get(contactId);
            Experians.getScoringEmailDetails(emailList, scoringIssueDetail, templates.get(0), documents);
        }

        try {
            emailDBInstance.sendBulkEmail(emailList);
        } catch(Exception e){
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'Credit Report Notification Failed', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                null, false
            );
            errorLogDBInstance.addInsert(errorLog);
        }

    }

    public static void sendCreditFreezeNotification (List<genesis__Applications__c> applicationList) {
        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>(applicationList);
        Set<Id> partyBrokerAndGuarantorIds = new Set<Id>();
        partyBrokerAndGuarantorIds.add(OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_GUARANTOR));
        List<clcommon__Party__c> partyList = partyDBInstance.getPartiesByApplicationIdsAndPartyTypeIds(
            applicationMap.keySet(), partyBrokerAndGuarantorIds
        );

        if(partyList.isEmpty()) {
            return;
        }

        Set<Id> accountIds = new Set<Id>();
        Map<Id, clcommon__Party__c> partyByContactId = new Map<Id, clcommon__Party__c>();

        for(genesis__Applications__c application : applicationList) {
            accountIds.add(application.genesis__Account__c);
        }

        for(clcommon__Party__c party : partyList) {
            partyByContactId.put(party.clcommon__Contact__c, party);
        }

        Map<Id, Contact> contactMap = new Map<Id, Contact> (contactDBInstance.getContactsByIds(partyByContactId.keySet()));
        Map<Id, Account> accountMap = new Map<Id, Account> (accountDBInstance.getAccountByIds(accountIds));
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<clcommon__Party__c> compuMailList = new List<clcommon__Party__c>();
        List<EmailTemplate> templates = emailTemplateDBInstance.getTemplatesByName(new Set<String>{Experians.EXPERIAN_TEMPLATE_NAME});
        List<Document> documents = documentDBInstance.getDocumentByDeveloperName(Experians.CAN_CAPITAL_LOGO);
        Map<Id, DateTime> applicationIdToLastEnquiryDateMap = new Map<Id, DateTime>();

        for(clcommon__Party__c party : partyList) {
            genesis__Applications__c application = applicationMap.get(party.genesis__Application__c);
            Contact contactDetail = contactMap.get(party.clcommon__Contact__c);
            Account accountDetail = accountMap.get(application.genesis__Account__c);

                Date statusUpdateDate = Date.newInstance(
                    application.Last_Status_Update_Date__c.year(), application.Last_Status_Update_Date__c.month(),
                    application.Last_Status_Update_Date__c.day()
                );

                if(statusUpdateDate.daysBetween(GeneralHelper.currentSystemDate) < 30 && application.genesis__Status__c != Applications.STATUS_DECLINED) {
                    application.Credit_Pull_Notification_Date__c = statusUpdateDate.addDays(30);
                    application.Credit_AAN_Sent__c = true;
                    application.Credit_AAN_Sent_Date__c = GeneralHelper.currentSystemDate;
                    application.AAN_Mode__c = Experians.AAN_MODE_COMPUMAIL;

                    if(applicationIdToLastEnquiryDateMap.containsKey(application.Id) && party.Last_Date_of_Inquiry__c != null && party.Last_Date_of_Inquiry__c > applicationIdToLastEnquiryDateMap.get(application.Id)) {
                        applicationIdToLastEnquiryDateMap.put(application.Id, party.Last_Date_of_Inquiry__c);
                    } else if (party.Last_Date_of_Inquiry__c != null) {
                        applicationIdToLastEnquiryDateMap.put(application.Id, party.Last_Date_of_Inquiry__c);
                    }

                    compuMailList.add(party);
                    contactDetail.Is_Generic__c = true;
                    contactDBInstance.addUpdate(contactDetail);
                    applicationDBInstance.addUpdate(application);

                } else {
                    application.genesis__Status__c = Applications.STATUS_DECLINED;
                    Applications.setDenialReasons(application, BusinessRules.DENIAL_REASON_OFFERS_EXPIRED);
                    application.Last_Status_Update_Date__c = GeneralHelper.currentSystemDate;
                    contactDetail.Is_Generic__c = false;
                    applicationDBInstance.addUpdate(application);
                    contactDBInstance.addUpdate(contactDetail);
                }
        }

        if(!emailList.isEmpty()) {
            emailDBInstance.sendBulkEmail(emailList);
        }

        System.debug('010compuMailList'+compuMailList);
        if(!compuMailList.isEmpty()){
            CompuMailManager.sendCompuMailForExperian(compuMailList, accountMap, applicationMap, applicationIdToLastEnquiryDateMap);
        }

        applicationDBInstance.executeUpdates();
        contactDBInstance.executeUpdates();
    }

    public static void createExperianBusinessCreditReportDocument(Map<Id, String> accountIdToCreditProfilePdf) {
        Map<Id, Attachment> accountIdToAttachment = new Map<Id, Attachment>();
        String documentType = GeneralConstants.DOCUMENT_TYPE_EXPERIAN_BUSINESS_REPORT;
        List<Attachment> attachmentList = new List<Attachment>();

        for(Id accountId : accountIdToCreditProfilePdf.keySet()) {
            Attachment reportAttachment = Attachments.createAttachment(
                documentType + '.pdf', EncodingUtil.base64Decode(accountIdToCreditProfilePdf.get(accountId)), accountId
            );
            attachmentList.add(reportAttachment);
        }

        attachmentDBInstance.addInserts(attachmentList).executeInserts();

        for(Attachment objAttachment: AttachmentList) {
            accountIdToAttachment.put(objAttachment.parentId, objAttachment);
        }

        if(!accountIdToAttachment.isEmpty()) {
            CategoryAttachAssnManager.createAccountDocumentCategoryAssociationByAttachmentId(accountIdToAttachment, documentType);
        }
    }

    public static void createExperianConsumerCreditReportDocument(Map<Id, String> accountIdToCreditProfileTTY) {
        Map<Id, Attachment> accountIdToAttachment = new Map<Id, Attachment>();
        String documentType = GeneralConstants.DOCUMENT_TYPE_EXPERIAN_CONSUMER_REPORT;
        List<Attachment> attachmentList = new List<Attachment>();

        for(Id accountId : accountIdToCreditProfileTTY.keySet()) {
            String currentSystemDateTime = GeneralHelper.currentSystemDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
            List<String> ttyResponse = accountIdToCreditProfileTTY.get(accountId).split('<<RES>>');
            String ttyResponseAfterFormat = ttyResponse[1].replaceAll('\r\n', '</br>');
            String fileName =  ttyResponse[0] + '_' + currentSystemDateTime + '.html';
            Attachment reportAttachment = Attachments.createAttachment(fileName, Blob.valueOf(ttyResponseAfterFormat), accountId);
            attachmentList.add(reportAttachment);
        }

        attachmentDBInstance.addInserts(attachmentList).executeInserts();

        for(Attachment objAttachment: AttachmentList) {
            accountIdToAttachment.put(objAttachment.parentId, objAttachment);
        }

        if(!accountIdToAttachment.isEmpty()) {
            CategoryAttachAssnManager.createAccountDocumentCategoryAssociationByAttachmentId(accountIdToAttachment, documentType);
        }
    }

    private class ExperianManagerException extends Exception {}
}