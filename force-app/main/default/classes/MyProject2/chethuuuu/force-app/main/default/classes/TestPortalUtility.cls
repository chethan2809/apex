@isTest
private class TestPortalUtility{

    @testSetup
    private static void dataSetup(){
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);
        Profile profile = [Select Id from Profile where name = 'System Administrator'];
        User testUser = new User(
            ProfileId = profile.Id,
            Username = TestUtility.generateFakeName() + 'test2@test.com',
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
    private static void testPortalUtility(){
        User  testUser =[select id,Username,email from user limit 1];
        Account testAccount = [select id,name from account where  name='Test Borrower'];
        Contact testContact = [select id,name from contact where lastname='Borrower'];
        genesis__Applications__c appln =[select id from genesis__Applications__c where Portal_Stage__c='LoanInfo'];
        genesis__org_parameters__c orgParams =[select id from genesis__org_parameters__c];

        clcommon__Document_Category__c parDocCategory = new clcommon__Document_Category__c();
        parDocCategory.clcommon__Active__c = true;
        parDocCategory.clcommon__Account__c = testAccount.id;
        parDocCategory.clcommon__Status__c = 'OPEN';
        parDocCategory.clcommon__Category_Name__c = 'Others';
        insert parDocCategory;

        clcommon__Document_Category__c docCategory = new clcommon__Document_Category__c();
        docCategory.clcommon__Active__c = true;
        docCategory.clcommon__Account__c = testAccount.id;
        docCategory.genesis__Application__c = appln.id;
        docCategory.clcommon__Status__c = 'OPEN';
        docCategory.clcommon__Parent_Document_Category__c = parDocCategory.Id;
        insert docCategory;

        Test.startTest();
            genesis__applications__c actualApplication = PortalUtility.fetchApplication(appln.Id);
            List<Map<String,Object>> actualList = PortalUtility.fetchUploadedDocuments(appln, 'Others');
            clcommon.Response actualResponse = PortalUtility.setResponse('testStatus', '200', 'testError');
            clcommon.Response actualErrorResponse = PortalUtility.getErrorResponse('testError');
        Test.stopTest();

        System.assert(actualApplication != null);
        System.assert(actualList != null);
        System.assert(actualResponse != null);
        System.assert(actualErrorResponse != null);
    }
}