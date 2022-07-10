@isTest
private class ContentVersionsTests {

    @isTest
    private static void insertAttachmentToContentVersion() {
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = Blob.valueOf('TestColumnHeader');
        attachment.filename = 'attach1.bin';

        Test.startTest();
            ContentVersion actualContentVersion = ContentVersions.insertAttachmentToContentVersion(attachment);
        Test.stopTest();

        System.assertEquals(attachment.filename, actualContentVersion.Title);
        System.assertEquals(attachment.body, actualContentVersion.VersionData);
    }
}