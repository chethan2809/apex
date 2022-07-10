trigger CategoryAttachAssnTrigger on clcommon__Category_Attachment_Association__c (after insert, after update, before delete, after delete) {
    if (Trigger.isInsert) {
        if (Trigger.isAfter) {
            new CategoryAttachAssnTriggerHandler().afterInsert(Trigger.newMap);
        }
    }
    if (Trigger.isUpdate) {
        if (Trigger.isAfter) {
            new CategoryAttachAssnTriggerHandler().afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
    if (Trigger.isDelete) {
        if (Trigger.isBefore) {
            new CategoryAttachAssnTriggerHandler().beforeDelete(Trigger.old);
        }

        if (Trigger.isAfter) {
            new CategoryAttachAssnTriggerHandler().afterDelete(Trigger.old);
        }
    }
}