@isTest
private class AbandonedAANNotificationJobTests {

    @TestSetup
    static void makeData(){
        TestUtility.runSetupData();
        Account accountRecord = TestUtility.createAccount();
        Opportunity opportunityRecord = TestUtility.createOpportunity();
        clcommon__CL_Product__c clProduct = TestUtility.createCLProduct();
    }

    @isTest
    private static void abandonedAANNotificationJob() {

        GeneralHelper.currentSystemDate = Date.newInstance(2017, 01, 06);

        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.AAN_Notifications_Days__c = 5;
        originationSettings.AAN_Batch_Size__c = 2000;
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;

        Account accountRecord = [
            SELECT Id
            FROM Account
            LIMIT 1
        ];

        Opportunity opportunityRecord = [
            SELECT Id
            FROM Opportunity
            LIMIT 1
        ];
        opportunityRecord.LeadSource = Leads.SOURCE_MERCHANT_PORTAL;
        update opportunityRecord;

        clcommon__CL_Product__c clProduct = [
            SELECT Id
            FROM clcommon__CL_Product__c
            LIMIT 1
        ];

        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Status__c = Applications.STATUS_NEW_ENTERED;
        application.genesis__Account__c = accountRecord.Id;
        application.Opportunity__c = opportunityRecord.Id;
        application.genesis__CL_Product__c = clProduct.Id;
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.Credit_Check_Consent__c = false;
        insert application;

        genesis__Applications__c newApplication = [
            SELECT Id, Abandon_Application__c, Last_Status_Update_Date__c
            FROM genesis__Applications__c
            LIMIT 1
        ];
        newApplication.Last_Status_Update_Date__c = GeneralHelper.currentSystemDate.addDays(-20);
        newApplication.Force_Stop_AAN__c = false;
        newApplication.Abandoned_Application_AAN_Sent__c = false;
        update newApplication;

        Exception ex;

        System.Test.startTest();
            try {
                AbandonedAANNotificationJob.execute();
            }
            catch(Exception e) {
                ex = e;
            }
        System.Test.stopTest();

        TestUtility.assertNullException(ex);

        list<genesis__Applications__c> actualApplicationList = [
            SELECT Id, AAN_Letter_Sent__c
            FROM genesis__Applications__c
            WHERE Id = :newApplication.Id
        ];

        System.assertEquals(1, actualApplicationList.size());
    }

    @isTest
    private static void abandonedAANNotificationJobCheckBatchSizeException() {

        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.AAN_Batch_Size__c = null;
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;
        Exception ex;

        System.Test.startTest();
            try {
                AbandonedAANNotificationJob.execute();
            }
            catch(Exception e) {
                ex = e;
            }
        System.Test.stopTest();

        TestUtility.assertException(ex);
        System.assertEquals(ex.getMessage(), 'AAN_Batch_Size__c is null');

    }
}