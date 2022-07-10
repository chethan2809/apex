trigger UCCFilingDetailTrigger on UCC_Filing_Detail__c (after insert, before update) {
    if (Trigger.isInsert) {
        if (Trigger.isAfter) {
            new UCCFilingDetailTriggerHandler().afterInsert(Trigger.newMap);
        }
    }

    if (Trigger.isUpdate) {
        if (Trigger.isBefore) {
            new UCCFilingDetailTriggerHandler().beforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}