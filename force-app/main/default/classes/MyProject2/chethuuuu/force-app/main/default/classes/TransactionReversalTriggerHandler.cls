public class TransactionReversalTriggerHandler {
    public void afterInsert(Map<Id, loan__Repayment_Transaction_Adjustment__c> newReversalTransactionMap) {

        RepaymentTransactionReversalManager.sendReversalTransactionNotification(newReversalTransactionMap.keySet());
    }
}