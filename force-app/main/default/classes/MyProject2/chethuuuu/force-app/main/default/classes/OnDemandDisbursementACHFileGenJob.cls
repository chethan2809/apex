public class OnDemandDisbursementACHFileGenJob implements Database.AllowsCallouts, Database.Stateful, Database.Batchable<SObject> {
    @TestVisible
    private static LoanDisbursalTxnDistributionDB disbursalTxnDistributionDBInstance = new LoanDisbursalTxnDistributionDB();

    List<loan__Disbursal_Txn_Distribution__c> disbursalTxnDistributionList = new List<loan__Disbursal_Txn_Distribution__c>();

    public OnDemandDisbursementACHFileGenJob(){}

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id
            FROM loan__Disbursal_Txn_Distribution__c
            WHERE loan__Sent_To_ACH_On__c = :GeneralHelper.currentSystemDate
                AND loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Loan_Status__c != :CLContracts.LOAN_STATUS_CANCELED
                AND loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Invalid_Data__c = false
                AND loan__Reversed__c = false
        ]);
    }

    public void execute(Database.BatchableContext bc, List<loan__Disbursal_Txn_Distribution__c> disbursalTxnDistributionList) {
        for(loan__Disbursal_Txn_Distribution__c disbursalTxn : disbursalTxnDistributionList){
            disbursalTxn.loan__Sent_to_ACH__c = false;
            disbursalTxn.loan__ACH_Filename__c = null;
            disbursalTxn.loan__Sent_To_ACH_On__c = null;
            disbursalTxnDistributionDBInstance.addUpdate(disbursalTxn);
        }
        this.disbursalTxnDistributionList = disbursalTxnDistributionList;
        disbursalTxnDistributionDBInstance.executeUpdates();
    }

    public void finish(Database.BatchableContext bc) {
        clcommon.DynamicJobAPI6 apiHandle = clcommon.APIFactory.getDynamicJobAPI6();
        if(!Test.IsRunningTest() && !disbursalTxnDistributionList.IsEmpty()){
            apiHandle.runOnce('CAN Loan Disbursal File Gen DAG');
        }
    }

    private class OnDemandDisbursementACHFileGenJobException extends Exception {}

}