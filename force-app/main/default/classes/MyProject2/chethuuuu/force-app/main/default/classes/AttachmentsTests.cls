@isTest
private class AttachmentsTests {

    @isTest
    private static void createAttachment() {
        Blob bodyContent = Blob.valueOf('Dummy File Body');
        Id parentId = TestUtility.getFakeId(Account.getSObjectType());

        Test.startTest();
            Attachment actualAttachment = Attachments.createAttachment('Dummy Name', bodyContent, parentId);
        Test.stopTest();

        System.assert(actualAttachment != Null);
        System.assertEquals('Dummy Name', actualAttachment.Name);
        System.assertEquals(bodyContent, actualAttachment.Body);
        System.assertEquals(parentId, actualAttachment.parentId);
    }
}