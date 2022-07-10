@isTest
private class CANScoringQueueableJobTests {

    @isTest
    private static void requestCANScoring() {
        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CANScoringManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        CANScoringManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-0000000002"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        applicationList.add(application);

        CANScoringQueueableJob canScoringQueueableInstance = new CANScoringQueueableJob(applicationList);

        Test.startTest();
            System.enqueueJob(canScoringQueueableInstance);
        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
        System.assertEquals(1, applicationDBStubInstance.forUpdateSObjects.size());
    }
}