@isTest
private class PartyTriggerHandlerTests {

    private static PartyTriggerHandler partyTriggerHandlerInstance = new PartyTriggerHandler();

    @isTest
    private static void afterUpdate() {
        Account account = TestUtility.createAccount();
        Contact contact = TestUtility.createContact();

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Status__c = Applications.STATUS_NEW_ENTERED;
        application.Opportunity__c = TestUtility.getFakeId(Opportunity.getSObjectType());
        application.Primary_Guarantor__c = contact.Id;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        PartyTriggerHandler.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Id = application.Opportunity__c;
        newOpportunity.StageName = 'New';
        newOpportunity.Primary_Contact__c = contact.Id;

        DBManagerTestsStub opportunityDBStubInstance = new DBManagerTestsStub();
        opportunityDBStubInstance.genericReturnObject = new List<Opportunity>{newOpportunity};
        PartyTriggerHandler.opportunityDBInstance = (OpportunityDB) Test.createStub(OpportunityDB.class, opportunityDBStubInstance);

        clcommon__Party_Type__c partyTypeCompetitor = new clcommon__Party_Type__c();
        partyTypeCompetitor.Name = GeneralConstants.PARTY_TYPE_COMPETITOR;
        partyTypeCompetitor.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());

        Map<String, Id> partyTypeToId = new Map<String, Id>();
        partyTypeToId.put(partyTypeCompetitor.Name, partyTypeCompetitor.Id);
        OriginationHelper.partyTypeToId = partyTypeToId;

        clcommon__Party__c oldParty = new clcommon__Party__c();
        oldParty.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        oldParty.clcommon__isPrimary__c = false;
        oldParty.genesis__Application__c = application.Id;
        oldParty.clcommon__Type__c = partyTypeCompetitor.Id;
        oldParty.Competitor_Bank_Account__c = TestUtility.getFakeId(loan__Bank_Account__c.getSObjectType());
        oldParty.Competitor_Amount__c = 1000;


        Map<Id, clcommon__Party__c> oldPartyMap = new Map<Id, clcommon__Party__c>();
        oldPartyMap.put(oldParty.Id, oldParty);

        clcommon__Party__c newParty = new clcommon__Party__c();
        newParty.clcommon__isPrimary__c = true;
        newParty.Id = oldParty.Id;
        newParty.clcommon__Contact__c = contact.Id;
        newParty.genesis__Application__c = application.Id;
        newParty.clcommon__Type__c = partyTypeCompetitor.Id;
        newParty.Competitor_Bank_Account__c = TestUtility.getFakeId(loan__Bank_Account__c.getSObjectType());
        newParty.Competitor_Amount__c = 2000;

        Map<Id, clcommon__Party__c> newPartyMap = new Map<Id, clcommon__Party__c>();
        newPartyMap.put(newParty.Id, newParty);

        clcommon__Relationship__c relationShip =  new clcommon__Relationship__c();
        relationShip.Id = TestUtility.getFakeId(clcommon__Relationship__c.getSObjectType());

        DBManagerTestsStub clCommonRelationshipDBInstance = new DBManagerTestsStub();
        clCommonRelationshipDBInstance.genericReturnObject = new List<clcommon__Relationship__c>{relationShip};
        PartyTriggerHandler.clCommonRelationshipDBInstance = (CLCommonRelationshipDB) Test.createStub(CLCommonRelationshipDB.class, clCommonRelationshipDBInstance);

        DBManagerTestsStub applicationManagerDBStubInstance = new DBManagerTestsStub();
        applicationManagerDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        PartyManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationManagerDBStubInstance);

        Test.startTest();
            partyTriggerHandlerInstance.afterUpdate(newPartyMap, oldPartyMap);
        Test.stopTest();

        System.assertEquals(1, applicationDBStubInstance.forUpdateSObjects.size());
        System.assertEquals(1, opportunityDBStubInstance.forUpdateSObjects.size());
        System.assertEquals(application.Primary_Guarantor__c, ((genesis__Applications__c)applicationDBStubInstance.forUpdateSObjects.get(0)).Primary_Guarantor__c);
    }

    @isTest
    private static void afterInsert() {

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        clcommon__Party_Type__c partyTypeCompetitor = new clcommon__Party_Type__c();
        partyTypeCompetitor.Name = GeneralConstants.PARTY_TYPE_COMPETITOR;
        partyTypeCompetitor.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());

        Map<String, Id> partyTypeToId = new Map<String, Id>();
        partyTypeToId.put(partyTypeCompetitor.Name, partyTypeCompetitor.Id);
        OriginationHelper.partyTypeToId = partyTypeToId;

        loan__Bank_Account__c bankAccount = new loan__Bank_Account__c();
        bankAccount.Id = TestUtility.getFakeId(loan__Bank_Account__c.getSObjectType());
        bankAccount.loan__Bank_Name__c = 'CAN Capital';
        bankAccount.loan__Bank_Account_Number__c = '123456789';
        bankAccount.loan__Routing_Number__c = '123456789';

        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        party.clcommon__isPrimary__c = false;
        party.genesis__Application__c = application.Id;
        party.clcommon__Type__c = partyTypeCompetitor.Id;
        party.Competitor_Amount__c = 2000;
        party.Competitor_Bank_Account__c = bankAccount.Id;
        party.Competitor_Bank_Account__r = bankAccount;

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = new List<clcommon__Party__c>{party};
        PartyManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        PartyManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        Test.startTest();
            partyTriggerHandlerInstance.afterInsert(new List<clcommon__Party__c>{party});
        Test.stopTest();

        System.assertEquals(bankAccount.loan__Bank_Name__c, party.Competitor_Bank_Account_Name__c);
        System.assertEquals(bankAccount.loan__Bank_Account_Number__c, party.Competitor_Bank_Account_Number__c);
        System.assertEquals(bankAccount.loan__Routing_Number__c, party.Competitor_Bank_Routing_Number__c);
    }

    @isTest
    private static void afterDelete() {

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        clcommon__Party_Type__c partyTypeCompetitor = new clcommon__Party_Type__c();
        partyTypeCompetitor.Name = GeneralConstants.PARTY_TYPE_COMPETITOR;
        partyTypeCompetitor.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());

        Map<String, Id> partyTypeToId = new Map<String, Id>();
        partyTypeToId.put(partyTypeCompetitor.Name, partyTypeCompetitor.Id);
        OriginationHelper.partyTypeToId = partyTypeToId;

        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        party.clcommon__isPrimary__c = false;
        party.genesis__Application__c = application.Id;
        party.clcommon__Type__c = partyTypeCompetitor.Id;
        party.Competitor_Amount__c = 2000;

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = new List<clcommon__Party__c>{party};
        PartyManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        PartyManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        Test.startTest();
            partyTriggerHandlerInstance.afterDelete(new List<clcommon__Party__c>{party});
        Test.stopTest();

        System.assert(party != null);
    }
}