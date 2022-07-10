@isTest(isParallel=true)
private class LoanPaymentSpreadDBTests {

    private static LoanPaymentSpreadDB loanPaymentSpreadDBInstance = new LoanPaymentSpreadDB();

    @isTest
    private static void getDefaultCANPaymentSpread() {

        Test.startTest();
            List<loan__Loan_Payment_Spread__c> loanPaymentList = loanPaymentSpreadDBInstance.getDefaultCANPaymentSpread();
        Test.stopTest();

        System.assert(loanPaymentList != null);
        System.assert(loanPaymentList.isEmpty());
    }
}