@isTest
private class PortalSecurityUtilTests {

    @isTest
    private static void validateUserApplication() {
        String applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        Test.startTest();
            Boolean actualValue = PortalSecurityUtil.validateUserApplication(applicationId);
        Test.stopTest();

        System.assertEquals(true, actualValue);
    }
    
    @isTest
    private static void validateUserByBorrowerAccountId(){
        
        //String applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        
		Contact con = new Contact();
		con.Id = TestUtility.getFakeId(Contact.getSObjectType());
        
        //List<User> getBrokerUserDetailsByLoggedInId = new List<User>();
        User user = new User();
        user.Username = 'test@uniquedomain.com';
        user.Email = 'no@email.com';
        user.ContactId = con.Id;
        user.Phone = '9988003366';
		//user.AccountId = account.Id;
        
        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
		userDBStubInstance.genericReturnObject = new List<User>{user};
		PortalSecurityUtil.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);
        
        Test.startTest();
            Boolean actualValue = PortalSecurityUtil.validateUserByBorrowerAccountId(account.Id);
        Test.stopTest();
    }
}