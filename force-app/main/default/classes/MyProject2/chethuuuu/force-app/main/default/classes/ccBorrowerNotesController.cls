public class ccBorrowerNotesController {
    @TestVisible
    private static ContentDocumentLinkDB contentDocumentLinkDBInstance = new ContentDocumentLinkDB();

    @AuraEnabled(cacheable=true)
    public static List<ContentDocumentLink> getNotesByAccountIds(Id borrowerAccountId){
        return contentDocumentLinkDBInstance.getContentDocumentLinkIDs(new Set<Id> {borrowerAccountId});
    }
}