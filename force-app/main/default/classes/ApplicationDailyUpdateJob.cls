public class ApplicationDailyUpdateJob implements Schedulable, Database.Batchable<SObject> {

    @TestVisible
    private static Origination_Settings__mdt defaultDailyUpdateSetting = CustomMetaDataHelper.defaultOriginationSetting;

    public ApplicationDailyUpdateJob() {}

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Set<String> ineligibleApplicationStatuses = new Set<String> {Applications.STATUS_APPROVED, Applications.STATUS_DECLINED};

        return Database.getQueryLocator([
            SELECT Id, genesis__Status__c, genesis__Expected_First_Payment_Date__c, genesis__Expected_Start_Date__c,
                genesis__Payment_Frequency__c, Last_Status_Update_Date__c, genesis__Expected_Close_Date__c,
                Decline_Reasons__c, Pricing_Factor__c, Maximum_Funding_Amount__c, genesis__Loan_Amount__c,
                genesis__Term__c, Type__c, Auto_Renewed__c, Broker_Contact__c,
                genesis__Account__r.Days_Since_Zero_Balance_Date__c, genesis__Account__r.Is_Exclusivity__c
            FROM genesis__Applications__c
            WHERE genesis__Status__c NOT IN :ineligibleApplicationStatuses
        ]);
    }

    public void execute(Database.BatchableContext bc, List<genesis__Applications__c> applicationList) {

        ApplicationDailyUpdateManager.updateApplicationAndPricing(applicationList);

    }

    public void execute(SchedulableContext sc) {
        if (defaultDailyUpdateSetting.Application_Update_Job_Size__c == null) {
            throw new ApplicationDailyUpdateJobException('Application_Update_Job_Size__c is null');
        }
        Database.executeBatch(this, Integer.ValueOf(defaultDailyUpdateSetting.Application_Update_Job_Size__c));
    }

    public static void execute() {
        ApplicationDailyUpdateJob applicationDailyUpdateJobInstance = new ApplicationDailyUpdateJob();
        applicationDailyUpdateJobInstance.execute(null);
    }

    public void finish(Database.BatchableContext bc) {

    }

    private class ApplicationDailyUpdateJobException extends Exception {}
}