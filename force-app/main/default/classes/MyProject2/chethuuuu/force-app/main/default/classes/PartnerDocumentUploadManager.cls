public class PartnerDocumentUploadManager {
    @TestVisible
    private static DocumentCategoryDB documentCategoryDBInstance = new DocumentCategoryDB();
    @TestVisible
    private static AttachmentDB attachmentDBInstance = new AttachmentDB();

    public static void uploadDocument(RestRequest request){
        String documentType = request.params.get(PartnerDocumentUploads.DOCUMENT_TYPE);
        String attachmentName = request.params.get(PartnerDocumentUploads.NAME);
        Id applicationId = PartnerDocumentUploads.validateRequest(request);

        List<clcommon__Document_Category__c> documentCategoryList = documentCategoryDBInstance.getDocumentCategoriesByApplicationIdsAndName(
            new Set<Id> { applicationId }, documentType
        );

        if(documentCategoryList.isEmpty()) {
            throw new PartnerDocumentUploadManagerException(PartnerDocumentUploads.NO_DOCUMENT_CATEGORY);
        }

        Attachment attachment = Attachments.createAttachment(attachmentName, request.requestBody, documentCategoryList.get(0).Id);
        attachmentDBInstance.addInsert(attachment);
        attachmentDBInstance.executeInserts();

        Map<Id, String> attachmentIdToFileName = new Map<Id, String> { attachment.Id => attachmentName };

        CategoryAttachAssnManager.createBulkDocumentCategoryAssociationForApplication(
            attachmentIdToFileName,
            applicationId,
            documentType
        );
    }

    private class PartnerDocumentUploadManagerException extends Exception {}
}