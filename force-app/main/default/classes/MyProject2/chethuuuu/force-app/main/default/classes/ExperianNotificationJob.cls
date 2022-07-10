public class ExperianNotificationJob implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts  {

    @TestVisible
   private static Origination_Settings__mdt defaultSetting = CustomMetaDataHelper.defaultOriginationSetting;

    public ExperianNotificationJob() {}

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, genesis__Account__c, genesis__Status__c, Last_Status_Update_Date__c, Electronic_Consent_Check__c, Primary_Guarantor__r.Name, Business_Type__c,
                Credit_Pull_Notification_Date__c, Decline_Reasons__c, Broker_Contact__r.Account.Email_cc__c, Type__c,
                Opportunity__c, Opportunity__r.Offer_Notification_To_Guarantor__c, Sales_Rep__c, Sales_Rep__r.Email, AAN_Letter_Sent__c,Credit_AAN_Sent__c, Credit_AAN_Sent_Date__c
            FROM genesis__Applications__c
            WHERE genesis__Status__c = :Applications.STATUS_GUARANTOR_CREDIT_CHECK
                AND Credit_Pull_Notification_Date__c <= :GeneralHelper.currentSystemDate
                AND Force_Stop_AAN__c = false
                AND (NOT (Type__c = :GeneralConstants.LOAN_TYPE_RENEWAL AND Auto_Renewed__c = true AND Is_Manual_Score_Run__c = false))
        ]);
    }

    public void execute(Database.BatchableContext bc, List<genesis__Applications__c> applicationList) {
        ExperianManager.sendCreditFreezeNotification(applicationList);
    }

    public void execute(SchedulableContext sc) {
        if (defaultSetting.Experian_Notification_Batch_Size__c == null) {
            throw new ExperianNotificationJobException('Experian_Notification_Batch_Size__c is null');
        }
        Database.executeBatch(this, Integer.valueOf(defaultSetting.Experian_Notification_Batch_Size__c));
    }

    public static void execute() {
        ExperianNotificationJob experianNotificationJobInstance = new ExperianNotificationJob();
        experianNotificationJobInstance.execute(null);
    }

    public void finish(Database.BatchableContext bc) {

    }

    private class ExperianNotificationJobException extends Exception {}
}