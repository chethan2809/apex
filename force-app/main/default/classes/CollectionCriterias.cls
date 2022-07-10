public class CollectionCriterias {
    @TestVisible
    private static CollectionCriteriaDB collectionCriteriaDBInstance = new CollectionCriteriaDB();

    public static void collectionCriterias(List<Collection_Criteria__c> collectionCriteriaList) {
        for(Collection_Criteria__c collectionCriteria : collectionCriteriaList)
        {
            if(collectionCriteria.Queue_Value__c <= 0) {
                collectionCriteria.addError('Queue Value Should be Greater Than 1');
            }
            if(collectionCriteria.Evaluation_Criteria__c != null) {
                Boolean isError = false;
                string queryValidate = collectionCriteria.Evaluation_Criteria__c;
                try {
                    Database.Query(queryValidate + ' LIMIT 0');
                } catch(QueryException ex) { isError = true; }
                if(isError == true) {
                    collectionCriteria.addError('Invalid Evaluation Criteria, Please Enter Valid SOQL');
                }
            }
        }
    }

    public static void beforeInsertCollectionCriteria(List<Collection_Criteria__c> collectionCriteriaList) {
        List<Collection_Criteria__c> criteriaList = collectionCriteriaDBInstance.getExistingCollectionCriteria();
        if(criteriaList.size() >= 1){
            collectionCriteriaList[0].addError('Please update existing Collection Criteria');
        }
    }
}