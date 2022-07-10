@isTest(isParallel=true)
private class ContentDocumentDBTests {

    private static ContentDocumentDB contentDocumentDBInstance = new ContentDocumentDB();

    @isTest
    private static void getAllContentDocumentsByIds() {
        Id contentDocumentId = TestUtility.getFakeId(ContentDocument.getSObjectType());
        Set<Id> contentDocumentIds = new Set<Id>();
        contentDocumentIds.add(contentDocumentId);

        Test.startTest();
            List<ContentDocument> contentDocumentList = contentDocumentDBInstance.getAllContentDocumentsByIds(contentDocumentIds);
        Test.stopTest();

        System.assert(contentDocumentList != null);
        System.assert(contentDocumentList.isEmpty());
    }
}