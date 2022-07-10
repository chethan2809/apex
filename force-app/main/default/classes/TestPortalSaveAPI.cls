@IsTest
public class TestPortalSaveAPI {

    @testSetup
    static void dataSetup() {

        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        Profile profile = [Select Id from Profile where name = 'System Administrator'];
        User testUser = new User(
            ProfileId = profile.Id,
            Username = TestUtility.generateFakeName() + '@example.com',
            Alias = 'test',
            Email = System.now().millisecond() + 'test2@test.com',
            EmailEncodingKey='UTF-8',
            FirstName='Bruce',
            LastName='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        insert testUser;

        Account testAccount =TestUtility.createAccount();
        testAccount.Name = 'Test Borrower';
        Update testAccount;

        Contact testContact = TestUtility.createContact();
         testContact.LastName = 'Borrower';
        Update testContact ;

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
    Static void Test_PortalSave()
    {

        User  testUser =[select id,Username,email from user limit 1];

        Account testAccount = [select id,name from account where  name='Test Borrower'];
        Contact testContact = [select id,name from contact where lastName='Borrower'];

        genesis__Applications__c appln =[select id from genesis__Applications__c where Portal_Stage__c='LoanInfo'];
        genesis__org_parameters__c orgParams =[select id from genesis__org_parameters__c] ;

        Test.startTest();
        clcommon.Response response = new PortalSaveAPI().invokeAction('', null, new Map<String, Object>{
                  'email' => testUser.Email,
                  'accountId' => testAccount.Id,
                  'acc' => testAccount,
                  'contactId' => testContact.Id,
                  'portalStage' => appln.Id,
                  'portalSubstage' => appln.Id,
                  'status' =>appln.Id,
                  CustomConstants.APPLICATION_ID => appln.Id
        });

        if(testUser.Email != null && testUser.Email == testUser.Username)
        {
            System.ResetPasswordResult result =  System.resetPassword(testUser.Id, true);

            response.status = clcommon.Constants.SUCCESS;

        }
        Test.stopTest();

        system.assertEquals('ERROR', response.Status);
    }

         @isTest
    Static void Test_PortalSaveException()
    {
        User testUser =[select id,Username,email from user limit 1];

        Account testAccount = [select id,name from account where  name='Test Borrower'];
        Contact testContact = [select id,name from contact where lastName='Borrower'];
        genesis__Applications__c appln =[select id from genesis__Applications__c where Portal_Stage__c='LoanInfo'];
        genesis__org_parameters__c orgParams =[select id from genesis__org_parameters__c] ;

        Test.startTest();
        clcommon.Response response = new PortalSaveAPI().invokeAction('', null, new Map<String, Object>{
                  'email' => testUser.Email,
                  'accountId' => testAccount.Id,
                  'acc' => testAccount,
                  'contactId' => testContact.Id,
                  CustomConstants.APPLICATION_ID => appln.Id
        });
        Test.stopTest();

        system.assertEquals(response.Status,'SUCCESS');
    }
}