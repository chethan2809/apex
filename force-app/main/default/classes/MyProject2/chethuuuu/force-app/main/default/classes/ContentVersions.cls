public class ContentVersions
{
    public static ContentVersion insertAttachmentToContentVersion(Messaging.InboundEmail.BinaryAttachment attachment)
    {
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = attachment.fileName;
        contentVersion.VersionData = attachment.body;
        contentVersion.PathOnClient = '/' + attachment.fileName;
        return contentVersion;
    }
}