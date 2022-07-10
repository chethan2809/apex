@isTest(isParallel=true)
private class loanAccountDailyUpdatesTests {
    @isTest
    private static void setConcurrentInterestRate() {
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);

        loan__Loan_Account__c loanAccount = (loan__Loan_Account__c) JSON.deserialize(
            '{"Disbursement_Count__c" : "1.0", "Remaining_Number_of_Payments__c" : "24", "Concurrent_Eligible_Amount__c" : "5000"}',
            loan__Loan_Account__c.class
        );
        loanAccount.Pricing_Factor__c = 1.45;
        loanAccount.loan__Frequency_of_Loan_Payment__c = 'Daily';

        Test.startTest();
            loanAccountDailyUpdates.setConcurrentInterestRate(loanAccount);
        Test.stopTest();

        System.assertNotEquals(null, loanAccount.Concurrent_Interest_Rate__c);
    }
}