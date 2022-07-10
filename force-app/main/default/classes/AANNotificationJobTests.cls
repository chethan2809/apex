@isTest
private class AANNotificationJobTests {

    @TestSetup
    static void makeData(){
        TestUtility.runSetupData();
        Account accountRecord = TestUtility.createAccount();
        Opportunity opportunityRecord = TestUtility.createOpportunity();
        clcommon__CL_Product__c clProduct = TestUtility.createCLProduct();
    }

    @isTest
    private static void aanNotificationJob() {

        GeneralHelper.currentSystemDate = Date.newInstance(2017, 01, 06);

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

        clcommon__CL_Product__c clProduct = [
            SELECT Id
            FROM clcommon__CL_Product__c
            LIMIT 1
        ];

        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Status__c = 'CLOSED - DECLINED';
        application.genesis__Account__c = accountRecord.Id;
        application.Opportunity__c = opportunityRecord.Id;
        application.genesis__CL_Product__c = clProduct.Id;
        insert application;

        genesis__Applications__c newApplication = [
            SELECT Id
            FROM genesis__Applications__c
            LIMIT 1
        ];

        newApplication.Last_Status_Update_Date__c = GeneralHelper.currentSystemDate.addDays(-20);
        newApplication.Type__c = 'New';
        newApplication.Auto_Renewed__c = false;
        newApplication.Decline_Reasons__c = 'Time in Business;Negative History with CAN';
        newApplication.AAN_Letter_Sent__c = false;
        newApplication.Force_Stop_AAN__c = false;
        newApplication.Credit_Check_Consent__c = true;
        update newApplication;

        Map<String, AAN_Decline_Code_Mapping__mdt> declineCodeMap = CustomMetaDataHelper.declineCodeMap;
        AAN_Decline_Code_Mapping__mdt declineCodeMetaData = new AAN_Decline_Code_Mapping__mdt();
        declineCodeMetaData.Apply_for_AAN__c = true;
        declineCodeMap.put('Time in Business', declineCodeMetaData);
        CustomMetaDataHelper.declineCodeMap = declineCodeMap;

        Exception ex;

        System.Test.startTest();
            try {
                AANNotificationJob.execute();
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
    private static void aanNotificationJobCheckBatchSizeException() {

        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.AAN_Batch_Size__c = null;
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;
        Exception ex;

        System.Test.startTest();
            try {
                AANNotificationJob.execute();
            }
            catch(Exception e) {
                ex = e;
            }
        System.Test.stopTest();

        TestUtility.assertException(ex);
        System.assertEquals(ex.getMessage(), 'AAN_Batch_Size__c is null');

    }

}