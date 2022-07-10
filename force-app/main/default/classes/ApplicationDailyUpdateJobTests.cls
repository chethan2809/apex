@isTest
private class  ApplicationDailyUpdateJobTests {

    @TestSetup
    private static void makeData(){
        TestUtility.runSetupData();
        Account account = TestUtility.createAccount();
        genesis__Applications__c application = TestUtility.createApplication();
    }
    @isTest
    private static void applicationDailyUpdateJob(){
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

        Test.startTest();
        try{
            ApplicationDailyUpdateJob.execute();
        }
        catch(Exception e) {
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

    @isTest
    private static void applicationDailyUpdateJobException() {

        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.Application_Update_Job_Size__c = null;
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;
        Exception ex;

        Test.startTest();
            try {
                ApplicationDailyUpdateJob.execute();
            }
            catch(Exception e){
                ex = e;
            }
        Test.stopTest();

        TestUtility.assertException(ex);
        System.assertEquals('Application_Update_Job_Size__c is null', ex.getMessage());
    }
}