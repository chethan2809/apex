@isTest(isParallel=true)
private class LoanDisbursalTransactionsDBTests {

    private static LoanDisbursalTransactionsDB loanDisbursalTransactionsDBInstance = new LoanDisbursalTransactionsDB();

    @isTest
    private static void loanDisbursalTransactionsByIds() {

        Id loanDisbursalTransactionId = TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType());
        Set<Id> loanDisbursalTransactionIds = new Set<Id>();
        loanDisbursalTransactionIds.add(loanDisbursalTransactionId);

        Test.startTest();
            List<loan__Loan_Disbursal_Transaction__c> loanDisbursalTransactionList = loanDisbursalTransactionsDBInstance.getLoanDisbursalTransactionsByIds(loanDisbursalTransactionIds);
        Test.stopTest();

        System.assert(loanDisbursalTransactionList != null);
        System.assert(loanDisbursalTransactionList.isEmpty());
    }

    @isTest
    private static void getDisbursalTransactionsListByLoanAccountIds() {

        Id loanAccountId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Set<Id> loanAccountIds = new Set<Id>();
        loanAccountIds.add(loanAccountId);

        Test.startTest();
            List<loan__Loan_Disbursal_Transaction__c> loanDisbursalTransactionListByLoanAccountIds = loanDisbursalTransactionsDBInstance.getDisbursalTransactionsListByLoanAccountIds(loanAccountIds);
        Test.stopTest();

        System.assert(loanDisbursalTransactionListByLoanAccountIds != null);
        System.assert(loanDisbursalTransactionListByLoanAccountIds.isEmpty());
    }
}