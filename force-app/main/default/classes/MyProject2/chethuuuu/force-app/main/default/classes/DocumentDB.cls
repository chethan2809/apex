public class DocumentDB extends DBManager {
    public List<Document> getDocumentByDeveloperName(String documentName) {
        return [
            SELECT Id, Name, DeveloperName FROM Document WHERE DeveloperName = :documentName
        ];
    }

    public List<Document> getDocumentByFolderId(Id folderId) {
        return [
            SELECT Id, Name, DeveloperName FROM Document WHERE FolderId = :folderId
        ];
    }
}