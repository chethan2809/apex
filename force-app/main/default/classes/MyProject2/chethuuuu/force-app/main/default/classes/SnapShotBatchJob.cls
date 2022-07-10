public class SnapShotBatchJob implements Schedulable, Database.Batchable<sObject> {
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    public SnapShotBatchJob(){}

    public Database.QueryLocator start (Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, Legacy_Number_of_Current_Missed_Payments__c, Legacy_Max_Missed_Payments__c, CLS_Active_Contract__c
            FROM Account
            WHERE Type = :Accounts.BORROWER
                AND Customer_Since__c != null
                AND Legacy_Active_Contract__c = false
            ORDER BY CreatedDate DESC
        ]);
    }

    public void execute (Database.BatchableContext bc , List<Account> accountList) {
        try {
            AccountDB accountDBInstance = new AccountDB();
            Map<Id, Account> accountMap = SnapShotManager.updateAccount(accountList);
            accountDBInstance.addUpdates(accountMap).executeUpdates();
        } catch(Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog('SnapShotBatchJob Failed', e.getMessage() + e.getStackTraceString(), JSON.serialize(accountList), accountList.get(0).Id, ErrorLogs.ERROR, null, false);
            errorLogDBInstance.addInsert(errorLog).executeInserts();
        }
    }

    public void execute(SchedulableContext sc) {
        Origination_Settings__mdt defaultSnapShotSetting = CustomMetaDataHelper.defaultOriginationSetting;
        if (defaultSnapShotSetting.Snapshot_Job_Size__c == null) {
            throw new SnapShotBatchJobException('Snapshot_Job_Size__c is null');
        }
        Database.executeBatch(this, Integer.ValueOf(defaultSnapShotSetting.Snapshot_Job_Size__c));
    }

    public static void execute() {
        SnapShotBatchJob snapShotBatchJobInstance = new SnapShotBatchJob();
        snapShotBatchJobInstance.execute(null);
    }

    public void finish(Database.BatchableContext bc){
    }

    private class SnapShotBatchJobException extends Exception {}
}