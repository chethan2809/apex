@isTest
private class TestCCBPRetrieveAccountDetailsAPI {

    @testSetup
    static void dataSetup() {
        TestUtility.runSetupData();
        Account acc=TestUtility.createAccount();
        contact con=TestUtility.createContact();
        genesis__Applications__c genApp = TestUtility.createApplication();
        clcommon__Party_Type__c partyType = new clcommon__Party_Type__c(Name = GeneralConstants.PARTY_TYPE_GUARANTOR);
        insert partyType;
        clcommon__Party__c genParty = new clcommon__Party__c(genesis__Application__c=genApp.Id,clcommon__Type__c=partyType.Id,clcommon__Account__c=acc.id,clcommon__Contact__c=con.id);
        insert genParty;
    }

    @isTest
    private static void retrieveAccountDetailsAPI() {
        Account account = [SELECT Id, Name, Phone, Biz_Start_Date__c, Business_Tax_ID__c, BillingStreet, BillingCity, BillingState, Last_Date_of_Activity__c,
                BillingPostalCode, Last_Business_Credit_Pull__c, Sic, Customer_Since__c, Legacy_Percent_Paid__c, Legacy_Current_Balance__c,
                clcommon__Legal_Entity_Type__c, Industry, clcommon__Email__c, BillingAddress, BillingCountry,
                Doing_Business_As_Name__c, AnnualRevenue, BillingBuildingNumber__c, clcommon__Legal_Entity_Type__r.Name,
                Fax, Legacy_Average_Bounced_Number_1M__c, Legacy_Ever_Paid_Days__c,
                Legacy_Renewal_Eligible__c, Legacy_Renewal_Application_Created_Date__c, Migrated_Date__c, loan__Borrower__c,
                Type, AccountSource, Business_Name__c, Legacy_Payment_Frequency__c, Legacy_Number_of_Current_Missed_Payments__c,
                Legacy_Latest_Missed_Payment_Date__c, OwnerId, Broker_Account__c, Broker_Contact__c
                FROM Account LIMIT 1
        ];

        genesis__Applications__c application = [SELECT Id, Name, genesis__Account__c,
            (SELECT Id,clcommon__Type__r.Name, clcommon__Type__c, clcommon__Account__c, clcommon__Contact__c,
            clcommon__Contact__r.Title__c, clcommon__Contact__r.FirstName, clcommon__Contact__r.LastName, clcommon__Contact__r.Email,
            clcommon__Contact__r.MobilePhone, clcommon__Contact__r.BirthDate, clcommon__Contact__r.genesis__SSN__c,
            clcommon__Contact__r.MailingStreet, clcommon__Contact__r.MailingBuildingNumber__c, clcommon__Contact__r.MailingCity,
            clcommon__Contact__r.MailingState, clcommon__Contact__r.MailingCountry, clcommon__Contact__r.MailingPostalCode
            FROM genesis__Parties__r)
            FROM genesis__Applications__c LIMIT 1
        ];

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        CCBPRetrieveAccountDetailsAPI.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub accountDBStubInstance1 = new DBManagerTestsStub();
        accountDBStubInstance1.genericReturnObject = new List<Account>{account};
        CCBPRetrieveAccountDetailsAPI.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance1);

        DBManagerTestsStub accountDBStubInstance2 = new DBManagerTestsStub();
        accountDBStubInstance2.genericReturnObject = new List<Account>{account};
        CLSPBPortalSecurity.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance2);

        User testUser = new User();
        testUser.Id = TestUtility.getFakeId(User.getSObjectType());

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{testUser};
        CLSPBPortalSecurity.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        DBManagerTestsStub accountDBStubInstance3 = new DBManagerTestsStub();
        accountDBStubInstance3.genericReturnObject = new List<Account>{account};
        CCBPBrokerHierarchyManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance3);

        Map<String, Object> argumentsFromPortal = new Map<String, Object>();
        argumentsFromPortal.put(PortalConstants.CLICK_RECORD_ID, account.Id);
        argumentsFromPortal.put(PortalConstants.ACCOUNT_RECORD_ID, account.Id);

        Test.startTest();
            clcommon.Response response = new CCBPRetrieveAccountDetailsAPI().invokeAction('', null, argumentsFromPortal);
        Test.stopTest();

        System.assert(response != null);
    }

    @isTest
    private static void retrieveAccountDetailsAPIValidUser() {
        Account account = [SELECT Id, Name, Phone, Biz_Start_Date__c, Business_Tax_ID__c, BillingStreet, BillingCity, BillingState, Last_Date_of_Activity__c,
                BillingPostalCode, Last_Business_Credit_Pull__c, Sic, Customer_Since__c, Legacy_Percent_Paid__c, Legacy_Current_Balance__c,
                clcommon__Legal_Entity_Type__c, Industry, clcommon__Email__c, BillingAddress, BillingCountry,
                Doing_Business_As_Name__c, AnnualRevenue, BillingBuildingNumber__c, clcommon__Legal_Entity_Type__r.Name,
                Fax, Legacy_Average_Bounced_Number_1M__c, Legacy_Ever_Paid_Days__c,
                Legacy_Renewal_Eligible__c, Legacy_Renewal_Application_Created_Date__c, Migrated_Date__c, loan__Borrower__c,
                Type, AccountSource, Business_Name__c, Legacy_Payment_Frequency__c, Legacy_Number_of_Current_Missed_Payments__c,
                Legacy_Latest_Missed_Payment_Date__c, OwnerId, Broker_Account__c, Broker_Contact__c
                FROM Account LIMIT 1
        ];

        TestUtility.createReciprocalRole();

        List<clcommon__Reciprocal_Role__c> guarantorRoleList = [SELECT Id, Name
                                                                FROM clcommon__Reciprocal_Role__c
                                                                WHERE Name = :Leads.GUARANTOR];

        Id guarantorRelationshipId = guarantorRoleList.isEmpty() ? null : guarantorRoleList[0].Id;

        clcommon__Relationship__c relationship = new clcommon__Relationship__c();
        relationship.clcommon__Entity__c = account.Id;
        relationship.clcommon__Related_Entity__c = account.Id;
        relationship.clcommon__Ownership_Percentage__c = 100;
        relationship.clcommon__Relationship__c = guarantorRelationshipId;

        DBManagerTestsStub clCommonRelationshipDBStubInstance = new DBManagerTestsStub();
        clCommonRelationshipDBStubInstance.genericReturnObject = new List<clcommon__Relationship__c>{relationship};
        CCBPBrokerHierarchyManager.clCommonRelationshipDBInstance = (ClCommonRelationshipDB) Test.createStub(ClCommonRelationshipDB.class, clCommonRelationshipDBStubInstance);

        DBManagerTestsStub clCommonRelationshipDBStubInstance1 = new DBManagerTestsStub();
        clCommonRelationshipDBStubInstance1.genericReturnObject = new List<clcommon__Relationship__c>{relationship};
        CLSPBPortalSecurity.clCommonRelationshipDBInstance = (ClCommonRelationshipDB) Test.createStub(ClCommonRelationshipDB.class, clCommonRelationshipDBStubInstance1);

        DBManagerTestsStub clCommonRelationshipDBStubInstance3 = new DBManagerTestsStub();
        clCommonRelationshipDBStubInstance3.genericReturnObject = new List<clcommon__Relationship__c>{relationship};
        CCBPCreateConcurrentApplicationAPI.clCommonRelationshipDBInstance = (ClCommonRelationshipDB) Test.createStub(ClCommonRelationshipDB.class, clCommonRelationshipDBStubInstance3);


        genesis__Applications__c application = [SELECT Id, Name, genesis__Account__c,
            (SELECT Id,clcommon__Type__r.Name, clcommon__Type__c, clcommon__Account__c, clcommon__Contact__c,
            clcommon__Contact__r.Title__c, clcommon__Contact__r.FirstName, clcommon__Contact__r.LastName, clcommon__Contact__r.Email,
            clcommon__Contact__r.MobilePhone, clcommon__Contact__r.BirthDate, clcommon__Contact__r.genesis__SSN__c,
            clcommon__Contact__r.MailingStreet, clcommon__Contact__r.MailingBuildingNumber__c, clcommon__Contact__r.MailingCity,
            clcommon__Contact__r.MailingState, clcommon__Contact__r.MailingCountry, clcommon__Contact__r.MailingPostalCode
            FROM genesis__Parties__r)
            FROM genesis__Applications__c LIMIT 1
        ];

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        CCBPRetrieveAccountDetailsAPI.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub accountDBStubInstance1 = new DBManagerTestsStub();
        accountDBStubInstance1.genericReturnObject = new List<Account>{account};
        CCBPRetrieveAccountDetailsAPI.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance1);

        DBManagerTestsStub accountDBStubInstance2 = new DBManagerTestsStub();
        accountDBStubInstance2.genericReturnObject = new List<Account>{account};
        CLSPBPortalSecurity.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance2);

        String accountIdjson = JSON.serialize(account.Id);
        User user = (User) JSON.deserialize(
            '{ "AccountId" : ' + accountIdjson + ' }', User.class
        );
        user.Id = UserInfo.getUserId();
        user.Email = 'test@uniquedomain.com';

        DBManagerTestsStub userDBStubInstance1 = new DBManagerTestsStub();
        userDBStubInstance1.genericReturnObject = new List<User>{user};
        CCBPBrokerHierarchyManager.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance1);

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{user};
        CLSPBPortalSecurity.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        DBManagerTestsStub accountDBStubInstance3 = new DBManagerTestsStub();
        accountDBStubInstance3.genericReturnObject = new List<Account>{account};
        CCBPBrokerHierarchyManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance3);

        

        Map<String, Object> argumentsFromPortal = new Map<String, Object>();
        argumentsFromPortal.put(PortalConstants.CLICK_RECORD_ID, account.Id);
        argumentsFromPortal.put(PortalConstants.ACCOUNT_RECORD_ID, account.Id);

        Test.startTest();
            clcommon.Response response = new CCBPRetrieveAccountDetailsAPI().invokeAction('', null, argumentsFromPortal);
        Test.stopTest();

        System.assert(response != null);
    }

    @isTest
    private static void retrieveAccountDetailsAPIException() {

        Account account = [SELECT Id FROM ACCOUNT LIMIT 1];
        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CCBPRetrieveAccountDetailsAPI.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Test.startTest();
            clcommon.Response response = new CCBPRetrieveAccountDetailsAPI().invokeAction('', null, new Map<String, Object>{
                PortalConstants.CLICK_RECORD_ID => 'acc.id',
                PortalConstants.ACCOUNT_RECORD_ID => 'acc.id'
            });
        Test.stopTest();

        System.assert(response != null);
        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
        System.assertEquals('ERROR', response.status);
    }
}