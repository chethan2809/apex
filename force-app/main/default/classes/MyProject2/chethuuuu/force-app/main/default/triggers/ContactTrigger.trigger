trigger ContactTrigger on Contact (before insert, before update) {
    if (Trigger.isInsert) {
        if(Trigger.isBefore) {
            new ContactTriggerHandler().beforeInsert(Trigger.new);
        }
    }
    if (Trigger.isUpdate) {
        if(Trigger.isBefore) {
            new ContactTriggerHandler().beforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}