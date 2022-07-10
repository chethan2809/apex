public class CongaSignDocumentDB extends DBManager {
    public List<APXT_CongaSign__Document__c> getFinalSignDocumentsIds(Set<Id> congaSignDocumentIds)
    {
        return [
            SELECT Id, Name, APXT_CongaSign__ContentVersionId__c, APXT_CongaSign__Transaction__r.Parent_a6t__c,
                APXT_CongaSign__Transaction__r.Parent_aEH__c
            FROM APXT_CongaSign__Document__c
            WHERE Id In : congaSignDocumentIds
                AND (APXT_CongaSign__Transaction__r.Parent_a6t__c != null
                    OR APXT_CongaSign__Transaction__r.Parent_aEH__c != null)
        ];
    }
}