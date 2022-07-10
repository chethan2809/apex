trigger InteractionLogTrigger on Interaction_Log__c (before insert, after insert, before update, after update) {
    if (Trigger.isInsert) {
        if (Trigger.isBefore) {
            new InteractionLogTriggerHandler().beforeInsert(Trigger.new);
        }
        if (Trigger.isAfter) {
            new InteractionLogTriggerHandler().afterInsert(Trigger.newMap);
        }
    }

    if (Trigger.isUpdate) {
        if (Trigger.isBefore) {
            new InteractionLogTriggerHandler().beforeUpdate(Trigger.new);
        }
        if (Trigger.isAfter) {
            new InteractionLogTriggerHandler().afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}