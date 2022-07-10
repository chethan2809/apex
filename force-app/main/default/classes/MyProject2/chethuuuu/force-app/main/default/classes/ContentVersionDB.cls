public class ContentVersionDB extends DBManager {

    public List<ContentVersion> getContentVersionsByIds(Set<Id> contentVersionIds) {
        return [
            SELECT Id, ContentDocumentId, FileExtension, VersionData, Title, ContentSize
            FROM ContentVersion
            WHERE Id IN :contentVersionIds
        ];
    }
}