@isTest
private class CollectionCriteriaDBTests {
    private static CollectionCriteriaDB collectionCriteriaDBInstance = new CollectionCriteriaDB();

    @TestSetup
    static void makeData() {
        Collection_Criteria__c collectionCriteria = new Collection_Criteria__c();
        collectionCriteria.Queue_Value__c = 1;
        collectionCriteria.Active__c = true;
        collectionCriteria.Evaluation_Criteria__c = 'SELECT Id FROM loan__Loan_Account__c';
        insert collectionCriteria;
    }

    @isTest
    private static void getCollectionCriteriaAndQueueValueTest() {
        Test.startTest();
            List<Collection_Criteria__c> collectionCriteriaList = collectionCriteriaDBInstance.getCollectionCriteriaAndQueueValue();
        Test.stopTest();

        System.assert(!collectionCriteriaList.isEmpty());
    }

    @isTest
    private static void getExistingCollectionCriteriaTest() {
        Test.startTest();
            List<Collection_Criteria__c> collectionCriteriaList =
                collectionCriteriaDBInstance.getExistingCollectionCriteria();
        Test.stopTest();

        System.assert(!collectionCriteriaList.isEmpty());
    }
}