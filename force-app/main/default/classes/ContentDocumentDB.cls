public class ContentDocumentDB extends DBManager {
    public List<ContentDocument> getAllContentDocumentsByIds(Set<Id> contentDocumentIds) {
        return [
            SELECT Id, LatestPublishedVersionId, Title
            FROM ContentDocument
            WHERE Id IN : contentDocumentIds
        ];
    }
}