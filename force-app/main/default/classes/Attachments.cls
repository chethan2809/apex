public class Attachments {

    public static Attachment createAttachment(String name, Blob body, Id parentId) {
        Attachment attachmentObj = new Attachment();
        attachmentObj.Body = body;
        attachmentObj.Name = name;
        attachmentObj.parentId = parentId;
        return attachmentObj;
    }
}