@isTest
public class ContentDocumentTriggerTests {

    private static ContentDocumentTriggerHandler contentDocumentTrigger = new ContentDocumentTriggerHandler();

        @isTest
        private static void afterUpdate() {

        ContentVersion contentVersion1 = new ContentVersion(
        Title = 'TestVersion',
        PathOnClient = 'TestVersion.jpg',
        VersionData = Blob.valueOf('Test Content'),
        IsMajorVersion = true
        );
        insert contentVersion1;

        ContentVersion contentVersion2 = [
            SELECT Id, Title, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :contentVersion1.Id
            LIMIT 1];

        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId
            FROM ContentDocument];

        ContentDocument oldContentDocument = documents[0];
        oldContentDocument.Id = documents[0].Id;

        ContentDocument newContentDocument = new ContentDocument();
        newContentDocument.Id = oldContentDocument.Id;

        Map<Id, ContentDocument> newContentDocumentMap = new Map<Id, ContentDocument>();
        newContentDocumentMap.put(newContentDocument.Id, newContentDocument);

        Map<Id, ContentDocument> oldContentDocumentMap = new Map<Id, ContentDocument>();
        oldContentDocumentMap.put(oldContentDocument.Id, oldContentDocument);

        Test.startTest();
            contentDocumentTrigger.afterUpdate(newContentDocumentMap, oldContentDocumentMap);
        Test.stopTest();

        System.assertEquals(documents.size(), 1);
        System.assertEquals(documents[0].Id, contentVersion2.ContentDocumentId);
        System.assertEquals(documents[0].LatestPublishedVersionId, contentVersion2.Id);
        System.assertEquals(documents[0].Title, contentVersion2.Title);
	}

    @isTest
    private static void beforeDelete() {

        Account Acc = TestUtility.generateAccount();
        Acc.Name = 'Test Account';

        insert Acc;

        ContentNote noteRecord = new ContentNote();
        noteRecord.Title   = 'Test Content Note - Account Object';
        String body        = 'Test Content Note - Account Object';
        noteRecord.Content = Blob.valueOf(body.escapeHTML4());
        insert noteRecord;

        ContentDocumentLink link = new ContentDocumentLink();
        link.ContentDocumentId   = noteRecord.id;
        link.LinkedEntityId      = Acc.Id;
        link.ShareType           = 'V';
        link.Visibility          = 'InternalUsers';
        insert link;

        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId, FileType
            FROM ContentDocument];

        try{
            delete documents[0];
            system.assert(true);
            }
        catch(DmlException e){
            System.Assert(e.getMessage().contains('Notes can not be deleted'));
        }
    }
}