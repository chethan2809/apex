public class TaskManager {

    @TestVisible
    private static EmailDB emailDBInstance = new EmailDB();

    @TestVisible
    private static AccountDB accountDBInstance = new AccountDB();

    public static void sendTaskStatusEmailNotification(List<collect__Collection_Activity__c> collectionActivityEmailList, EmailTemplate caseEscalationEmailTemplate) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(collect__Collection_Activity__c collectionActivity :collectionActivityEmailList) {

            String body = caseEscalationEmailTemplate.HtmlValue;
            body = body.replace('{{COLLECTOR}}', String.valueOf(collectionActivity.collect__Dev_Contract__r.Owner.Name));
            body = body.replace('{{SUPERVISOR}}', String.valueOf(collectionActivity.collect__Account_Manager__r.Name));

            String subject = caseEscalationEmailTemplate.Subject;
            subject = subject.replace('{{SUPERVISOR}}', String.valueOf(collectionActivity.collect__Account_Manager__r.Name));
            List<String> toAddresses = new List<String>();
            toAddresses.add(collectionActivity.collect__Dev_Contract__r.Owner.Email);
            OrgWideEmailAddress orgWideAddress = GeneralHelper.orgWideEmailAddressByEmail.get(GeneralConstants.CAN_SALESFORCE_NOTIFICATION_EMAIL_ADDRESS);
            Messaging.SingleEmailMessage email = Emails.getEmailMessageSetup(
                toAddresses, null, CustomMetaDataHelper.defaultGeneralSetting.From_Email__c, subject, body, true, null, orgWideAddress
            );

            emailList.add(email);

        }

        emailDBInstance.sendBulkEmail(emailList);
    }

    public static void setAccountOutcomeActivityFields(Map<Id, String> accountIdToOutcomeMap) {
        for(Id accountId : accountIdToOutcomeMap.keySet()) {
            Account accountRecord = new Account(Id = accountId);
            String outcome = accountIdToOutcomeMap.get(accountRecord.Id);
            accountRecord.Most_Recent_Activity_Outcome__c = outcome;
            if (outcome == Tasks.OUTCOME_OUT_OF_MARKET){
                accountRecord.Out_of_Market__c = true;
            }
            accountDBInstance.addUpdate(accountRecord);
        }
        accountDBInstance.executeUpdates();
    }

}