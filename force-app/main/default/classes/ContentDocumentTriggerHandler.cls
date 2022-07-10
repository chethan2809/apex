public class ContentDocumentTriggerHandler {

    @TestVisible
    private static CategoryAttachmentAssociationDB categoryAttachmentAssociationDBInstance = new CategoryAttachmentAssociationDB();

    @TestVisible
    ContentDocumentLinkDB contentDocumentLinkDBInstance = new ContentDocumentLinkDB();

    public void afterUpdate(Map<Id, ContentDocument> newContentDocumentMap, Map<Id, ContentDocument> oldContentDocumentMap) {
        Map<Id, Id> contentDocumentOldIdToNewId = new Map<Id, Id>();

        for(ContentDocument contentDocument : newContentDocumentMap.values()) {
            ContentDocument oldContentDocument = oldContentDocumentMap.get(contentDocument.Id);
            if(oldContentDocument.LatestPublishedVersionId !=  contentDocument.LatestPublishedVersionId
                && oldContentDocument.LatestPublishedVersionId != null) {
               contentDocumentOldIdToNewId.put(oldContentDocument.LatestPublishedVersionId, contentDocument.LatestPublishedVersionId);
            }
        }

        List<clcommon__Category_Attachment_Association__c>  categoryAttachmentAssociationsList =  categoryAttachmentAssociationDBInstance.getCategoryAttachmentAssociationsByAttachmentIds(contentDocumentOldIdToNewId.keySet());
        for(clcommon__Category_Attachment_Association__c categoryAttachmentAssociation : categoryAttachmentAssociationsList) {
            categoryAttachmentAssociation.clcommon__Attachment_Id__c = contentDocumentOldIdToNewId.get(CategoryAttachmentAssociation.clcommon__Attachment_Id__c);
            categoryAttachmentAssociationDBInstance.addUpdate(categoryAttachmentAssociation);
        }

        categoryAttachmentAssociationDBInstance.executeUpdates();
    }

    public void beforeDelete(Map<Id, ContentDocument> oldContentDocumentMap) {
        Set<Id> contentDocId = new Set<Id>();
        Map<Id, Id> contDocIdToEntityIdMap = new Map<Id, Id>();
        Set<String> indelibleNotesObjectPrefix = new Set<String>();
        indelibleNotesObjectPrefix.add(GeneralHelper.getObjectKeyPrefix('Account'));
        indelibleNotesObjectPrefix.add(GeneralHelper.getObjectKeyPrefix('Lead'));
        indelibleNotesObjectPrefix.add(GeneralHelper.getObjectKeyPrefix('Opportunity'));
        indelibleNotesObjectPrefix.add(GeneralHelper.getObjectKeyPrefix('Contact'));

        List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();

        for(ContentDocument contentDoc : oldContentDocumentMap.values()){
            if(contentDoc.FileType == GeneralConstants.CONTENT_DOCUMENT_NOTE_TYPE){
                contentDocId.add(contentDoc.Id);
            }
        }

        if(!contentDocId.isEmpty()) {
            contentDocumentLinkList = contentDocumentLinkDBInstance.getLinkedEntityIdByContentDocumentLinkIDs(contentDocId);
            for(ContentDocumentLink contentDocLink : contentDocumentLinkList){
                if(indelibleNotesObjectPrefix.contains(String.valueOf(contentDocLink.LinkedEntityId).left(3))) {
                    CustomError.addError(oldContentDocumentMap.get(contentDocLink.ContentDocumentId), 'Notes can not be deleted');
                }
            }
        }
    }
}