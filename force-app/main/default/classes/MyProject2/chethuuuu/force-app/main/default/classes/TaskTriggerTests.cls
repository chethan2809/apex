@isTest
private class TaskTriggerTests {

    @isTest
    static void afterInsertTask() {
        Account accountRecord = new Account();
        accountRecord.Name = 'Activity Outcome pick list Test';
        insert accountRecord;

        Task task = new Task();
        task.Status = 'Completed';
        task.WhatId = accountRecord.Id;

        Exception ex;
        Test.startTest();
            try {
                insert task;
            } catch(Exception e) {
                ex = e;
            }
        Test.stopTest();

        TestUtility.assertNullException(ex);
        System.assert(task.Id != null);
    }


    @isTest
    static void afterUpdateDisableTriggerCheck() {

        CAN_General_Settings__c generalSetting = new CAN_General_Settings__c();
        generalSetting.Name='test';
        generalSetting.Disable_Task_Trigger__c = true;
        generalSetting.Late_fee_job_time__c = '21:00:00';
        CustomSettingsHelper.generalSettings = generalSetting;

        Task task = new Task();
        task.Subject = 'Test';
        task.Status = 'New';
        task.Priority = 'Normal';
        task.CallType = 'Outbound';
        insert task;
        task.Status = 'open';

        Exception ex;
        Test.startTest();
            try {
                update task;
            } catch(Exception e) {
                ex = e;
            }
        Test.stopTest();

        TestUtility.assertNullException(ex);

        Task actualTask = [SELECT Id, Status FROM TASK WHERE Id = :task.Id LIMIT 1];
        System.assertNotEquals('open', actualTask.Status);
    }

    @isTest
    static void afterUpdateTasks() {

        Account accountRecord = new Account();
        accountRecord.Name = 'Activity Outcome pick list Test';
        insert accountRecord;

        Task task = new Task();
        task.Subject = 'Test';
        task.Status = 'New';
        task.Priority = 'Normal';
        task.CallType = 'Outbound';
        insert task;

        task.Status = 'Completed';
        task.WhatId = accountRecord.id;

        Exception ex;
        Test.startTest();
            try {
                update task;
            } catch(Exception e) {
                ex = e;
            }
        Test.stopTest();
        TestUtility.assertNullException(ex);

        Task actualTask = [SELECT Id, Status FROM TASK WHERE Id = :task.Id LIMIT 1];
        System.assertEquals('Completed', actualTask.Status);
    }
}