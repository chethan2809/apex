@isTest
private class PortalApplicationAPITests {
   @testSetup
   static void dataSetup() {

      RecordType recType = [
         SELECT Id, Name, SobjectType, DeveloperName
         FROM RecordType
         WHERE DeveloperName = 'Loan'
         AND SObjectType = 'genesis__Applications__c'
         LIMIT 1
      ];

      GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);
      UserRole userRole = [
         SELECT Id, DeveloperName
         FROM UserRole
         WHERE DeveloperName = 'CEO'
         LIMIT 1
      ];

      User adminUser = [
         SELECT Id, UserRoleId
         FROM User
         WHERE Profile.Name = 'System Administrator'
         AND IsActive = true
         LIMIT 1
      ];
      adminUser.UserRoleId = userRole.Id;
      update adminUser;

      System.runAs(adminUser){
         Account account = new Account(Name='Test Account Name');
         insert account;

         Contact contact = new Contact(LastName = 'Contact Last Name', AccountId = account.Id);
         insert contact;

         User user = new User();
         user.ProfileID = [
            SELECT Id
            FROM Profile
            WHERE Name='BorrowerOLB'
         ].Id;

         user.EmailEncodingKey = 'ISO-8859-1';
         user.LanguageLocaleKey = 'en_US';
         user.TimeZoneSidKey = 'America/New_York';
         user.LocaleSidKey = 'en_US';
         user.FirstName = 'first';
         user.LastName = 'last';
         user.Username = TestUtility.generateFakeName() + '@example.com';
         user.CommunityNickname = 'testUser123';
         user.Alias = 't1';
         user.Email = 'test@uniquedomain.com';
         user.IsActive = true;
         user.ContactId = contact.Id;
         insert user;
      }
   }

   @isTest
   static void PortalApplicationAPITest(){
      Contact con = [
         SELECT Id, Birthdate, MailingBuildingNumber__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MobilePhone
         FROM Contact
         WHERE lastname='Contact Last Name'
      ];
      genesis__Applications__c application = new genesis__Applications__c();
      application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

      clcommon__Party__c party = new clcommon__Party__c();
      party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
      party.genesis__Application__c = application.Id;
      party.clcommon__Contact__c = con.Id;

      DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
      partyDBStubInstance.genericReturnObject = new List<clcommon__Party__c>{party};
      PortalApplicationAPI.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

      DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
      contactDBStubInstance.genericReturnObject = new List<Contact>{con};
      PortalApplicationAPI.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);
     
      Map<String, Object> requestMap = new Map<String, Object>();
      requestMap.put('applicationId',application.Id);
      requestMap.put('borrowerAddr','{"Current_Street__c":"123 Townsend Street","Mailing_Building__c":"145","Current_City__c":"San Francisco","Current_State_Province__c":"Current_State_Province__c","Current_Country__c":"United States","Current_Zip_Postal_Code__c":"94107"}');
      requestMap.put('borrowerPersonalInfoName','{"DOB__c":"1998-10-06","Mobile__c":"9823457819"}');
      requestMap.put('portalStage','Home');
      requestMap.put('portalSubstage','CoBorrower Info');

      User borrowerUser = [
         SELECT Id
         FROM User
         WHERE email='test@uniquedomain.com'
      ];
      clcommon.Response response = new clcommon.Response();

      System.runAs(borrowerUser){
         Test.startTest();
            response = new PortalApplicationAPI().invokeAction('', null, requestMap);
         Test.stopTest();
      }

      System.assert(response != null);
   }

   @isTest
   static void PortalApplicationAPIErrorTest(){
      Contact con = [
         SELECT Id
         FROM Contact
         WHERE lastname='Contact Last Name'
      ];
      genesis__Applications__c application = new genesis__Applications__c();
      application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

      clcommon__Party__c party = new clcommon__Party__c();
      party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
      party.genesis__Application__c = application.Id;
      party.clcommon__Contact__c = con.Id;

      DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
      partyDBStubInstance.genericReturnObject = new List<clcommon__Party__c>{party};
      PortalApplicationAPI.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

      DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
      PortalApplicationAPI.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

      Map<String, Object> requestMap = new Map<String, Object>();

      User borrowerUser = [
         SELECT Id
         FROM User
         WHERE email='test@uniquedomain.com'
      ];
      clcommon.Response response = new clcommon.Response();

      Exception ex;
      System.runAs(borrowerUser){
         Test.startTest();
            try {
               response = new PortalApplicationAPI().invokeAction('', null, requestMap);
            } catch(Exception e){
               ex = e;
            }
         Test.stopTest();
      }

      System.assertEquals(PortalConstants.API_RESPONSE_STATUS_FAILED, response.status);
   }
}