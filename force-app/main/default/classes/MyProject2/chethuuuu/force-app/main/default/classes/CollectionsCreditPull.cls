public class CollectionsCreditPull
{
    @TestVisible
    private static AccountDB accountDBInstance = new AccountDB();
    @TestVisible
    private static ContactDB contactDBInstance = new ContactDB();
    @TestVisible
    private static CreditReportDetailDB creditReportDetailDBInstance = new CreditReportDetailDB();
    @TestVisible
    private static AttachmentDB attachmentDBInstance = new AttachmentDB();
    @TestVisible
    private static CollectionCaseDB collectionCaseDBInstance = new CollectionCaseDB();
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    @AuraEnabled
    public static void consumerCreditPull(Id contactId, Id collectionCaseId) {
        try {
            String consumerAccessToken;
            if(consumerAccessToken == null) {
                API_Detail__mdt apiDetails = Experians.experianConsumerAPIDetails;
                consumerAccessToken = 'Bearer '+ ExperianCallOut.getAccessToken(apiDetails);
            }
            Map<String, Object> contactCreditProfile;
            HttpResponse contactCreditProfileFullResponse;
            Map<Id, String> accountIdToCreditProfileTTY = new Map<Id, String>();

            Map<Id, Credit_Report_Detail__c> creditReportByContactId = new Map<Id, Credit_Report_Detail__c>();
            Map<Id, Contact> contactMap = new Map<Id, Contact> (contactDBInstance.getContactsByIds(new Set<Id> {contactId}));

            Contact contactDetail = contactMap.get(contactId);
            contactCreditProfileFullResponse = ExperianCallOut.requestExperianConsumerCreditCheck(contactDetail, consumerAccessToken);
            ExperianCalloutParser parser = new ExperianCalloutParser(contactDetail, null);
            contactCreditProfile = parser.responseParse(contactCreditProfileFullResponse);

            Credit_Report_Detail__c creditReport = Experians.createConsumerCreditReportDetail(
                contactCreditProfile, contactDetail, creditReportByContactId
            );
            creditReport.Source_Type__c = GeneralConstants.CREDIT_REPORT_SOURCE_TYPE_COLLECTIONS;
            if(creditReport != null && creditReport.Credit_Statement__c != null
                && (creditReport.Credit_Statement__c.contains('FILE FROZEN') || creditReport.Credit_Statement__c.contains('FILE LOCKED'))
                || (contactCreditProfile != null && contactCreditProfile.containsKey('message'))){
                    throw new CollectionsCreditPullException('Consumer report is :' + String.valueOf(creditReport.Credit_Statement__c));
            } else {
                List<Collection_Case__c> collectionCaseList = collectionCaseDBInstance.getCollectionCasesByIds(new Set<Id> {collectionCaseId});
                if(!collectionCaseList.isEmpty()){
                    Collection_Case__c collectionCase = collectionCaseList[0];
                    collectionCase.Last_Consumer_Credit_Report_Pull_Date__c = GeneralHelper.currentSystemDateTime;
                    collectionCaseDBInstance.addUpdate(collectionCase);
                    collectionCaseDBInstance.executeUpdates();
                }
            }
            if(contactCreditProfile.containsKey('ttyResponse')) {
                String ttyResponse = contactDetail.Name + '<<RES>>' + String.valueOf(contactCreditProfile.get('ttyResponse'));
                accountIdToCreditProfileTTY.put(contactDetail.AccountId, ttyResponse);
            }

            if(!accountIdToCreditProfileTTY.isEmpty()) {
                createExperianConsumerCreditReportDocument(accountIdToCreditProfileTTY, collectionCaseId);
            }

            creditReportDetailDBInstance.addInsert(creditReport);
            creditReportDetailDBInstance.executeInserts();
        } catch (Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog('Experian Consumer Credit Check Failed', e, collectionCaseId, false);
            errorLogDBInstance.addInsert(errorLog);
            errorLogDBInstance.executeInserts();
        }
    }

    @AuraEnabled
    public static void businessCreditPull(Id borrowerAccountId, Id collectionCaseId) {
        try {
            Map<String, Object> accountBusinessSearch;
            Map<String, Object> accountCreditPremierProfile;
            HttpResponse accountCreditAggregatesFullResponse;
            HttpResponse accountCreditPremierProfileFullResponse;
            Map<String, Object> accountCreditAggregates;
            Map<Id, String> accountIdToCreditProfilePdf = new Map<Id, String>();
            Map<Id, Account> accountMap = new Map<Id, Account> (accountDBInstance.getAccountByIds(new Set<Id> {borrowerAccountId}));
            Account accountDetail = accountMap.get(borrowerAccountId);
            Map<Id, Credit_Report_Detail__c> creditReportByAccountId = new Map<Id, Credit_Report_Detail__c>();
            ExperianCalloutParser parser = new ExperianCalloutParser(null, accountDetail);
            String businessAccessToken;
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

                Credit_Report_Detail__c creditReport = Experians.createBusinessCreditReportDetail(
                    accountBusinessSearch, accountCreditPremierProfile, accountCreditAggregates, accountDetail,
                    creditReportByAccountId
                );
                creditReportDetailDBInstance.addInsert(creditReport);
                creditReport.Source_Type__c = GeneralConstants.CREDIT_REPORT_SOURCE_TYPE_COLLECTIONS;

                List<Collection_Case__c> collectionCaseList = collectionCaseDBInstance.getCollectionCasesByIds(new Set<Id> {collectionCaseId});
                if(!collectionCaseList.isEmpty()){
                    Collection_Case__c collectionCase = collectionCaseList[0];
                    collectionCase.Last_Business_Credit_Report_Pull_Date__c = GeneralHelper.currentSystemDateTime;
                    collectionCaseDBInstance.addUpdate(collectionCase);
                    collectionCaseDBInstance.executeUpdates();
                }

                accountIdToCreditProfilePdf.put(
                    accountDetail.Id, ExperianCallOut.requestExperianBusinessPremierProfilePdfCreditCheck(
                        accountDetail, accountBusinessSearch, businessAccessToken
                    )
                );

                if(!accountIdToCreditProfilePdf.isEmpty()) {
                    createExperianBusinessCreditReportDocument(accountIdToCreditProfilePdf, collectionCaseId);
                }

            } else if(accountBusinessSearch.get('responseMessage') != null
                && !String.valueOf(accountBusinessSearch.get('responseMessage')).contains('Your search did not match any records')
            ) {
                throw new CollectionsCreditPullException(String.valueOf(accountBusinessSearch.get('responseMessage')));
            }
            creditReportDetailDBInstance.executeInserts();
        } catch (Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog('Experian Business Credit Check Failed', e, collectionCaseId, false);
            errorLogDBInstance.addInsert(errorLog);
            errorLogDBInstance.executeInserts();
        }
    }

    public static void createExperianBusinessCreditReportDocument(Map<Id, String> collectionCaseIdToCreditProfilePdf, Id collectionCaseId) {
        Map<Id, Attachment> collectionCaseIdToAttachment = new Map<Id, Attachment>();
        String documentType = GeneralConstants.DOCUMENT_TYPE_COLLECTIONS_BUSINESS_CREDIT;
        List<Attachment> attachmentList = new List<Attachment>();

        for(Id collectionId : collectionCaseIdToCreditProfilePdf.keySet()) {
            Attachment reportAttachment = Attachments.createAttachment(
                documentType + '.pdf', EncodingUtil.base64Decode(collectionCaseIdToCreditProfilePdf.get(collectionId)), collectionCaseId
            );
            attachmentList.add(reportAttachment);
        }

        attachmentDBInstance.addInserts(attachmentList).executeInserts();

        for(Attachment objAttachment: AttachmentList) {
            collectionCaseIdToAttachment.put(objAttachment.parentId, objAttachment);
        }

        if(!collectionCaseIdToAttachment.isEmpty()) {
            CategoryAttachAssnManager.createCollectionsDocumentCategoryAssociationByAttachmentId(collectionCaseIdToAttachment, documentType);
        }
    }

    public static void createExperianConsumerCreditReportDocument(Map<Id, String> collectionCaseIdToCreditProfileTTY, Id collectionCaseId) {
        Map<Id, Attachment> collectionCaseIdToAttachment = new Map<Id, Attachment>();
        String documentType = GeneralConstants.DOCUMENT_TYPE_COLLECTIONS_CONSUMER_CREDIT;
        List<Attachment> attachmentList = new List<Attachment>();

        for(Id collectionId : collectionCaseIdToCreditProfileTTY.keySet()) {
            String currentSystemDateTime = GeneralHelper.currentSystemDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
            List<String> ttyResponse = collectionCaseIdToCreditProfileTTY.get(collectionId).split('<<RES>>');
            String ttyResponseAfterFormat = ttyResponse[1].replaceAll('\r\n', '</br>');
            String fileName =  ttyResponse[0] + '_' + currentSystemDateTime + '.html';
            Attachment reportAttachment = Attachments.createAttachment(fileName, Blob.valueOf(ttyResponseAfterFormat), collectionCaseId);
            attachmentList.add(reportAttachment);
        }

        attachmentDBInstance.addInserts(attachmentList).executeInserts();

        for(Attachment objAttachment: AttachmentList) {
            collectionCaseIdToAttachment.put(objAttachment.parentId, objAttachment);
        }

        if(!collectionCaseIdToAttachment.isEmpty()) {
            CategoryAttachAssnManager.createCollectionsDocumentCategoryAssociationByAttachmentId(collectionCaseIdToAttachment, documentType);
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Credit_Report_Detail__c> getBusinessCreditReportByAccountId(Id borrowerAccountId, Boolean isChanged) {
        return [
            SELECT Id, Account__c, Account__r.Name, Name, Total_No_Trades_Count__c, Months_Since_Biz_Added_To_Experian__c, Contact__c, Application__c,
                Trades_Count_DBT_30_Plus__c, Most_Recent_Open_Collections_Trade_Age__c, Legal_Name__c, Street__c, Tax_Liens__c, Type__c,
                City__c, State__c, Zip__c, ZipExtension__c, Industry_Type__c, SIC_Code__c, Business_Start_Date__c, Business_First_Seen_YYYY__c,
                Is_Recent_Bankruptcy__c, Is_Open_Bankruptcy__c, Competitor_Judgement__c, Judgement_Liens__c, Source_Type__c
            FROM Credit_Report_Detail__c
            WHERE Account__c = :borrowerAccountId
                AND Type__c = :GeneralConstants.CREDIT_REPORT_TYPE_EXPERIAN_BUSINESS
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Credit_Report_Detail__c> getConsumerCreditReportByContactId(Id contactId, Boolean isChanged) {
        return [
            SELECT Id, Contact__c, Contact__r.Name, Bankruptcy_Risk_Score__c, Account__c, Application__c,
                No_Of_Open_Trades__c, Overall_Amount_Balance_Ratio__c, Total_Credit_Inquiries_Last_6_Months__c,
                Open_Revolving_Trades_CreditRatio_100__c, Open_Revolving_Trades_Last_6_Months__c,
                Mortgage_Trades_90Days_Dlq_In_12_months__c, Mortgage_Trades_In_12Months__c,
                Total_Credit_Personal_Finance_Inquires__c, Avg_Months_Trds_Opn_Excl_Collections__c, Personal_FICO_Score__c,
                Total_No_Trades_Count__c, Is_Recent_Bankruptcy__c, Is_Open_Bankruptcy__c, Total_No_Late_Mortgage_Count__c,
                Credit_Statement__c, Score_Factor_Code__c, Name, Source_Type__c
            FROM Credit_Report_Detail__c
            WHERE Contact__c = :contactId
                AND Type__c = :GeneralConstants.CREDIT_REPORT_TYPE_EXPERIAN_CONSUMER
        ];
    }
    private class CollectionsCreditPullException extends Exception {}
}