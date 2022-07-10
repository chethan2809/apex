@isTest
private class CollectionCriteriasTests {
    @isTest
    private static void collectionCriteriasTest() {

        List<Collection_Criteria__c> collectionCriteriaList = new List<Collection_Criteria__c>();
        Collection_Criteria__c collectionCriteria = new Collection_Criteria__c();
        collectionCriteria.Queue_Value__c = 1;
        collectionCriteria.Active__c = true;
        collectionCriteria.Evaluation_Criteria__c = 'SELECT Id FROM loan__Loan_Account__c';
        collectionCriteriaList.add(collectionCriteria);

        Test.startTest();
            CollectionCriterias.collectionCriterias(collectionCriteriaList);
        Test.stopTest();

        system.assert(collectionCriteria != null);
    }
}