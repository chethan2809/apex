@isTest
private class PartyManagerTests {

    @isTest
    private static void createApplicationParties() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Id borrowerAccountId = TestUtility.getFakeId(Account.getSObjectType());
        Id guarantorAccountId = TestUtility.getFakeId(Account.getSObjectType());
        Id guarantorContactId = TestUtility.getFakeId(Contact.getSObjectType());

        User brokerUserRecord = new User();
        brokerUserRecord.Id = TestUtility.getFakeId(User.getSObjectType());
        brokerUserRecord.ContactId = guarantorContactId;

        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        party.genesis__Application__c = application.Id;

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = new List<clcommon__Party__c>{party};
        PartyManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        Test.startTest();
            PartyManager.createApplicationParties(application, borrowerAccountId, guarantorAccountId, guarantorContactId, brokerUserRecord);
        Test.stopTest();

        System.assertEquals(3, partyDBStubInstance.forInsertSObjects.size());
        System.assertEquals(party.genesis__Application__c, ((clcommon__Party__c)partyDBStubInstance.forInsertSObjects.get(0)).genesis__Application__c);

        clcommon__Party__c guarantorParty = (clcommon__Party__c) partyDBStubInstance.forInsertSObjects.get(1);
        System.assertEquals('Both', guarantorParty.Beneficial_Owner_Type__c);
    }

    @isTest
    private static void calculateTotalCompetitorAmount() {
        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>();
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Total_Competitors_Amount__c = 1000;
        applicationMap.put(application.Id, application);

        loan__Bank_Account__c bankAccount = new loan__Bank_Account__c();
        bankAccount.loan__Bank_Name__c = 'CAN Capital';
        bankAccount.loan__Bank_Account_Number__c = '1234567890';
        bankAccount.loan__Routing_Number__c = '123456789';

        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        party.genesis__Application__c = application.Id;
        party.Competitor_Amount__c = 2000;
        party.Competitor_Bank_Account__r = bankAccount;

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = new List<clcommon__Party__c>{party};
        PartyManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        PartyManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        Test.startTest();
            PartyManager.calculateTotalCompetitorAmount(applicationMap);
        Test.stopTest();

        System.assertEquals(1, applicationDBStubInstance.forUpdateSObjects.size());

        genesis__Applications__c actualApplication = (genesis__Applications__c) applicationDBStubInstance.forUpdateSObjects.get(0);
        System.assertEquals(3000, actualApplication.Total_Competitors_Amount__c);
    }

    @isTest
    private static void setCompetitorBankAccountFieldsInParty() {
        loan__Bank_Account__c bankAccount = new loan__Bank_Account__c();
        bankAccount.loan__Bank_Name__c = 'CAN Capital';
        bankAccount.loan__Bank_Account_Number__c = '1234567890';
        bankAccount.loan__Routing_Number__c = '123456789';

        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        party.Competitor_Amount__c = 2000;
        party.Competitor_Bank_Account__r = bankAccount;

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = new List<clcommon__Party__c>{party};
        PartyManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        Test.startTest();
            PartyManager.setCompetitorBankAccountFieldsInParty(new Set<Id> {party.Id});
        Test.stopTest();

        System.assertEquals(1, partyDBStubInstance.forUpdateSObjects.size());
        System.assertEquals(party.Competitor_Bank_Account_Name__c, bankAccount.loan__Bank_Name__c);
        System.assertEquals(party.Competitor_Bank_Account_Number__c, bankAccount.loan__Bank_Account_Number__c);
        System.assertEquals(party.Competitor_Bank_Routing_Number__c, bankAccount.loan__Routing_Number__c);
    }
}