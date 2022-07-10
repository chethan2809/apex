@isTest
private class ContractConditionsTests {

    @isTest
    private static void createContractCondition() {
        Id loanAccountId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        ServicingHelper.conditionsOnSpreadId = TestUtility.getFakeId(loan__Conditions_On_Spread__c.getSObjectType());
        ServicingHelper.defaultPaymentSpreadId = TestUtility.getFakeId(loan__Loan_Payment_Spread__c.getSObjectType());

        Test.startTest();
            loan__Contract_Condition__c loanContractCondition = ContractConditions.createContractCondition(loanAccountId);
        Test.stopTest();

        System.assert(loanContractCondition != null);
        System.assertEquals(loanAccountId, loanContractCondition.loan__Loan_Account__c);
    }
}