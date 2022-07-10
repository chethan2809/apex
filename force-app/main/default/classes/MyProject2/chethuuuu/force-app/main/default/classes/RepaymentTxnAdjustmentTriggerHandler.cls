public class RepaymentTxnAdjustmentTriggerHandler {
    @TestVisible
    private static RepaymentTxnAdjustmentDB repaymentTxnAdjustmentDBInstance = new RepaymentTxnAdjustmentDB();

    public void afterInsert(Map<Id, loan__Repayment_Transaction_Adjustment__c> newReversalTransactionMap) {
        Map<Id,loan__Repayment_Transaction_Adjustment__c> repaymentTransactionMap = new Map<Id,loan__Repayment_Transaction_Adjustment__c>(
            repaymentTxnAdjustmentDBInstance.getReversalTransactionListByIds(newReversalTransactionMap.keySet())
        );
        RepaymentTxnAdjustmentManager.setContractFields(repaymentTransactionMap);
        RepaymentTxnAdjustmentManager.setLoanPaymentTransactionFields(repaymentTransactionMap);

        RepaymentTxnAdjustmentManager.sendReversalTransactionNotification(newReversalTransactionMap.keySet());
    }
}