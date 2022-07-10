public class UCCFilingAttachments {
    public static UCC_Filing_Attachment__c createUCCFilingAttachments(UCC_Filing_Detail__c uccFiling, String attachmentID, String description) {
        UCC_Filing_Attachment__c uccFilingAttachment = new UCC_Filing_Attachment__c();
        uccFilingAttachment.UCC_Filing_Detail__c = uccFiling.Id;
        uccFilingAttachment.UCC_Attachment_ID__c = attachmentID;
        uccFilingAttachment.Description__c = description;
        uccFilingAttachment.Account__c = uccFiling.Account__c;
        return uccFilingAttachment;
    }
}