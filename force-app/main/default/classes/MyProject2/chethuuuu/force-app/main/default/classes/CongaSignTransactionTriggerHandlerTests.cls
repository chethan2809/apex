@isTest
private class CongaSignTransactionTriggerHandlerTests {

    private static CongaSignTransactionTriggerHandler congaSignTransactionTriggerHandlerInstance = new CongaSignTransactionTriggerHandler();

    @isTest
    private static void afterInsertCongaSignForStatusSent() {

        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Status__c = 'OFFER ACCEPTED';
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        CongaSignTransactionManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        APXT_CongaSign__Transaction__c newCongaSignTransaction = new APXT_CongaSign__Transaction__c();
        newCongaSignTransaction.Id = TestUtility.getFakeId(APXT_CongaSign__Transaction__c.getSObjectType());
        newCongaSignTransaction.Parent_a6t__c = application.Id;
        newCongaSignTransaction.APXT_CongaSign__Status__c = 'SENT';

        DBManagerTestsStub congaSignTransactionsDBInstance = new DBManagerTestsStub();
        congaSignTransactionsDBInstance.genericReturnObject = new List<APXT_CongaSign__Transaction__c>{newCongaSignTransaction};
        CongaSignTransactionTriggerHandler.congaSignTransactionsDBInstance = (congaSignTransactionsDB) Test.createStub(congaSignTransactionsDB.class, congaSignTransactionsDBInstance);

        Map<Id, APXT_CongaSign__Transaction__c> newCongaSignMap = new Map<Id, APXT_CongaSign__Transaction__c>();
        newCongaSignMap.put(newCongaSignTransaction.Id, newCongaSignTransaction);

        Test.startTest();
            congaSignTransactionTriggerHandlerInstance.afterInsert(newCongaSignMap);
        Test.stopTest();

        System.assertEquals(1, applicationDBStubInstance.forUpdateSObjects.size());
        System.assertEquals(Applications.STATUS_DOCS_OUT, ((genesis__Applications__c)applicationDBStubInstance.forUpdateSObjects.get(0)).genesis__Status__c);
    }

    @isTest
    private static void afterUpdateCongaSignForStatusSent() {

        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Status__c = 'OFFER ACCEPTED';
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        CongaSignTransactionManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        APXT_CongaSign__Transaction__c oldCongaSignTransaction = new APXT_CongaSign__Transaction__c();
        oldCongaSignTransaction.Id = TestUtility.getFakeId(APXT_CongaSign__Transaction__c.getSObjectType());

        Map<Id, APXT_CongaSign__Transaction__c> oldCongaSignMap = new Map<Id, APXT_CongaSign__Transaction__c>();
        oldCongaSignMap.put(oldCongaSignTransaction.Id, oldCongaSignTransaction);

        APXT_CongaSign__Transaction__c newCongaSignTransaction = new APXT_CongaSign__Transaction__c();
        newCongaSignTransaction.Id = oldCongaSignTransaction.Id;
        newCongaSignTransaction.Parent_a6t__c = application.Id;
        newCongaSignTransaction.APXT_CongaSign__Status__c = 'SENT';

        DBManagerTestsStub congaSignTransactionsDBInstance = new DBManagerTestsStub();
        congaSignTransactionsDBInstance.genericReturnObject = new List<APXT_CongaSign__Transaction__c>{newCongaSignTransaction};
        CongaSignTransactionTriggerHandler.congaSignTransactionsDBInstance = (congaSignTransactionsDB) Test.createStub(congaSignTransactionsDB.class, congaSignTransactionsDBInstance);


        Map<Id, APXT_CongaSign__Transaction__c> newCongaSignMap = new Map<Id, APXT_CongaSign__Transaction__c>();
        newCongaSignMap.put(newCongaSignTransaction.Id, newCongaSignTransaction);

        Test.startTest();
            congaSignTransactionTriggerHandlerInstance.afterUpdate(newCongaSignMap, oldCongaSignMap);
        Test.stopTest();

        System.assertEquals(1, applicationDBStubInstance.forUpdateSObjects.size());
        System.assertEquals(Applications.STATUS_DOCS_OUT, ((genesis__Applications__c)applicationDBStubInstance.forUpdateSObjects.get(0)).genesis__Status__c);
    }
}