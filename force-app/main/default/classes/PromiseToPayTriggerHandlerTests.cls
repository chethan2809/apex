@isTest
private class PromiseToPayTriggerHandlerTests {

    private static PromiseToPayTriggerHandler promiseToPayTriggerHandlerInstance = new PromiseToPayTriggerHandler();

    @isTest
    private static void taskAfterInsert() {
        Id collContractId = TestUtility.getFakeId(collect__Loan_Account__c.getSObjectType());
        Id userId = TestUtility.getFakeId(User.getSObjectType());

        collect__Promise_To_Pay__c promiseToPay = new collect__Promise_To_Pay__c();
        promiseToPay.collect__Promise_Broken__c = true;
        promiseToPay.collect__Dev_Contract__c = collContractId;
        promiseToPay.OwnerId = userId;
        promiseToPay.Id = TestUtility.getFakeId(collect__Promise_To_Pay__c.getSObjectType());

        Map<Id, collect__Promise_To_Pay__c> newMap = new Map<Id, collect__Promise_To_Pay__c>();
        newMap.put(promiseToPay.Id, promiseToPay);

        DBManagerTestsStub taskDBStubInstance = new DBManagerTestsStub();
        PromiseToPayTriggerHandler.taskDBInstance = (TaskDB) Test.createStub(TaskDB.class, taskDBStubInstance);

        Test.startTest();
            promiseToPayTriggerHandlerInstance.afterInsert(newMap);
        Test.stopTest();

        System.assertEquals(1, taskDBStubInstance.forInsertSObjects.size());
        System.assertEquals(promiseToPay, newMap.get(promiseToPay.Id));
    }

    @isTest
    private static void taskAfterUpdate() {
        Id collContractId = TestUtility.getFakeId(collect__Loan_Account__c.getSObjectType());
        Id userId = TestUtility.getFakeId(User.getSObjectType());

        collect__Promise_To_Pay__c oldPromiseToPay = new collect__Promise_To_Pay__c();
        oldPromiseToPay.collect__Promise_Broken__c = false;
        oldPromiseToPay.Id = TestUtility.getFakeId(collect__Promise_To_Pay__c.getSObjectType());

        Map<Id, collect__Promise_To_Pay__c> oldMap = new Map<Id, collect__Promise_To_Pay__c>();
        oldMap.put(oldPromiseToPay.Id, oldPromiseToPay);

        collect__Promise_To_Pay__c promiseToPay = new collect__Promise_To_Pay__c();
        promiseToPay.collect__Promise_Broken__c = true;
        promiseToPay.collect__Dev_Contract__c = collContractId;
        promiseToPay.OwnerId = userId;
        promiseToPay.Id = oldPromiseToPay.Id;

        Map<Id, collect__Promise_To_Pay__c> newMap = new Map<Id, collect__Promise_To_Pay__c>();
        newMap.put(promiseToPay.Id, promiseToPay);

        DBManagerTestsStub taskDBStubInstance = new DBManagerTestsStub();
        PromiseToPayTriggerHandler.taskDBInstance = (TaskDB) Test.createStub(TaskDB.class, taskDBStubInstance);

        Test.startTest();
            promiseToPayTriggerHandlerInstance.afterUpdate(newMap, oldMap);
        Test.stopTest();

        System.assertEquals(1, taskDBStubInstance.forInsertSObjects.size());
        System.assertEquals(promiseToPay, newMap.get(promiseToPay.Id));
        System.assertEquals(oldPromiseToPay, oldMap.get(promiseToPay.Id));
    }
}