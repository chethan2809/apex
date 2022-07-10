@isTest
private class CollectionCaseTriggerTests {
    @isTest
    private static void collectionCaseTriggerTests() {

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        CollectionCaseTriggerHandler.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        CollectionCaseDB collectionCaseDBInstance = new CollectionCaseDB();

        Test.startTest();
            Account account = TestUtility.createAccount();
            Collection_Case__c collectionCase = new Collection_Case__c();
            collectionCase.Contract_Number__c = 'LAI0000001';
            collectionCase.Account__c = account.Id;
            collectionCaseDBInstance.addInsert(collectionCase);
            collectionCaseDBInstance.executeInserts();

            Collection_Case__c collection = new Collection_Case__c();
            collection.Id = collectionCase.Id;
            collection.Collections_status__c = 'Bad Standing';
            collectionCaseDBInstance.addUpdate(collection);
            collectionCaseDBInstance.executeUpdates();
        Test.stopTest();

        system.assert(collectionCase != null);
    }
}