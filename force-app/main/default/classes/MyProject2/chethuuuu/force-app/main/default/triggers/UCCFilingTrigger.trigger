trigger UCCFilingTrigger on UCC_Filing_Detail__c (
    before insert, after insert, before update, after update
) {
    if (Trigger.isInsert) {
        if (Trigger.isAfter) {
            //new UCCFilingTriggerHandler().afterInsert(Trigger.newMap);
        }
    }
}