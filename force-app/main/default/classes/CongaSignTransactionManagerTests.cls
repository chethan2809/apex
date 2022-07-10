@isTest(isParallel=true)
private class CongaSignTransactionManagerTests {

    @isTest
    private static void sendCongaSignChatterNotificationsTests(){

        APXT_CongaSign__Transaction__c congaSignTransaction;
        Set<Id> congaSignTransactionId = new Set<Id>();

        DBManagerTestsStub congaSignTransactionsDBInstance = new DBManagerTestsStub();
        congaSignTransactionsDBInstance.genericReturnObject = new List<APXT_CongaSign__Transaction__c> {congaSignTransaction};
        CongaSignTransactionManager.congaSignTransactionsDBInstance = (CongaSignTransactionsDB) Test.createStub(
            CongaSignTransactionsDB.class, congaSignTransactionsDBInstance
        );

        DBManagerTestsStub errorLogDBInstance = new DBManagerTestsStub();
        CongaSignTransactionManager.errorLogDBInstance = (errorLogDB) Test.createStub(errorLogDB.class, errorLogDBInstance);

        Test.startTest();
        CongaSignTransactionManager.sendCongaSignChatterNotifications(congaSignTransactionId);
        Test.stopTest();

        System.assertEquals(1, errorLogDBInstance.forInsertSObjects.size());
    }

    @isTest
    private static void updateApplicationStatusOnDocsSent() {

        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Status__c = 'OFFER ACCEPTED';
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        CongaSignTransactionManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        Test.startTest();
            CongaSignTransactionManager.updateApplicationStatusOnDocsSent(new Set<Id> {application.Id});
        Test.stopTest();

        System.assertEquals(1, applicationDBStubInstance.forUpdateSObjects.size());
        System.assertEquals(Applications.STATUS_DOCS_OUT, ((genesis__Applications__c)applicationDBStubInstance.forUpdateSObjects.get(0)).genesis__Status__c);
    }

    @isTest
    private static void doNotUpdateApplicationStatusOnDocsSent() {

        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Status__c = 'DOCS IN';
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        CongaSignTransactionManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        Test.startTest();
            CongaSignTransactionManager.updateApplicationStatusOnDocsSent(new Set<Id> {application.Id});
        Test.stopTest();

        System.assertEquals(0, applicationDBStubInstance.forUpdateSObjects.size());
    }
}