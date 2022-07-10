public class AANNotifications {
    public static final String AAN_NOTIFICATION_TO_GUARANTOR = 'AAN_Notification_To_Guarantor';
    public static final String CAN_CAPITAL_LOGO = 'CAN_CAPITAL_IMAGE';
    public static final String AAN_MODE_EMAIL = 'Email';
    public static final String AAN_MODE_COMPUMAIL = 'CompuMail';

    public static String buildGuarantorAANNotificationTemplateBody(clcommon__Party__c party, String emailBody, List<Document> documents){
        emailBody = party.genesis__Application__r.genesis__Account__r.Name != null
            ? emailBody.replace('{{ACCOUNT_NAME}}', String.valueOf(party.genesis__Application__r.genesis__Account__r.Name)) : emailBody.replace('{{ACCOUNT_NAME}}', '');
        emailBody = emailBody.replace('{{CURRENT_DATE}}', String.valueOf(GeneralHelper.currentSystemDate));
        emailBody = party.clcommon__Contact__r.Name != null
            ? emailBody.replace('{{CUSTOMER_NAME}}', String.valueOf(party.clcommon__Contact__r.Name)) : emailBody.replace('{{CUSTOMER_NAME}}', '');
        emailBody = party.genesis__Application__r.genesis__Account__r.BillingStreet != null
            ? emailBody.replace('{{BILLING_STREET}}', String.valueOf(party.genesis__Application__r.genesis__Account__r.BillingStreet)) : emailBody.replace('{{BILLING_STREET}}', '');
        emailBody = party.genesis__Application__r.genesis__Account__r.BillingCity != null
            ? emailBody.replace('{{BILLING_CITY}}', String.valueOf(party.genesis__Application__r.genesis__Account__r.BillingCity)) : emailBody.replace('{{BILLING_CITY}}', '');
        emailBody = party.genesis__Application__r.genesis__Account__r.BillingState != null
            ? emailBody.replace('{{BILLING_STATE}}', String.valueOf(party.genesis__Application__r.genesis__Account__r.BillingState)) : emailBody.replace('{{BILLING_STATE}}', '');
        emailBody = party.genesis__Application__r.genesis__Account__r.BillingPostalCode != null
            ? emailBody.replace('{{BILLING_POSTAL_CODE}}', String.valueOf(party.genesis__Application__r.genesis__Account__r.BillingPostalCode)) : emailBody.replace('{{BILLING_POSTAL_CODE}}', '');

        String url = '';
        if(!documents.isEmpty()) {
            if(GeneralHelper.domainUrl.contains('genesisextn.visualforce.com')) {
                url = GeneralHelper.domainUrl.replace('genesisextn.visualforce.com', 'c.documentforce.com/servlet/servlet.ImageServer?');
            } else {
                url = GeneralHelper.domainUrl.replace('.my.salesforce.com', '--c.documentforce.com/servlet/servlet.ImageServer?');
            }
            url += 'id=' + documents[0].Id + '&oid=' + UserInfo.getOrganizationId();
        }

        emailBody = emailBody.replace('{{IMAGE__LOGO}}', url);
        return emailBody;
    }

    public static String buildSolePropGuarantorAANNotificationTemplateBody(clcommon__Party__c party, String emailBody, Decimal experianCreditScore, List<String> reasonCodes){
        String reasons = '';
        if(reasonCodes != null) {
            for (String reason : reasonCodes) {
                reasons += String.valueOf(reason) + '<br>';
            }
        }
        emailBody = emailBody.replace('{{SOLEPROPBODYSTART}}', '');
        emailBody = emailBody.replace('{{SOLEPROPBODYEND}}', '');
        emailBody = experianCreditScore != null
            ? emailBody.replace('{{CREDIT_SCORE}}', 'Your Experian credit score:' + String.valueOf(experianCreditScore))
            : emailBody.replace('{{CREDIT_SCORE}}', '');
        emailBody = party.clcommon__Contact__r.Last_Consumer_Credit_Pull__c != null
            ? emailBody.replace('{{CREDIT_INQUIRY_DATE}}', '<br>Date:' + String.valueOf(party.clcommon__Contact__r.Last_Consumer_Credit_Pull__c))
            : emailBody.replace('{{CREDIT_INQUIRY_DATE}}', '');
        emailBody = reasons != ''
            ? emailBody.replace('{{REASONS}}', 'Key factors that adversely affected your credit score: <br><br>' + reasons)
            : emailBody.replace('{{REASONS}}', '');
        emailBody = emailBody.replace('{{SOLEPROPCONTENTSTART}}', '');
        emailBody = emailBody.replace('{{SOLEPROPCONTENTEND}}', '');
        if(emailBody.contains('{{NONSOLECONTENTSTART}}')){
            emailBody = emailBody.replace(emailBody.substringBetween('{{NONSOLECONTENTSTART}}', '{{NONSOLECONTENTEND}}'), '');
        }
        emailBody = emailBody.replace('{{NONSOLECONTENTSTART}}', '');
        emailBody = emailBody.replace('{{NONSOLECONTENTEND}}', '');
        emailBody = emailBody.replace('{{SOLEPROPADDRESSSTART}}', '');
        emailBody = emailBody.replace('{{SOLEPROPADDRESSEND}}', '');
        return emailBody;
    }

    public static String buildNonSoleAANNotificationTemplateBody(String emailBody){
        emailBody = emailBody.replace('{{NONSOLECONTENTSTART}}', '');
        emailBody = emailBody.replace('{{NONSOLECONTENTEND}}', '');
        if(emailBody.contains('{{SOLEPROPCONTENTSTART}}')) {
            emailBody = emailBody.replace(emailBody.substringBetween('{{SOLEPROPCONTENTSTART}}', '{{SOLEPROPCONTENTEND}}'), '');
        }
        emailBody = emailBody.replace('{{SOLEPROPCONTENTSTART}}', '');
        emailBody = emailBody.replace('{{SOLEPROPCONTENTEND}}', '');
        if(emailBody.contains('{{SOLEPROPBODYSTART}}')) {
            emailBody = emailBody.replace(emailBody.substringBetween('{{SOLEPROPBODYSTART}}', '{{SOLEPROPBODYEND}}'), '');
        }
        emailBody = emailBody.replace('{{SOLEPROPBODYSTART}}', '');
        emailBody = emailBody.replace('{{SOLEPROPBODYEND}}', '');
        if(emailBody.contains('{{SOLEPROPADDRESSSTART}}')) {
            emailBody = emailBody.replace(emailBody.substringBetween('{{SOLEPROPADDRESSSTART}}', '{{SOLEPROPADDRESSEND}}'), '');
        }
        emailBody = emailBody.replace('{{SOLEPROPADDRESSSTART}}', '');
        emailBody = emailBody.replace('{{SOLEPROPADDRESSEND}}', '');
        return emailBody;
    }

    public static String getReasonCodesByContact(List<String> reasonCodes){
        String reasons = '';
        for (String reason : reasonCodes) {
            reasons += String.valueOf(reason) + ',';
        }
        return reasons;
    }
}