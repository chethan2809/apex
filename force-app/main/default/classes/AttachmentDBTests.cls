@isTest
private class AttachmentDBTests {

    private static AttachmentDB attachmentDBInstance = new AttachmentDB();

    @isTest
    private static void getAllAttachmentsByIds() {
        Id attachmentId = TestUtility.getFakeId(Attachment.getSObjectType());
        Set<Id> attachmentIds = new Set<Id>();
        attachmentIds.add(attachmentId);

        Test.startTest();
            List<Attachment> attachmentList = attachmentDBInstance.getAllAttachmentsByIds(attachmentIds);
        Test.stopTest();

        System.assert(attachmentList != null);
        System.assert(attachmentList.isEmpty());
    }

    @isTest
    private static void getAllAttachmentsByParentIdAndDescription() {
        Id attachmentId = TestUtility.getFakeId(Attachment.getSObjectType());

        Test.startTest();
            List<Attachment> attachmentList = attachmentDBInstance.getAllAttachmentsByParentIdAndDescription(attachmentId, attachmentId);
        Test.stopTest();

        System.assert(attachmentList != null);
        System.assert(attachmentList.isEmpty());
    }
}