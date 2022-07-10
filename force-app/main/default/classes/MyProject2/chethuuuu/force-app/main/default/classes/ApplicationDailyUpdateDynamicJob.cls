global class ApplicationDailyUpdateDynamicJob extends clcommon.DynamicJob {

    private Date sodDate;
    private static final String JOB_NAME = 'Application Daily Update Dynamic Job';
    private static final Integer DEFAULT_BATCH_SIZE = 150;

    global ApplicationDailyUpdateDynamicJob() {
        this(null);
    }

    public ApplicationDailyUpdateDynamicJob(String query) {
        super(JOB_NAME, query);
    }

    global override void doExecute(SchedulableContext sc) {
    }

    global override void doInitialize() {}

    global override String getRuntimeQuery() {
        String ineligibleApplicationStatuses = '\'' + Applications.STATUS_APPROVED + '\' , \'' + Applications.STATUS_DECLINED + '\'';

        return 'SELECT Id, genesis__Status__c, genesis__Expected_First_Payment_Date__c, genesis__Expected_Start_Date__c,' +
            + ' genesis__Payment_Frequency__c, Last_Status_Update_Date__c, genesis__Expected_Close_Date__c,' +
            + '    Decline_Reasons__c, Pricing_Factor__c, Maximum_Funding_Amount__c, genesis__Loan_Amount__c,' +
            + '    genesis__Term__c, Type__c, Auto_Renewed__c, Broker_Contact__c, ' +
            + '    genesis__Account__r.Days_Since_Zero_Balance_Date__c, genesis__Account__r.Is_Exclusivity__c' +
            + ' FROM genesis__Applications__c' +
            + ' WHERE genesis__Status__c NOT IN (' + ineligibleApplicationStatuses + ')';
    }

    global override String getRuntimeQueryForPipelinedExecution(Set<Id> records) {
        return null;
    }

    global override void doStart(Database.BatchableContext bc) {}

    global override void doExecute(Database.BatchableContext BC, List<sObject> scope) {
        ApplicationDailyUpdateManager.updateApplicationAndPricing(scope);
    }

    global override void doFinish(Database.BatchableContext bc) {
        Origination_Settings__mdt defaultDailyUpdateSetting = CustomMetaDataHelper.defaultOriginationSetting;
        Integer size = 20;
        if (defaultDailyUpdateSetting.Application_Update_Job_Size__c != null) {
            size = Integer.ValueOf(defaultDailyUpdateSetting.Application_Update_Job_Size__c);
        }

        loan.AccrualEntryJob accrualEntryJobInstance =  new loan.AccrualEntryJob();
        Database.executeBatch(accrualEntryJobInstance, size);
    }
}