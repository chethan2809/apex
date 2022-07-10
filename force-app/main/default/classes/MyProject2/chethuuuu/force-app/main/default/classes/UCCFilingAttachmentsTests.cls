@IsTest(isParallel=true)
private class UCCFilingAttachmentsTests {
    @IsTest
    private static void createUCCFilingAttachments() {
        Id AccountId = TestUtility.getFakeId(Account.getSObjectType());
        UCC_Filing_Detail__c uccFiling =  new UCC_Filing_Detail__c();
        uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        uccFiling.Account__c = AccountId;

        String attachmentId = '123456';
        String description = 'UCC Filing Acknowledgment';

        Test.startTest();
            UCC_Filing_Attachment__c uccFilingAttachment = UCCFilingAttachments.createUCCFilingAttachments(uccFiling, attachmentId, description);
        Test.stopTest();

        System.assert(uccFilingAttachment != null);
        System.assertEquals(AccountId, uccFilingAttachment.Account__c);
        System.assertEquals(attachmentId, uccFilingAttachment.UCC_Attachment_ID__c);
        System.assertEquals(description, uccFilingAttachment.Description__c);
        System.assertEquals(uccFiling.Id, uccFilingAttachment.UCC_Filing_Detail__c);
    }
}