public class CategoryAttachAssnTriggerHandler {

    @TestVisible
    private static CategoryAttachmentAssociationDB categoryAttachmentAssociationDBInstance = new CategoryAttachmentAssociationDB();

    public void afterInsert(Map<Id, clcommon__Category_Attachment_Association__c > newCategoryAttachmentAssociationMap) {
        Set<Id> categoryAssociationIds = new Set<Id>();
        for(clcommon__Category_Attachment_Association__c categoryAssociation : newCategoryAttachmentAssociationMap.values()) {
            if(categoryAssociation.Wasabi_Link__c == null) {
                categoryAssociationIds.add(categoryAssociation.Id);
            }
        }

        if(!categoryAssociationIds.isEmpty()) {
            Map<Id, clcommon__Category_Attachment_Association__c> attachmentIdToCategoryAss = new Map<Id, clcommon__Category_Attachment_Association__c>();
            for(clcommon__Category_Attachment_Association__c categoryAssociation
                :categoryAttachmentAssociationDBInstance.getCategoryAttachmentAssociationsByIds(categoryAssociationIds)
            ) {
                attachmentIdToCategoryAss.put(categoryAssociation.clcommon__Attachment_Id__c, categoryAssociation);
            }

            new QueueableJobHandler().executeWasabiQueueableJob(attachmentIdToCategoryAss, CategoryAttachAssns.RequestType.INSERT_FILE);
        }
    }

    public void afterUpdate(
        Map<Id, clcommon__Category_Attachment_Association__c > newCategoryAttachmentAssociationMap,
        Map<Id, clcommon__Category_Attachment_Association__c> oldCategoryAttachmentAssociationMap
    ) {

        Set<Id> categoryAssociationIds = new Set<Id>();
        Set<Id> attachmentIdsForDeletion = new Set<Id>();

        for(clcommon__Category_Attachment_Association__c categoryAssociation : newCategoryAttachmentAssociationMap.values()) {
            clcommon__Category_Attachment_Association__c oldCategoryAssociation = oldCategoryAttachmentAssociationMap.get(categoryAssociation.Id);
            if(oldCategoryAssociation.clcommon__Attachment_Id__c !=  categoryAssociation.clcommon__Attachment_Id__c
                && oldCategoryAssociation.clcommon__Attachment_Id__c != null) {
               categoryAssociationIds.add(categoryAssociation.Id);
            }
            if(oldCategoryAssociation.Wasabi_Link__c != categoryAssociation.Wasabi_Link__c && categoryAssociation.Wasabi_Link__c != null
                && categoryAssociation.clcommon__Attachment_Id__c != null
            ) {
                attachmentIdsForDeletion.add(categoryAssociation.clcommon__Attachment_Id__c);
            }
        }

        if(!categoryAssociationIds.isEmpty()) {
            Map<Id, clcommon__Category_Attachment_Association__c> attachmentIdToCategoryAss = new Map<Id, clcommon__Category_Attachment_Association__c>();
            for(clcommon__Category_Attachment_Association__c categoryAssociation
                :categoryAttachmentAssociationDBInstance.getCategoryAttachmentAssociationsByIds(categoryAssociationIds)
            ) {
                attachmentIdToCategoryAss.put(categoryAssociation.clcommon__Attachment_Id__c, categoryAssociation);
            }
            new QueueableJobHandler().executeWasabiQueueableJob(attachmentIdToCategoryAss, CategoryAttachAssns.RequestType.INSERT_FILE);
        }

        if(!attachmentIdsForDeletion.isEmpty()) {
            if(GeneralHelper.isAsynchronous()) {
                CategoryAttachAssnManager.deleteLocalAttachmentsAndContentVersions(attachmentIdsForDeletion);
            } else {
                CategoryAttachAssnManager.deleteLocalAttachmentsAndContentVersionsAsync(attachmentIdsForDeletion);
            }
        }
    }

    public void beforeDelete(List<clcommon__Category_Attachment_Association__c > categoryAttachmentAssociationList){
        for(clcommon__Category_Attachment_Association__c categoryAttachmentAssoc : categoryAttachmentAssociationList){
            CategoryAttachAssns.validateBeforeDeletion(categoryAttachmentAssoc);
        }
    }

    public void afterDelete(List<clcommon__Category_Attachment_Association__c > categoryAttachmentAssociationList) {
        Set<String> docUploadedPkIds = new Set<String>();
        Map<Id, clcommon__Category_Attachment_Association__c> categoryAssByIds = new Map<Id, clcommon__Category_Attachment_Association__c>();
        for(clcommon__Category_Attachment_Association__c categoryAssociation : categoryAttachmentAssociationList) {
            if(categoryAssociation.Wasabi_Link__c != null) {
                categoryAssByIds.put(categoryAssociation.Id, categoryAssociation);
            }
            if(categoryAssociation.Ocrolus_Uploaded_PK__c != null) {
                docUploadedPkIds.add(categoryAssociation.Ocrolus_Uploaded_PK__c);
            }
        }

        if(!categoryAssByIds.isEmpty() && CustomSettingsHelper.generalSettings.Delete_Docs_In_Wasabi__c) {
            new QueueableJobHandler().executeWasabiQueueableJob(categoryAssByIds, CategoryAttachAssns.RequestType.DELETE_FILE);
        }

        if(!docUploadedPkIds.isEmpty()) {
            if(GeneralHelper.isAsynchronous()) {
                OcrolusManager.processDeleteFile(docUploadedPkIds);
            } else {
                OcrolusManager.processDeleteFileAsync(docUploadedPkIds);
            }
        }
    }
}