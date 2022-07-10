public class ContentDocumentLinkTriggerHandler {
    @TestVisible
    private static CustomContentDocumentLinkDB customeContentDocumentLinkDBInstance = new CustomContentDocumentLinkDB();

    public void afterInsert(Map<Id, ContentDocumentLink> newContentDocumentLinkMap) {
        for (ContentDocumentLink contentDocumentLink : newContentDocumentLinkMap.values()) {
            CustomContentDocumentLink__c customContentDocumentLinkRecord = new CustomContentDocumentLink__c();
            customContentDocumentLinkRecord.ContentDocumentId__c = contentDocumentLink.ContentDocumentId;
            customContentDocumentLinkRecord.LinkedEntityId__c = contentDocumentLink.LinkedEntityId;
            customeContentDocumentLinkDBInstance.addInsert(customContentDocumentLinkRecord);

        }
        customeContentDocumentLinkDBInstance.executeInserts();
    }

    private class ContentDocumentLinkTriggerHandlerException extends Exception {}
}