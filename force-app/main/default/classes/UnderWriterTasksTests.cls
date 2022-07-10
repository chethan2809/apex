@isTest
private class UnderWriterTasksTests {

    @isTest
    private static void createUnderWriterTask() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        Test.startTest();
            UnderWriter_Task__c taskDetail = UnderWriterTasks.createUnderWriterTask(applicationId, 'Test Task', 'Test Category', 1);
        Test.stopTest();

        System.assert(taskDetail != null);
        System.assertEquals(applicationId, taskDetail.Application__c);
        System.assertEquals('Test Task', taskDetail.Task_Name__c);
        System.assertEquals('Test Category', taskDetail.Category__c);
        System.assertEquals(1, taskDetail.Order__c);
    }
}