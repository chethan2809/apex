public class Documents {
    public static Document createDocument(String documentName, Blob body, Id folderId, String fileType, String contentType) {
        Document documentRecord = new Document();
        documentRecord.Name = documentName;
        documentRecord.Body = body;
        documentRecord.FolderId = folderId;
        documentRecord.Type = fileType;
        documentRecord.ContentType = contentType;

        return documentRecord;
    }
}