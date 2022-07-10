public class ExpirationJob implements Schedulable, Database.Batchable<SObject> {

    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    public static Origination_Settings__mdt defaultExpirationSetting = CustomMetaDataHelper.defaultOriginationSetting;

    public ExpirationJob() {}

    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator([
            SELECT Id, Is_UCC_Expiring__c, Expiration_Date__c
            FROM UCC_Filing_Detail__c
            WHERE Expiration_Date__c <= :GeneralHelper.currentSystemDate.addDays(30)
                AND Is_UCC_Expiring__c = false
        ]);
    }

    public void execute(Database.BatchableContext bc, List<UCC_Filing_Detail__c> uccFilingList) {
        try {
            UCCFilingManager.setUCCExpirationFields(uccFilingList);
        } catch (Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'UCC Filing Expiration', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR, null, false
            );
            errorLogDBInstance.addInsert(errorLog).executeInserts();
        }
    }

    public void execute(SchedulableContext sc) {
        if (defaultExpirationSetting.AAN_Batch_Size__c == null) {
            throw new ExpirationJobException('AAN_Batch_Size__c is null');
        }
        Database.executeBatch(this, Integer.ValueOf(defaultExpirationSetting.AAN_Batch_Size__c));
    }

    public static void execute() {
        ExpirationJob expirationJobInstance = new ExpirationJob();
        expirationJobInstance.execute(null);
    }

    public void finish(Database.BatchableContext bc) {

    }

    private class ExpirationJobException extends Exception {}
}