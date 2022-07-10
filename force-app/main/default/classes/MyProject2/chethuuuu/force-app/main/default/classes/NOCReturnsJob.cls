public class NOCReturnsJob implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts   {

    public static Origination_Settings__mdt defaultAANSetting = CustomMetaDataHelper.defaultOriginationSetting;

    public NOCReturnsJob() {}

    public Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime notificationDate = DateTime.newInstance(
            GeneralHelper.getNBusinessDate(GeneralHelper.currentSystemDate, - Integer.ValueOf(defaultAANSetting.AAN_Notifications_Days__c)), DateTime.Now().Time()
        );

        return Database.getQueryLocator([
            SELECT Id
            FROM AAN_Decline_Code_Mapping__mdt
        ]);
    }

    public void execute(Database.BatchableContext bc, List<AAN_Decline_Code_Mapping__mdt> applicationList) {
        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>();
        Map<String, AAN_Decline_Code_Mapping__mdt> declineCodeMap = CustomMetaDataHelper.declineCodeMap;
    }

    public void execute(SchedulableContext sc) {
        if (defaultAANSetting.AAN_Batch_Size__c == null) {
            throw new NOCReturnsJobException('AAN_Batch_Size__c is null');
        }
        Database.executeBatch(this, Integer.ValueOf(defaultAANSetting.AAN_Batch_Size__c));
    }

    public static void execute() {
        NOCReturnsJob nOCReturnsJobInstance = new NOCReturnsJob();
        nOCReturnsJobInstance.execute(null);
    }

    public void finish(Database.BatchableContext bc) {

    }

    private class NOCReturnsJobException extends Exception {}
}