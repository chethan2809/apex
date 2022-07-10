public class AANNotificationJob implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts  {

    public static ApplicationDB applicationDBInstance = new ApplicationDB();
    public static Origination_Settings__mdt defaultAANSetting = CustomMetaDataHelper.defaultOriginationSetting;

    public AANNotificationJob() {}

    public Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime notificationDate = DateTime.newInstance(
            GeneralHelper.getNBusinessDate(GeneralHelper.currentSystemDate, - Integer.ValueOf(defaultAANSetting.AAN_Notifications_Days__c)), DateTime.Now().Time()
        );

        return Database.getQueryLocator([
            SELECT Id, Name, genesis__Status__c, Last_Status_Update_Date__c, Force_Stop_AAN__c, AAN_Letter_Sent__c, Decline_Reasons__c,
                genesis__Account__c, Electronic_Consent_Check__c, AAN_Mode__c, Primary_Guarantor__r.Name, Business_Type__c, Previous_Status__c,
                Is_Credit_Declined__c, Auto_Renewed__c, Renewal_Concurrent_LoanAccount__c, Is_EIS_Renewal__c, Decline_AAN_Sent_Date__c, Type__c, Abandon_Application__c,
                Is_Manual_Score_Run__c
            FROM genesis__Applications__c
            WHERE genesis__Status__c = :Applications.STATUS_DECLINED
                AND Decline_Reasons__c != null
                AND AAN_Letter_Sent__c = false
                AND Last_Status_Update_Date__c <= :notificationDate
                AND Force_Stop_AAN__c = false
        ]);
    }

    public void execute(Database.BatchableContext bc, List<genesis__Applications__c> applicationList) {
        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>();
        Map<String, AAN_Decline_Code_Mapping__mdt> declineCodeMap = CustomMetaDataHelper.declineCodeMap;

        for(genesis__Applications__c application :applicationList) {
            if(application.genesis__Status__c == Applications.STATUS_DECLINED && application.Decline_Reasons__c != null) {
                for(String declineReason :application.Decline_Reasons__c.split(';')){
                    if(declineCodeMap.containsKey(declineReason) && declineCodeMap.get(declineReason).Apply_for_AAN__c) {
                        applicationMap.put(application.Id, application);
                        application.AAN_Type__c = declineCodeMap.get(declineReason).MasterLabel;
                        break;
                    }
                }
            }
        }

        if(!applicationMap.isEmpty() && !CAN_General_Settings__c.getInstance().Disable_AAN__c) {
            AANNotificationManager.sendAANNotification(applicationMap);
        }
    }

    public void execute(SchedulableContext sc) {
        if (defaultAANSetting.AAN_Batch_Size__c == null) {
            throw new AANNotificationJobException('AAN_Batch_Size__c is null');
        }
        Database.executeBatch(this, Integer.ValueOf(defaultAANSetting.AAN_Batch_Size__c));
    }

    public static void execute() {
        AANNotificationJob aANNotificationJobInstance = new AANNotificationJob();
        aANNotificationJobInstance.execute(null);
    }

    public void finish(Database.BatchableContext bc) {

    }

    private class AANNotificationJobException extends Exception {}

}