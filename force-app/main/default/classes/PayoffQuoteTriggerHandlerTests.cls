@isTest
private class PayoffQuoteTriggerHandlerTests {

    @isTest
    static void beforeInsert() {
        GeneralHelper.currentSystemDate = Date.newInstance(2021, 01, 01);
        GeneralHelper.currentSystemDateTime = DateTime.newInstance(GeneralHelper.currentSystemDate, DateTime.Now().Time());

        loan__Loan_Account__c loanAccount = (loan__Loan_Account__c) JSON.deserialize(
            '{ "Pre_Closure_Penalty_Amount__c" : "100"}', loan__Loan_Account__c.class
        );
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccount.Is_Pre_Closure_Fee_Applied__c = false;

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c> {loanAccount};
        PayoffQuoteTriggerHandler.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        loan__Payoff_Quote__c newPayoffQuote = new loan__Payoff_Quote__c();
        newPayoffQuote.Name = 'Name';
        newPayoffQuote.loan__Loan_Account__c = loanAccount.Id;
        newPayoffQuote.loan__Poq_Unpaid_Charges__c = 100;
        newPayoffQuote.loan__Poq_Total_Payoff_Amount__c = 500;

        Test.startTest();
            new PayoffQuoteTriggerHandler().beforeInsert(new List<loan__Payoff_Quote__c> {newPayoffQuote});
        Test.stopTest();

        System.assertEquals(200, newPayoffQuote.loan__Poq_Unpaid_Charges__c);
        System.assertEquals(600, newPayoffQuote.loan__Poq_Total_Payoff_Amount__c);
    }
}