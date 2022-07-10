public class ContentDocumentLinkDB extends DBManager
{
    public List<ContentDocumentLink> getContentDocumentLinkIDs(Set<Id> Ids)
    {
        return [
            SELECT Id, ContentDocument.LatestPublishedVersionID, ContentDocument.Title
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :Ids
        ];
    }

    public List<ContentDocumentLink> getLinkedEntityIdByContentDocumentLinkIDs(Set<Id> contentDocIds)
    {
        return [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE ContentDocumentId IN :contentDocIds
        ];
    }

}