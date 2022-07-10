public class CollectionCaseTriggerHandler {
    @TestVisible
    private static DocumentCategoryDB documentCategoryDBInstance = new DocumentCategoryDB();
    @TestVisible
    private static AccountDB accountDBInstance = new AccountDB();

    public void afterInsert(Map<Id, Collection_Case__c> newCollectionCaseMap) {
        for(Collection_Case__c collectionCase : newCollectionCaseMap.values()) {
            for(clcommon__Document_Definition__c documentDefinition :OriginationHelper.documentDefinitionList) {
                if(documentDefinition.Document_Category__c == 'Collection') {
                    clcommon__Document_Category__c documentCategory = DocumentCategories.createDocumentCategory(documentDefinition);
                    documentCategory.Collection_Case__c = collectionCase.Id;
                    documentCategoryDBInstance.addInsert(documentCategory);
                }
            }
            accountDBInstance.addUpdate(Accounts.setAccountFieldsFromCollectionsAfterInsert(collectionCase));
        }
        documentCategoryDBInstance.executeInserts();
        accountDBInstance.executeUpdates();
    }

    public void beforeUpdate(Map<Id, Collection_Case__c> newCollectionCaseMap,
        Map<Id, Collection_Case__c> oldCollectionCaseMap
    ) {
        for (Collection_Case__c collectionCase : newCollectionCaseMap.values()) {
            Collection_Case__c oldCollectionCase = oldCollectionCaseMap.get(collectionCase.Id);
            if(collectionCase.Collections_status__c != oldCollectionCase.Collections_status__c) {
                collectionCase.Last_Status_Change_Date__c = GeneralHelper.currentSystemDate;
            }
            if(collectionCase.Collections_sub_status__c != oldCollectionCase.Collections_sub_status__c) {
                collectionCase.Last_Sub_status_Change_Date__c = GeneralHelper.currentSystemDate;
            }
        }
    }

    public void afterUpdate(Map<Id, Collection_Case__c> newCollectionCaseMap,
        Map<Id, Collection_Case__c> oldCollectionCaseMap
    ) {
        for (Collection_Case__c collectionCase : newCollectionCaseMap.values()) {
            Collection_Case__c oldCollectionCase = oldCollectionCaseMap.get(collectionCase.Id);
            accountDBInstance.addUpdate(Accounts.setAccountFieldsFromCollectionsAfterUpdate(collectionCase, oldCollectionCase));
        }
        accountDBInstance.executeUpdates();
    }

}