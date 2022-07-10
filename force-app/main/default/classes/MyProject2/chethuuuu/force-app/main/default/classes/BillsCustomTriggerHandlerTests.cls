@isTest
private class BillsCustomTriggerHandlerTests {

    private static BillsCustomTriggerHandler billsCustomTriggerHandlerInstance = new BillsCustomTriggerHandler();

    @isTest
    private static void afterInsert() {
        loan__Loan_account_Due_Details__c loanAccountDueDetails = new loan__Loan_account_Due_Details__c();
        loanAccountDueDetails.Id = TestUtility.getFakeId(loan__Loan_account_Due_Details__c.getSObjectType());

        Map<Id, loan__Loan_account_Due_Details__c> loanAccountDueDetailsMap = new Map<Id, loan__Loan_account_Due_Details__c>();
        loanAccountDueDetailsMap.put(loanAccountDueDetails.Id, loanAccountDueDetails);

        Test.startTest();
            billsCustomTriggerHandlerInstance.afterInsert(loanAccountDueDetailsMap);
        Test.stopTest();

        system.assertEquals(loanAccountDueDetails, loanAccountDueDetailsMap.get(loanAccountDueDetails.Id));
    }
}