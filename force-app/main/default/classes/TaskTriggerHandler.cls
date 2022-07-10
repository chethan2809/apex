public class TaskTriggerHandler {

    @TestVisible
    private static EmailTemplateDB emailTemplateDBInstance = new EmailTemplateDB();
    @TestVisible
    private static CollectionActivityDB collectionActivityDBInstance = new CollectionActivityDB();
    @TestVisible
    private static TaskDB taskDBInstance = new TaskDB();

    public void afterInsert(Map<Id, Task> newTaskMap) {
        Map<Id, string> taskOutcomeByAccountId = new Map<Id, string>();

        for( Task newTask:newTaskMap.values()) {
            if (newTask.AccountId != null && newTask.Activity_Outcome__c != null && newTask.TaskSubtype == Tasks.TASK_SUB_TYPE_CALL) {
                taskOutcomeByAccountId.put(newTask.AccountId, newTask.Activity_Outcome__c);
            }
        }

        if (!taskOutcomeByAccountId.isEmpty()){
            TaskManager.setAccountOutcomeActivityFields(taskOutcomeByAccountId);
        }
    }

    public void afterUpdate(Map<Id, Task> newTaskMap, Map<Id, Task> oldTaskMap) {
        Set<Id> collectionActivityIds = new Set<Id>();
        Set<Id> completedTaskIds = new Set<Id>();
        Set<Id> outcomeTaskAccountIds = new Set<Id>();
        Set<Id> taskAndAccountIds = new Set<Id>();
        Map<Id, String> recentTaskOutcomeByAccountId = new Map<Id, String>();

        for(Task newTask : newTaskMap.values()) {
            Task oldTask = oldTaskMap.get(newTask.Id);
            if(newTask.Status != oldTask.Status && newTask.Status == 'Completed') {
                completedTaskIds.add(newTask.Id);
                taskAndAccountIds.add(newTask.Id);
            }

            if (newTask.Activity_Outcome__c != oldTask.Activity_Outcome__c && newTask.AccountId != null &&
                newTask.Activity_Outcome__c != null && newTask.TaskSubtype == Tasks.TASK_SUB_TYPE_CALL){
                outcomeTaskAccountIds.add(newTask.AccountId);
                taskAndAccountIds.add(newTask.Id);
            }
        }

        if (!taskAndAccountIds.isEmpty()) {
            for(Task newTask : taskDBInstance.getTasksByIds(taskAndAccountIds)) {
                if(completedTaskIds.contains(newTask.Id) && newTask.What.Type == 'collect__Collection_Activity__c') {
                    collectionActivityIds.add(newTask.WhatId);
                }
                if (outcomeTaskAccountIds.contains(newTask.AccountId) && !recentTaskOutcomeByAccountId.containsKey(newTask.AccountId)) {
                    recentTaskOutcomeByAccountId.put(newTask.AccountId, newTask.Activity_Outcome__c);
                }
            }
        }

        if (!recentTaskOutcomeByAccountId.isEmpty()) {
            TaskManager.setAccountOutcomeActivityFields(recentTaskOutcomeByAccountId);
        }

        if(!collectionActivityIds.isEmpty()) {
            List<collect__Collection_Activity__c> collectionActivityEmailList = collectionActivityDBInstance.getCollectionActivityOwnerDetails(collectionActivityIds);
            List<EmailTemplate> templates = emailTemplateDBInstance.getTemplatesByName(new Set<String>{Tasks.CASE_ESCALATION_ACTION_COMPLETED_NOTIFICATION});

            if(!collectionActivityEmailList.isEmpty() && !templates.isEmpty()) {
                TaskManager.sendTaskStatusEmailNotification(collectionActivityEmailList, templates.get(0));
            }
        }
    }

    public void beforeUpdate(Map<Id, Task> newTaskMap, Map<Id, Task> oldTaskMap) {
        for(Task newTask : newTaskMap.values()){
            Task oldTask = oldTaskMap.get(newTask.Id);
            if(newTask.CallDisposition != null && newTask.CallDisposition != oldTask.CallDisposition) {
                Tasks.setActivityOutcomeByCallDisposition(newTask);
            }
        }
    }
}