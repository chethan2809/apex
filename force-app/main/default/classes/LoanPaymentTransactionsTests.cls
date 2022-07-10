@isTest
private class LoanPaymentTransactionsTests {

    @isTest
    private static void createLoanPaymentTransaction() {
        Id loanAccountId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Id paymentModeId = TestUtility.getFakeId(loan__Payment_Mode__c.getSObjectType());

        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);
        Date transactionDate = GeneralHelper.currentSystemDate.addDays(5);
        Decimal transactionAmount = 0.3;

        Test.startTest();
            loan__Loan_Payment_Transaction__c loan = LoanPaymentTransactions.createLoanPaymentTransaction(loanAccountId , paymentModeId , transactionAmount , transactionDate);
        Test.stopTest();

        System.assertEquals(loanAccountId, loan.loan__Loan_Account__c);
        System.assertEquals(paymentModeId, loan.loan__Payment_Mode__c);
        System.assertEquals(transactionDate, loan.loan__Transaction_Date__c);
        System.assertEquals(transactionAmount, loan.loan__Transaction_Amount__c);
    }
}