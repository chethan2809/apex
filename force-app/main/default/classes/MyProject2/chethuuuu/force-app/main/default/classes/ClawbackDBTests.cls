@isTest(isParallel=true)
private class ClawbackDBTests {

    private static ClawbackDB clawbackDBInstance = new ClawbackDB();

    @isTest
    private static void getExistingClawBacksByLoanAccountIds() {
        Id loanAccountId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Set<Id> loanAccountIds = new Set<Id>();
        loanAccountIds.add(loanAccountId);

        Test.startTest();
            List<Clawback__c> clawBackList = clawbackDBInstance.getExistingClawBacksByLoanAccountIds(loanAccountIds);
        Test.stopTest();

        System.assert(clawBackList != null);
        System.assert(clawBackList.isEmpty());
    }
}