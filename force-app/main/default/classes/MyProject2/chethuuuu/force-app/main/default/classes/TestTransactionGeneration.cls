@isTest
private class TestTransactionGeneration
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
        testContact.LastName = 'Borrower';
        Update testContact ;

        Test.startTest();
        TestUtility.runSetupData();
        genesis__Applications__c appln = TestUtility.createApplication();
        appln.Portal_Stage__c = 'LoanInfo';
        Update appln;

        genesis__org_parameters__c orgParams = genesis__Org_Parameters__c.getOrgDefaults();
        orgParams.genesis__Digits_After_Decimals__c = 2;
        orgParams.genesis__Rounding_Mode__c = 'Nearest';
        upsert orgParams;
    }

    @IsTest
    static void testTransactionGeneration() {

        User  testUser =[select id,Username,email from user limit 1];

        Account testAccount = [select id,name from account where  name='Test Borrower'];

        Profile profile = [Select Id from Profile where name = 'System Administrator'];
        Contact testContact = [select id,name,email,FirstName,LastName from contact where lastname='Borrower'];
        genesis__Applications__c appln =[select id,Portal_Stage__c from genesis__Applications__c where Portal_Stage__c='LoanInfo'];
        genesis__org_parameters__c orgParams =[select id from genesis__org_parameters__c];
        Id clContractId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        Test.startTest();

        clcommon.Response response = new TransactionGeneration().invokeAction('', null, new Map<String, Object>{
             'loanId' => null
        });
        Test.stopTest();
        System.assert(response != null);
    }
}