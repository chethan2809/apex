trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert) {
    if (Trigger.isInsert) {
        if (Trigger.isAfter) {
            new ContentDocumentLinkTriggerHandler().afterInsert(Trigger.newMap);
        }
    }
}