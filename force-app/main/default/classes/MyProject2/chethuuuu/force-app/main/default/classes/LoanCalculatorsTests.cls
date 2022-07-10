@isTest(isParallel=true)
private class LoanCalculatorsTests {

    @isTest
    static void loanCalculators() {
        Test.startTest();
            String var = LoanCalculators.FIRST_PAYMENT_AMOUNT;
        Test.stopTest();

        System.assert(var != null);
    }
}