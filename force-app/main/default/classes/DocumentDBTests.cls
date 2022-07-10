@isTest(isParallel=true)
private class DocumentDBTests {

    private static DocumentDB documentDBInstance = new DocumentDB();

    @isTest
    private static void getDocumentByDeveloperName() {
        Test.startTest();
            List<Document> document = documentDBInstance.getDocumentByDeveloperName('Test Document');
        Test.stopTest();

        System.assert(document != null);
        System.assert(document.isEmpty());
    }

    @isTest
    private static void getDocumentByFolderId() {
        Id folderId = TestUtility.getFakeId(Folder.getSObjectType());
        Test.startTest();
            List<Document> document = documentDBInstance.getDocumentByFolderId(folderId);
        Test.stopTest();

        System.assert(document != null);
        System.assert(document.isEmpty());
    }
}