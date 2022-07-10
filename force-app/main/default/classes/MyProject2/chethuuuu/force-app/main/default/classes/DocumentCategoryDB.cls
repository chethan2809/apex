public class DocumentCategoryDB extends DBManager {

    public List<clcommon__Document_Category__c> getDocumentCategoriesByIds(Set<Id> documentCategoryIds) {
        return [
            SELECT Id, clcommon__Category_Name__c, genesis__Application__c, clcommon__Account__c
            FROM clcommon__Document_Category__c
            WHERE Id IN : documentCategoryIds
        ];
    }

    public List<clcommon__Document_Category__c> getDocumentCategoriesByApplicationIdsAndName(Set<Id> applicationIds, String definitionName) {
        return [
            SELECT Id, clcommon__Category_Name__c, genesis__Application__c
            FROM clcommon__Document_Category__c
            WHERE genesis__Application__c IN : applicationIds AND clcommon__Category_Name__c = : definitionName
        ];
    }

    public List<clcommon__Document_Category__c> getDocumentCategoriesAndItsAttachmentsByAccountIdsAndName(Set<Id> accountIds, String definitionName) {
        return [
            SELECT Id, clcommon__Account__c, (SELECT Id FROM clcommon__DocCat_Attachment_Associations__r)
            FROM clcommon__Document_Category__c
            WHERE clcommon__Account__c IN : accountIds AND clcommon__Category_Name__c = :definitionName
        ];
    }

    public List<clcommon__Document_Category__c> getDocumentCategoriesAndItsAttachmentByApplicationIdsAndName(
        Set<Id> applicationIds, String definitionName
    ) {
        return [
            SELECT Id, genesis__Application__c,
                (
                    SELECT Id, clcommon__Attachment_Id__c, Wasabi_Link__c, Ocrolus_Document_Status__c, Ocrolus_Uploaded_PK__c
                    FROM clcommon__DocCat_Attachment_Associations__r
                    ORDER BY CreatedDate DESC
                )
            FROM clcommon__Document_Category__c
            WHERE genesis__Application__c IN : applicationIds AND clcommon__Category_Name__c = :definitionName
        ];
    }

    public List<clcommon__Document_Category__c> getDocumentCategoriesByApplicationAndCollectionsIdsAndNames(Set<Id> applicationOrCollectionIds, Set<String> definitionNames) {
        return [
            SELECT Id, clcommon__Category_Name__c, collect_Loan_Account__c,
                genesis__Application__c, Collection_Case__c
            FROM clcommon__Document_Category__c
            WHERE (collect_Loan_Account__c IN : applicationOrCollectionIds OR
                Collection_Case__c IN :applicationOrCollectionIds OR
                genesis__Application__c IN : applicationOrCollectionIds)
            AND clcommon__Category_Name__c IN : definitionNames
        ];
    }

    public List<clcommon__Document_Category__c> getDocumentCategoriesAndItsAttachmentsByCollectionsIdsAndName(Set<Id> collectionCaseIds, String definitionName) {
        return [
            SELECT Id, Collection_Case__c, (SELECT Id FROM clcommon__DocCat_Attachment_Associations__r)
            FROM clcommon__Document_Category__c
            WHERE Collection_Case__c IN : collectionCaseIds AND clcommon__Category_Name__c = :definitionName
        ];
    }
}