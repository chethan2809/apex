public class CollectionCriteriaDB {
    public List<Collection_Criteria__c> getCollectionCriteriaAndQueueValue() {
        return [
            SELECT Id, Evaluation_Criteria__c, Queue_Value__c
                FROM Collection_Criteria__c
                WHERE Active__c = true
                ORDER BY LastModifiedDate DESC
                LIMIT 1
        ];
    }

    public List<Collection_Criteria__c> getExistingCollectionCriteria() {
        return [
            SELECT Id
            FROM Collection_Criteria__c
            WHERE Active__c = true
        ];
    }
}