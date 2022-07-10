@isTest
private class  ApplicationDailyUpdateDynamicJobTests {

    @TestSetup
    private static void makeData(){
        TestUtility.runSetupData();
        Account account = TestUtility.createAccount();
        genesis__Applications__c application = TestUtility.createApplication();
    }

    @isTest
    private static void applicationDailyUpdateDynamicJob(){
        Set<String> ineligibleApplicationStatuses = new Set<String> {'CLOSED - APPROVED','CLOSED - DECLINED'};
        Set<String> ineligiblePricingStatus = new Set<String> {
         'Archived','Rejected'
        };

        genesis__Applications__c application = [
            SELECT Id, genesis__Status__c, genesis__Expected_First_Payment_Date__c, genesis__Expected_Start_Date__c,
                genesis__Payment_Frequency__c, Last_Status_Update_Date__c, genesis__Expected_Close_Date__c,
                Decline_Reasons__c
            FROM genesis__Applications__c
            WHERE genesis__Status__c NOT IN :ineligibleApplicationStatuses];

        application.genesis__Payment_Frequency__c = 'DAILY';
        update application;

        Exception ex;
        ApplicationDailyUpdateDynamicJob applicationDailyUpdateDynamicJobInstanceCon = new ApplicationDailyUpdateDynamicJob('DUMMY String');
        ApplicationDailyUpdateDynamicJob applicationDailyUpdateDynamicJobInstance = new ApplicationDailyUpdateDynamicJob();
        applicationDailyUpdateDynamicJobInstance.doInitialize();
        applicationDailyUpdateDynamicJobInstance.getRuntimeQuery();
        applicationDailyUpdateDynamicJobInstance.getRuntimeQueryForPipelinedExecution(new Set<Id>());
        applicationDailyUpdateDynamicJobInstance.doFinish(null);

        Test.startTest();
            try {
                applicationDailyUpdateDynamicJobInstance.doExecute(null);
                Database.executeBatch(applicationDailyUpdateDynamicJobInstance);
            } catch(Exception e) {
                ex = e;
            }
        Test.stopTest();

        list<genesis__Applications__c> updatedApplication = [
            SELECT Id, genesis__Payment_Frequency__c
            FROM genesis__Applications__c
            WHERE Id = :application.Id
        ];

        System.assertEquals(1, updatedApplication.size());
        System.assertEquals(application.genesis__Payment_Frequency__c, updatedApplication.get(0).genesis__Payment_Frequency__c);
    }
}