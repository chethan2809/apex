public class DocumentCategories {

    public static clcommon__Document_Category__c createDocumentCategory(clcommon__Document_Definition__c documentDefinition) {
        clcommon__Document_Category__c documentCategory = new clcommon__Document_Category__c();
        documentCategory.clcommon__Category_Name__c = documentDefinition.Name;
        documentCategory.clcommon__Show_In_Portal__c = documentDefinition.clcommon__Show_In_Portal__c;
        documentCategory.clcommon__Document_Definition__c = documentDefinition.Id;
        return documentCategory;
    }

    public static Map<Id, List<clcommon__Category_Attachment_Association__c>> getCategoryAttachmentListByApplicationId(
        List<clcommon__Document_Category__c> documentCategoryList
    ) {
        Map<Id, List<clcommon__Category_Attachment_Association__c>> applicationIdToCategoryAttachmentList = new Map<Id, List<clcommon__Category_Attachment_Association__c>>();
        Map<Id, Boolean> applicationIdToHasWasabiLink = new Map<Id, Boolean>();

        for(clcommon__Document_Category__c docCategory : documentCategoryList) {
            if(docCategory.clcommon__DocCat_Attachment_Associations__r.isEmpty()) {
                continue;
            }

            Id applicationId = docCategory.genesis__Application__c;
            applicationIdToHasWasabiLink.put(applicationId, true);

            for(clcommon__Category_Attachment_Association__c categoryAttachment: docCategory.clcommon__DocCat_Attachment_Associations__r) {
                if(categoryAttachment.Wasabi_Link__c == null) {
                    applicationIdToHasWasabiLink.put(applicationId, false);
                }

                if(applicationIdToHasWasabiLink.get(applicationId)) {
                    if(applicationIdToCategoryAttachmentList.containsKey(applicationId)) {
                        applicationIdToCategoryAttachmentList.get(applicationId).add(categoryAttachment);
                    } else {
                        applicationIdToCategoryAttachmentList.put(
                            applicationId, new List<clcommon__Category_Attachment_Association__c> {categoryAttachment}
                        );
                    }
                } else if (applicationIdToCategoryAttachmentList.containsKey(applicationId)) {
                    applicationIdToCategoryAttachmentList.remove(applicationId);
                }
            }
        }

        return applicationIdToCategoryAttachmentList;
    }

    private class DocumentCategoriesException extends Exception {}
}