public class CollectionCaseStrategiesJob implements Schedulable, Database.Batchable<sObject>, Database.Stateful {

    @TestVisible
    private static Origination_Settings__mdt defaultOriginationSetting = CustomMetaDataHelper.defaultOriginationSetting;
    @TestVisible
    private static CollectionCriteriaDB collectionCriteriaDBInstance = new CollectionCriteriaDB();
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    private List<loan__Loan_Account__c> delinquentAllCLContracts;

    public CollectionCaseStrategiesJob() {
        delinquentAllCLContracts = new List<loan__Loan_Account__c>();
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<Collection_Criteria__c> collectionCriteriaList = collectionCriteriaDBInstance.getCollectionCriteriaAndQueueValue();
        String evaluationCriteria;

        if(!collectionCriteriaList.isEmpty()){
            evaluationCriteria = collectionCriteriaList[0].Evaluation_Criteria__c;
        }

        return Database.getQueryLocator (evaluationCriteria);
    }

    public void execute(Database.BatchableContext bC, List<loan__Loan_Account__c> contractList) {
        try {
            delinquentAllCLContracts.addAll(contractList);
            CollectionCaseStrategiesManager.createCollectionCaseStrategies(contractList);
        } catch(Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog ('CollectionCaseStrategiesJob Failed', e.getMessage() + e.getStackTraceString(), JSON.serialize(contractList), contractList.get(0).Id, ErrorLogs.ERROR, null, false);
            errorLogDBInstance.addInsert(errorLog).executeInserts();
        }
    }

    public void execute(SchedulableContext sc) {
        if (defaultOriginationSetting.Collection_Case_Strategy_Batch_Size__c == null) {
            throw new CollectionCaseStrategiesJobException('Collection_Case_Strategy_Batch_Size__c is null');
        }
        Database.executeBatch(this, Integer.ValueOf(defaultOriginationSetting.Collection_Case_Strategy_Batch_Size__c));
    }

    public static void execute() {
        CollectionCaseStrategiesJob collectionCaseStrategiesJobInstance = new CollectionCaseStrategiesJob();
        collectionCaseStrategiesJobInstance.execute(null);
    }

    public void finish(Database.BatchableContext BC) {
        try {
            CollectorAssignmentManager.collectorAssignment(delinquentAllCLContracts);
        } catch(Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog ('Collection Case User Assignment Failed', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR, null, false);
            errorLogDBInstance.addInsert(errorLog).executeInserts();
        }
    }

    private class CollectionCaseStrategiesJobException extends Exception {}
}