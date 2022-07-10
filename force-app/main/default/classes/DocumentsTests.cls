@isTest
private class DocumentsTests {

    @isTest
    private static void createDocument() {
        Id folderId = TestUtility.getFakeId(Folder.getSObjectType());
        String docCategoryName = 'Dummy File';
        Blob bodyContent = Blob.valueOf('Dummy File Body');

        Test.startTest();
            Document actualDocument = Documents.createDocument('Dummy File', bodyContent, folderId, 'txt', 'text');
        Test.stopTest();

        System.assert(actualDocument != Null);
        System.assertEquals('Dummy File', actualDocument.Name);
        System.assertEquals(bodyContent, actualDocument.Body);
        System.assertEquals('txt', actualDocument.Type);
        System.assertEquals('text', actualDocument.contentType);
    }
}