@isTest
private class TestCCBPBrokerProfileEditAPI {

    @isTest
	private static void brokerProfileEditAPIPhone() {

        Contact con = TestUtility.generateContact();
        con.MobilePhone = '9191919191';
        Insert con;

        User testUser = (User) JSON.deserialize(
            '{ "AccountId" : "accountId"}' , User.class
        );
        testUser.Email = 'no@email.com';
        testUser.ContactId = con.Id;
        testUser.Id = TestUtility.getFakeId(User.getSObjectType());

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{testUser};
        CCBPBrokerProfileEditAPI.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        DBManagerTestsStub userDBStubInstance2 = new DBManagerTestsStub();
        userDBStubInstance2.genericReturnObject = new List<User>{testUser};
        CLSPBPortalSecurity.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance2);

        Test.startTest();
            clcommon.Response response = new CCBPBrokerProfileEditAPI().invokeAction('', null, new Map<String, Object>{
                PortalConstants.BROKER_CONTACT_DETAILS => JSON.serialize(con),
                    PortalConstants.EDIT_TYPE => PortalConstants.PHONE
            });
        Test.stopTest();

        System.assertEquals('SUCCESS', response.Status);
	}

    @isTest
	private static void brokerProfileEditAPIEmail(){

        Contact con = TestUtility.generateContact();
        con.MobilePhone = '9191919191';
        Insert con;

        User testUser = (User) JSON.deserialize(
            '{ "AccountId" : "accountId"}' , User.class
        );
        testUser.Email = 'no@email.com';
        testUser.ContactId = con.Id;
        testUser.Id = TestUtility.getFakeId(User.getSObjectType());

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{testUser};
        CCBPBrokerProfileEditAPI.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        DBManagerTestsStub userDBStubInstance2 = new DBManagerTestsStub();
        userDBStubInstance2.genericReturnObject = new List<User>{testUser};
        CLSPBPortalSecurity.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance2);

        Test.startTest();
            clcommon.Response response = new CCBPBrokerProfileEditAPI().invokeAction('', null, new Map<String, Object>{
                PortalConstants.BROKER_CONTACT_DETAILS => JSON.serialize(con),
                    PortalConstants.EDIT_TYPE => PortalConstants.EMAIL
            });
        Test.stopTest();

        System.assertEquals('SUCCESS', response.Status);
	}

    @isTest
	private static void brokerProfileEditAPIAddress(){

        Contact con = TestUtility.generateContact();
        con.MobilePhone = '9191919191';
        Insert con;

        User testUser = (User) JSON.deserialize(
            '{ "AccountId" : "accountId"}' , User.class
        );
        testUser.Email = 'no@email.com';
        testUser.ContactId = con.Id;
        testUser.Id = TestUtility.getFakeId(User.getSObjectType());

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{testUser};
        CCBPBrokerProfileEditAPI.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        DBManagerTestsStub userDBStubInstance2 = new DBManagerTestsStub();
        userDBStubInstance2.genericReturnObject = new List<User>{testUser};
        CLSPBPortalSecurity.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance2);

        Test.startTest();
            clcommon.Response response = new CCBPBrokerProfileEditAPI().invokeAction('', null, new Map<String, Object>{
                PortalConstants.BROKER_CONTACT_DETAILS => JSON.serialize(con),
                    PortalConstants.EDIT_TYPE => PortalConstants.ADDRESS
            });
        Test.stopTest();

        System.assertEquals('SUCCESS', response.Status);
	}

    @isTest
	private static void brokerProfileEditAPILoggedInUserFalse(){

        Contact con = TestUtility.generateContact();
        con.MobilePhone = '9191919191';
        Insert con;

        User testUser = (User) JSON.deserialize(
            '{ "AccountId" : "accountId"}' , User.class
        );
        testUser.Email = 'no@email.com';
        testUser.ContactId = con.Id;
        testUser.Id = TestUtility.getFakeId(User.getSObjectType());

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{testUser};
        CCBPBrokerProfileEditAPI.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        DBManagerTestsStub userDBStubInstance2 = new DBManagerTestsStub();
        CLSPBPortalSecurity.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance2);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CCBPBrokerProfileEditAPI.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Test.startTest();
            clcommon.Response response = new CCBPBrokerProfileEditAPI().invokeAction('', null, new Map<String, Object>{
                PortalConstants.BROKER_CONTACT_DETAILS => JSON.serialize(con),
                    PortalConstants.EDIT_TYPE => PortalConstants.ADDRESS
            });
            String actualValue = new CCBPBrokerProfileEditAPI().getNamespaceForObjectName();
        Test.stopTest();

        System.assertEquals('genesis__', actualValue);
        System.assertEquals('ERROR', response.Status);
        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
	}

    @isTest
	private static void brokerProfileEditAPIException(){

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CCBPBrokerProfileEditAPI.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Test.startTest();
            clcommon.Response response = new CCBPBrokerProfileEditAPI().invokeAction('', null, new Map<String, Object>{
                PortalConstants.BROKER_CONTACT_DETAILS => null,
                    PortalConstants.EDIT_TYPE => null
            });
        Test.stopTest();

        System.assertEquals('ERROR', response.Status);
        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
	}
}