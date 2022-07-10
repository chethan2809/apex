@isTest
private class PayoffQuoteTriggerTests {

    @isTest
    private static void payoffQuoteTriggerTestsMethod() {
        TestUtility.runSetupData();
        loan__Loan_Account__c contract = TestUtility.createContract();

        loan__Payoff_Quote__c loanPayoff = new loan__Payoff_Quote__c();
        loanPayoff.Name =  'PayoffQuote';
        loanPayoff.loan__Poq_valid_till_Dt__c = Date.today();
        loanPayoff.loan__Loan_Account__c = contract.Id;

        Exception ex;
        Test.startTest();
         try{
            insert loanPayoff;
         }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();

        list<loan__Payoff_Quote__c> actualLoanPayoff =[
            SELECT Id, Name, loan__Loan_Account__c
            FROM loan__Payoff_Quote__c
        ];

        System.assert(loanPayoff.Id != null);
        System.assertEquals(1, actualLoanPayoff.size());
        System.assertEquals(loanPayoff.loan__Loan_Account__c, actualLoanPayoff.get(0).loan__Loan_Account__c);
    }
}