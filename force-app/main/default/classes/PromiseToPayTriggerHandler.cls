public class PromiseToPayTriggerHandler {
    @TestVisible
    private static TaskDB taskDBInstance = new TaskDB();

    public void afterInsert(Map<Id, collect__Promise_To_Pay__c> newMap) {
        for(collect__Promise_To_Pay__c promiseToPay :newMap.values()) {
            if(promiseToPay.collect__Promise_Broken__c) {
                Task newTask = new Task();
                newTask.subject = System.Label.Collector_Task_Subject;
                newTask.WhatId = promiseToPay.Id;
                newTask.Collection_Contract__c = promiseToPay.collect__Dev_Contract__c;
                newTask.OwnerId = promiseToPay.OwnerId;
                newTask.Priority = 'Normal';
                newTask.Status = 'Open';
                taskDBInstance.addInsert(newTask);
            }
        }
        taskDBInstance.executeInserts();
    }

    public void afterUpdate(Map<Id, collect__Promise_To_Pay__c> newMap, Map<Id, collect__Promise_To_Pay__c> oldMap) {
        for(collect__Promise_To_Pay__c promiseToPay :newMap.values()) {
            if(promiseToPay.collect__Promise_Broken__c &&
                promiseToPay.collect__Promise_Broken__c != oldMap.get(promiseToPay.Id).collect__Promise_Broken__c) {
                Task newTask = new Task();
                newTask.subject = System.Label.Collector_Task_Subject;
                newTask.WhatId = promiseToPay.Id;
                newTask.Collection_Contract__c = promiseToPay.collect__Dev_Contract__c;
                newTask.OwnerId = promiseToPay.OwnerId;
                newTask.Priority = 'Normal';
                newTask.Status = 'Open';
                taskDBInstance.addInsert(newTask);
            }
        }
        taskDBInstance.executeInserts();
    }

    private class PromiseToPayTriggerHandlerException extends Exception {}
}