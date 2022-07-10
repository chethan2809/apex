trigger CollectionCaseTrigger on Collection_Case__c (after insert, before update, after update) {

    if (Trigger.isInsert) {
        if (Trigger.isAfter) {
            new CollectionCaseTriggerHandler().afterInsert(Trigger.newMap);
        }
    }

    if (Trigger.isUpdate) {
        if (Trigger.isBefore) {
            new CollectionCaseTriggerHandler().beforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }

    if (Trigger.isUpdate) {
        if (Trigger.isAfter) {
            new CollectionCaseTriggerHandler().afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}