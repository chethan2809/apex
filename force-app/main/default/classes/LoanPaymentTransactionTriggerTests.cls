@IsTest
private class LoanPaymentTransactionTriggerTests
{
    @IsTest
    private static void loanPaymentTransactionTest()
    {
        TestUtility.runSetupData();
        loan__Loan_Account__c  clContract = TestUtility.createContract();

        loan__Payment_Mode__c mode = new loan__Payment_Mode__c();
        mode.Name ='test';
        insert mode;

        loan__Loan_Payment_Transaction__c loanPayment = TestUtility.generateLoanPaymentTransaction(clContract.Id, 1200, mode.Id);
        insert loanPayment;

        Test.startTest();
        loanPayment.loan__Reversed__c = true;
        update loanPayment;
        Test.stopTest();

        System.assert(loanPayment.Id != null);
    }
}