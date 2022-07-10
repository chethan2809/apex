@isTest(isParallel=true)
private class RepaymentTxnAdjustmentDBTests {

    private static RepaymentTxnAdjustmentDB repaymentTxnAdjustmentDBInstance = new RepaymentTxnAdjustmentDB();

    @isTest
    private static void getReversalTransactionListByIds() {
        Id repaymentTransactionId = TestUtility.getFakeId(loan__Repayment_Transaction_Adjustment__c.getSObjectType());
        Set<Id> repaymentTransactionIds = new Set<Id>();
        repaymentTransactionIds.add(repaymentTransactionId);

        Test.startTest();
            List<loan__Repayment_Transaction_Adjustment__c> repaymentTransactionList = repaymentTxnAdjustmentDBInstance.getReversalTransactionListByIds(repaymentTransactionIds);
        Test.stopTest();

        System.assert(repaymentTransactionList != null);
        System.assert(repaymentTransactionList.isEmpty());
    }

    @isTest
    private static void getReversalTransactionListByIdsAndReversalReasonCodes() {
        Id repaymentTransactionId = TestUtility.getFakeId(loan__Repayment_Transaction_Adjustment__c.getSObjectType());
        Set<Id> repaymentTransactionIds = new Set<Id>();
        repaymentTransactionIds.add(repaymentTransactionId);

        Test.startTest();
            List<loan__Repayment_Transaction_Adjustment__c> repaymentTransactionList = repaymentTxnAdjustmentDBInstance.getReversalTransactionListByIdsAndReversalReasonCodes(repaymentTransactionIds,
                RepaymentTxnAdjustments.REVERSAL_REASON_CODES);
        Test.stopTest();

        System.assert(repaymentTransactionList != null);
        System.assert(repaymentTransactionList.isEmpty());
    }
}