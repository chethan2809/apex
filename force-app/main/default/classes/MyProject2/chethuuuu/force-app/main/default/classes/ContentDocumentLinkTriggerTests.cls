@isTest
private class  ContentDocumentLinkTriggerTests {
    private static ContentDocumentLinkDB contentDocumentLinkDBInstance = new ContentDocumentLinkDB();
    @isTest
    private static void contentDocumentLinkTriggerTest(){
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Test Note';
        contentVersion.PathOnClient = 'TestDocument.pdf';
        contentVersion.VersionData = Blob.valueOf('Test Content');
        contentVersion.IsMajorVersion = true;
        Insert contentVersion;

        List<ContentDocument> contentDocument = [
            SELECT Id, Title, LatestPublishedVersionId
            FROM contentDocument
        ];

        Account newAccount = TestUtility.createAccount();

        ContentDocumentLink contentDocumentLinkNew = new ContentDocumentLink();
        contentDocumentLinkNew.ContentDocumentId = contentDocument[0].Id;
        contentDocumentLinkNew.LinkedEntityId = newAccount.Id;

        Test.startTest();
            insert contentDocumentLinkNew;
        Test.StopTest();
    }
}