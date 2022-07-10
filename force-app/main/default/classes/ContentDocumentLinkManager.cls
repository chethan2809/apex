public class ContentDocumentLinkManager
{
    public static ContentDocumentLinkDB contentDocumentLinkDBInstance = new ContentDocumentLinkDB();
    public static Map<Id, String> getContentDocumentLinkByParentIds(Set<Id> parentID)
    {
        List<ContentDocumentLink> contentDocument = contentDocumentLinkDBInstance.getContentDocumentLinkIDs(parentID);
        Map<Id, String> attachmentIdToFileName = new Map<Id, String>();
        for(ContentDocumentLink cdLink : contentDocument) {
            attachmentIdToFileName.put(cdLink.ContentDocument.LatestPublishedVersionID, cdLink.ContentDocument.Title);
        }
        return attachmentIdToFileName;
    }
}