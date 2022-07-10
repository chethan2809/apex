public class CategoryAttachAssns {

    public enum RequestType { INSERT_FILE, DELETE_FILE }

    public static clcommon__Category_Attachment_Association__c createCategoryAttachAssn(String name, Id attachmentId, Id documentCategoryId) {
        clcommon__Category_Attachment_Association__c documentCategoryAsst = new clcommon__Category_Attachment_Association__c();
        documentCategoryAsst.Name = name.left(80);
        documentCategoryAsst.clcommon__Attachment_Id__c = attachmentId;
        documentCategoryAsst.clcommon__Document_Category__c = documentCategoryId;
        return documentCategoryAsst;
    }

    public static clcommon__Category_Attachment_Association__c createCategoryAttachAssn(
        String name, Id attachmentId, Id documentCategoryId, String wasabiLink
    ) {
        clcommon__Category_Attachment_Association__c documentCategoryAsst = new clcommon__Category_Attachment_Association__c();
        documentCategoryAsst.Name = name.left(80);
        documentCategoryAsst.clcommon__Attachment_Id__c = attachmentId;
        documentCategoryAsst.clcommon__Document_Category__c = documentCategoryId;
        documentCategoryAsst.Wasabi_Link__c = wasabiLink;
        return documentCategoryAsst;
    }

    public static clcommon__Category_Attachment_Association__c setCategoryAttachAssnOcrolusFields(
        clcommon__Category_Attachment_Association__c categoryAttachmentAssoc, String uploadedPk, String documentStatus,  String failureMessage
    ) {
        categoryAttachmentAssoc.Ocrolus_Uploaded_PK__c = uploadedPk;
        categoryAttachmentAssoc.Ocrolus_Document_Status__c = documentStatus;
        categoryAttachmentAssoc.Ocrolus_Upload_Failure_Message__c = failureMessage;
        return categoryAttachmentAssoc;
    }

    public static void validateBeforeDeletion(clcommon__Category_Attachment_Association__c categoryAttachmentAss){
        if(categoryAttachmentAss.Ocrolus_Uploaded_PK__c != null && categoryAttachmentAss.Ocrolus_Document_Status__c == Ocrolus.OCROLUS_DOC_STATUS_VERIFYING){
            CustomError.addError(categoryAttachmentAss, 'Document Cannot Be Deleted When Under Ocrolus Verification In Progress');
        }
    }
}