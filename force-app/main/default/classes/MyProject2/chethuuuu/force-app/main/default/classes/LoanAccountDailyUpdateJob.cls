public class LoanAccountDailyUpdateJob implements Schedulable, Database.Batchable<SObject> {

    @TestVisible
    private static Origination_Settings__mdt defaultDailyUpdateSetting = CustomMetaDataHelper.defaultOriginationSetting;
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    public LoanAccountDailyUpdateJob() {}

    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator([
            SELECT Id, Concurrent_Eligible_Amount__c, Pricing_Factor__c, Remaining_Number_of_Payments__c, loan__Frequency_of_Loan_Payment__c,
                Disbursement_Count__c, Concurrent_Interest_Rate__c
            FROM loan__Loan_Account__c
            WHERE loan__Loan_Status__c IN :CLContracts.LOAN_GOOD_AND_BAD_STATUSES
                AND Disbursement_Count__c = 1
                AND Concurrent_Eligible_Amount__c > 0
                AND Remaining_Number_of_Payments__c > 0
                AND loan__Invalid_Data__c = false
        ]);
    }

    public void execute(Database.BatchableContext bc, List<loan__Loan_Account__c> loanAccountList) {
        try {
        LoanAccountDailyUpdateManager.setLoanAccountFields(loanAccountList);
        } catch(Exception e){
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'Concurrent Interest Rate Calculation Failed', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                null, false
            );
            errorLogDBInstance.addInsert(errorLog);
        }
        errorLogDBInstance.executeInserts();
    }

    public void execute(SchedulableContext sc) {
        if (defaultDailyUpdateSetting.Loan_Account_Update_Job_Size__c == null) {
            throw new LoanAccountDailyUpdateJobException('Loan_Account_Update_Job_Size__c is null');
        }
        Database.executeBatch(this, Integer.ValueOf(defaultDailyUpdateSetting.Loan_Account_Update_Job_Size__c));
    }

    public static void execute() {
        LoanAccountDailyUpdateJob loanAccountDailyUpdateJobInstance = new LoanAccountDailyUpdateJob();
        loanAccountDailyUpdateJobInstance.execute(null);
    }

    public void finish(Database.BatchableContext bc) {

    }

    private class LoanAccountDailyUpdateJobException extends Exception {}
}