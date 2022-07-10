@isTest
private class CCBPCongaAPICallerTests {

    @TestSetup
    static void makeData(){

        TestUtility.runSetupData();
        genesis__Applications__c application1 = TestUtility.createApplication();
   }

    @isTest
    private static void invokeActionTestMethod() {
        CCBPCongaAPICaller congaApiCaller = new CCBPCongaAPICaller();

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        CLSPBPortalSecurity.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub accountDBStubInstance2 = new DBManagerTestsStub();
        accountDBStubInstance2.genericReturnObject = new List<Account>{account};
        CCBPBrokerHierarchyManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance2);


        String accountIdjson = JSON.serialize(account.Id);
        User user = (User) JSON.deserialize(
            '{ "AccountId" : ' + accountIdjson + ' }', User.class
        );
        user.Id = UserInfo.getUserId();

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{user};
        CCBPBrokerHierarchyManager.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        clcommon__Relationship__c relationship = new clcommon__Relationship__c();
        relationship.clcommon__Entity__c = account.Id;
        relationship.clcommon__Related_Entity__c = account.Id;

        DBManagerTestsStub clCommonRelationshipDBStubInstance = new DBManagerTestsStub();
        clCommonRelationshipDBStubInstance.genericReturnObject = new List<clcommon__Relationship__c>{relationship};
        CCBPBrokerHierarchyManager.clCommonRelationshipDBInstance = (ClCommonRelationshipDB) Test.createStub(ClCommonRelationshipDB.class, clCommonRelationshipDBStubInstance);

        genesis__Applications__c application = [SELECT Id, Name, OwnerId
                                                FROM genesis__Applications__c
                                                LIMIT 1];

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        CLSPBPortalSecurity.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        Map<String, Object> argumentsFromPortal = new Map<String, Object>();
        argumentsFromPortal.put('partnerInfo', 'partnerInfo');
        argumentsFromPortal.put('applicationId', application.Id);
        System.Test.setMock(HttpCalloutMock.class, new CongaCalloutMock.CongaCalloutSuccessResponse());

        Test.startTest();
            clcommon.Response response = new CCBPCongaAPICaller().invokeAction('', null,argumentsFromPortal);
        Test.stopTest();

        System.assert(response.status != null);
    }

    @isTest
    private static void testInvokeActionTestMethod() {
        CCBPCongaAPICaller congaApiCaller = new CCBPCongaAPICaller();
        genesis__Applications__c application = [SELECT Id, Name, OwnerId
                                                FROM genesis__Applications__c
                                                LIMIT 1];

        Map<String, Object> argumentsFromPortal = new Map<String, Object>();
        argumentsFromPortal.put('partnerInfo','partnerInfo');
        argumentsFromPortal.put('applicationId',application.Id);

        System.Test.setMock(HttpCalloutMock.class, new CongaCalloutMock.CongaCalloutSuccessResponse());

        Test.startTest();
        clcommon.Response response1 = new CCBPCongaAPICaller().invokeAction('', null,argumentsFromPortal);
        Test.stopTest();
        System.assert(response1.status != null);
    }
}