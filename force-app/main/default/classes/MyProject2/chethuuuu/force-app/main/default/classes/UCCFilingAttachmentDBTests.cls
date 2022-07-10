@IsTest(isParallel=true)
private class UCCFilingAttachmentDBTests {

    private static UCCFilingAttachmentDB uccFilingAttachmentDBInstance = new UCCFilingAttachmentDB();

    @isTest
    private static void getUCCFilingAttachmentsByIDs() {

        UCC_Filing_Attachment__c uccAttachment =  new UCC_Filing_Attachment__c();
        uccAttachment.Id = TestUtility.getFakeId(UCC_Filing_Attachment__c.getSObjectType());

        Set<Id> uccAttachmentIDs = new Set<Id>();
        uccAttachmentIDs.add(uccAttachment.Id);

        Test.startTest();
            List<UCC_Filing_Attachment__c> uccAttachmentList = uccFilingAttachmentDBInstance.getUCCFilingAttachmentsByIDs(uccAttachmentIDs);
        Test.stopTest();

        System.assert(uccAttachmentList != null);
    }

    @isTest
    private static void getUCCFilingAttachmentsByUCCFilingIDs() {
        Id uccFilingId = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        Set<Id> uccFilingIds = new Set<Id>();
        uccFilingIds.add(uccFilingId);

        Test.startTest();
        List<UCC_Filing_Attachment__c> uccAttachmentList = uccFilingAttachmentDBInstance.getUCCFilingAttachmentsByIDs(uccFilingIds);
        Test.stopTest();

        System.assert(uccAttachmentList != null);
        System.assert(uccAttachmentList.isEmpty());
    }
}