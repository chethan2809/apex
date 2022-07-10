public class AbandonedAANNotificationJob implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts {

    public static Origination_Settings__mdt defaultAANSetting = CustomMetaDataHelper.defaultOriginationSetting;

    public AbandonedAANNotificationJob() {}

    public Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime notificationDate = DateTime.newInstance(
            GeneralHelper.getNBusinessDate(GeneralHelper.currentSystemDate, - Integer.ValueOf(defaultAANSetting.AAN_Notifications_Days__c)), DateTime.Now().Time()
        );

        return Database.getQueryLocator([
            SELECT Id, Name, genesis__Status__c, Last_Status_Update_Date__c, Force_Stop_AAN__c, Owner.Name, genesis__Account__c,
            Electronic_Consent_Check__c, AAN_Mode__c, Primary_Guarantor__r.Name, Business_Type__c, Previous_Status__c, Is_Credit_Declined__c,
            Auto_Renewed__c, Renewal_Concurrent_LoanAccount__c, Is_EIS_Renewal__c, Type__c, Abandon_Application__c,
            Abandoned_Application_AAN_Sent__c, Abandoned_Application_AAN_Sent_Date__c
            FROM genesis__Applications__c
            WHERE Abandon_Application__c = true
                AND Abandoned_Application_AAN_Sent__c = false
                AND Last_Status_Update_Date__c <= :notificationDate
                AND Force_Stop_AAN__c = false
        ]);
    }

    public void execute(Database.BatchableContext bc, List<genesis__Applications__c> applicationList) {
        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>();
        for(genesis__Applications__c application :applicationList) {
            applicationMap.put(application.Id, application);
        }

        if(!applicationMap.isEmpty() && !CAN_General_Settings__c.getInstance().Disable_AAN__c) {
            AANNotificationManager.sendAANNotification(applicationMap);
        }
    }

    public void execute(SchedulableContext sc) {
        if (defaultAANSetting.AAN_Batch_Size__c == null) {
            throw new AbandonedAANNotificationJobException('AAN_Batch_Size__c is null');
        }
        Database.executeBatch(this, Integer.ValueOf(defaultAANSetting.AAN_Batch_Size__c));
    }

    public static void execute() {
        AbandonedAANNotificationJob abandonedANNotificationJobInstance = new AbandonedAANNotificationJob();
        abandonedANNotificationJobInstance.execute(null);
    }

    public void finish(Database.BatchableContext bc) {

    }

    private class AbandonedAANNotificationJobException extends Exception {}
}