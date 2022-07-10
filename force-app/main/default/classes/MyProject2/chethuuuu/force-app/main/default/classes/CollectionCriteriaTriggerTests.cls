@isTest
private class CollectionCriteriaTriggerTests {
    @isTest
    private static void collectionCriteriaTriggerTest() {
        Collection_Criteria__c collectionCriteria = new Collection_Criteria__c();
        collectionCriteria.Queue_Value__c = 1;
        collectionCriteria.Active__c = true;
        collectionCriteria.Evaluation_Criteria__c = 'SELECT Id FROM loan__Loan_Account__c';
        Test.startTest();
            insert collectionCriteria;
        Test.stopTest();

        system.assert(collectionCriteria != null);
    }

    @isTest
    private static void collectionCriteriaTriggerUpdateTest() {
        Collection_Criteria__c collectionCriteria = new Collection_Criteria__c();
        collectionCriteria.Queue_Value__c = 1;
        collectionCriteria.Active__c = true;
        collectionCriteria.Evaluation_Criteria__c = 'SELECT Id FROM loan__Loan_Account__c';
        insert collectionCriteria;

        Collection_Criteria__c criteria = new Collection_Criteria__c();
        criteria.Id = collectionCriteria.Id;
        criteria.Queue_Value__c = 2;
        criteria.Active__c = true;

        Test.startTest();
            update criteria;
        Test.stopTest();

        system.assert(criteria != null);
    }
}