public class CollectionCriteriaTriggerHandler {
    public void beforeInsert(List<Collection_Criteria__c> triggerNew) {
        CollectionCriterias.beforeInsertCollectionCriteria(triggerNew);
        CollectionCriterias.collectionCriterias(triggerNew);
    }
    public void beforeUpdate(List<Collection_Criteria__c> triggerNew) {
        CollectionCriterias.collectionCriterias(triggerNew);
    }
}