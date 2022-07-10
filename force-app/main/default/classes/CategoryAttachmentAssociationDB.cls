public class CategoryAttachmentAssociationDB extends DBManager {

    public List<clcommon__Category_Attachment_Association__c> getCategoryAttachmentAssociationsByIds(Set<Id> categoryAssociationIds) {
        return [
            SELECT Id, Name, Wasabi_Link__c, clcommon__Attachment_Id__c, clcommon__Document_Category__r.clcommon__Category_Name__c,
                clcommon__Document_Category__r.genesis__Application__c, clcommon__Document_Category__r.genesis__Application__r.Name,
                clcommon__Document_Category__r.Collection_Case__c, clcommon__Document_Category__r.Collection_Case__r.Name,
                clcommon__Document_Category__r.clcommon__Account__c, clcommon__Document_Category__r.clcommon__Account__r.Name,
                clcommon__Document_Category__r.clcommon__Account__r.Merchant_ID__c, Application__c, Ocrolus_Uploaded_PK__c,
                Ocrolus_Document_Status__c
            FROM clcommon__Category_Attachment_Association__c
            WHERE Id IN : categoryAssociationIds
        ];
    }

    public List<clcommon__Category_Attachment_Association__c> getCategoryAttachmentAssociationsByAttachmentIds(Set<Id> attachmentIds){
        return [
            SELECT Id, Name, clcommon__Attachment_Id__c
            FROM clcommon__Category_Attachment_Association__c
            WHERE clcommon__Attachment_Id__c IN : attachmentIds
        ];
    }
}