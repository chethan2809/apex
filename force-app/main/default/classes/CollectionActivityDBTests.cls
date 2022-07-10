@isTest(isParallel=true)
private class CollectionActivityDBTests {

    private static CollectionActivityDB collectionActivityDBInstance = new CollectionActivityDB();

    @isTest
    private static void getCollectionActivityOwnerDetails() {
        Id collActivityId = TestUtility.getFakeId(collect__Collection_Activity__c.getSObjectType());
        Set<Id> collActivityIds = new Set<Id>();
        collActivityIds.add(collActivityId);

        Test.startTest();
            List<collect__Collection_Activity__c> collActivityList = collectionActivityDBInstance.getCollectionActivityOwnerDetails(collActivityIds);
        Test.stopTest();

        System.assert(collActivityList != null);
        System.assert(collActivityList.isEmpty());
    }
}