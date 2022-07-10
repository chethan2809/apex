@isTest
private class UnderWriterTaskManagerTests {

    @isTest
    private static void createUnderWriterTasks() {

        Map<String, UnderWriter_Task_Category_Mapping__mdt> underWriterTaskMap = CustomMetaDataHelper.underWriterTaskCategoryMapping;

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        applicationList.add(application);

        Contact contactRecord = TestUtility.generateContact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());

        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        party.genesis__Application__c = application.Id;
        party.clcommon__Contact__r = contactRecord;

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = new List<clcommon__Party__c>{party};
        UnderWriterTaskManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        DBManagerTestsStub underWriterTaskDBStubInstance = new DBManagerTestsStub();
        UnderWriterTaskManager.underWriterTaskDBInstance = (UnderWriterTaskDB) Test.createStub(UnderWriterTaskDB.class, underWriterTaskDBStubInstance);

        Test.startTest();
            UnderWriterTaskManager.createUnderWriterTasks(applicationList);
        Test.stopTest();

        List<UnderWriter_Task__c> insertedTaskDetailList = underWriterTaskDBStubInstance.forInsertSObjects;

        System.assertEquals(application.Id, insertedTaskDetailList[0].Application__c);
    }
}