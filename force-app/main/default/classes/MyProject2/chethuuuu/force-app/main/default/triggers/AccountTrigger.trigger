trigger AccountTrigger on Account (before insert, after insert, before update, after update) {
    if (Trigger.isInsert) {
        if (Trigger.isBefore) {
            new AccountTriggerHandler().beforeInsert(Trigger.new);
        }
    }
    if (Trigger.isInsert) {
        if (Trigger.isAfter) {
            new AccountTriggerHandler().afterInsert(Trigger.newMap);
        }
    }
    if (Trigger.isUpdate) {
        if(Trigger.isBefore) {
            new AccountTriggerHandler().beforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
    if (Trigger.isUpdate) {
        if(Trigger.isAfter) {
            new AccountTriggerHandler().afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}