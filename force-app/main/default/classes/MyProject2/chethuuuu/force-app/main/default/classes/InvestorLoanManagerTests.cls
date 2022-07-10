@isTest
private class InvestorLoanManagerTests {

    @isTest
    private static void createInvestorLoans() {

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        loan__Loan_Disbursal_Transaction__c loanDisbursalTransaction = new loan__Loan_Disbursal_Transaction__c();
        loanDisbursalTransaction.Id = TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType());
        loanDisbursalTransaction.Investor_Account__c = account.Id;

        DBManagerTestsStub loanDisbursalTransactionsDBStubInstance = new DBManagerTestsStub();
        LoanDisbursalTransactionsDBStubInstance.genericReturnObject = new List<loan__Loan_Disbursal_Transaction__c>{loanDisbursalTransaction};
        InvestorLoanManager.LoanDisbursalTransactionsDBInstance = (LoanDisbursalTransactionsDB) Test.createStub(LoanDisbursalTransactionsDB.class, LoanDisbursalTransactionsDBStubInstance);

        Set<Id> loanDisbursalTransactionIds = new Set<Id>();
        loanDisbursalTransactionIds.add(loanDisbursalTransaction.Id);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        InvestorLoanManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Test.startTest();
            InvestorLoanManager.createInvestorLoans(loanDisbursalTransactionIds);
        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }
}