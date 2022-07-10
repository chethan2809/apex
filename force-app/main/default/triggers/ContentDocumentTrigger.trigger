trigger ContentDocumentTrigger on ContentDocument (before delete, after update) {
    if (Trigger.isUpdate) {
            if (Trigger.isAfter) {
                new ContentDocumentTriggerHandler().afterUpdate(Trigger.newMap, Trigger.oldMap);
            }
        }
    
    if (Trigger.isDelete) {
            if (Trigger.isBefore) {
                new ContentDocumentTriggerHandler().beforeDelete(Trigger.oldMap);
            }
        }
    }