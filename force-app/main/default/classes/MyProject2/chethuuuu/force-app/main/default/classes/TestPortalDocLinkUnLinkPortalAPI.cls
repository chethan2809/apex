@isTest
public class TestPortalDocLinkUnLinkPortalAPI
{
    @testSetup
    static void dataSetup() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        Profile profile = [Select Id from Profile where name = 'System Administrator'];
        User testUser = new User(
            ProfileId = profile.Id,
            Username = TestUtility.generateFakeName() + '@example.com',
            Alias = 'test',
            Email=System.now().millisecond() + 'test2@test.com',
            EmailEncodingKey='UTF-8',
            FirstName='Bruce',
            LastName='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        insert testUser;

        Account testAccount = TestUtility.createAccount();
        testAccount.Name = 'Test Borrower';
        Update testAccount;

        Contact testContact = TestUtility.createContact();
        testContact.lastName = 'Borrower';
        Update testContact;

        TestUtility.runSetupData();
        genesis__Applications__c appln = TestUtility.createApplication();
        appln.Portal_Stage__c = 'LoanInfo';
        Update appln;
        genesis__org_parameters__c orgParams = genesis__Org_Parameters__c.getOrgDefaults();
        orgParams.genesis__Digits_After_Decimals__c = 2;
        orgParams.genesis__Rounding_Mode__c = 'Nearest';
        upsert orgParams;
    }

    @isTest
    private static void test_PortalDocLinkUnLinkPortalAPI()
    {
        User  testUser =[select id,Username,email from user limit 1];

        Account testAccount = [select id,name from account where  name='Test Borrower'];
        Contact testContact = [select id,name from contact where lastname='Borrower'];

        genesis__Applications__c appln =[select id from genesis__Applications__c where Portal_Stage__c='LoanInfo'];
        genesis__org_parameters__c orgParams =[select id from genesis__org_parameters__c] ;

        Test.startTest();

        clcommon.Response response = new PortalDocLinkUnLinkPortalAPI().invokeAction('', null, new Map<String, Object>{
                CustomConstants.APPLICATION_ID => appln.Id
        });

        Test.stopTest();
        system.assertEquals('ERROR', response.Status);
    }

    @isTest
    private static void test_PortalDocLinkUnLinkPortalAPIException()
    {
        Test.startTest();
            clcommon.Response response = new PortalDocLinkUnLinkPortalAPI().invokeAction(null, null, new Map<String, Object>{
            });
        Test.stopTest();
        system.assertEquals('ERROR', response.Status);
    }

    @isTest
    private static void test_PortalDocLinkUnLinkPortalAPIException1()
    {
        User  testUser =[select id,Username,email from user limit 1];

        Account testAccount = [select id,name from account where  name='Test Borrower'];
        Contact testContact = [select id,name from contact where lastname='Borrower'];

        genesis__Applications__c appln =[select id from genesis__Applications__c where Portal_Stage__c='LoanInfo'];
        genesis__org_parameters__c orgParams =[select id from genesis__org_parameters__c] ;

        Test.startTest();

        clcommon.Response response = new PortalDocLinkUnLinkPortalAPI().invokeAction('', null, new Map<String, Object>{
                CustomConstants.APPLICATION_ID => 1234
        });

        Test.stopTest();
        system.assertEquals('ERROR', response.Status);
    }

}