trigger CaseTrigger on Case (after update, after insert) {
    if (Trigger.isUpdate) {
        if(Trigger.isAfter) {
            new CaseTriggerHandler().afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}