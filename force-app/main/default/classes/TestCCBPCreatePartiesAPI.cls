@IsTest
public class TestCCBPCreatePartiesAPI {
    @testSetup static void dataSetup() {
        // user usr= TestUtility.createUser( new Map<String,String>());
        Account acc=TestUtility.createAccount();
        contact con=TestUtility.createContact();
        TestUtility.runSetupData();
        genesis__Applications__c genApp=TestUtility.createApplication();
    }
    @isTest
    static void CCBPCreatePartiesAPI() {
        genesis__Applications__c acc=[select id from genesis__Applications__c limit 1];
        Map<String,Object> con= new Map<String,String>{'loan__Contact_Type__c'=>Leads.GUARANTOR ,'Birthdate' => '2000-03-11','Title__c' => 'Owner','FirstName' => 'Contact ','LastName' => ' Lastname','Email' => 'Testcontactx@email.com','MobilePhone' => ''};
        Map<String,Object> contactMap = new Map<String,Object>{
                'clcommon__Contact__r.' => con
                    };
        clcommon.Response response = new CCBPCreatePartiesAPI().invokeAction('', null, new Map<String, Object>{
           PortalConstants.APPLICATION_ID => acc.Id,
               PortalConstants.PARTY_PERSONAL_DETAILS =>JSON.serialize(contactMap)
                });
    }

    @isTest
    static void CCBPCreatePartiesAPITest() {

        State_Name_Vs_State_Code_Mapping__mdt stateNamevsStateCodeMetadata = new State_Name_Vs_State_Code_Mapping__mdt();
        stateNamevsStateCodeMetadata.DeveloperName = 'Kansas';
        stateNamevsStateCodeMetadata.MasterLabel = stateNamevsStateCodeMetadata.DeveloperName;
        stateNamevsStateCodeMetadata.short_code__c = 'KS';
        Map<String, State_Name_Vs_State_Code_Mapping__mdt> stateNamevsStateCodeMetadataMap = new Map<String, State_Name_Vs_State_Code_Mapping__mdt>();
        stateNamevsStateCodeMetadataMap.put(stateNamevsStateCodeMetadata.DeveloperName, stateNamevsStateCodeMetadata);
        CustomMetaDataHelper.stateVsStateCodeMap = stateNamevsStateCodeMetadataMap;

        Default_Portal_Owner_Mapping__mdt defaultPortalOwner = new Default_Portal_Owner_Mapping__mdt();
        defaultPortalOwner.DeveloperName = PortalConstants.DEFAULT_BROKER_PORTAL_OWNER;
        defaultPortalOwner.MasterLabel = defaultPortalOwner.DeveloperName;
        defaultPortalOwner.Owner_Email__c = 'test@uniquedomain.com';
        Map<String, Default_Portal_Owner_Mapping__mdt> defaultPortalOwnerMap = new Map<String, Default_Portal_Owner_Mapping__mdt>();
        defaultPortalOwnerMap.put(defaultPortalOwner.DeveloperName, defaultPortalOwner);
        CustomMetaDataHelper.defaultPortalOwnerMap = defaultPortalOwnerMap;

        genesis__Applications__c acc=[select id from genesis__Applications__c limit 1];
        Map<String,Object> con= new Map<String,String>{'loan__Contact_Type__c'=>Leads.GUARANTOR ,'Birthdate' => '2000-03-11','Title__c' => 'Owner','Title__c' => 'Owner','FirstName' => 'Contact ','LastName' => ' Lastname','MailingState' => ' Kansas','Email' => 'Testcontactx@email.com','MobilePhone' => ''};
        Map<String,Object> contactMap = new Map<String,Object>{
                'clcommon__Contact__r.' => con
                    };

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
      user.Email = 'test@uniquedomain.com';

      Contact con1 = [SELECT Id, Name, AccountId FROM Contact LIMIT 1];

      DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
      userDBStubInstance.genericReturnObject = new List<User>{user};
      CCBPBrokerHierarchyManager.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

      DBManagerTestsStub userDBStubInstance1 = new DBManagerTestsStub();
      userDBStubInstance1.genericReturnObject = new List<User>{user};
      CCBPCreatePartiesAPI.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance1);

      DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
      contactDBStubInstance.genericReturnObject = new List<Contact>{con1};
      CCBPCreatePartiesAPI.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);


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

        clcommon.Response response = new CCBPCreatePartiesAPI().invokeAction('', null, new Map<String, Object>{
           PortalConstants.APPLICATION_ID => application.Id,
               PortalConstants.PARTY_PERSONAL_DETAILS =>JSON.serialize(contactMap)
                });
    }

    @isTest
    static void CCBPCreatePartiesAPITestExistingContact() {

        State_Name_Vs_State_Code_Mapping__mdt stateNamevsStateCodeMetadata = new State_Name_Vs_State_Code_Mapping__mdt();
        stateNamevsStateCodeMetadata.DeveloperName = 'Kansas';
        stateNamevsStateCodeMetadata.MasterLabel = stateNamevsStateCodeMetadata.DeveloperName;
        stateNamevsStateCodeMetadata.short_code__c = 'KS';
        Map<String, State_Name_Vs_State_Code_Mapping__mdt> stateNamevsStateCodeMetadataMap = new Map<String, State_Name_Vs_State_Code_Mapping__mdt>();
        stateNamevsStateCodeMetadataMap.put(stateNamevsStateCodeMetadata.DeveloperName, stateNamevsStateCodeMetadata);
        CustomMetaDataHelper.stateVsStateCodeMap = stateNamevsStateCodeMetadataMap;

        Default_Portal_Owner_Mapping__mdt defaultPortalOwner = new Default_Portal_Owner_Mapping__mdt();
        defaultPortalOwner.DeveloperName = PortalConstants.DEFAULT_BROKER_PORTAL_OWNER;
        defaultPortalOwner.MasterLabel = defaultPortalOwner.DeveloperName;
        defaultPortalOwner.Owner_Email__c = 'test@uniquedomain.com';
        Map<String, Default_Portal_Owner_Mapping__mdt> defaultPortalOwnerMap = new Map<String, Default_Portal_Owner_Mapping__mdt>();
        defaultPortalOwnerMap.put(defaultPortalOwner.DeveloperName, defaultPortalOwner);
        CustomMetaDataHelper.defaultPortalOwnerMap = defaultPortalOwnerMap;

        genesis__Applications__c acc=[select id from genesis__Applications__c limit 1];
        Map<String,Object> con= new Map<String,String>{'loan__Contact_Type__c'=>Leads.GUARANTOR ,'Birthdate' => '2000-03-11','Title__c' => 'Owner','Title__c' => 'Owner','FirstName' => 'Contact ','LastName' => ' Lastname','MailingState' => ' Kansas','Email' => 'Testcontactx@email.com','MobilePhone' => ''};
        Map<String,Object> contactMap = new Map<String,Object>{
                'clcommon__Contact__r.' => con
                    };

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
      user.Email = 'test@uniquedomain.com';

      Contact con1 = new Contact();
      con1.LastName = 'CANPortalUser';
      con1.FirstName = 'CANUserAZ';
      con1.accountid = account.Id;

      DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
      userDBStubInstance.genericReturnObject = new List<User>{user};
      CCBPBrokerHierarchyManager.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

      DBManagerTestsStub userDBStubInstance1 = new DBManagerTestsStub();
      userDBStubInstance1.genericReturnObject = new List<User>{user};
      CCBPCreatePartiesAPI.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance1);

      DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
      contactDBStubInstance.genericReturnObject = new List<Contact>{con1};
      CCBPCreatePartiesAPI.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);


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

        clcommon.Response response = new CCBPCreatePartiesAPI().invokeAction('', null, new Map<String, Object>{
           PortalConstants.APPLICATION_ID => application.Id,
               PortalConstants.PARTY_PERSONAL_DETAILS =>JSON.serialize(contactMap)
                });
    }

    @isTest
    static void CCBPCreatePartiesAPIExistingContacts() {
        genesis__Applications__c acc=[select id from genesis__Applications__c limit 1];
        contact cont= new contact(FirstName='Contact',LastName='LastName',Email='Testcontactx@email.com',loan__Contact_Type__c=Leads.GUARANTOR);
        insert cont;
        Map<String,Object> con= new Map<String,String>{'loan__Contact_Type__c'=>Leads.GUARANTOR ,'Birthdate' => '2000-03-11','Title__c' => 'Owner','FirstName' => 'Contact','LastName' => 'Lastname','Email' => 'Testcontactx@email.com','MobilePhone' => ''};
        Map<String,Object> contactMap = new Map<String,Object>{
                'clcommon__Contact__r.' => con
                    };
        clcommon.Response response = new CCBPCreatePartiesAPI().invokeAction('', null, new Map<String, Object>{
           PortalConstants.APPLICATION_ID => acc.Id,
               PortalConstants.PARTY_PERSONAL_DETAILS =>JSON.serialize(contactMap)
                });
    }
     @isTest
    static void CCBPCreatePartiesAPIException() {
        genesis__Applications__c acc=[select id from genesis__Applications__c limit 1];
        Map<String,Object> con= new Map<String,String>{'Birthdate' => '2000-03-11','Title__c' => 'Owner','FirstName' => 'Contact ','LastName' => ' Lastname','Email' => 'Testcontactx@email.com','MobilePhone' => ''};
        Map<String,Object> contactMap = new Map<String,Object>{
                'clcommon__Contact__r.' => con
                    };
        clcommon.Response response = new CCBPCreatePartiesAPI().invokeAction('', null, new Map<String, Object>{
           PortalConstants.APPLICATION_ID => acc.Id,
               PortalConstants.PARTY_PERSONAL_DETAILS =>JSON.serialize(contactMap)
                });
    }
     @isTest
    static void CCBPCreatePartiesAPIExceptionAppIdnull() {

        clcommon.Response response = new CCBPCreatePartiesAPI().invokeAction('', null, new Map<String, Object>{
            });
    }
     @isTest
    static void CCBPCreatePartiesAPIExceptionAppIdInvalid() {
       genesis__Applications__c acc=[select id from genesis__Applications__c limit 1];
        clcommon.Response response = new CCBPCreatePartiesAPI().invokeAction('', null, new Map<String, Object>{
           PortalConstants.APPLICATION_ID => acc.Id

                });
    }
     @isTest
    static void CCBPCreatePartiesAPIAgeRest() {
        genesis__Applications__c acc=[select id from genesis__Applications__c limit 1];
        Map<String,Object> con= new Map<String,String>{'loan__Contact_Type__c'=>Leads.GUARANTOR ,'Birthdate' => '2020-03-11','Title__c' => 'Owner','FirstName' => 'Contact ','LastName' => ' Lastname','Email' => 'Testcontactx@email.com','MobilePhone' => ''};
        Map<String,Object> contactMap = new Map<String,Object>{
                'clcommon__Contact__r.' => con
                    };
        clcommon.Response response = new CCBPCreatePartiesAPI().invokeAction('', null, new Map<String, Object>{
           PortalConstants.APPLICATION_ID => acc.Id,
               PortalConstants.PARTY_PERSONAL_DETAILS =>JSON.serialize(contactMap)
                });
    }
 }