@IsTest
public class Test_SMB_PortalPartyAPI {

    @isTest
    static void test_SMB_PortalParty()
    {
       Account acc = TestUtility.createAccount();
        contact con= new contact(accountid=acc.id,firstname='Test',lastname='Borrower',email='testcontact@gmail.com');
        insert con;
        TestUtility.runSetupData();
        genesis__Applications__c genApp=TestUtility.createApplication();
        clcommon__Party_Type__c partyType =new clcommon__Party_Type__c(Name = GeneralConstants.PARTY_TYPE_GUARANTOR); 
        insert partyType;
        clcommon__Party__c genParty= new clcommon__Party__c(genesis__Application__c=genApp.Id,clcommon__Type__c=partyType.Id,clcommon__Account__c=acc.id,clcommon__Contact__c=con.id); 
        insert genParty;
        clcommon__Legal_Entity__c  lg= new clcommon__Legal_Entity__c(Name='Individual');
        insert lg;

        Test.startTest();
            clcommon.Response response = new SMB_PortalPartyAPI().invokeAction('', null, new Map<String, Object>{
                'firstName' =>'Test',
                'lastName' => 'Borrower',
                'partyType' => genParty.Id,
                'email' => 'testcontact@gmail.com',
                'applicationId' => genApp.Id
            });
        Test.stopTest();
    }

    @isTest
    static void test_SMB_PortalPartyExc()
    {
        Test.startTest();
            clcommon.Response response = new SMB_PortalPartyAPI().invokeAction('', null, null);
        Test.stopTest();
    }

    @isTest
    static void test_SMB_PortalPartyCon()
    {
        Account acc=TestUtility.createAccount();
        contact con= new contact(accountid=acc.id,firstname='Test',lastname='Borrower',email='testcontact@gmail.com');

        TestUtility.runSetupData();
        genesis__Applications__c genApp=TestUtility.createApplication();
        clcommon__Party_Type__c partyType =new clcommon__Party_Type__c(Name = GeneralConstants.PARTY_TYPE_GUARANTOR); 
        insert partyType;
        clcommon__Party__c genParty= new clcommon__Party__c(genesis__Application__c=genApp.Id,clcommon__Type__c=partyType.Id,clcommon__Account__c=acc.id); 
        insert genParty;
        clcommon__Legal_Entity__c  lg= new clcommon__Legal_Entity__c(Name='Individual');
        insert lg;

        Test.startTest();
            clcommon.Response response = new SMB_PortalPartyAPI().invokeAction('', null, new Map<String, Object>{
                'firstName' =>'Test',
                'lastName' => 'Borrower',
                'partyType' => genParty.Id,
                'email' => 'testcontact@gmail.com',
                'applicationId' => genApp.Id
            });
        Test.stopTest();
    }

    @isTest
    static void test_SMB_PortalPartyNo()
    {
       Account acc=TestUtility.createAccount();
        contact con= new contact(accountid=acc.id,firstname='Test',lastname='Borrower',email='testcontact@gmail.com');
        insert con;
        TestUtility.runSetupData();
        genesis__Applications__c genApp=TestUtility.createApplication();

        Test.startTest();
            clcommon.Response response = new SMB_PortalPartyAPI().invokeAction('', null, new Map<String, Object>{
                'firstName' =>'Test',
                'lastName' => 'Borrower',
                'email' => 'testcontact@gmail.com',
                'applicationId' => genApp.Id
            });
        Test.stopTest();
    }
}