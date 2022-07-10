@isTest
private class LoanCalculatorManagerTests {

    @isTest
    private static void getInterestRate() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);
        Date contractDate = GeneralHelper.currentSystemDate;
        Date firstPaymentDate = GeneralHelper.currentSystemDate.addDays(10);

        LoanCalculatorManager loanCalculatorManagerInstance = new LoanCalculatorManager();

        Test.startTest();
            Decimal actualInterestRate = loanCalculatorManagerInstance.getInterestRate(
                3000, 1000, contractDate, firstPaymentDate, 6, 'WEEKLY'
            );
        Test.stopTest();

        System.assert(actualInterestRate != null);
    }

    @isTest
    private static void getFinalCalculationResults() {

        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);
        Date contractDate = GeneralHelper.currentSystemDate;
        Date lastPaymentDate = GeneralHelper.currentSystemDate.addDays(100);
        Date firstPaymentDate = GeneralHelper.currentSystemDate.addDays(10);

        LoanCalculatorManager loanCalculatorManagerInstance = new LoanCalculatorManager();

        Test.startTest();
            Decimal actualFirstPaymentAmount = (Decimal) loanCalculatorManagerInstance.getFinalCalculationResults(
                'WEEKLY', contractDate, firstPaymentDate, lastPaymentDate, 3000, 100, 6, 10
            ).get(LoanCalculators.FIRST_PAYMENT_AMOUNT);
        Test.stopTest();

        System.assert(actualFirstPaymentAmount != null);
    }
}