@isTest
private class OcrolusSchedulableTests {

    @isTest
    private static void OcrolusSchedule() {
        String cronExp = '0 0 12 1 1 ? *';

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-0000000002"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        applicationList.add(application);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        OcrolusManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Test.startTest();
            String jobId = System.schedule('OcrolusSchedulableTests',  cronExp, new OcrolusSchedulable(applicationList));
            CronTrigger triggerCron = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                                        FROM CronTrigger 
                                        WHERE id = :jobId];
            System.assertEquals(cronExp, triggerCron.CronExpression);
            System.assertEquals(0, triggerCron.TimesTriggered);
        Test.stopTest();

        System.assertEquals(0, applicationDBStubInstance.forUpdateSObjects.size());
        System.assertEquals(0, errorLogDBStubInstance.forInsertSObjects.size());
    }
}