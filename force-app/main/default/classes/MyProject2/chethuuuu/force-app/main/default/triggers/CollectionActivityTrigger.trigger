trigger CollectionActivityTrigger on collect__Collection_Activity__c (after insert, after update) {
    if(CAN_General_Settings__c.getInstance().Disable_Collection_Activity_Trigger__c) {
        return;
    }

    if (Trigger.isInsert) {
        if(Trigger.isAfter) {
            new CollectionActivityTriggerHandler().afterInsert(Trigger.newMap);
        }
    }

    if (Trigger.isUpdate) {
        if(Trigger.isAfter) {
            new CollectionActivityTriggerHandler().afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }

}