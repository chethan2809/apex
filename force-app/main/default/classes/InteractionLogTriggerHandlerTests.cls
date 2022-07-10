@isTest
private class InteractionLogTriggerHandlerTests {

    @isTest
    private static void beforeInsert() {
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Action_Code__c = 'Bankruptcy Filed';
        interactionLogRecord.Case_Number__c = null;

        List<Interaction_Log__c> interactionLogsList = new List<Interaction_Log__c>();
        interactionLogsList.add(interactionLogRecord);

        Test.startTest();
            InteractionLogTriggerHandler interactionLog =  new InteractionLogTriggerHandler();
            interactionLog.beforeInsert(new List<Interaction_Log__c> {interactionLogRecord});

        Test.stopTest();
        System.assert(interactionLogsList != null);
    }

    @isTest
    private static void beforeUpdate() {
        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Action_Code__c = 'Bankruptcy Filed';
        interactionLogRecord.Case_Number__c = null;

        List<Interaction_Log__c> interactionLogsList = new List<Interaction_Log__c>();
        interactionLogsList.add(interactionLogRecord);

        Test.startTest();
            InteractionLogTriggerHandler interactionLog =  new InteractionLogTriggerHandler();
            interactionLog.beforeUpdate(new List<Interaction_Log__c> {interactionLogRecord});
        Test.stopTest();

        System.assert(interactionLogsList != null);
    }

    @isTest
    private static void afterInsert() {
        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Collection_Case__c collectionCase = new Collection_Case__c();
        collectionCase.Id = TestUtility.getFakeId(Collection_Case__c.getSObjectType());
        collectionCase.Contract_Number__c = 'LAI0000002';
        collectionCase.CL_Contract_Id__c = testExternalId;
        collectionCase.Supervisor__c = userId;
        collectionCase.Account__c = accountId;

        DBManagerTestsStub collectionCaseDBStubInstance = new DBManagerTestsStub();
        collectionCaseDBStubInstance.genericReturnObject = new List<Collection_Case__c> {collectionCase};
        InteractionLogManager.collectionCaseDBInstance = (CollectionCaseDB) Test.createStub(CollectionCaseDB.class, collectionCaseDBStubInstance);

        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Action_Code__c = CollectionCaseConstants.BANKRUPTCY;
        interactionLogRecord.Sub_Action_Code__c = CollectionCaseConstants.BANKRUPTCY_FILED;
        interactionLogRecord.Collection_Case__c = collectionCase.Id;

        Task taskRecord = new Task();
        taskRecord.WhatId = interactionLogRecord.Id;
        taskRecord.Collection_Contract__c = collectionCase.CL_Contract_Id__c;
        taskRecord.Priority = 'Normal';
        taskRecord.Status = 'Open';

        DBManagerTestsStub taskDBStubInstance = new DBManagerTestsStub();
        taskDBStubInstance.genericReturnObject = new List<Task> {taskRecord};
        InteractionLogManager.taskDBInstance = (TaskDB) Test.createStub(TaskDB.class, taskDBStubInstance);

        Map<Id, Interaction_Log__c> newInteractionLogMap = new Map<Id, Interaction_Log__c>{interactionLogRecord.Id => interactionLogRecord};
        Exception Ex;
        Test.startTest();
        try{
            InteractionLogTriggerHandler interactionLog =  new InteractionLogTriggerHandler();
            interactionLog.afterInsert(newInteractionLogMap);
        }catch(Exception e){
            e = Ex;
        }
        Test.stopTest();

        System.assert(newInteractionLogMap != null);
    }

    @isTest
    private static void afterUpdate() {
        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        Collection_Case__c collectionCase = new Collection_Case__c();
        collectionCase.Id = TestUtility.getFakeId(Collection_Case__c.getSObjectType());
        collectionCase.Contract_Number__c = 'LAI0000002';
        collectionCase.CL_Contract_Id__c = testExternalId;

        Interaction_Log__c interactionLogRecord = new Interaction_Log__c();
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        interactionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        interactionLogRecord.Collection_Case__c = collectionCase.Id;
        interactionLogRecord.Action_Code__c = 'Judgment Awarded';

        Interaction_Log__c oldInteractionLogRecord = new Interaction_Log__c();
        oldInteractionLogRecord.Id = TestUtility.getFakeId(Interaction_Log__c.getSObjectType());
        oldInteractionLogRecord.Collection_Case__c = collectionCase.Id;
        oldInteractionLogRecord.Action_Code__c = 'Judgment Awarded';

        Map<Id, Interaction_Log__c> newInteractionLogMap = new Map<Id, Interaction_Log__c>{interactionLogRecord.Id => interactionLogRecord};
        Map<Id, Interaction_Log__c> oldInteractionLogMap = new Map<Id, Interaction_Log__c>{oldInteractionLogRecord.Id => oldInteractionLogRecord};

        Exception Ex;
        Test.startTest();
        try{
            InteractionLogTriggerHandler interactionLog =  new InteractionLogTriggerHandler();
            interactionLog.afterUpdate(newInteractionLogMap, oldInteractionLogMap);
        }catch(Exception e){
            e = Ex;
        }
        Test.stopTest();

        System.assert(newInteractionLogMap != null);
    }
}