public class CollectionCaseStrategiesManager {

    @TestVisible
    private static CollectionCaseDB collectionCaseDBInstance = new CollectionCaseDB();

    public static void createCollectionCaseStrategies(List<loan__Loan_Account__c> contractList) {
        Map<Id, Collection_Case__c> collectionCasesMap = CollectionCaseHelper.getAllCollectionCasesMap;
        for (loan__Loan_Account__c clContract : contractList) {
            Collection_Case__c collectionCase = new Collection_Case__c();
            String currentQueue = '';
            if(collectionCasesMap != null && collectionCasesMap.containsKey(clContract.Id)) {
                collectionCase = collectionCasesMap.get(clContract.Id);
                currentQueue = collectionCasesMap.get(clContract.Id).Case_Queue__c;
            }
            collectionCase = CollectionCaseStrategies.setCollectionCaseFields(clContract, collectionCase);
            if(collectionCase.Case_Queue__c != currentQueue &&
                (collectionCase.Is_Active__c != null && collectionCase.Is_Active__c == false)
            ) {
                collectionCase.Is_Same_Queue__c = false;
                collectionCase.Manual_Collector_Assigned__c = false;
            } else {
                collectionCase.Is_Same_Queue__c = true;
            }
            collectionCase.Is_Active__c = true;
            collectionCaseDBInstance.addUpsert(collectionCase);
        }
        collectionCaseDBInstance.executeUpserts();
    }

    private class CollectionCaseStrategiesManagerException extends Exception {}
}