public class AANNotificationManager {
    @TestVisible
    private static ApplicationDB applicationDBInstance = new ApplicationDB();
    @TestVisible
    private static PartyDB partyDBInstance = new PartyDB();
    @TestVisible
    private static EmailDB emailDBInstance = new EmailDB();
    @TestVisible
    private static ContactDB contactDBInstance = new ContactDB();
    @TestVisible
    private static AccountDB accountDBInstance = new AccountDB();
    @TestVisible
    private static EmailTemplateDB emailTemplateDBInstance = new EmailTemplateDB();
    @TestVisible
    private static CreditReportDetailDB creditReportDetailDBInstance = new CreditReportDetailDB();
    @TestVisible
    private static DocumentDB documentDBInstance = new DocumentDB();

    public static void sendAANNotification(Map<Id, genesis__Applications__c> applicationMap) {
        Set<Id> partyBrokerAndGuarantorIds = new Set<Id>();
        String primaryGuarantor;
        Map<Id, Id> contactIdToApplicationId = new Map<Id, Id>();
        partyBrokerAndGuarantorIds.add(OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_GUARANTOR));
        partyBrokerAndGuarantorIds.add(OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BROKER));
        List<clcommon__Party__c> partyList = partyDBInstance.getPartiesByApplicationIdsAndPartyTypeIds(
            applicationMap.keySet(), partyBrokerAndGuarantorIds
        );
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Set<Id> partyContactIds = new Set<Id>();
        Map<Id, Decimal> creditReportScoreMap = new Map<Id, Decimal>();
        List<clcommon__Party__c> compuMailList = new List<clcommon__Party__c>();
        List<clcommon__Party__c> abandonedCompuMailList = new List<clcommon__Party__c>();
        Set<Id> accountIds = new Set<Id>();

        for(clcommon__Party__c party:partyList) {
            contactIdToApplicationId.put(party.clcommon__Contact__c, party.genesis__Application__c);
            partyContactIds.add(party.clcommon__Contact__c);
        }

        for(genesis__Applications__c application : applicationMap.values()) {
            accountIds.add(application.genesis__Account__c);
        }

        Map<Id, Contact> contactMap = new Map<Id, Contact> (contactDBInstance.getContactsByIds(contactIdToApplicationId.keySet()));
        Map<Id, Account> accountMap = new Map<Id, Account> (accountDBInstance.getAccountByIds(accountIds));

        Map<String, Credit_Score_Factor_Reason_Mapping__mdt> reasonCodeMap = CustomMetaDataHelper.reasonCodeMap;
        List<Credit_Report_Detail__c> creditReportDetailsByContactIds = creditReportDetailDBInstance.getConsumerCreditReportByContactIds(partyContactIds);
        Map<Id, List<String>> contactToReasonCodesMap = new  Map<Id, List<String>>();
        if(creditReportDetailsByContactIds != null) {
            for(Credit_Report_Detail__c creditReportDetail : creditReportDetailsByContactIds) {
                List<String> reasonCodes = new List<String>();
                if(creditReportDetail.Personal_FICO_Score__c != null) {
                    creditReportScoreMap.put(creditReportDetail.Contact__c, creditReportDetail.Personal_FICO_Score__c);
                }

                if(creditReportDetail.Score_Factor_Code__c != null) {
                    for(String reasonCode :creditReportDetail.Score_Factor_Code__c.split(',')) {
                        if(reasonCodeMap.containsKey(reasonCode)) {
                            reasonCodes.add(reasonCodeMap.get(reasonCode).Reason__c);
                        }
                    }
                    contactToReasonCodesMap.put(creditReportDetail.Contact__c, reasonCodes);
                }
            }
        }

        for(clcommon__Party__c party : partyList) {
            if(party.clcommon__Contact__r.Email != null) {
                Contact contactDetail = contactMap.get(party.clcommon__Contact__c);
                List<String> reasonCodes = contactToReasonCodesMap.get(contactDetail.Id);
                String reasons = '';
                if(reasonCodes != null) {
                    reasons = AANNotifications.getReasonCodesByContact(reasonCodes);
                }
                party.clcommon__Contact__r.Reasons_for_Credit_Score__c = reasons;
                genesis__Applications__c application = applicationMap.get(party.genesis__Application__c);
                Account account = accountMap.get(application.genesis__Account__c);
                if(party.clcommon__Type__r.Name == GeneralConstants.PARTY_TYPE_GUARANTOR){
                    if(party.clcommon__isPrimary__c != null && party.clcommon__isPrimary__c == true) {
                        primaryGuarantor = String.valueOf(party.clcommon__Contact__r.Name);
                    }
                    if(application.Abandon_Application__c) {
                        application.AAN_Mode__c = Experians.AAN_MODE_COMPUMAIL;
                        application.Abandoned_Application_AAN_Sent__c = true;
                        application.Abandoned_Application_AAN_Sent_Date__c = GeneralHelper.currentSystemDate;
                        applicationDBInstance.addUpdate(application);
                        abandonedCompuMailList.add(party);
                    } else if(( application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL && application.Auto_Renewed__c  && !application.Is_Credit_Declined__c && application.genesis__Status__c == Applications.STATUS_DECLINED)
                        || (application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL && account.Legacy_Percent_Paid__c == 100 && application.genesis__Status__c == Applications.STATUS_DECLINED)
                        || (application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL && !application.Auto_Renewed__c)
                        || (application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL && application.Auto_Renewed__c && application.Is_Manual_Score_Run__c)
                        || (application.Type__c != GeneralConstants.LOAN_TYPE_RENEWAL)){
                        application.AAN_Mode__c = Experians.AAN_MODE_COMPUMAIL;
                        application.AAN_Letter_Sent__c = true;
                        application.Decline_AAN_Sent_Date__c = GeneralHelper.currentSystemDate;
                        applicationDBInstance.addUpdate(application);
                        if(!(application.Business_Type__c == GeneralConstants.LEGAL_TYPE_SOLE_PROP)) {
                            compuMailList.add(party);
                        }
                    }
                }
            }
        }

        if(!compuMailList.isEmpty()){
            CompuMailManager.sendCompuMailForAAN(compuMailList, accountMap, applicationMap);
        }

        if(!abandonedCompuMailList.isEmpty()){
            CompuMailManager.sendCompuMailForAbandonApplication(abandonedCompuMailList, accountMap, applicationMap);
        }

        emailDBInstance.sendBulkEmail(emailList);
        applicationDBInstance.executeUpdates();
    }

    public static void sendAANNotificationsToGuarantor(
        clcommon__Party__c party, String templateByName, List<Messaging.SingleEmailMessage> emailList, Decimal experianCreditScore, List<String> reasonCodes
    ) {
        List<Document> documents = documentDBInstance.getDocumentByDeveloperName(AANNotifications.CAN_CAPITAL_LOGO);
        List<String> toAddresses = new List<String> { party.clcommon__Contact__r.Email };
        Set<String> templateNames = new Set<String> { templateByName };
        List<EmailTemplate> templates = emailTemplateDBInstance.getTemplatesByName(templateNames);
        String emailSubject = templates[0].Subject;
        String emailBody = templates[0].Body;
        emailBody = AANNotifications.buildGuarantorAANNotificationTemplateBody(party, emailBody, documents);

        if(party.genesis__Application__r.Business_Type__c == GeneralConstants.LEGAL_TYPE_SOLE_PROP) {
            emailBody = AANNotifications.buildSolePropGuarantorAANNotificationTemplateBody(
                party, emailBody, experianCreditScore, reasonCodes);
        } else {
            emailBody = AANNotifications.buildNonSoleAANNotificationTemplateBody(emailBody);
        }
        OrgWideEmailAddress orgWideAddress = GeneralHelper.orgWideEmailAddressByEmail.get(GeneralConstants.CAN_NO_REPLY_AAN_EMAIL_ADDRESS);
        Messaging.SingleEmailMessage email = Emails.getEmailMessageSetup(
            toAddresses, null, CustomMetaDataHelper.defaultGeneralSetting.From_Email__c, emailSubject,
            emailBody, true, null, orgWideAddress
        );

        emailList.add(email);
    }
}