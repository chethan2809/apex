trigger PartyTrigger on clcommon__Party__c (after insert, before update, after update, after delete) {
    if (Trigger.isUpdate) {
        if(Trigger.isBefore) {
            //new PartyTriggerHandler().beforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
        if(Trigger.isAfter) {
            //new PartyTriggerHandler().afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
    if (Trigger.isInsert) {
        if(Trigger.isAfter) {
            //new PartyTriggerHandler().afterInsert(Trigger.new);
        }
    }
    if (Trigger.isDelete) {
        if(Trigger.isAfter) {
            //new PartyTriggerHandler().afterDelete(Trigger.old);
        }
    }
}