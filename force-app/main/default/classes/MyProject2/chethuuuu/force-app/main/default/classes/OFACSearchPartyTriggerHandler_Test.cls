@isTest
public class OFACSearchPartyTriggerHandler_Test {

    private static OFACSearchPartyTriggerHandler partyTriggerHandlerInstance = new OFACSearchPartyTriggerHandler();

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

        clcommon__Party__c oldParty = new clcommon__Party__c();
        oldParty.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        oldParty.clcommon__isPrimary__c = false;
        oldParty.genesis__Application__c = application.Id;

        Map<Id, clcommon__Party__c> oldPartyMap = new Map<Id, clcommon__Party__c>();
        oldPartyMap.put(oldParty.Id, oldParty);

        clcommon__Party__c newParty = new clcommon__Party__c();
        newParty.clcommon__isPrimary__c = true;
        newParty.Id = oldParty.Id;
        newParty.Run_OFAC_Check__c = true;
        newParty.clcommon__Contact__c = contact.Id;

        Map<Id, clcommon__Party__c> newPartyMap = new Map<Id, clcommon__Party__c>();
        newPartyMap.put(newParty.Id, newParty);

        Test.startTest();
        OFACSearchPartyTriggerHandler.runOFACCheck(new List<clcommon__Party__c>{newParty}, oldPartyMap);
        Test.stopTest();
    }
    /*@isTest
    static void test(){

        Account oAccount = new Account();
        oAccount.Name = 'Test Account';
        insert oAccount;

        Contact oContact = new Contact();
        oContact.FirstName = 'Marisol';
        oContact.LastName = 'Testcase';
        oContact.AccountId = oAccount.Id;
        insert oContact;

        genesis__Applications__c oApplication = new genesis__Applications__c();
        oApplication.genesis__Account__c = oAccount.Id;
        insert oApplication;

        clcommon__Party__c oParty = new clcommon__Party__c();
        oParty.clcommon__Account__c = oAccount.Id;
        oParty.clcommon__Contact__c = oContact.Id;
        oParty.genesis__Application__c = oApplication.Id;
        insert oParty;

        test.startTest();
        oParty.Run_OFAC_Check__c = true;
        update oParty;
        test.stopTest();
    }*/

}