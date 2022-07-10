@IsTest(isParallel=true)
private class TaskTriggerHandlerTests {

    @isTest
    private static void afterInsertTests() {

        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        TaskManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);
        Task newTask = (Task) JSON.deserialize('{"AccountId" : "' + accountRecord.Id + '","TaskSubtype" : "' + Tasks.TASK_SUB_TYPE_CALL + '"}', Task.class);
        newTask.Id = TestUtility.getFakeId(Task.getSObjectType());
        newTask.Status = 'Completed';
        newTask.Activity_Outcome__c = Tasks.OUTCOME_OUT_OF_MARKET;
        newTask.WhatId = accountRecord.Id;

        Map<Id, Task> newTaskMap = new Map<Id, Task>();
        newTaskMap.put(newTask.Id, newTask);

        Test.startTest();
            new TaskTriggerHandler().afterInsert(newTaskMap);
        Test.stopTest();

        System.assertEquals(1, accountDBStubInstance.forUpdateSObjects.size());
        Account actualUpdatedAccount = (Account) accountDBStubInstance.forUpdateSObjects.get(0);

        System.assertEquals(accountRecord.Id, actualUpdatedAccount.Id);
        System.assertEquals(newTask.Activity_Outcome__c, actualUpdatedAccount.Most_Recent_Activity_Outcome__c);
    }


    @isTest
    private static void afterUpdateWhenOutcomeChange() {

        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        TaskManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Id modifiedTaskId = TestUtility.getFakeId(Task.getSObjectType());
        Task modifiedOldTask = new Task();
        modifiedOldTask.Id = modifiedTaskId;
        modifiedOldTask.Activity_Outcome__c = 'Email';

        Map<Id, Task> oldTaskMap = new Map<Id, Task>();
        oldTaskMap.put(modifiedOldTask.Id, modifiedOldTask);

        Task modifiedNewTask = (Task) JSON.deserialize('{"AccountId" : "' + accountRecord.Id + '","TaskSubtype" : "' + Tasks.TASK_SUB_TYPE_CALL + '"}', Task.class);
        modifiedNewTask.Id = modifiedTaskId;
        modifiedNewTask.Activity_Outcome__c = 'In Market';
        modifiedNewTask.WhatId = accountRecord.Id;
        Map<Id, Task> newTaskMap = new Map<Id, Task>();
        newTaskMap.put(modifiedNewTask.Id, modifiedNewTask);

        Task mostRecentTask = (Task) JSON.deserialize('{"AccountId" : "' + accountRecord.Id + '","TaskSubtype" : "' + Tasks.TASK_SUB_TYPE_CALL + '"}', Task.class);
        mostRecentTask.Id = TestUtility.getFakeId(Task.getSObjectType());
        mostRecentTask.Status = 'Completed';
        mostRecentTask.Activity_Outcome__c = Tasks.OUTCOME_OUT_OF_MARKET;
        mostRecentTask.WhatId = accountRecord.Id;

        DBManagerTestsStub taskDBStubInstance = new DBManagerTestsStub();
        taskDBStubInstance.genericReturnObject = new List<Task> {mostRecentTask, modifiedNewTask};
        TaskTriggerHandler.taskDBInstance = (TaskDB) Test.createStub(TaskDB.class, taskDBStubInstance);

        Test.startTest();
            new TaskTriggerHandler().afterUpdate(newTaskMap, oldTaskMap);
        Test.stopTest();

        System.assertEquals(1, accountDBStubInstance.forUpdateSObjects.size());
        Account actualUpdatedAccount = (Account) accountDBStubInstance.forUpdateSObjects.get(0);

        System.assertEquals(accountRecord.Id, actualUpdatedAccount.Id);
        System.assertNotEquals(modifiedNewTask.Activity_Outcome__c, actualUpdatedAccount.Most_Recent_Activity_Outcome__c);
        System.assertEquals(mostRecentTask.Activity_Outcome__c, actualUpdatedAccount.Most_Recent_Activity_Outcome__c);
    }

    @isTest
    private static void afterUpdateWhenCollectionActivityCompleted() {

        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        TaskManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        collect__Collection_Activity__c collectActivityRecord = new collect__Collection_Activity__c();
        collectActivityRecord.Id = TestUtility.getFakeId(collect__Collection_Activity__c.getSObjectType());

        DBManagerTestsStub collectActivityDBStubInstance = new DBManagerTestsStub();
        collectActivityDBStubInstance.genericReturnObject = new List<collect__Collection_Activity__c>{collectActivityRecord};
        TaskTriggerHandler.collectionActivityDBInstance = (CollectionActivityDB) Test.createStub(CollectionActivityDB.class, collectActivityDBStubInstance);

        DBManagerTestsStub emailTemplateDBStubInstance = new DBManagerTestsStub();
        emailTemplateDBStubInstance.genericReturnObject = new List<EmailTemplate>();
        TaskTriggerHandler.emailTemplateDBInstance = (EmailTemplateDB) Test.createStub(EmailTemplateDB.class, emailTemplateDBStubInstance);

        Id taskId = TestUtility.getFakeId(Task.getSObjectType());
        Task oldTask = new Task();
        oldTask.Id = taskId;
        oldTask.Status = 'New';
        oldTask.Activity_Outcome__c = 'Email';
        Map<Id, Task> oldTaskMap = new Map<Id, Task>();
        oldTaskMap.put(oldTask.Id, oldTask);

        Task newTask = new Task();
        newTask.Id = taskId;
        newTask.Status = 'Completed';
        newTask.WhatId = TestUtility.getFakeId(collect__Collection_Activity__c.getSObjectType());
        Map<Id, Task> newTaskMap = new Map<Id, Task>();
        newTaskMap.put(newTask.Id, newTask);

        DBManagerTestsStub taskDBStubInstance = new DBManagerTestsStub();
        taskDBStubInstance.genericReturnObject = new List<Task>{newTask};
        TaskTriggerHandler.taskDBInstance = (TaskDB) Test.createStub(TaskDB.class, taskDBStubInstance);

        Test.startTest();
            new TaskTriggerHandler().afterUpdate(newTaskMap, oldTaskMap);
        Test.stopTest();

        System.assertEquals(0, accountDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void beforeUpdateForUpdatingActivityOutcome() {
        Map<Id,Task> newTaskMap = new Map<Id,Task>();
        Map<Id,Task> oldTaskMap = new Map<Id,Task>();

        Task newTask = new Task();
        newTask.Id = TestUtility.getFakeId(Task.getSObjectType());
        newTask.CallDisposition = Tasks.ACTIVITY_OUTCOME_EMAIL;
        newTaskMap.put(newTask.Id, newTask);

        Task oldTask = new Task();
        oldTask.Id = newTask.Id;
        oldTask.CallDisposition = Tasks.ACTIVITY_OUTCOME_DO_NOT_CALL;
        oldTaskMap.put(oldTask.Id, oldTask);

        Test.startTest();
            new TaskTriggerHandler().beforeUpdate(newTaskMap, oldTaskMap);
        Test.stopTest();

        System.assertEquals(newTask.Activity_Outcome__c, Tasks.ACTIVITY_OUTCOME_EMAIL);
    }

}