@isTest
private class ExperianBusinessQueueableJobTests {

    @isTest
    private static void requestExperianBusiness() {
        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        account.Last_Business_Credit_Pull__c = null;

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        ExperianManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        ExperianManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-0000000002"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = account.Id;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ExperianManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        applicationList.add(application);

        ExperianBusinessQueueableJob experianBusinessInstance = new ExperianBusinessQueueableJob(applicationList);

        Test.startTest();
            System.enqueueJob(experianBusinessInstance);
        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
        System.assertEquals(1, applicationDBStubInstance.forUpdateSObjects.size());
        System.assertEquals(0, accountDBStubInstance.forUpdateSObjects.size());
    }
}