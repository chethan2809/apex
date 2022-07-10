@isTest
private class ContentDocumentLinkTriggerHandlerTests {
    @isTest
    private static void afterInsert() {

        Map<Id, ContentDocumentLink> contentDocumentLinkMap = new Map<Id, ContentDocumentLink>();
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
        ContentDocumentLink contentDocumentLinkRecord = (ContentDocumentLink) JSON.deserialize('{"ContentDocumentId" : "' + contentDocument[0].Id + '","LinkedEntityId" : "' + newAccount.Id + '"}', ContentDocumentLink.class);
        contentDocumentLinkRecord.Id = TestUtility.getFakeId(ContentDocumentLink.getSObjectType());

        DBManagerTestsStub customContentDocumentLinkDBStubInstance = new DBManagerTestsStub();
        customContentDocumentLinkDBStubInstance.genericReturnObject = new List<ContentDocumentLink> {contentDocumentLinkRecord};
        ContentDocumentLinkTriggerHandler.customeContentDocumentLinkDBInstance = (CustomContentDocumentLinkDB) Test.createStub(CustomContentDocumentLinkDB.class, customContentDocumentLinkDBStubInstance);

        contentDocumentLinkMap.put(contentDocumentLinkRecord.Id, contentDocumentLinkRecord);

        ContentDocumentLinkTriggerHandler contentDocumentLinkTriggerHandlerInstance = new ContentDocumentLinkTriggerHandler();

        Test.startTest();
            contentDocumentLinkTriggerHandlerInstance.afterInsert(contentDocumentLinkMap);
        Test.stopTest();

        CustomContentDocumentLink__c accountRecordInserted = (CustomContentDocumentLink__c) customContentDocumentLinkDBStubInstance.forInsertSObjects.get(0);
        System.assertEquals(accountRecordInserted.LinkedEntityId__c, newAccount.Id);
        System.assertEquals(1, customContentDocumentLinkDBStubInstance.forInsertSObjects.size());
    }
}