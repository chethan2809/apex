public class ContentDocumentLinks {
    public static ContentDocumentLink insertAttachmentToSObject(SObject obj, ContentVersion contentInsert)
    {
        ContentVersionDB contentVersionDbInstance = new ContentVersionDB();
        List<ContentVersion> contentVersion = contentVersionDbInstance.getContentVersionsByIds(new Set<Id> {contentInsert.Id});
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.ContentDocumentId = contentVersion[0].ContentDocumentId;
        contentLink.LinkedEntityId = obj.Id;
        contentLink.ShareType = 'V';
    	contentLink.Visibility = 'AllUsers';
        return contentLink;
    }
}