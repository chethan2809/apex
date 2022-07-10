public class UnderWriterTaskDB extends DBManager {
    public List<UnderWriter_Task__c> getUnderWriterTaskByApplicationIdsAndTaskNames(Set<Id> applicationIds, Set<String> taskNames) {
        return [
            SELECT Id, Task_Name__c, Verification_Type__c, Application__c
            FROM UnderWriter_Task__c
            WHERE Application__c IN :applicationIds
                AND Task_Name__c IN :taskNames
        ];
    }
}