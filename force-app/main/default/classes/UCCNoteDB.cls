public class UCCNoteDB extends DBManager {
    public List<UCC_Notes__c> getUCCNotsByUCCFilingIDs(Set<Id> uccFilingIDs) {
        return [
            SELECT Id, UCC_Filing_Detail__c, Description__c
            FROM UCC_Notes__c
            WHERE UCC_Filing_Detail__c IN :uccFilingIDs
        ];
    }
}