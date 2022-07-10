@isTest
private class ExperianNotificationJobTests {
    @TestSetup
    static void makeData(){
        TestUtility.runSetupData();
        genesis__Applications__c applications = TestUtility.createApplication();
    }

    @isTest
    private static void experianNotificationJob() {

        genesis__Applications__c applications = [
            SELECT Id, genesis__Status__c, Credit_Pull_Notification_Date__c
            FROM genesis__Applications__c
        ];

        applications.genesis__Status__c = 'GUARANTOR CREDIT CHECK';
        applications.Credit_Pull_Notification_Date__c = GeneralHelper.currentSystemDate;
        applications.Credit_AAN_Sent__c = false;
        applications.Credit_Check_Consent__c = true;
        applications.SIC_Code__c = '123';
        applications.Business_Start_Date__c = GeneralHelper.currentSystemDate;
        update applications;

        Exception ex;

        System.Test.startTest();
            try {
                ExperianNotificationJob.execute();
            }
            catch(Exception e) {
                ex = e;
            }
        System.Test.stopTest();

        TestUtility.assertNullException(ex);

        list<genesis__Applications__c> actualApplicationList = [
            SELECT Id
            FROM genesis__Applications__c
            WHERE Id = :applications.Id
        ];

        System.assertEquals(1, actualApplicationList.size());

    }

    @isTest
    private static void experianNotificationJobCheckBatchSizeException() {

        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.Experian_Notification_Batch_Size__c = null;
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;
        Exception ex;

        System.Test.startTest();
            try {
                ExperianNotificationJob.execute();
            }
            catch(Exception e) {
                ex = e;
            }
        System.Test.stopTest();

        TestUtility.assertException(ex);
        System.assertEquals(ex.getMessage(), 'Experian_Notification_Batch_Size__c is null');

    }
}