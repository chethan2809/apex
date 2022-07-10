@isTest
private class OcrolusQueueableJobTests {

    @isTest
    private static void requestOcrolus() {

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-0000000002"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        applicationList.add(application);

        OcrolusQueueableJob ocrolusQueueableInstance = new OcrolusQueueableJob(applicationList);

        Test.startTest();
            System.enqueueJob(ocrolusQueueableInstance);
        Test.stopTest();

        System.assertEquals(1, applicationDBStubInstance.forUpdateSObjects.size());
    }
}