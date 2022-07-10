public class CollectionContractTriggerHandler {
    @TestVisible
    private static DocumentCategoryDB documentCategoryDBInstance = new DocumentCategoryDB();
    @TestVisible
    private static CLContractDB clContractDBInstance = new CLContractDB();
    @TestVisible
    private static CollectionContractDB collectionContractDBInstance = new CollectionContractDB();

    public void beforeInsert(List<collect__Loan_Account__c> triggerNew) {
        set<Id> clCollectionIds = new set<Id>();
        for(collect__Loan_Account__c collectionsContract : triggerNew) {
            clCollectionIds.add(collectionsContract.collect__External_ID__c);
        }
        Map<Id,loan__Loan_Account__c> clContactsMap = new Map<Id,loan__Loan_Account__c>(clContractDBInstance.getLoanAccountsByIds(clCollectionIds));
        for(collect__Loan_Account__c collectionContract : triggerNew) {
            if(!clContactsMap.isEmpty()) {
                collectionContract = CollectionContracts.setCollectionContractFields(clContactsMap, collectionContract);
            }
        }
    }

    public void beforeUpdate(List<collect__Loan_Account__c> triggerNew) {
        set<Id> clCollectionIds = new set<Id>();
        for(collect__Loan_Account__c collectionsContract : triggerNew) {
            clCollectionIds.add(collectionsContract.collect__External_ID__c);
        }
        Map<Id,loan__Loan_Account__c> clContactsMap = new Map<Id,loan__Loan_Account__c>(clContractDBInstance.getLoanAccountsByIds(clCollectionIds));
        for(collect__Loan_Account__c collectionContract : triggerNew) {
            if(!clContactsMap.isEmpty()) {
                collectionContract = CollectionContracts.setCollectionContractFields(clContactsMap, collectionContract);
            }
        }
    }

    public void afterInsert(Map<Id, collect__Loan_Account__c> newCollectionLoanAccountMap) {
        for(collect__Loan_Account__c loanContract : newCollectionLoanAccountMap.values()) {
            for(clcommon__Document_Definition__c documentDefinition :OriginationHelper.documentDefinitionList) {
                if(documentDefinition.Document_Category__c == 'Collection') {
                    clcommon__Document_Category__c documentCategory = DocumentCategories.createDocumentCategory(documentDefinition);
                    documentCategory.collect_Loan_Account__c = loanContract.Id;
                    documentCategoryDBInstance.addInsert(documentCategory);
                }
            }
        }
        documentCategoryDBInstance.executeInserts();
    }
}