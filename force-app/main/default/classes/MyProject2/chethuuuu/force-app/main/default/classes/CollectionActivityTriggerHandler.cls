public class CollectionActivityTriggerHandler {
    @TestVisible
    private static TaskDB taskDBInstance = new TaskDB();

    public void afterUpdate(Map<Id, collect__Collection_Activity__c> newMap, Map<Id, collect__Collection_Activity__c> oldMap) {
        List<Task> taskList = new List<Task>();
        for(collect__Collection_Activity__c collectionActivity :newMap.values()) {
            if(collectionActivity.Supervisor__c && collectionActivity.Supervisor__c != oldMap.get(collectionActivity.Id).Supervisor__c) {
                Task newTask = Tasks.createTask(collectionActivity);
                taskList.add(newTask);
                taskDBInstance.addInsert(newTask);
            }
        }
        taskDBInstance.executeInserts();
    }
    public void afterInsert(Map<Id, collect__Collection_Activity__c> newMap) {
        List<Task> taskList = new List<Task>();
        for(collect__Collection_Activity__c collectionActivity :newMap.values()) {
            if(collectionActivity.Supervisor__c) {
                Task newTask = Tasks.createTask(collectionActivity);
                taskList.add(newTask);
                taskDBInstance.addInsert(newTask);
            }
        }
        taskDBInstance.executeInserts();
    }
}