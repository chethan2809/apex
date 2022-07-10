@isTest(isParallel=true)
private class CollectionActivitiesDBTests {

    private static CollectionActivitiesDB collectionActivitiesDBInstance = new CollectionActivitiesDB();

    @isTest
    private static void getCollectionActivitiesByIds() {
        Id collActivityId = TestUtility.getFakeId(collect__Collection_Activity__c.getSObjectType());
        Set<Id> collActivityIds = new Set<Id>();
        collActivityIds.add(collActivityId);

        Test.startTest();
            List<collect__Collection_Activity__c> collActivityList = collectionActivitiesDBInstance.getCollectionActivitiesByIds(collActivityIds);
        Test.stopTest();

        System.assert(collActivityList != null);
        System.assert(collActivityList.isEmpty());
    }
}