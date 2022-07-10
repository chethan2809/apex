public class LateFeeCreationJob implements Schedulable, Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, loan__Fee_Set__c, Late_fee_Applied_Date__c, Total_Unpaid_Due_Amount_To_Current__c
            FROM loan__Loan_Account__c
            WHERE loan__Invalid_Data__c = false
                AND Total_Unpaid_Due_Amount_To_Current__c > 500
        ]);
    }

    public void execute(Database.BatchableContext bc, List<loan__Loan_Account__c> loanAccountList) {
        LateFeeCreationManager.processLateFeeCreation(loanAccountList);
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(this);
        if(sc != null) {
            System.abortJob(sc.getTriggerId());
        }
    }

    public static void execute() {
        LateFeeCreationJob lateFeeCreationJobInstance = new LateFeeCreationJob();
        lateFeeCreationJobInstance.execute(null);
    }

    public void finish(Database.BatchableContext bc) {
    }

    private class LateFeeCreationJobException extends Exception {}

}