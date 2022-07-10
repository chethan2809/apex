public class loanAccountDailyUpdates {

    @TestVisible
    private static LoanCalculatorManager loanCalculatorManagerInstance = new LoanCalculatorManager();

    public static void setConcurrentInterestRate(loan__Loan_Account__c loanAccount){
        Decimal paymentAmount = (loanAccount.Concurrent_Eligible_Amount__c * loanAccount.Pricing_Factor__c) / loanAccount.Remaining_Number_of_Payments__c;
        Decimal interestRate = loanCalculatorManagerInstance.getInterestRate(
            loanAccount.Concurrent_Eligible_Amount__c, paymentAmount, GeneralHelper.currentSystemDate,
            GeneralHelper.getNBusinessDate(GeneralHelper.currentSystemDate, 1), (Integer) loanAccount.Remaining_Number_of_Payments__c.round(),
            loanAccount.loan__Frequency_of_Loan_Payment__c
        );
        loanAccount.Concurrent_Interest_Rate__c = interestRate;
    }
}