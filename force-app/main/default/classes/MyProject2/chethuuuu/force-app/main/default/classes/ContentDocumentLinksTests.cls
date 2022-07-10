@isTest
private class ContentDocumentLinksTests {

    private static ContentVersionDB contentVersionDBInstance = new ContentVersionDB();

    @isTest
    private static void insertAttachmentToSObject() {

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Test Document';
        contentVersion.PathOnClient = 'TestDocument.pdf';
        contentVersion.VersionData = Blob.valueOf('Test Content');
        contentVersion.IsMajorVersion = true;
        Insert contentVersion;

        List<ContentVersion> cvList = [
          SELECT Id, Title, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :contentVersion.Id
        ];

        Schema.SObjectType accountType = Schema.getGlobalDescribe().get('Account');
        SObject newAccount = accountType.newSObject();

        Test.startTest();
            ContentDocumentLink newContentDocumentLink = ContentDocumentLinks.insertAttachmentToSObject(newAccount, cvList[0]);
        Test.stopTest();

        System.assertEquals(cvList[0].ContentDocumentId, newContentDocumentLink.ContentDocumentId);
        System.assertEquals(newAccount.Id, newContentDocumentLink.LinkedEntityId);
        System.assertEquals('V', newContentDocumentLink.ShareType);
        System.assertEquals('AllUsers', newContentDocumentLink.Visibility);
    }
}