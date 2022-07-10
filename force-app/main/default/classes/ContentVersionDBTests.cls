@isTest(isParallel=true)
private class ContentVersionDBTests {

    private static ContentVersionDB contentVersionDBInstance = new ContentVersionDB();

    @isTest
    private static void getContentVersionsByIds() {
        Id contentVersionId = TestUtility.getFakeId(ContentVersion.getSObjectType());
        Set<Id> contentVersionIds = new Set<Id>();
        contentVersionIds.add(contentVersionId);

        Test.startTest();
            List<ContentVersion> contentVersionList = contentVersionDBInstance.getContentVersionsByIds(contentVersionIds);
        Test.stopTest();

        System.assert(contentVersionList != null);
        System.assert(contentVersionList.isEmpty());
    }
}