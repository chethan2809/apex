public class UCCFilingContinuationJob implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts {

    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    public static Origination_Settings__mdt defaultContinuationSetting = CustomMetaDataHelper.defaultOriginationSetting;

    public UCCFilingContinuationJob() {}

    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator([
            SELECT Id, UCC_Expiration_Date__c, Is_UCC_Continuation_Eligible__c, Number_Of_Days_To_Expire_UCC__c
            FROM Account
            WHERE (Is_UCC_Continuation_Eligible__c = true
                    AND Number_Of_Days_To_Expire_UCC__c <= :CustomSettingsHelper.generalSettings.UCC_Continuation_Days__c
                    AND Number_Of_Days_To_Expire_UCC__c >= 0
                )
                OR (Number_Of_Days_To_Expire_UCC__c < 0
                    AND UCC_Status__c =:GeneralConstants.UCC_STATUS_ACTIVE
                )
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Account> accountList) {
        try {
            Set<Id> continuedAccountIds = new Set<Id>();
            List<Account> uccExpiredList =  new List<Account>();
            for(Account accountRecord : accountList) {
                if (accountRecord.Is_UCC_Continuation_Eligible__c && accountRecord.Number_Of_Days_To_Expire_UCC__c >= 0) {
                    continuedAccountIds.add(accountRecord.Id);
                } else {
                    uccExpiredList.add(accountRecord);
                }
            }

            if(!continuedAccountIds.isEmpty()) {
                UCCFilingManager.uccFilingContinuation(continuedAccountIds);
            }

            if(!uccExpiredList.isEmpty()) {
                UCCFilingManager.setUCCExpiredFields(uccExpiredList);
            }
        } catch (Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'UCC Filing Continuation Job Failed', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR, null, false
            );
            errorLogDBInstance.addInsert(errorLog).executeInserts();
        }
    }

    public void execute(SchedulableContext sc) {
        if (defaultContinuationSetting.UCC_Continuation_Batch_Size__c == null) {
            throw new UCCFilingContinuationJobException('UCC_Continuation_Batch_Size__c is null');
        }
        Database.executeBatch(this, Integer.ValueOf(defaultContinuationSetting.UCC_Continuation_Batch_Size__c));
    }

    public static void execute() {
        UCCFilingContinuationJob continuationJobInstance = new UCCFilingContinuationJob();
        continuationJobInstance.execute(null);
    }

    public void finish(Database.BatchableContext bc) {

    }

    private class UCCFilingContinuationJobException extends Exception {}
}