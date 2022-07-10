@isTest
public class OFACTriggerHandler_Test {

    @testSetup
    static void createTestData(){
        TestUtility.runSetupData();
        Account oAccount = TestUtility.generateAccount();
        oAccount.Name = 'Test Account';
        insert oAccount;

        Contact oContact = TestUtility.generateContact();
        oContact.FirstName = 'Marisol';
        oContact.LastName = 'Testcase';
        oContact.AccountId = oAccount.Id;
        insert oContact;

        Opportunity oppty = TestUtility.generateOpportunity(oContact.Id, oAccount.Id);
        oppty.Name = 'Test Opportunity';
        insert oppty;

        ofacchecker__OFAC__c oOFAC2 = new ofacchecker__OFAC__c();
        oOFAC2.ofacchecker__First_Name__c = 'Osama';
        oOFAC2.ofacchecker__Last_Name__c = 'Laden';
        oOFAC2.ofacchecker__Parent_Record_Id__c = oContact.Id;
        insert oOFAC2;

        genesis__Applications__c oApplication = TestUtility.createApplication();
        //oApplication.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        oApplication.genesis__Account__c = oAccount.Id;
        oApplication.genesis__Loan_Amount__c = 10000;
        oApplication.genesis__Status__c = Applications.STATUS_NEW_ENTERED;
        oApplication.Opportunity__c = oppty.Id;
        update oApplication;

        clcommon__Party__c oParty = new clcommon__Party__c();
        oParty.clcommon__Account__c = oAccount.Id;
        oParty.clcommon__Contact__c = oContact.Id;
        oParty.genesis__Application__c = oApplication.Id;
        insert oParty;
        System.debug('oParty >>' + oParty.Id);
    }

    @isTest
    public static void testOFAC(){

        List<Account> listAccounts = [Select Id from Account where Name = 'Test Account'];

        ofacchecker__OFAC__c oOFAC1 = new ofacchecker__OFAC__c();
        oOFAC1.ofacchecker__Company_Name__c = 'Bank of Kunlun';
        oOFAC1.ofacchecker__Parent_Record_Id__c = listAccounts[0].Id;

        test.startTest();
        insert oOFAC1;
        test.stopTest();
    }
}