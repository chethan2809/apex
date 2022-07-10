public class CollectionActivityDB extends DBManager {
    public List<collect__Collection_Activity__c> getCollectionActivityOwnerDetails(Set<Id> collectionActivityIds) {
        return [
            SELECT Id, collect__Account_Manager__r.Name, collect__Dev_Contract__r.Owner.Email, collect__Dev_Contract__r.Owner.Name
            FROM collect__Collection_Activity__c
            WHERE Id IN :collectionActivityIds
        ];
    }
}