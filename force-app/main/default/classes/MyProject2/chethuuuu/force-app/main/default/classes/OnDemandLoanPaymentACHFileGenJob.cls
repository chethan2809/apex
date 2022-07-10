public class OnDemandLoanPaymentACHFileGenJob implements Database.AllowsCallouts, Database.Batchable<SObject>, Database.Stateful {
    @TestVisible
    private static LoanPaymentTransactionDB loanPaymentDBInstance = new LoanPaymentTransactionDB();

    List<loan__Loan_Payment_Transaction__c> loanPaymentTransactionList = new List<loan__Loan_Payment_Transaction__c>();

    public OnDemandLoanPaymentACHFileGenJob(){}

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id
            FROM loan__Loan_Payment_Transaction__c
            WHERE loan__Sent_To_ACH_On__c = :GeneralHelper.currentSystemDate
                AND loan__Loan_Account__r.loan__Loan_Status__c != :CLContracts.LOAN_STATUS_CANCELED
                AND loan__Loan_Account__r.loan__Invalid_Data__c = false
                AND loan__Reversed__c = false
        ]);
    }

    public void execute(Database.BatchableContext bc, List<loan__Loan_Payment_Transaction__c> loanPaymentTransactionList) {
        for(loan__Loan_Payment_Transaction__c loanPayment : loanPaymentTransactionList){
            loanPayment.loan__Sent_to_ACH__c = false;
            loanPayment.loan__ACH_Filename__c = null;
            loanPayment.loan__Sent_To_ACH_On__c = null;
            loanPaymentDBInstance.addUpdate(loanPayment);
        }
        this.loanPaymentTransactionList = loanPaymentTransactionList;
        loanPaymentDBInstance.executeUpdates();
    }

    public void finish(Database.BatchableContext bc) {
        clcommon.DynamicJobAPI6 apiHandle = clcommon.APIFactory.getDynamicJobAPI6();
        if(!Test.IsRunningTest() && !loanPaymentTransactionList.IsEmpty()){
            apiHandle.runOnce('CAN Loan Payment Transaction DAG');
        }
    }

    private class OnDemandLoanPaymentACHFileGenJobException extends Exception {}

}