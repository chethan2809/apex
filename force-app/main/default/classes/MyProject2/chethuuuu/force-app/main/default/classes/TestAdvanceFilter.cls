@isTest
private class TestAdvanceFilter {
    @testSetup
    static void dataSetup() {

        Account testAccount = new Account(Name = 'Test Borrower');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Borrower', AccountId = testAccount.Id);
        insert testContact;

        TestUtility.runSetupData();
        genesis__Applications__c appln = TestUtility.createApplication();
        genesis__org_parameters__c orgParams = genesis__Org_Parameters__c.getOrgDefaults();
        orgParams.genesis__Digits_After_Decimals__c = 2;
        orgParams.genesis__Rounding_Mode__c = 'Nearest';
        upsert orgParams;
    }

    @isTest
    private static void test_AdvanceFilterException()
    {
        User testUser =[select id,Username,email from user limit 1];

        Account testAccount = [select id,name from account where  name='Test Borrower'];

        Contact testContact = [select id,name from contact where lastname='Borrower'];
        genesis__Applications__c appln =[select id,name,genesis__Expected_Start_Date__c,genesis__Expected_First_Payment_Date__c from genesis__Applications__c];
        genesis__org_parameters__c orgParams =[select id from genesis__org_parameters__c] ;

        Task t = new Task();
        t.Status = 'Completed';
        t.genesis__Application__c = appln.Id;
        insert t;

        Test.startTest();
        clcommon.Response response = new AdvanceFilter().invokeAction('', null, new Map<String, Object>{
        });
        Test.stopTest();

        System.assertEquals('Completed', t.Status);
    }

    @isTest
    private static void test_AdvanceFilter()
    {
        User testUser =[select id,Username,email from user limit 1];

        Account testAccount = [select id,name from account where  name='Test Borrower'];

        Contact testContact = [select id,name from contact where lastname='Borrower'];
        genesis__Applications__c appln =[select id,genesis__Expected_Start_Date__c,genesis__Expected_First_Payment_Date__c from genesis__Applications__c];
        genesis__org_parameters__c orgParams =[select id from genesis__org_parameters__c] ;

        Task t = new Task();
        t.Status = 'Completed';
        t.genesis__Application__c = appln.Id;
        insert t;

        Test.startTest();
        clcommon.Response response = new AdvanceFilter().invokeAction('', null, new Map<String, Object>{
                  'appNumber' => appln.Id,
                  'accountName' => testAccount.name,
                  'userAccountId' => testAccount.Id,
                  'fromDate' => appln.genesis__Expected_Start_Date__c,
                  'toDate' => appln.genesis__Expected_First_Payment_Date__c
        });
        Test.stopTest();

        System.assertEquals(appln.Id, t.genesis__Application__c);
    }

    @isTest
    private static void test_AdvanceFilter1()
    {
        User testUser =[select id,Username,email from user limit 1];

        Account testAccount = [select id,name from account where  name='Test Borrower'];

        Contact testContact = [select id,name from contact where lastname='Borrower'];
        genesis__Applications__c appln =[select id,genesis__Expected_Start_Date__c,genesis__Expected_First_Payment_Date__c from genesis__Applications__c];
        genesis__org_parameters__c orgParams =[select id from genesis__org_parameters__c] ;

        Task t = new Task();
        t.Status = 'Completed';
        t.genesis__Application__c = appln.Id;
        insert t;

        Test.startTest();
        String flag = '1';
        clcommon.Response response = new AdvanceFilter().invokeAction('', null, new Map<String, Object>{
                  'appNumber' => appln.Id,
                  'accountName' => testAccount.name,
                  'userAccountId' => testAccount.Id,
                  'fromDate' => appln.genesis__Expected_Start_Date__c,
                  'toDate' => appln.genesis__Expected_First_Payment_Date__c,
                  'keyword' => 'keyword',
                  'minLoanAmount' => 200.00,
                  'maxLoanAmount' => 1000.00,
                  'appstatusFilter' => 'NEW ENTERED',
                  'flag' => 1
        });
        AdvanceFilter.picklistValues('Account','Name');
        Test.stopTest();

        System.assertEquals('Test Borrower', testAccount.Name);
    }

    @isTest
    private static void test_AdvanceFilter2()
    {
        User testUser =[select id,Username,email from user limit 1];

        Account testAccount = [select id,name from account where  name='Test Borrower'];

        Contact testContact = [select id,name,LastName from contact where lastname='Borrower'];
        genesis__Applications__c appln =[select id,genesis__Expected_Start_Date__c,genesis__Expected_First_Payment_Date__c from genesis__Applications__c];
        genesis__org_parameters__c orgParams =[select id from genesis__org_parameters__c] ;

        Task t = new Task();
        t.Status = 'Completed';
        t.genesis__Application__c = appln.Id;
        insert t;

        Test.startTest();
        clcommon.Response response = new AdvanceFilter().invokeAction('', null, new Map<String, Object>{
                  'appNumber' => appln.Id,
                  'accountName' => testAccount.name,
                  'userAccountId' => testAccount.Id,
                  'fromDate' => appln.genesis__Expected_Start_Date__c,
                  'toDate' => appln.genesis__Expected_First_Payment_Date__c,
                  'flag' => 2
        });
        AdvanceFilter.picklistValues('Account','Name');
        Test.stopTest();

        System.assertEquals('Borrower',testContact.lastname);
    }

    @isTest
    static void test_AdvanceFilter3()
    {
        User testUser =[select id,Username,email from user limit 1];

        Account testAccount = [select id,name from account where  name='Test Borrower'];

        Contact testContact = [select id,name from contact where lastname='Borrower'];
        genesis__Applications__c appln =[select id,genesis__Expected_Start_Date__c,genesis__Expected_First_Payment_Date__c from genesis__Applications__c];
        genesis__org_parameters__c orgParams =[select id from genesis__org_parameters__c] ;

        Task t = new Task();
        t.Status = 'Completed';
        t.genesis__Application__c = appln.Id;
        insert t;

        clcommon__Party_Type__c partyType = new clcommon__Party_Type__c();
        partyType.Name = 'DEALER';
        insert partyType;

        clcommon__Party__c party = new clcommon__Party__c();
        party.clcommon__Account__c = testAccount.Id;
        party.genesis__Application__c = appln.Id;
        party.clcommon__Type__c = partyType.Id;
        insert party;

        Test.startTest();
        clcommon.Response response = new AdvanceFilter().invokeAction('', null, new Map<String, Object>{
                  'appNumber' => appln.Id,
                  'accountName' => testAccount.name,
                  'userAccountId' => testAccount.Id,
                  'fromDate' => appln.genesis__Expected_Start_Date__c,
                  'toDate' => appln.genesis__Expected_First_Payment_Date__c,
                  'flag' => 3
        });
        AdvanceFilter.picklistValues('Account','Name');
        Test.stopTest();

        System.assertEquals('DEALER', partyType.Name);
    }

    @isTest
    private static void test_AdvanceFilter4()
    {
        User testUser =[select id,Username,email from user limit 1];

        Account testAccount = [select id,name from account where  name='Test Borrower'];

        Contact testContact = [select id,name from contact where lastname='Borrower'];
        genesis__Applications__c appln =[select id,genesis__Expected_Start_Date__c,genesis__Expected_First_Payment_Date__c from genesis__Applications__c];
        genesis__org_parameters__c orgParams =[select id from genesis__org_parameters__c] ;

        Task t = new Task();
        t.Status = 'Completed';
        t.genesis__Application__c = appln.Id;
        insert t;

        clcommon__Party_Type__c partyType = new clcommon__Party_Type__c();
        partyType.Name = 'DEALER';
        insert partyType;

        clcommon__Party__c party = new clcommon__Party__c();
        party.clcommon__Account__c = testAccount.Id;
        party.genesis__Application__c = appln.Id;
        party.clcommon__Type__c = partyType.Id;
        insert party;

        Test.startTest();
        clcommon.Response response = new AdvanceFilter().invokeAction('', null, new Map<String, Object>{
                  'appNumber' => appln.Id,
                  'accountName' => testAccount.name,
                  'userAccountId' => testAccount.Id,
                  'fromDate' => appln.genesis__Expected_Start_Date__c,
                  'toDate' => appln.genesis__Expected_First_Payment_Date__c,
                  'flag' => 4
        });
        AdvanceFilter.picklistValues('Account','Name');
        Test.stopTest();

        System.assertEquals(partyType.Id, party.clcommon__Type__c);
    }

    @isTest
    static void test_AdvanceFilter5()
    {
        User testUser =[select id,Username,email from user limit 1];

        Account testAccount = [select id,name from account where  name='Test Borrower'];

        Contact testContact = [select id,name from contact where lastname='Borrower'];
        genesis__Applications__c appln =[select id,genesis__Status__c, genesis__Expected_Start_Date__c,genesis__Expected_First_Payment_Date__c from genesis__Applications__c];
        genesis__org_parameters__c orgParams =[select id from genesis__org_parameters__c] ;

        Task t = new Task();
        t.Status = 'Completed';
        t.genesis__Application__c = appln.Id;
        insert t;

        Test.startTest();
        clcommon.Response response = new AdvanceFilter().invokeAction('', null, new Map<String, Object>{
                  'appNumber' => appln.Id,
                  'accountName' => testAccount.name,
                  'userAccountId' => testAccount.Id,
                  'fromDate' => appln.genesis__Expected_Start_Date__c,
                  'toDate' => appln.genesis__Expected_First_Payment_Date__c,
                  'appstatusFilter' => 'NEW ENTERED',
                  'flag' => 5
        });
        AdvanceFilter.picklistValues('Account','Name');
        Test.stopTest();

        System.assertEquals('SUCCESS', response.status);
    }

    @isTest
    static void test_AdvanceFilter6()
    {
        User testUser =[select id,Username,email from user limit 1];

        Account testAccount = [select id,name from account where  name='Test Borrower'];

        Contact testContact = [select id,name from contact where lastname='Borrower'];
        genesis__Applications__c appln =[select id,genesis__Expected_Start_Date__c,genesis__Expected_First_Payment_Date__c from genesis__Applications__c];
        genesis__org_parameters__c orgParams =[select id from genesis__org_parameters__c] ;

        Task t = new Task();
        t.Status = 'Completed';
        t.genesis__Application__c = appln.Id;
        insert t;

        Test.startTest();
        clcommon.Response response = new AdvanceFilter().invokeAction('', null, new Map<String, Object>{
                  'appNumber' => appln.Id,
                  'accountName' => testAccount.name,
                  'userAccountId' => testAccount.Id,
                  'fromDate' => appln.genesis__Expected_Start_Date__c,
                  'toDate' => appln.genesis__Expected_First_Payment_Date__c,
                  'flag' => 6
        });
        AdvanceFilter.picklistValues('Account','Name');
        Test.stopTest();

        System.assertEquals('SUCCESS', response.status);
    }

    @isTest
    static void test_AdvanceFilter0()
    {
        User testUser =[select id,Username,email from user limit 1];

        Account testAccount = [select id,name from account where  name='Test Borrower'];

        Contact testContact = [select id,name from contact where lastname='Borrower'];
        genesis__Applications__c appln =[select id,genesis__Expected_Start_Date__c,genesis__Expected_First_Payment_Date__c from genesis__Applications__c];
        genesis__org_parameters__c orgParams =[select id from genesis__org_parameters__c] ;

        Task t = new Task();
        t.Status = 'Completed';
        t.genesis__Application__c = appln.Id;
        insert t;

        Test.startTest();
        clcommon.Response response = new AdvanceFilter().invokeAction('', null, new Map<String, Object>{
                  'appNumber' => appln.Id,
                  'accountName' => testAccount.name,
                  'userAccountId' => testAccount.Id,
                  'fromDate' => appln.genesis__Expected_Start_Date__c,
                  'toDate' => appln.genesis__Expected_First_Payment_Date__c,
                  'flag' => 0
        });
        AdvanceFilter.picklistValues('Account','Name');
        Test.stopTest();

        System.assertEquals('Key Flag Needs to be pushed', response.errorMessage);
    }

    @isTest
    private static void test_AdvanceFilternew()
    {
        User testUser =[select id,Username,email from user limit 1];

        Account testAccount = [select id,name from account where  name='Test Borrower'];

        Contact testContact = [select id,name from contact where lastname='Borrower'];
        genesis__Applications__c appln =[select id,genesis__Expected_Start_Date__c,genesis__Expected_First_Payment_Date__c from genesis__Applications__c];
        genesis__org_parameters__c orgParams =[select id from genesis__org_parameters__c] ;

        Task t = new Task();
        t.Status = 'Completed';
        t.genesis__Application__c = appln.Id;
        insert t;

        clcommon__Party_Type__c partyType = new clcommon__Party_Type__c();
        partyType.Name = 'DEALER';
        insert partyType;

        clcommon__Party__c party = new clcommon__Party__c();
        party.clcommon__Account__c = testAccount.Id;
        party.genesis__Application__c = appln.Id;
        party.clcommon__Type__c = partyType.Id;
        insert party;

        Test.startTest();
        clcommon.Response response = new AdvanceFilter().invokeAction('', null, new Map<String, Object>{
                  'appNumber' => appln.Id,
                  'accountName' => testAccount.name,
                  'userAccountId' => testAccount.Id,
                  'fromDate' => appln.genesis__Expected_Start_Date__c,
                  'toDate' => appln.genesis__Expected_First_Payment_Date__c,
                  'keyword' => 'keyword',
                  'minLoanAmount' => 200.00,
                  'maxLoanAmount' => 1000.00,
                  'appstatusFilter' => 'NEW ENTERED',
                  'flag' => 6
        });
        AdvanceFilter.picklistValues('Account','Name');
        Test.stopTest();

        System.assertNotEquals(clcommon.Constants.ERROR,response.status);
    }
}