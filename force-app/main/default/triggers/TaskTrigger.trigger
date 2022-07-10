trigger TaskTrigger on Task (after insert, after update, before update) {
    if(CustomSettingsHelper.generalSettings.Disable_Task_Trigger__c) {
        return;
    }
    if (Trigger.isInsert) {
        if (Trigger.isAfter) {
            new TaskTriggerHandler().afterInsert(Trigger.newMap);
        }
    }
    if (Trigger.isUpdate) {
        if (Trigger.isBefore) {
            new TaskTriggerHandler().beforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
        if (Trigger.isAfter) {
            new TaskTriggerHandler().afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}