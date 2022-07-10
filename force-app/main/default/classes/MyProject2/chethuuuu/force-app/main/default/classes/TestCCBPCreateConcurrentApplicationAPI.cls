@IsTest
public class TestCCBPCreateConcurrentApplicationAPI {

    @isTest
    static void CCBPCreateConcurrentApplicationAPI()
    {
        TestUtility.runSetupData();
        genesis__Applications__c application1 = TestUtility.createApplication();
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

        DBManagerTestsStub clCommonRelationshipDBStubInstance1 = new DBManagerTestsStub();
        clCommonRelationshipDBStubInstance1.genericReturnObject = new List<clcommon__Relationship__c>{relationship};
        CLSPBPortalSecurity.clCommonRelationshipDBInstance = (ClCommonRelationshipDB) Test.createStub(ClCommonRelationshipDB.class, clCommonRelationshipDBStubInstance1);

        genesis__Applications__c application = [SELECT Id, Name, OwnerId
                                                FROM genesis__Applications__c
                                                LIMIT 1];

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        CLSPBPortalSecurity.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance1 = new DBManagerTestsStub();
        CCBPCreateConcurrentApplicationAPI.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance1);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CCBPCreateConcurrentApplicationAPI.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        map<String,String> currentAccountDetails= new Map<String,String>{'Id' => account.id,'Max_Funding_Amount__c'=>'1000', 'What_is_used_for__c' =>'Expansion','Annual_Volume__c'=> '10','Concurrent_Eligible_Amount_Portal__c'=>'10'};
        map<String,String> applicationDetails= new Map<String,String>{'Id' => application.id,'Application__r.genesis__Payment_Frequency__c'=>'Daily', 'Application__r.genesis__Term__c' =>'12'};

        test.startTest();
        clcommon.Response response = new CCBPCreateConcurrentApplicationAPI().invokeAction('', null, new Map<String, Object>{
            PortalConstants.CONCURRENT_ACCOUNT_DETAILS => JSON.serialize(currentAccountDetails),
            PortalConstants.APPLICATION_DETAILS => JSON.serialize(applicationDetails)});
        test.stoptest();
        System.assert(response != null);
    }

    @isTest
    static void CCBPCreateConcurrentApplicationAPI1()
    {
        TestUtility.runSetupData();
        genesis__Applications__c application1 = TestUtility.createApplication();
        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        account.Migrated_Date__c=GeneralHelper.currentSystemDate;
        account.Migrated_From__c='EIS';
        account.Type = GeneralConstants.PARTY_TYPE_BORROWER;
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(account.Type).getRecordTypeId();

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        CLSPBPortalSecurity.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub accountDBStubInstance2 = new DBManagerTestsStub();
        accountDBStubInstance2.genericReturnObject = new List<Account>{account};
        CCBPBrokerHierarchyManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance2);

        DBManagerTestsStub accountDBStubInstance3 = new DBManagerTestsStub();
        accountDBStubInstance3.genericReturnObject = new List<Account>{account};
        CCBPCreateConcurrentApplicationAPI.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance3);

        General_Setting__mdt generalSettingMetadata = new General_Setting__mdt();
        generalSettingMetadata.DeveloperName = 'Link Guarantor For Migrated Concrt App';
        generalSettingMetadata.MasterLabel = generalSettingMetadata.DeveloperName;
        generalSettingMetadata.Link_Guarantor_For_Migrated_Concrt_App__c = true;
        Map<String, General_Setting__mdt> generalSettingMetadataMap = new Map<String, General_Setting__mdt>();
        generalSettingMetadataMap.put(generalSettingMetadata.DeveloperName, generalSettingMetadata);
        CustomMetaDataHelper.defaultGeneralSetting = generalSettingMetadata;

        Default_Portal_Owner_Mapping__mdt defaultPortalOwner = new Default_Portal_Owner_Mapping__mdt();
        defaultPortalOwner.DeveloperName = PortalConstants.DEFAULT_BROKER_PORTAL_OWNER;
        defaultPortalOwner.MasterLabel = defaultPortalOwner.DeveloperName;
        defaultPortalOwner.Owner_Email__c = 'test@uniquedomain.com';
        Map<String, Default_Portal_Owner_Mapping__mdt> defaultPortalOwnerMap = new Map<String, Default_Portal_Owner_Mapping__mdt>();
        defaultPortalOwnerMap.put(defaultPortalOwner.DeveloperName, defaultPortalOwner);
        CustomMetaDataHelper.defaultPortalOwnerMap = defaultPortalOwnerMap;

        String accountIdjson = JSON.serialize(account.Id);
        User user = (User) JSON.deserialize(
            '{ "AccountId" : ' + accountIdjson + ' }', User.class
        );
        user.Id = UserInfo.getUserId();
        user.Email = 'test@uniquedomain.com';

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{user};
        CCBPBrokerHierarchyManager.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        DBManagerTestsStub userDBStubInstance1 = new DBManagerTestsStub();
        userDBStubInstance1.genericReturnObject = new List<User>{user};
        CCBPCreateConcurrentApplicationAPI.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance1);

        clcommon__Relationship__c relationship = new clcommon__Relationship__c();
        relationship.clcommon__Entity__c = account.Id;
        relationship.clcommon__Related_Entity__c = account.Id;

        DBManagerTestsStub clCommonRelationshipDBStubInstance = new DBManagerTestsStub();
        clCommonRelationshipDBStubInstance.genericReturnObject = new List<clcommon__Relationship__c>{relationship};
        CCBPBrokerHierarchyManager.clCommonRelationshipDBInstance = (ClCommonRelationshipDB) Test.createStub(ClCommonRelationshipDB.class, clCommonRelationshipDBStubInstance);

        DBManagerTestsStub clCommonRelationshipDBStubInstance1 = new DBManagerTestsStub();
        clCommonRelationshipDBStubInstance1.genericReturnObject = new List<clcommon__Relationship__c>{relationship};
        CLSPBPortalSecurity.clCommonRelationshipDBInstance = (ClCommonRelationshipDB) Test.createStub(ClCommonRelationshipDB.class, clCommonRelationshipDBStubInstance1);

        genesis__Applications__c application = [SELECT Id, Name, OwnerId
                                                FROM genesis__Applications__c
                                                LIMIT 1];

        Contact con = [SELECT Id, Name, AccountId FROM Contact LIMIT 1];

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        CLSPBPortalSecurity.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{con};
        CCBPCreateConcurrentApplicationAPI.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance1 = new DBManagerTestsStub();
        CCBPCreateConcurrentApplicationAPI.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance1);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CCBPCreateConcurrentApplicationAPI.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        map<String,String> currentAccountDetails= new Map<String,String>{'Id' => account.id,'Max_Funding_Amount__c'=>'1000', 'What_is_used_for__c' =>'Expansion','Annual_Volume__c'=> '10','Concurrent_Eligible_Amount_Portal__c'=>'10'};
        map<String,String> applicationDetails= new Map<String,String>{'Id' => application.id,'Application__r.genesis__Payment_Frequency__c'=>'Daily', 'Application__r.genesis__Term__c' =>'12'};

        test.startTest();
        clcommon.Response response = new CCBPCreateConcurrentApplicationAPI().invokeAction('', null, new Map<String, Object>{
            PortalConstants.CONCURRENT_ACCOUNT_DETAILS => JSON.serialize(currentAccountDetails),
            PortalConstants.APPLICATION_DETAILS => JSON.serialize(applicationDetails)});
        test.stoptest();
        System.assert(response != null);
    }

    @isTest
    static void CCBPCreateConcurrentApplicationAPI2()
    {
        TestUtility.runSetupData();
        genesis__Applications__c application1 = TestUtility.createApplication();

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        account.Migrated_Date__c = null;
        account.Migrated_From__c = null;
        account.Type = GeneralConstants.PARTY_TYPE_BORROWER;
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(account.Type).getRecordTypeId();

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        CLSPBPortalSecurity.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub accountDBStubInstance2 = new DBManagerTestsStub();
        accountDBStubInstance2.genericReturnObject = new List<Account>{account};
        CCBPBrokerHierarchyManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance2);

        DBManagerTestsStub accountDBStubInstance3 = new DBManagerTestsStub();
        accountDBStubInstance3.genericReturnObject = new List<Account>{account};
        CCBPCreateConcurrentApplicationAPI.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance3);

        General_Setting__mdt generalSettingMetadata = new General_Setting__mdt();
        generalSettingMetadata.DeveloperName = 'Link Guarantor For Migrated Concrt App';
        generalSettingMetadata.MasterLabel = generalSettingMetadata.DeveloperName;
        generalSettingMetadata.Link_Guarantor_For_Migrated_Concrt_App__c = true;
        Map<String, General_Setting__mdt> generalSettingMetadataMap = new Map<String, General_Setting__mdt>();
        generalSettingMetadataMap.put(generalSettingMetadata.DeveloperName, generalSettingMetadata);
        CustomMetaDataHelper.defaultGeneralSetting = generalSettingMetadata;

        Default_Portal_Owner_Mapping__mdt defaultPortalOwner = new Default_Portal_Owner_Mapping__mdt();
        defaultPortalOwner.DeveloperName = PortalConstants.DEFAULT_BROKER_PORTAL_OWNER;
        defaultPortalOwner.MasterLabel = defaultPortalOwner.DeveloperName;
        defaultPortalOwner.Owner_Email__c = 'test@uniquedomain.com';
        Map<String, Default_Portal_Owner_Mapping__mdt> defaultPortalOwnerMap = new Map<String, Default_Portal_Owner_Mapping__mdt>();
        defaultPortalOwnerMap.put(defaultPortalOwner.DeveloperName, defaultPortalOwner);
        CustomMetaDataHelper.defaultPortalOwnerMap = defaultPortalOwnerMap;

        String accountIdjson = JSON.serialize(account.Id);
        User user = (User) JSON.deserialize(
            '{ "AccountId" : ' + accountIdjson + ' }', User.class
        );
        user.Id = UserInfo.getUserId();
        user.Email = 'test@uniquedomain.com';

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{user};
        CCBPBrokerHierarchyManager.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        DBManagerTestsStub userDBStubInstance1 = new DBManagerTestsStub();
        userDBStubInstance1.genericReturnObject = new List<User>{user};
        CCBPCreateConcurrentApplicationAPI.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance1);

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

        genesis__Applications__c application = [SELECT Id, Name, OwnerId
                                                FROM genesis__Applications__c
                                                LIMIT 1];

        Contact con = [SELECT Id, Name, AccountId FROM Contact LIMIT 1];

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        CLSPBPortalSecurity.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{con};
        CCBPCreateConcurrentApplicationAPI.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance1 = new DBManagerTestsStub();
        CCBPCreateConcurrentApplicationAPI.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance1);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CCBPCreateConcurrentApplicationAPI.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        DBManagerTestsStub opportunityDBStubInstance = new DBManagerTestsStub();
        CCBPCreateConcurrentApplicationAPI.opportunityDBInstance = (OpportunityDB) Test.createStub(OpportunityDB.class, opportunityDBStubInstance);

        map<String,String> currentAccountDetails= new Map<String,String>{'Id' => account.id,'Max_Funding_Amount__c'=>'1000', 'What_is_used_for__c' =>'Expansion','Annual_Volume__c'=> '10','Concurrent_Eligible_Amount_Portal__c'=>'10'};
        map<String,String> applicationDetails= new Map<String,String>{'Id' => application.id,'Application__r.genesis__Payment_Frequency__c'=>'Daily', 'Application__r.genesis__Term__c' =>'12'};

        test.startTest();
        clcommon.Response response = new CCBPCreateConcurrentApplicationAPI().invokeAction('', null, new Map<String, Object>{
            PortalConstants.CONCURRENT_ACCOUNT_DETAILS => JSON.serialize(currentAccountDetails),
            PortalConstants.APPLICATION_DETAILS => JSON.serialize(applicationDetails)});
        test.stoptest();
        System.assert(response != null);
    }

     @isTest
    static void CCBPCreateConcurrentApplicationAPIMigrationnull()
    {
        Account acc= TestUtility.createAccount();

        Account acc2= TestUtility.createAccount();

        Contact con = new Contact(FirstName = 'Test', LastName = 'Borrower',accountid=acc2.id);
        insert con ;
        //Contact con2 = new Contact(FirstName = 'Test2', LastName = 'Borrower2',accountid=acc.id);
        //insert con2 ;
        AccountContactRelation acr= new AccountContactRelation(accountid=acc.Id,contactid=con.id);
        Insert acr;
        map<String,String> currentAccountDetails= new Map<String,String>{'Id' => acc.id,'Max_Funding_Amount__c'=>'1000', 'What_is_used_for__c' =>'Expansion','Annual_Volume__c'=> '10','Concurrent_Eligible_Amount_Portal__c'=>'10'};
        test.startTest();
        clcommon.Response response = new CCBPCreateConcurrentApplicationAPI().invokeAction('', null, new Map<String, Object>{
         PortalConstants.CONCURRENT_ACCOUNT_DETAILS => JSON.serialize(currentAccountDetails)

                });
        test.stoptest();
    }
     @isTest
    static void CCBPCreateConcurrentApplicationAPINone()
    {
        Account acc= TestUtility.createAccount();
        acc.Migrated_From__c='ABC';
        acc.Type='Borrower';
        //acc.Concurrent_Eligible__c=True;
        update acc;
       Account acc2= TestUtility.createAccount();

        Contact con = new Contact(FirstName = 'Test', LastName = 'Borrower',accountid=acc2.id);
        insert con ;
        //Contact con2 = new Contact(FirstName = 'Test2', LastName = 'Borrower2',accountid=acc.id);
        //insert con2 ;
        AccountContactRelation acr= new AccountContactRelation(accountid=acc.Id,contactid=con.id);
        Insert acr;
        clcommon__Reciprocal_Role__c crr1= new clcommon__Reciprocal_Role__c(Name=Leads.GUARANTOR);
        insert crr1;
        clcommon__Relationship__c cr= new clcommon__Relationship__c(clcommon__Related_Entity__c=acc.id,clcommon__Entity__c=acc.id,clcommon__Relationship__c=crr1.Id,clcommon__Ownership_Percentage__c=100);
        Insert cr;
        map<String,String> currentAccountDetails= new Map<String,String>{'Id' => acc.id,'Max_Funding_Amount__c'=>'1000', 'What_is_used_for__c' =>'Expansion','Annual_Volume__c'=> '10','Concurrent_Eligible_Amount_Portal__c'=>'10'};
        test.startTest();
        clcommon.Response response = new CCBPCreateConcurrentApplicationAPI().invokeAction('', null, new Map<String, Object>{
         PortalConstants.CONCURRENT_ACCOUNT_DETAILS => JSON.serialize(currentAccountDetails)

                });
        test.stoptest();
        System.assert(response != null);
    }
}