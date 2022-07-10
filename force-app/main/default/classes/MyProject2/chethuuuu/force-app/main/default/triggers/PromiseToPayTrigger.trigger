trigger PromiseToPayTrigger on collect__Promise_To_Pay__c (after insert, after update) {
    if(CAN_General_Settings__c.getInstance().Disable_Promise_To_Pay_Trigger__c) {
        return;
    }
    if (Trigger.isInsert) {
        if (Trigger.isAfter) {
            new PromiseToPayTriggerHandler().afterInsert(Trigger.newMap);
        }
    }
    if (Trigger.isUpdate) {
        if (Trigger.isAfter) {
            new PromiseToPayTriggerHandler().afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}