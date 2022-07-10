@isTest
private class LexisNexisFraudScoreQueueableJobTests {

    @isTest
    private static void requestLexisNexisFraudScore() {
        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        LexisNexisManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        LexisNexisManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        List<Contact> contactList = new List<Contact>();
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactList.add(contact);

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{contact};
        LexisNexisManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-0000000002"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = account.Id;

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        applicationList.add(application);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        LexisNexisManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        party.genesis__Application__c = application.Id;
        party.clcommon__Account__c = account.Id;

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = new List<clcommon__Party__c>{party};
        LexisNexisManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        LexisNexisFraudScoreQueueableJob lexisNexisFraudScoreInstance = new LexisNexisFraudScoreQueueableJob(applicationList);

        Test.startTest();
            System.enqueueJob(lexisNexisFraudScoreInstance);
        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
        System.assertEquals(1, applicationDBStubInstance.forUpdateSObjects.size());
        System.assertEquals(0, accountDBStubInstance.forUpdateSObjects.size());
    }
}