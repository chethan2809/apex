global class LoanAccountDailyUpdateDynamicJob extends clcommon.DynamicJob {

    private Date sodDate;
    private static final String JOB_NAME = 'Loan Account Daily Update Dynamic Job';
    private static final Integer DEFAULT_BATCH_SIZE = 150;
    @TestVisible
    private static Origination_Settings__mdt defaultDailyUpdateSetting = CustomMetaDataHelper.defaultOriginationSetting;
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    global LoanAccountDailyUpdateDynamicJob() {
        this(null);
    }

    public LoanAccountDailyUpdateDynamicJob(String query) {
        super(JOB_NAME, query);
    }

    global override void doExecute(SchedulableContext sc) {
    }

    global override void doInitialize() {}

    global override String getRuntimeQuery() {
        String eligibleLoanStatuses = '\'Active - Good Standing\' , \'Active - Good Standing\'';

        return ' SELECT Id, Concurrent_Eligible_Amount__c, Pricing_Factor__c, Remaining_Number_of_Payments__c, loan__Frequency_of_Loan_Payment__c,' +
            + ' Disbursement_Count__c, Concurrent_Interest_Rate__c' +
            + ' FROM loan__Loan_Account__c' +
            + ' WHERE loan__Loan_Status__c IN (' + eligibleLoanStatuses + ')' +
            + '     AND Disbursement_Count__c = 1' +
            + '     AND Concurrent_Eligible_Amount__c > 0' +
            + '     AND Remaining_Number_of_Payments__c > 0' +
            + '     AND loan__Invalid_Data__c = false';
    }

    global override String getRuntimeQueryForPipelinedExecution(Set<Id> records) {
        return null;
    }

    global override void doStart(Database.BatchableContext bc) {}

    global override void doExecute(Database.BatchableContext BC, List<sObject> scope) {
        try {
            LoanAccountDailyUpdateManager.setLoanAccountFields(scope);
        } catch(Exception e){
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'Concurrent Interest Rate Calculation Failed', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                null, false
            );
            errorLogDBInstance.addInsert(errorLog);
        }
        errorLogDBInstance.executeInserts();
    }

    global override void doFinish(Database.BatchableContext bc) {
    }
}