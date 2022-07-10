@isTest
private class ContentDocumentLinkManagerTests {

    @isTest
    private static void getContentDocumentLinkByParentIds() {
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Test Document';
        contentVersion.PathOnClient = 'TestDocument.pdf';
        contentVersion.VersionData = Blob.valueOf('Test Content');
        contentVersion.IsMajorVersion = true;
        Insert contentVersion;

        List<ContentDocument> contentDocument = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM contentDocument
        ];

        ContentDocumentLink contentDocumentLinkNew = new ContentDocumentLink();
        contentDocumentLinkNew.ContentDocumentId = contentDocument[0].Id;
        contentDocumentLinkNew.LinkedEntityId = TestUtility.getFakeId(Account.getSObjectType());

        Set<Id> parentId = new Set<Id>();
        parentId.add(contentDocumentLinkNew.LinkedEntityId);

        DBManagerTestsStub contentDocumentLinkDBStubInstance = new DBManagerTestsStub();
        contentDocumentLinkDBStubInstance.genericReturnObject = new List<ContentDocumentLink>{contentDocumentLinkNew};
        ContentDocumentLinkManager.contentDocumentLinkDBInstance = (ContentDocumentLinkDB) Test.createStub(ContentDocumentLinkDB.class, contentDocumentLinkDBStubInstance);

        Test.startTest();
            Map<Id, String> attachmentToFileMap = ContentDocumentLinkManager.getContentDocumentLinkByParentIds(parentId);
        Test.stopTest();

        System.assertEquals(1, attachmentToFileMap.size());
    }
}