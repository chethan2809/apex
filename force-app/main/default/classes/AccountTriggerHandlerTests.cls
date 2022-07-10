@isTest
private class AccountTriggerHandlerTests {

    @isTest
    private static void beforeInsertTests()
    {
        Account account = new Account();
        account.Name = 'collection test';
        account.Type = GeneralConstants.PARTY_TYPE_BORROWER;
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(account.Type).getRecordTypeId();
        account.Legacy_Percent_Paid__c = 76.00;
        account.BillingState = 'Ohio';
        insert account;

        Test.startTest();
            new AccountTriggerHandler().beforeInsert(new List<Account> {account});
        Test.stopTest();
    }

    @isTest
    private static void afterInsertTests()
    {
        Account account = new Account();
        account.Name = 'collection test';
        account.Type = GeneralConstants.PARTY_TYPE_BORROWER;
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(account.Type).getRecordTypeId();
        account.Legacy_AccountID__c = '0123476';
        insert account;

        Map<Id, Account> newAccountMap = new Map<Id, Account>();
        newAccountMap.put(account.Id, account);

        Test.startTest();
            new AccountTriggerHandler().afterInsert(newAccountMap);
        Test.stopTest();
    }

    @isTest
    private static void afterInsertGuarantorTests()
    {
        Account account = new Account();
        account.Name = 'collection test';
        account.Type = GeneralConstants.PARTY_TYPE_GUARANTOR;
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(account.Type).getRecordTypeId();
        account.Legacy_AccountID__c = '0123476';
        insert account;

        Map<Id, Account> newAccountMap = new Map<Id, Account>();
        newAccountMap.put(account.Id, account);

        Test.startTest();
            new AccountTriggerHandler().afterInsert(newAccountMap);
        Test.stopTest();
    }

    @isTest
    private static void beforeUpdateTests()
    {
        clcommon__Document_Definition__c documentDefinition = new clcommon__Document_Definition__c();
        documentDefinition.Name = GeneralConstants.DOCUMENT_TYPE_EXPERIAN_BUSINESS_REPORT;
        documentDefinition.Document_Category__c = 'Account';

        DBManagerTestsStub ddDBStubInstance = new DBManagerTestsStub();
        ddDBStubInstance.genericReturnObject = new List<clcommon__Document_Definition__c>{documentDefinition};
        OriginationHelper.documentDefinitionDBInstance = (DocumentDefinitionDB) Test.createStub(DocumentDefinitionDB.class, ddDBStubInstance);

        CAN_Industry_Rating_Profile__c irp = new CAN_Industry_Rating_Profile__c();
        irp.Description__c = 'BUSINESS SERVICES';
        irp.Digit_Code__c = '73';
        irp.Industry_Rating__c = 'B';

        DBManagerTestsStub irpDBStubInstance = new DBManagerTestsStub();
        irpDBStubInstance.genericReturnObject = new List<CAN_Industry_Rating_Profile__c>{irp};
        OriginationHelper.industryRatingProfileDBInstance = (IndustryRatingProfileDB) Test.createStub(IndustryRatingProfileDB.class, irpDBStubInstance);

        Account oldAcc = new Account();
        oldAcc.Sic = '083';
        oldAcc.Name = 'old Acc';
        oldAcc.Industry = 'REAL ESTATE AGENTS AND MANAGERS';
        oldAcc.BillingState = 'New York';
        insert oldAcc;

        Account newAcc = new Account();
        newAcc.Sic = '073';
        newAcc.Id = oldAcc.Id;
        newAcc.Industry = 'BUSINESS SERVICES';
        newAcc.Legacy_Percent_Paid__c = 65.00;
        newAcc.BillingState = 'Ohio';
        update newAcc;

        Map<Id, Account> oldMap = new Map<Id, Account>();
        oldMap.put(oldAcc.Id, oldAcc);
        Map<Id, Account> newMap = new Map<Id, Account>();
        newMap.put(newAcc.Id, newAcc);
        Test.startTest();
            new AccountTriggerHandler().beforeUpdate(newMap, oldMap);
        Test.stopTest();
    }

    @isTest
    private static void afterUpdateTests()
    {
        clcommon__Document_Definition__c documentDefinition = new clcommon__Document_Definition__c();
        documentDefinition.Name = GeneralConstants.DOCUMENT_TYPE_EXPERIAN_BUSINESS_REPORT;
        documentDefinition.Document_Category__c = 'Account';

        DBManagerTestsStub ddDBStubInstance = new DBManagerTestsStub();
        ddDBStubInstance.genericReturnObject = new List<clcommon__Document_Definition__c>{documentDefinition};
        OriginationHelper.documentDefinitionDBInstance = (DocumentDefinitionDB) Test.createStub(DocumentDefinitionDB.class, ddDBStubInstance);

        Account oldAcc = new Account();
        oldAcc.Id = TestUtility.getFakeId(Account.getSObjectType());
        oldAcc.Legacy_Negative_CAN_History__c = false;
        oldAcc.Name = 'old acc trigger test';

        DBManagerTestsStub accountOldDBStubInstance = new DBManagerTestsStub();
        accountOldDBStubInstance.genericReturnObject = new List<Account>{oldAcc};
        AccountTriggerHandler.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountOldDBStubInstance);

        Account newAcc = new Account();
        newAcc.Id = oldAcc.Id;
        newAcc.Legacy_Negative_CAN_History__c = true;
        newAcc.Name = 'new acc trigger test';

        DBManagerTestsStub accountNewDBStubInstance = new DBManagerTestsStub();
        accountNewDBStubInstance.genericReturnObject = new List<Account>{newAcc};
        AccountTriggerHandler.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountNewDBStubInstance);

        Account newGuarantorAcc = new Account();
        newGuarantorAcc.Id = TestUtility.getFakeId(Account.getSObjectType());
        newGuarantorAcc.Name = 'do not sync with sfmc test';

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{newGuarantorAcc};
        AccountTriggerHandler.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Contact newContact = new Contact();
        newContact.Id = TestUtility.getFakeId(Contact.getSObjectType());
        newContact.AccountId = newGuarantorAcc.Id;
        newContact.LastName = 'do not sync with sfmc test';

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{newContact};
        AccountTriggerHandler.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        List<clcommon__Reciprocal_Role__c> guarantorRoleList = [SELECT Id, Name FROM clcommon__Reciprocal_Role__c WHERE Name = :Accounts.GUARANTOR];
        Id guarantorRelationshipId = guarantorRoleList.isEmpty() ? null : guarantorRoleList[0].Id;

        clcommon__Relationship__c relationshipRecord = CLCommonRelationships.createCLCommonRelationships(newAcc.Id, newGuarantorAcc.Id, guarantorRelationshipId);

        Map<Id, Account> oldMap = new Map<Id, Account>();
        oldMap.put(oldAcc.Id, oldAcc);
        Map<Id, Account> newMap = new Map<Id, Account>();
        newMap.put(newAcc.Id, newAcc);

        Id reciprocalRoleId = TestUtility.getFakeId(clcommon__Reciprocal_Role__c.getSObjectType());
        Map<String, Id> reciprocalRoleIdByName = new Map<String, Id> {Accounts.GUARANTOR => reciprocalRoleId };
        GeneralHelper.reciprocalRoleIdByName = reciprocalRoleIdByName;

        DBManagerTestsStub clCommonRelationshipDBStubInstance = new DBManagerTestsStub();
        clCommonRelationshipDBStubInstance.genericReturnObject = new List<clcommon__Relationship__c>{relationshipRecord};
        AccountTriggerHandler.clCommonRelationshipDBInstance = (CLCommonRelationshipDB) Test.createStub(CLCommonRelationshipDB.class, clCommonRelationshipDBStubInstance);

        Test.startTest();
            new AccountTriggerHandler().afterUpdate(newMap, oldMap);
        Test.stopTest();
    }

    @IsTest
    private static void afterUpdateOwnerTests()
    {
        Map<Id, Account> oldAccountMap = new Map<Id, Account>();
        Map<Id, Account> newAccountMap = new Map<Id, Account>();

        Account newBorrowerAccount = TestUtility.createBorrowerAccount();
        Account guarantorAccount = TestUtility.createGuarantorAccount();
        Id userId = userinfo.getUserId();

        newBorrowerAccount.Type = GeneralConstants.PARTY_TYPE_BORROWER;
        newBorrowerAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(newBorrowerAccount.Type).getRecordTypeId();
        newBorrowerAccount.OwnerId = userId;

        Contact guarantorContact = new Contact();
        guarantorContact.Id = TestUtility.getFakeId(Contact.getSObjectType());
        guarantorContact.AccountId = guarantorAccount.Id;

        clcommon__Relationship__c relationshipRecord = new clcommon__Relationship__c();
        relationshipRecord.clcommon__Entity__c = newBorrowerAccount.Id;
        relationshipRecord.clcommon__Related_Entity__c = guarantorAccount.Id;

        Id reciprocalRoleId = TestUtility.getFakeId(clcommon__Reciprocal_Role__c.getSObjectType());
        Map<String, Id> reciprocalRoleIdByName = new Map<String, Id> {Accounts.GUARANTOR => reciprocalRoleId };
        GeneralHelper.reciprocalRoleIdByName = reciprocalRoleIdByName;

        DBManagerTestsStub clcommonRelationshipDBStubInstance = new DBManagerTestsStub();
        clcommonRelationshipDBStubInstance.genericReturnObject = new List<clcommon__Relationship__c> {relationshipRecord};
        AccountTriggerHandler.clCommonRelationshipDBInstance = (CLCommonRelationshipDB) Test.createStub(CLCommonRelationshipDB.class, clcommonRelationshipDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        AccountTriggerHandler.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact> {guarantorContact};
        AccountTriggerHandler.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        Account oldAccount = new Account();
        oldAccount.Id = newBorrowerAccount.Id;
        oldAccount.Name = 'Old Account Owner ID';
        oldAccount.Sic = '083';
        oldAccount.Type = Accounts.BORROWER;
        oldAccount.Industry = 'REAL ESTATE AGENTS AND MANAGERS';

        oldAccountMap.put(oldAccount.Id, oldAccount);
        newAccountMap.put(newBorrowerAccount.Id, newBorrowerAccount);

        Test.startTest();
            new AccountTriggerHandler().afterUpdate(newAccountMap, oldAccountMap);
        Test.stopTest();

        System.assertEquals(1, contactDBStubInstance.forUpdateSObjects.size());
        System.assertEquals(1, accountDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void afterUpdateWhenPAMChanged() {

        Map<Id, Account> oldAccountMap = new Map<Id, Account>();
        Map<Id, Account> newAccountMap = new Map<Id, Account>();
        Id userId = TestUtility.getFakeId(User.getSObjectType());
        Id newBrokerAccountId = TestUtility.getFakeId(Account.getSObjectType());

        User userRecord = (User) JSON.deserialize('{"AccountId" : "' + newBrokerAccountId + '"}', User.class);
        userRecord.Id = userId;

        User pamUser = new User();
        pamUser.Id = TestUtility.getFakeId(User.getSObjectType());

        Account newBrokerAccount = new Account();
        newBrokerAccount.Type = GeneralConstants.PARTY_TYPE_BROKER;
        newBrokerAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(newBrokerAccount.Type).getRecordTypeId();
        newBrokerAccount.Id = newBrokerAccountId;
        newBrokerAccount.Partner_Account_Manager__c = pamUser.Id;

        Account oldAccount = new Account();
        oldAccount.Id = newBrokerAccountId;
        oldAccount.Partner_Account_Manager__c = null;

        oldAccountMap.put(oldAccount.Id, oldAccount);
        newAccountMap.put(newBrokerAccount.Id, newBrokerAccount);

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User> {userRecord};
        AccountTriggerHandler.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        Test.startTest();
            new AccountTriggerHandler().afterUpdate(newAccountMap, oldAccountMap);
        Test.stopTest();

        System.assertEquals(1, userDBStubInstance.forUpdateSObjects.size());

        user actualUpdatedUser = (User) userDBStubInstance.forUpdateSObjects.get(0);
        System.assertEquals(userRecord.Id, actualUpdatedUser.Id);
        System.assertEquals(newBrokerAccount.Partner_Account_Manager__c, actualUpdatedUser.Partner_Account_Manager__c);
    }

    @isTest
    private static void afterUpdateForUCCFiling() {
        Map<Id, Account> oldAccountMap = new Map<Id, Account>();
        Map<Id, Account> newAccountMap = new Map<Id, Account>();

        Account newAccount = new Account();
        newAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        newAccount.UCC_Order_Number__c = '1234598';
        newAccount.Legacy_Active_Contract__c = true;
        newAccount.EIS_Extend_UCC__c = true;
        newAccountMap.put(newAccount.Id, newAccount);

        Account oldAccount = new Account();
        oldAccount.Id = newAccount.Id;
        oldAccount.UCC_Order_Number__c = null;
        oldAccountMap.put(oldAccount.Id, oldAccount);

        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        uccFiling.Account__c = newAccount.Id;

        DBManagerTestsStub uCCFilingDBStubInstance = new DBManagerTestsStub();
        AccountTriggerHandler.UCCFilingDBInstance = (UCCFilingDB) Test.createStub(UCCFilingDB.class, UCCFilingDBStubInstance);

        Test.startTest();
            new AccountTriggerHandler().afterUpdate(newAccountMap, oldAccountMap);
        Test.stopTest();

        System.assertEquals(0, uCCFilingDBStubInstance.forUpdateSObjects.size());
    }
}