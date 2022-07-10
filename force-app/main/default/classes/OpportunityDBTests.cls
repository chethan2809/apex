@isTest(isParallel=true)
private class OpportunityDBTests {

    private static OpportunityDB opportunityDBInstance = new OpportunityDB();

    @isTest
    private static void getOpportunityByAccountIds() {
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(accountId);

        Test.startTest();
            List<Opportunity> opportunityList = OpportunityDBInstance.getOpportunityByAccountIds(accountIds);
        Test.stopTest();

        System.assert(opportunityList != null);
        System.assert(opportunityList.isEmpty());
    }

    @isTest
    private static void getOpportunityByIds() {
        Id oppId = TestUtility.getFakeId(Opportunity.getSObjectType());
        Set<Id> opportunityIds = new Set<Id>();
        opportunityIds.add(oppId);

        Test.startTest();
            List<Opportunity> opportunityList = OpportunityDBInstance.getOpportunityByIds(opportunityIds);
        Test.stopTest();

        System.assert(opportunityList != null);
        System.assert(opportunityList.isEmpty());
    }
}