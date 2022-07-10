@isTest
public class TestPartyUtil
{
    @isTest
    public static void TestPartyUtils()
    {
        TestUtility.runSetupData();
        Account acc=TestUtility.createAccount();
        contact con=TestUtility.createContact();
        genesis__Applications__c genApp = TestUtility.createApplication();
        clcommon__Party_Type__c partyType = new clcommon__Party_Type__c(Name = GeneralConstants.PARTY_TYPE_GUARANTOR); 
        insert partyType;
        clcommon__Party__c genParty= new clcommon__Party__c(genesis__Application__c=genApp.Id,clcommon__Type__c=partyType.Id,clcommon__Account__c=acc.id,clcommon__Contact__c=con.id); 
        insert genParty;
        Test.startTest();
        PartyUtil pu= new PartyUtil(genParty.Id);
        pu.deleteParty();
        Test.stopTest();
    }

    @isTest
    public static void TestPartyUtilsException()
    {
        Exception ex;

        Test.startTest();
        try{
        PartyUtil pu= new PartyUtil('genParty.Id');
        pu.deleteParty();
        }
        catch(exception e){
        ex = e;
        }
        Test.stopTest();
        TestUtility.assertException(ex);
    }

    @isTest
    public static void TestPartyUtilsException1()
    {
        Exception ex;
        Test.startTest();
        try{
        PartyUtil pu= new PartyUtil(' ');
        pu.deleteParty();
        }
        catch(exception e){
        ex = e;
        }
        Test.stopTest();
        TestUtility.assertException(ex);
    }
}