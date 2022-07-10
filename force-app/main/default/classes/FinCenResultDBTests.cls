@isTest(isParallel=true)
private class FinCenResultDBTests {

    private static FinCenResultDB finCenResultDBInstance = new FinCenResultDB();
    @isTest
    private static void getFinCenResult() {
        Id finCenResultId = TestUtility.getFakeId(FinCen_Result__c.getSObjectType());
        Set<Id> finCenResultIds = new Set<Id>();
        finCenResultIds.add(finCenResultId);

        Test.startTest();
            List<FinCen_Result__c> finCenResultList = finCenResultDBInstance.getFinCenResult(finCenResultIds);
        Test.stopTest();

        System.assert(finCenResultList != null);
        System.assert(finCenResultList.isEmpty());
    }
}