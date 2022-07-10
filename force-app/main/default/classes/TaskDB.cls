public class TaskDB extends DBManager {

    public List<Task> getIncompleteTasksByApplicationAndTaskIds(Set<Id> applicationIds, Set<Id> taskIds) {
        return [
            SELECT Id, genesis__Application__c, genesis__Application__r.Name, Subject, Status,
                Description, CreatedById, OwnerId, genesis__Department__c
            FROM Task
            WHERE genesis__Application__c IN :applicationIds
                AND Id IN :taskIds
                AND genesis__Department__c = null
            LIMIT 1
        ];
    }

    public List<Task> getTasksByIds(Set<Id> taskIds) {
        return [
            SELECT Id, WhatId, What.Type, AccountId, Activity_Outcome__c
            FROM Task
            WHERE Id IN :taskIds
            ORDER BY CreatedDate DESC
        ];
    }

    public List<Task> getTasksByPTPIds(Set<Id> ptpIds) {
        return [
            SELECT Subject, Priority, Status, CreatedDate
            FROM Task
            WHERE Id IN :ptpIds
        ];
    }

    public List<Task> getAllTasksByIdsORAccountIds (Set<Id> taskAndAccountIds) {
        return [
            SELECT Id
            FROM Task
            WHERE Id IN :taskAndAccountIds OR AccountId IN :taskAndAccountIds
            ORDER BY CreatedDate DESC
        ];
    }

}