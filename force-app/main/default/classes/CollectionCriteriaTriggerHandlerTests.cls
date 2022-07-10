@isTest
private class CollectionCriteriaTriggerHandlerTests {
    @isTest
    private static void collectionCriteriaTriggerHandlerBeforeInsert() {
        List<Collection_Criteria__c> collectionCriteriaList = new List<Collection_Criteria__c>();
        Collection_Criteria__c collectionCriteria = new Collection_Criteria__c();
        collectionCriteria.Queue_Value__c = 1;
        collectionCriteria.Active__c = true;
        collectionCriteria.Evaluation_Criteria__c = 'SELECT Id FROM Collection_Criteria__c';
        collectionCriteriaList.add(collectionCriteria);

        Test.startTest();
            new CollectionCriteriaTriggerHandler().beforeInsert(collectionCriteriaList);
        Test.stopTest();

        system.assert(collectionCriteria != null);
    }

    @isTest
    private static void collectionCriteriaTriggerHandlerBeforeUpdate() {
        List<Collection_Criteria__c> collectionCriteriaList = new List<Collection_Criteria__c>();
        Collection_Criteria__c collectionCriteria = new Collection_Criteria__c();
        collectionCriteria.Queue_Value__c = 1;
        collectionCriteria.Active__c = true;
        collectionCriteria.Evaluation_Criteria__c = 'SELECT Id FROM Collection_Criteria__c';
        collectionCriteriaList.add(collectionCriteria);

        Test.startTest();
            new CollectionCriteriaTriggerHandler().beforeUpdate(collectionCriteriaList);
        Test.stopTest();

        system.assert(collectionCriteria != null);
    }
}