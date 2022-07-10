public class CategoryAttachAssnManager {

    @TestVisible
    private static DocumentCategoryDB documentCategoryDBInstance = new DocumentCategoryDB();
    @TestVisible
    private static ContentDocumentDB contentDocumentDBInstance = new ContentDocumentDB();
    @TestVisible
    private static CategoryAttachmentAssociationDB categoryAttachmentAssociationDBInstance = new CategoryAttachmentAssociationDB();
    @TestVisible
    private static AttachmentDB attachmentDBInstance = new AttachmentDB();
    @TestVisible
    private static ContentVersionDB contentVersionDBInstance = new ContentVersionDB();
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    public static void createAccountDocumentCategoryAssociationByAttachmentId(Map<Id, Attachment> accountIdToAttachment, String documentType) {
        List<clcommon__Document_Category__c> documentCategoryList =
            documentCategoryDBInstance.getDocumentCategoriesAndItsAttachmentsByAccountIdsAndName
            (
                accountIdToAttachment.keySet(), documentType
            );
        Map<Id, Id> documentCategoryIdByAccountId = new Map<Id, Id>();
        List<clcommon__Document_Category__c> missedDocumentCategories = new List<clcommon__Document_Category__c>();

        for(clcommon__Document_Category__c documentCategory : documentCategoryList) {
            if(!documentCategory.clcommon__DocCat_Attachment_Associations__r.isEmpty()) {
                categoryAttachmentAssociationDBInstance.addDeletes(documentCategory.clcommon__DocCat_Attachment_Associations__r);
            }
            documentCategoryIdByAccountId.put(documentCategory.clcommon__Account__c, documentCategory.Id);
        }

        for(Id accountId : accountIdToAttachment.keySet()) {
            if(documentCategoryIdByAccountId.containsKey(accountId)) {
                clcommon__Category_Attachment_Association__c documentCategoryAsst = CategoryAttachAssns.createCategoryAttachAssn(
                    accountIdToAttachment.get(accountId).Name, accountIdToAttachment.get(accountId).Id,
                    documentCategoryIdByAccountId.get(accountId)
                );
                categoryAttachmentAssociationDBInstance.addInsert(documentCategoryAsst);
            } else {
                clcommon__Document_Category__c documentCategory = DocumentCategories.createDocumentCategory(
                    OriginationHelper.documentDefinitionByName.get(documentType)
                );
                documentCategory.clcommon__Account__c = accountId;
                missedDocumentCategories.add(documentCategory);
            }
        }

        if(!missedDocumentCategories.isEmpty()) {
            documentCategoryDBInstance.addInserts(missedDocumentCategories).executeInserts();
            for(clcommon__Document_Category__c documentCategory :missedDocumentCategories) {
                clcommon__Category_Attachment_Association__c documentCategoryAsst = CategoryAttachAssns.createCategoryAttachAssn(
                    accountIdToAttachment.get(documentCategory.clcommon__Account__c).Name,
                    accountIdToAttachment.get(documentCategory.clcommon__Account__c).Id, documentCategory.Id
                );
                categoryAttachmentAssociationDBInstance.addInsert(documentCategoryAsst);
            }
        }

        categoryAttachmentAssociationDBInstance.executeDeletes();
        categoryAttachmentAssociationDBInstance.executeInserts();
    }

    public static void createBulkDocumentCategoryAssociationForApplication(
        Map<Id, String> attachmentIdToFileName, Id applicationId, String documentType
    ) {
        List<clcommon__Document_Category__c> documentCategoryList = documentCategoryDBInstance.getDocumentCategoriesByApplicationIdsAndName(
            new Set<Id> { applicationId }, documentType
        );

        if(documentCategoryList.isEmpty()) {
            throw new CategoryAttachAssnManagerException(
                'There was no Document Category found for this application with type ' + documentType
            );
        }

        for(Id attachmentId : attachmentIdToFileName.keySet()) {
            clcommon__Category_Attachment_Association__c documentCategoryAsst = CategoryAttachAssns.createCategoryAttachAssn(
                attachmentIdToFileName.get(attachmentId), attachmentId, documentCategoryList.get(0).Id
            );
            categoryAttachmentAssociationDBInstance.addInsert(documentCategoryAsst);
        }

        categoryAttachmentAssociationDBInstance.executeInserts();
    }

    public static void createDocumentCategoryAssociationForSignedDocuments(List<APXT_CongaSign__Document__c> finalSignedDocumentList) {
        Set<Id> finalCongaSignDocumentIds = new Set<Id>();
        Set<String> definitionNames = new Set<String> {
            GeneralConstants.DOCUMENT_TYPE_LOAN_AGREEMENT, GeneralConstants.DOCUMENT_TYPE_CL_COLLECTIONS,
            GeneralConstants.DOCUMENT_TYPE_COLLECTIONS
        };

        for(APXT_CongaSign__Document__c congaSignDocument : finalSignedDocumentList) {
            if(congaSignDocument.APXT_CongaSign__Transaction__r.Parent_a6t__c != null) {
                finalCongaSignDocumentIds.add(congaSignDocument.APXT_CongaSign__Transaction__r.Parent_a6t__c);
            } else if(congaSignDocument.APXT_CongaSign__Transaction__r.Parent_aEH__c != null) {
                finalCongaSignDocumentIds.add(congaSignDocument.APXT_CongaSign__Transaction__r.Parent_aEH__c);
            }
        }

        List<clcommon__Document_Category__c> documentCategoryList = documentCategoryDBInstance.getDocumentCategoriesByApplicationAndCollectionsIdsAndNames(
            finalCongaSignDocumentIds, definitionNames
        );
        Map<Id,Id> parentIdToDocumentCategoryId = new Map<Id,Id>();
        for(clcommon__Document_Category__c documentCategory: documentCategoryList) {
            if(documentCategory.genesis__Application__c != null) {
                parentIdToDocumentCategoryId.put(documentCategory.genesis__Application__c, documentCategory.Id);
            } else if(documentCategory.collect_Loan_Account__c != null) {
                parentIdToDocumentCategoryId.put(documentCategory.collect_Loan_Account__c, documentCategory.Id);
            }
        }
        for(APXT_CongaSign__Document__c congaSignDocument : finalSignedDocumentList) {
            Id attachmentId = congaSignDocument.APXT_CongaSign__ContentVersionId__c;
            Id documentCategoryId;
            if(congaSignDocument.APXT_CongaSign__Transaction__r.Parent_a6t__c != null) {
                documentCategoryId = parentIdToDocumentCategoryId.get(congaSignDocument.APXT_CongaSign__Transaction__r.Parent_a6t__c);
            } else if(congaSignDocument.APXT_CongaSign__Transaction__r.Parent_aEH__c != null) {
                documentCategoryId = parentIdToDocumentCategoryId.get(congaSignDocument.APXT_CongaSign__Transaction__r.Parent_aEH__c);
            }
            clcommon__Category_Attachment_Association__c documentCategoryAsst = CategoryAttachAssns.createCategoryAttachAssn(
                congaSignDocument.Name, attachmentId, documentCategoryId
            );
            categoryAttachmentAssociationDBInstance.addInsert(documentCategoryAsst);
        }
        categoryAttachmentAssociationDBInstance.executeInserts();
    }

    public static void createDocumentCategoryAssociationForApplicationsByAttachmentId(
        Map<Id, Attachment> applicationIdToAttachment, String documentType
    ) {
        Map<Id, Id> documentCategoryIdByApplicationId = new Map<Id, Id>();
        List<clcommon__Document_Category__c> documentCategoryList = documentCategoryDBInstance.getDocumentCategoriesByApplicationIdsAndName(
            applicationIdToAttachment.keySet(), documentType
        );

        for(clcommon__Document_Category__c documentCategory : documentCategoryList) {
            documentCategoryIdByApplicationId.put(documentCategory.genesis__Application__c, documentCategory.Id);
        }

        for(Id applicationId : applicationIdToAttachment.keySet()) {
            clcommon__Category_Attachment_Association__c documentCategoryAsst = CategoryAttachAssns.createCategoryAttachAssn(
                applicationIdToAttachment.get(applicationId).Name, applicationIdToAttachment.get(applicationId).Id,
                documentCategoryIdByApplicationId.get(applicationId)
            );
            categoryAttachmentAssociationDBInstance.addInsert(documentCategoryAsst);
        }

        categoryAttachmentAssociationDBInstance.executeInserts();
    }

    public static void deleteLocalAttachmentsAndContentVersions(Set<Id> attachmentIdsForDeletion) {
        List<Attachment> attachmentList = attachmentDBInstance.getAllAttachmentsByIds(attachmentIdsForDeletion);
        List<ContentVersion> contentVersionList = contentVersionDBInstance.getContentVersionsByIds(attachmentIdsForDeletion);
        try {
            if(!attachmentList.isEmpty()) {
                attachmentDBInstance.addDeletes(attachmentList).executeDeletes();
            }
            if(!contentVersionList.isEmpty()) {
                Map<Id, ContentDocument> listToDeleteConVer = new Map<Id, ContentDocument>();
                for (ContentVersion conVer : contentVersionList) {
                    contentDocumentDBInstance.addDelete(new ContentDocument(Id = conVer.ContentDocumentId));
                }
                contentDocumentDBInstance.executeDeletes();
            }
        } catch (Exception ex) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'File Deletion in Salesforce', 'Failed to delete files in Salesforce', attachmentIdsForDeletion.toString(), null, ErrorLogs.ERROR,
                null, false
            );
            errorLogDBInstance.addInsert(errorLog).executeInserts();
        }
    }

    public static void createBulkDocumentCategoryAssociationForCollectionCase(
        Map<Id, String> attachmentIdToFileName, Id collectionCaseId, String documentType
    ) {
        List<clcommon__Document_Category__c> documentCategoryList = documentCategoryDBInstance.getDocumentCategoriesByApplicationAndCollectionsIdsAndNames(
            new Set<Id> { collectionCaseId }, new Set<String> { documentType }
        );

        if(documentCategoryList.isEmpty()) {
            throw new CategoryAttachAssnManagerException(
                'There was no Document Category found for this collection Case with type ' + documentType
            );
        }

        for(Id attachmentId : attachmentIdToFileName.keySet()) {
            clcommon__Category_Attachment_Association__c documentCategoryAsst = CategoryAttachAssns.createCategoryAttachAssn(
                attachmentIdToFileName.get(attachmentId), attachmentId, documentCategoryList.get(0).Id
            );
            categoryAttachmentAssociationDBInstance.addInsert(documentCategoryAsst);
        }

        categoryAttachmentAssociationDBInstance.executeInserts();
    }

    public static void createCollectionsDocumentCategoryAssociationByAttachmentId(Map<Id, Attachment> collectionCaseIdToAttachment, String documentType) {
        List<clcommon__Document_Category__c> documentCategoryList =
            documentCategoryDBInstance.getDocumentCategoriesAndItsAttachmentsByCollectionsIdsAndName
            (
                collectionCaseIdToAttachment.keySet(), documentType
            );
        Map<Id, Id> documentCategoryIdByCollectionCaseId = new Map<Id, Id>();
        List<clcommon__Document_Category__c> missedDocumentCategories = new List<clcommon__Document_Category__c>();

        for(clcommon__Document_Category__c documentCategory : documentCategoryList) {
            if(!documentCategory.clcommon__DocCat_Attachment_Associations__r.isEmpty()) {
                categoryAttachmentAssociationDBInstance.addDeletes(documentCategory.clcommon__DocCat_Attachment_Associations__r);
            }
            documentCategoryIdByCollectionCaseId.put(documentCategory.Collection_Case__c, documentCategory.Id);
        }

        for(Id collectionCaseId : collectionCaseIdToAttachment.keySet()) {
            if(documentCategoryIdByCollectionCaseId.containsKey(collectionCaseId)) {
                clcommon__Category_Attachment_Association__c documentCategoryAsst = CategoryAttachAssns.createCategoryAttachAssn(
                    collectionCaseIdToAttachment.get(collectionCaseId).Name, collectionCaseIdToAttachment.get(collectionCaseId).Id,
                    documentCategoryIdByCollectionCaseId.get(collectionCaseId)
                );
                categoryAttachmentAssociationDBInstance.addInsert(documentCategoryAsst);
            } else {
                clcommon__Document_Category__c documentCategory = DocumentCategories.createDocumentCategory(
                    OriginationHelper.documentDefinitionByName.get(documentType)
                );
                documentCategory.Collection_Case__c = collectionCaseId;
                missedDocumentCategories.add(documentCategory);
            }
        }

        if(!missedDocumentCategories.isEmpty()) {
            documentCategoryDBInstance.addInserts(missedDocumentCategories).executeInserts();
            for(clcommon__Document_Category__c documentCategory :missedDocumentCategories) {
                clcommon__Category_Attachment_Association__c documentCategoryAsst = CategoryAttachAssns.createCategoryAttachAssn(
                    collectionCaseIdToAttachment.get(documentCategory.Collection_Case__c).Name,
                    collectionCaseIdToAttachment.get(documentCategory.Collection_Case__c).Id, documentCategory.Id
                );
                categoryAttachmentAssociationDBInstance.addInsert(documentCategoryAsst);
            }
        }

        categoryAttachmentAssociationDBInstance.executeDeletes();
        categoryAttachmentAssociationDBInstance.executeInserts();
    }

    @future
    public static void deleteLocalAttachmentsAndContentVersionsAsync(Set<Id> attachmentIdsForDeletion) {
        deleteLocalAttachmentsAndContentVersions(attachmentIdsForDeletion);
    }

    private class CategoryAttachAssnManagerException extends Exception {}
}