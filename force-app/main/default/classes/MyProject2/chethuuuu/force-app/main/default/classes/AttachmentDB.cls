public class AttachmentDB extends DBManager {

    public List<Attachment> getAllAttachmentsByIds(Set<Id> attachmentIds) {
        return [
            SELECT Id, Name, Body, ParentId, BodyLength
            FROM Attachment
            WHERE Id IN :attachmentIds
        ];
    }

    public List<Attachment> getAllAttachmentsByParentIdAndDescription(Id parentId, String description) {
        return [
            SELECT Id, Name FROM Attachment WHERE ParentId =: parentId AND Description = :description
        ];
    }
}