@isTest(isParallel=true)
private class TaskDBTests {

    private static TaskDB taskDBInstance = new TaskDB();

    @isTest
    private static void getIncompleteTasksByApplicationAndTaskIds() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(applicationId);

        Id taskId = TestUtility.getFakeId(Task.getSObjectType());
        Set<Id> taskIds = new Set<Id>();
        taskIds.add(taskId);

        Test.startTest();
            List<Task> taskList = taskDBInstance.getIncompleteTasksByApplicationAndTaskIds(applicationIds, taskIds);
        Test.stopTest();

        System.assert(taskList != null);
        System.assert(taskList.isEmpty());
    }

    @isTest
    private static void getTasksByIds() {
        Id taskId = TestUtility.getFakeId(Task.getSObjectType());
        Set<Id> taskIds = new Set<Id>();
        taskIds.add(taskId);

        Test.startTest();
            List<Task> taskList = taskDBInstance.getTasksByIds(taskIds);
        Test.stopTest();

        System.assert(taskList != null);
        System.assert(taskList.isEmpty());
    }

    @isTest
    private static void getTasksByPTPIds() {
        Id taskId = TestUtility.getFakeId(Task.getSObjectType());
        Set<Id> ptpIds = new Set<Id>();
        PTPIds.add(taskId);

        Test.startTest();
            List<Task> taskList = taskDBInstance.getTasksByPTPIds(ptpIds);
        Test.stopTest();

        System.assert(taskList != null);
        System.assert(taskList.isEmpty());
    }

    @isTest
    private static void getAllTasksByIdsORAccountIds() {
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id taskId = TestUtility.getFakeId(Task.getSObjectType());

        Set<Id> taskAndAccountIds = new Set<Id> {taskId, accountId};
        taskAndAccountIds.add(taskId);

        Test.startTest();
            List<Task> taskList = taskDBInstance.getAllTasksByIdsORAccountIds(taskAndAccountIds);
        Test.stopTest();

        System.assert(taskList != null);
        System.assert(taskList.isEmpty());
    }
}