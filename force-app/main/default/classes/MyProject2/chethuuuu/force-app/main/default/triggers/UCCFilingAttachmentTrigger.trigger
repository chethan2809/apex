trigger UCCFilingAttachmentTrigger on UCC_Filing_Attachment__c (before insert, after insert, before update, after update) {
    if (Trigger.isUpdate) {
        if (Trigger.isAfter) {
            //new UCCFilingAttachmentTriggerHandler().afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}