@IsTest
private class TestCCBPCompleteTaskPortalAPI {
 @testSetup
 static void dataSetup()
    {
         GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);
         UserRole userRole = [SELECT Id, DeveloperName
                             FROM UserRole
                             WHERE DeveloperName = 'CEO'
                             LIMIT 1];

         User adminUser = [SELECT Id, UserRoleId
                           FROM User
                           WHERE Profile.Name = 'System Administrator'
                           AND IsActive = true
                           LIMIT 1];
         adminUser.UserRoleId = userRole.Id;
         update adminUser;
         System.runAs(adminUser){

        Account account = new Account(Name='Test Account Name');
        insert account;
        Account childAcc = new Account (
          Name = 'childAccount',
                parent = account
        );
        insert childAcc;
         Contact contact = new Contact(LastName = 'Contact Last Name', AccountId = account.Id);
         insert contact;

         User user = new User();
         user.ProfileID = [SELECT Id
                           FROM Profile
                           WHERE Name='BrokerCommunityPlus'].Id;
         user.EmailEncodingKey = 'ISO-8859-1';
         user.LanguageLocaleKey = 'en_US';
         user.TimeZoneSidKey = 'America/New_York';
         user.LocaleSidKey = 'en_US';
         user.FirstName = 'first';
         user.LastName = 'last';
         user.Username = TestUtility.generateFakeName() + '@example.com';
         user.CommunityNickname = 'testUser123';
         user.Alias = 't1';
         user.IsActive = true;
         user.Email = 'test@uniquedomain.com';
         user.ContactId = contact.Id;
         insert user;
         }
         User testAcc = [Select Id from User where Email = 'test@uniquedomain.com'];
         System.runAs(testAcc){
            TestUtility.runSetupData();
            genesis__Applications__c genApp=TestUtility.createApplication();
            genApp.Portal_Stage__c='LoanInfo';
            Update genApp;
         }
    }

    @isTest
    private static void testCCBPCompleteTaskPortalAPI()
    {
        User testUser = [Select Id, Email from User where Email = 'test@uniquedomain.com'];
        System.runAs(testUser){
        Map<String,Object> con= new Map<String,String>{'loan__Contact_Type__c'=>Leads.GUARANTOR ,'Birthdate' => '2000-03-11','Title__c' => 'Owner','FirstName' => 'Contact ','LastName' => ' Lastname','Email' => 'Testcontactx@email.com','MobilePhone' => ''};
        Map<String,Object> contactMap = new Map<String,Object>{'clcommon__Contact__r.' => con};
        genesis__Applications__c appln =[select id from genesis__Applications__c where Portal_Stage__c='LoanInfo'];

        Task t = new Task();
        t.Status = 'Completed';
        t.genesis__Application__c = appln.Id;
        t.OwnerId = testUser.Id;
        t.Subject = 'testSub';
        t.Description = 'testDes';
        insert t;

        String htmlValue = '<table border="0" cellpadding="5" width="550" cellspacing="5" height="400" > <tr valign="top" height="400" > <td tEditID="c1r1" style=" background-color:#FFFFFF; bEditID:r3st1; color:#000000; bLabel:main; font-size:12pt; font-family:arial;" aEditID="c1r1" locked="0" > <![CDATA[<font face="arial"><span style="font-size: 12pt;">Dear&nbsp;{!'+t.CreatedBy+'},</span></font> <div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div> <div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">This is to inform you that the below task which created by you is updated as completed by the assigned broker from the broker portal. Please find and review the details of it below and act accordingly.</div> <div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div> <div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><b>Task Details:</b></div> <div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div> <table border: 1px solid #000000;> <tr> <td style="color: rgb(0, 0, 0); border: 1px solid #000000; font-family: arial; font-size: 12pt;">Application:</td> <td style="color: rgb(0, 0, 0); border: 1px solid #000000; font-family: arial; font-size: 12pt;">{!'+t.genesis__Application__c+'}</td> </tr> <tr> <td style="color: rgb(0, 0, 0); border: 1px solid #000000; font-family: arial; font-size: 12pt;">Subject:</td> <td style="color: rgb(0, 0, 0); border: 1px solid #000000; font-family: arial; font-size: 12pt;">{!'+t.Subject+'}</td> </tr> <tr> <td style="color: rgb(0, 0, 0); border: 1px solid #000000; font-family: arial; font-size: 12pt;">Status:</td> <td style="color: rgb(0, 0, 0); border: 1px solid #000000; font-family: arial; font-size: 12pt;">{!'+t.Status+'}</td> </tr> <tr> <td style="color: rgb(0, 0, 0); border: 1px solid #000000; font-family: arial; font-size: 12pt;">Comments:</td> <td style="color: rgb(0, 0, 0); border: 1px solid #000000; font-family: arial; font-size: 12pt;">{!'+t.Description+'}</td> </tr> </table> <div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div> <div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">Thanks,</div> <div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">CAN Capital</div> <div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div></td> </tr> </table>';

        Id folderId = UserInfo.getUserId();
        EmailTemplate emailTemplate = new EmailTemplate (DeveloperName = PortalConstants.UNDERWRITER_NOTIFICATION, TemplateType= 'Text', FolderId = folderId, Name = 'test', HtmlValue = htmlValue);
        insert emailTemplate;

        test.startTest();

        clcommon.Response response = new CCBPCompleteTaskPortalAPI().invokeAction('', null, new Map<String, Object>{
              PortalConstants.TASK_ID => t.Id,
              'applicationId' => appln.Id,
                  'email' => testUser.Email
                  });

        test.stopTest();
        System.assert(response != null);
        }
    }

    @isTest
    private static void testCCBPCompleteTaskPortalAPItest()
    {
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

        Task t = new Task();
        t.Status = 'Completed';
        t.genesis__Application__c = application.Id;
        t.OwnerId = user.Id;
        t.Subject = 'testSub';
        t.Description = 'testDes';
        insert t;

        String htmlValue = '<table border="0" cellpadding="5" width="550" cellspacing="5" height="400" > <tr valign="top" height="400" > <td tEditID="c1r1" style=" background-color:#FFFFFF; bEditID:r3st1; color:#000000; bLabel:main; font-size:12pt; font-family:arial;" aEditID="c1r1" locked="0" > <![CDATA[<font face="arial"><span style="font-size: 12pt;">Dear&nbsp;{!'+t.CreatedBy+'},</span></font> <div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div> <div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">This is to inform you that the below task which created by you is updated as completed by the assigned broker from the broker portal. Please find and review the details of it below and act accordingly.</div> <div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div> <div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><b>Task Details:</b></div> <div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div> <table border: 1px solid #000000;> <tr> <td style="color: rgb(0, 0, 0); border: 1px solid #000000; font-family: arial; font-size: 12pt;">Application:</td> <td style="color: rgb(0, 0, 0); border: 1px solid #000000; font-family: arial; font-size: 12pt;">{!'+t.genesis__Application__c+'}</td> </tr> <tr> <td style="color: rgb(0, 0, 0); border: 1px solid #000000; font-family: arial; font-size: 12pt;">Subject:</td> <td style="color: rgb(0, 0, 0); border: 1px solid #000000; font-family: arial; font-size: 12pt;">{!'+t.Subject+'}</td> </tr> <tr> <td style="color: rgb(0, 0, 0); border: 1px solid #000000; font-family: arial; font-size: 12pt;">Status:</td> <td style="color: rgb(0, 0, 0); border: 1px solid #000000; font-family: arial; font-size: 12pt;">{!'+t.Status+'}</td> </tr> <tr> <td style="color: rgb(0, 0, 0); border: 1px solid #000000; font-family: arial; font-size: 12pt;">Comments:</td> <td style="color: rgb(0, 0, 0); border: 1px solid #000000; font-family: arial; font-size: 12pt;">{!'+t.Description+'}</td> </tr> </table> <div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div> <div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">Thanks,</div> <div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">CAN Capital</div> <div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;"><br></div></td> </tr> </table>';

        Id folderId = UserInfo.getUserId();
        EmailTemplate emailTemplate = new EmailTemplate (DeveloperName = PortalConstants.UNDERWRITER_NOTIFICATION, TemplateType= 'Text', FolderId = folderId, Name = 'test', HtmlValue = htmlValue);

         DBManagerTestsStub emailDBStubInstance = new DBManagerTestsStub();
         emailDBStubInstance.genericReturnObject = new List<EmailTemplate>{emailTemplate};
         CCBPCompleteTaskPortalAPI.emailDBInstance = (EmailDB) Test.createStub(EmailDB.class, emailDBStubInstance);

        test.startTest();
         clcommon.Response response = new CCBPCompleteTaskPortalAPI().invokeAction('', null, new Map<String, Object>{
               PortalConstants.TASK_ID => t.Id,
               'applicationId' => application.Id,
                     'email' => user.Email
                     });
         test.stopTest();
        System.assert(response != null);
    }

    @isTest
    private static void testCCBPCompleteTaskPortalAPIExc()
    {
         User testUser = [Select Id from User where Email = 'test@uniquedomain.com'];
         System.runAs(testUser){
            test.startTest();
            clcommon.Response response = new CCBPCompleteTaskPortalAPI().invokeAction('', null, new Map<String, Object>{
            });
            test.stopTest();
         }
    }
}