@isTest
private class CollectionActivityTriggerHandlerTests {

    private static CollectionActivityTriggerHandler collectionActivityTriggerHandlerInstance = new CollectionActivityTriggerHandler();

    @isTest
    private static void afterUpdate() {
        collect__Collection_Activity__c oldCollActivity = new collect__Collection_Activity__c();
        oldCollActivity.Id = TestUtility.getFakeId(collect__Collection_Activity__c.getSObjectType());
        oldCollActivity.Supervisor__c = false;

        Map<Id, collect__Collection_Activity__c> oldCollActivityMap = new Map<Id, collect__Collection_Activity__c>();
        oldCollActivityMap.put(oldCollActivity.Id, oldCollActivity);

        collect__Collection_Activity__c newCollActivity = new collect__Collection_Activity__c();
        newCollActivity.Id = oldCollActivity.Id;
        newCollActivity.Supervisor__c = true;
        newCollActivity.collect__Account_Manager__c = TestUtility.getFakeId(Contact.getSObjectType());

        Map<Id, collect__Collection_Activity__c> newCollActivityMap = new Map<Id, collect__Collection_Activity__c>();
        newCollActivityMap.put(newCollActivity.Id, newCollActivity);

        DBManagerTestsStub taskDBStubInstance = new DBManagerTestsStub();
        CollectionActivityTriggerHandler.taskDBInstance = (TaskDB) Test.createStub(TaskDB.class, taskDBStubInstance);

        Test.startTest();
            collectionActivityTriggerHandlerInstance.afterUpdate(newCollActivityMap, oldCollActivityMap);
        Test.stopTest();

        System.assertEquals(1, taskDBStubInstance.forInsertSObjects.size());
        System.assertEquals(newCollActivity.Id, ((Task)taskDBStubInstance.forInsertSObjects.get(0)).WhatId);
    }

    @isTest
    private static void afterInsert() {
        collect__Collection_Activity__c newCollActivity = new collect__Collection_Activity__c();
        newCollActivity.Id = TestUtility.getFakeId(collect__Collection_Activity__c.getSObjectType());
        newCollActivity.Supervisor__c = true;
        newCollActivity.collect__Account_Manager__c = TestUtility.getFakeId(Contact.getSObjectType());

        Map<Id, collect__Collection_Activity__c> newCollActivityMap = new Map<Id, collect__Collection_Activity__c>();
        newCollActivityMap.put(newCollActivity.Id, newCollActivity);

        DBManagerTestsStub taskDBStubInstance = new DBManagerTestsStub();
        CollectionActivityTriggerHandler.taskDBInstance = (TaskDB) Test.createStub(TaskDB.class, taskDBStubInstance);

        Test.startTest();
            collectionActivityTriggerHandlerInstance.afterInsert(newCollActivityMap);
        Test.stopTest();

        System.assertEquals(1, taskDBStubInstance.forInsertSObjects.size());
        System.assertEquals(newCollActivity.Id, ((Task)taskDBStubInstance.forInsertSObjects.get(0)).WhatId);
    }
}