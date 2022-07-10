@IsTest
private class TestCCBPRetrieveAccountSearchDetailsAPI{
    @testSetup static void dataSetup() {
        Account acc=TestUtility.createAccount();
        acc.name='TestBorrowerTest';
        update acc;
        contact con=TestUtility.createContact();
    }

    @IsTest
    static void CCBPRetrieveAccountSearchDetailsAPI(){
        String[] strlist=new String[]{'xyz','yz'};
        Map<String, Object> map1 =new Map<String, Object>();

        test.startTest();
            CCBPRetrieveAccountSearchDetailsAPI ccsearch=new CCBPRetrieveAccountSearchDetailsAPI();
            clcommon.Response response = ccsearch.invokeAction('abc',strlist,map1);
        test.stopTest();
        System.assert(response != null);
    }

    @IsTest
    static void CCBPRetrieveAccountSearchDetailsAPI1(){
        String[] strlist=new String[]{'xyz','yz'};
        Map<String, Object> map1 =new Map<String, Object>();

        Account testAccount =  [select id,name from account where  name='TestBorrowerTest'];

        test.startTest();
            CCBPRetrieveAccountSearchDetailsAPI ccsearch=new CCBPRetrieveAccountSearchDetailsAPI();
            clcommon.Response response = ccsearch.invokeAction('abc',strlist,map1);
        test.stopTest();
        System.assert(response != null);
    }

    @isTest
    static void CCBPRetrieveAccountSearchDetailsAPIException() {

        Id accountId = TestUtility.getFakeId(Account.getSObjectType());

        Test.startTest();
            clcommon.Response response = new CCBPRetrieveAccountSearchDetailsAPI().invokeAction('', null, new Map<String, Object>());
        Test.stopTest();
        System.assert(response != null);
    }

    @isTest
    static void CCBPRetrieveAccountSearchDetailsAPIException1() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        User user = new User();
        user.ProfileID = [Select Id From Profile Where Name='System Administrator'].Id;
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.FirstName = 'first';
        user.LastName = 'last';
        user.Username = TestUtility.generateFakeName() + 'test2@test.com';
        user.CommunityNickname = 'testUser123';
        user.Alias = 't1';
        user.Email = 'no@email.com';
        user.IsActive = true;
        insert user;

        User userRec = [SELECT Id, AccountId, ContactId FROM User WHERE LastName = 'last' LIMIT 1];

        System.runAs(userRec){
            Test.startTest();
                clcommon.Response response = new CCBPRetrieveAccountSearchDetailsAPI().invokeAction('', null, new Map<String, Object>());
            Test.stopTest();

            System.assert(response != null);
        }
    }
}