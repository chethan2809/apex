@isTest
public class InvocableOFACSearch_Test {

    @isTest static void ofacTest(){
        TestUtility.runSetUpData();

        Account oAccount = TestUtility.generateAccount();
        insert oAccount;

        Contact oContact = TestUtility.generateContact();
        oContact.AccountId = oAccount.Id;
        insert oContact;

        genesis__Applications__c application = TestUtility.createApplication();

        clcommon__Party__c oParty = new clcommon__Party__c();
        oParty.genesis__Application__c = application.Id;
        oParty.clcommon__Account__c = oAccount.Id;
        oParty.clcommon__Contact__c = oContact.Id;
        insert oParty;

        List<Id> lstIds= new List<Id>();
        lstIds.add(oParty.Id);

        Test.startTest();
        InvocableOFACSearch.runOFAC(lstIds);
        Test.stopTest();
    }

}