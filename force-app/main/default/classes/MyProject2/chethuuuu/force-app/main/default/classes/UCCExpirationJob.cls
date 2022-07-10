public class UCCExpirationJob implements Schedulable, Database.Batchable<SObject> {

    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    public static Origination_Settings__mdt defaultExpirationSetting = CustomMetaDataHelper.defaultOriginationSetting;

    public UCCExpirationJob() {}

    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator([
            SELECT Id, UCC_Expiration_Date__c
            FROM Account
            WHERE
            (
                (
                    UCC_Expiration_Date__c <= :GeneralHelper.currentSystemDate.addDays(30)
                    AND Is_UCC_Continuation_Eligible__c = true
                ) OR (
                    UCC_Expiration_Date__c < :GeneralHelper.currentSystemDate
                )
            )
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Account> accountList) {
        try {
            //UCCFilingManager.setUCCExpirationFields(accountList);
        } catch (Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'UCC Filing Expiration', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR, null, false
            );
            errorLogDBInstance.addInsert(errorLog).executeInserts();
        }
    }

    public void execute(SchedulableContext sc) {
        if (defaultExpirationSetting.UCC_Expiration_Batch_Size__c == null) {
            throw new UCCExpirationJobException('UCC_Expiration_Batch_Size__c is null');
        }
        Database.executeBatch(this, Integer.ValueOf(defaultExpirationSetting.UCC_Expiration_Batch_Size__c));
    }

    public static void execute() {
        UCCExpirationJob expirationJobInstance = new UCCExpirationJob();
        expirationJobInstance.execute(null);
    }

    public void finish(Database.BatchableContext bc) {

    }

    private class UCCExpirationJobException extends Exception {}
}