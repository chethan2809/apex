public class UCCFilingAttachmentDB extends DBManager {
    public List<UCC_Filing_Attachment__c> getUCCFilingAttachmentsByUCCFilingIDs (Set<Id> uccFilingIDs) {
        return [
            SELECT Id, UCC_Filing_Detail__c, UCC_Attachment_ID__c, Description__c
            FROM UCC_Filing_Attachment__c
            WHERE UCC_Filing_Detail__c IN :uccFilingIDs
        ];
    }

    public List<UCC_Filing_Attachment__c> getUCCFilingAttachmentsByIDs (Set<Id> uccAttachmentIDs) {
        return [
            SELECT Id, UCC_Filing_Detail__c, UCC_Attachment_ID__c, Description__c, Account__c, Account__r.Name, Wasabi_Link__c
            FROM UCC_Filing_Attachment__c
            WHERE Id IN :uccAttachmentIDs
        ];
    }
}