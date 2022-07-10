@isTest
private class CLSPBPortalSecurityTests {

    @isTest
    private static void validApplicationTrue() {

        TestUtility.runSetupData();
        genesis__Applications__c application = TestUtility.createApplication();

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        CLSPBPortalSecurity.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        CLSPBPortalSecurity.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub accountDBStubInstance2 = new DBManagerTestsStub();
        accountDBStubInstance2.genericReturnObject = new List<Account>{account};
        CCBPBrokerHierarchyManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance2);

        Test.startTest();
            Boolean isValidApplication = CLSPBPortalSecurity.validApplication(application.Id);
        Test.stopTest();

        System.assertEquals(true, isValidApplication);
    }

    @isTest
    private static void validApplicationFalse() {

        String applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        CLSPBPortalSecurity.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub accountDBStubInstance2 = new DBManagerTestsStub();
        accountDBStubInstance2.genericReturnObject = new List<Account>{account};
        CCBPBrokerHierarchyManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance2);

        Test.startTest();
            Boolean isValidApplication = CLSPBPortalSecurity.validApplication(applicationId);
        Test.stopTest();

        System.assertEquals(false, isValidApplication);
    }

    @isTest
    private static void validateUserByBorrowerAccountIdTrue() {

        User user = new User();
        user.Id = TestUtility.getFakeId(User.getSObjectType());

        DBManagerTestsStub userDBStub = new DBManagerTestsStub();
        userDBStub.genericReturnObject = new List<User>{User};
        CLSPBPortalSecurity.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStub);

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        CLSPBPortalSecurity.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);
        
        clcommon__Relationship__c clCommonRelationship = new clcommon__Relationship__c();
        clCommonRelationship.clcommon__Entity__c = account.Id;
        clCommonRelationship.clcommon__Related_Entity__c = account.Id;
            
        DBManagerTestsStub clCommonRelationshipDBStubInstance = new DBManagerTestsStub();
        clCommonRelationshipDBStubInstance.genericReturnObject = new List<clcommon__Relationship__c>{clCommonRelationship};
        CLSPBPortalSecurity.clCommonRelationshipDBInstance = (CLCommonRelationshipDB) Test.createStub(CLCommonRelationshipDB.class, clCommonRelationshipDBStubInstance);

        DBManagerTestsStub accountDBStubInstance2 = new DBManagerTestsStub();
        accountDBStubInstance2.genericReturnObject = new List<Account>{account};
        CCBPBrokerHierarchyManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance2);

        Test.startTest();
            Boolean isValidUser = CLSPBPortalSecurity.validateUserByBorrowerAccountId(account.Id);
        Test.stopTest();

        System.assertEquals(true, isValidUser);
    }

    @isTest
    private static void validateUserByBorrowerAccountIdFalse() {

        User user = new User();
        user.Id = TestUtility.getFakeId(User.getSObjectType());

        DBManagerTestsStub userDBStub = new DBManagerTestsStub();
        userDBStub.genericReturnObject = new List<User>{User};
        CLSPBPortalSecurity.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStub);

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        CCBPBrokerHierarchyManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Test.startTest();
            Boolean isValidUser = CLSPBPortalSecurity.validateUserByBorrowerAccountId(account.Id);
        Test.stopTest();

        System.assertEquals(false, isValidUser);
    }

    @isTest
    private static void validLoggedInBrokerUserTrue() {

        Contact contact = new Contact();
        contact.Id = TestUtility.getFakeId(Contact.getSObjectType());

        User user = new User();
        user.Id = TestUtility.getFakeId(User.getSObjectType());

        DBManagerTestsStub userDBStub = new DBManagerTestsStub();
        userDBStub.genericReturnObject = new List<User>{User};
        CLSPBPortalSecurity.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStub);

        Test.startTest();
            Boolean isValidUser = CLSPBPortalSecurity.validLoggedInBrokerUser(contact.Id);
        Test.stopTest();

        System.assertEquals(true, isValidUser);
    }

    @isTest
    private static void validLoggedInBrokerUserFalse() {

        Contact contact = new Contact();
        contact.Id = TestUtility.getFakeId(Contact.getSObjectType());

        Test.startTest();
            Boolean isValidUser = CLSPBPortalSecurity.validLoggedInBrokerUser(contact.Id);
        Test.stopTest();

        System.assertEquals(false, isValidUser);
    }
}