@isTest
private class ApplicationTriggerTests {

    @isTest
    private static void applicationTriggerTest(){
        TestUtility.runSetupData();
        genesis__Applications__c application = TestUtility.createApplication();
        application.SIC_Code__c = 'DUMMY';
        update application;

        list<genesis__Applications__c> applicationList = [
            SELECT Id, SIC_Code__c
            FROM genesis__Applications__c
        ];

        System.assert(application.Id != null);
        System.assertEquals(1, applicationList.size());
        System.assertEquals(application.SIC_Code__c, applicationList[0].SIC_Code__c);
    }
}