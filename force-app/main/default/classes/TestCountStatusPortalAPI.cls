@isTest
public with sharing class TestCountStatusPortalAPI {
    @testSetup
    private static void setup() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        UserRole userRole = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'CEO' LIMIT 1];

        User adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;

        System.runAs(adminUser){
            Account account = new Account(Name = 'Test Broker Account Name');
            Insert account;

            Account childAccount = new Account(Name = 'Test Child Account Name', ParentId = account.Id);
            INSERT childAccount;

            Contact contact = new Contact(LastName = 'Test Broker Last Name', AccountId = account.Id);
            insert contact;

            User user = new User();
            user.ProfileID = [Select Id From Profile Where Name='BrokerCommunityPlus'].Id;
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

        User userRec = [SELECT Id, AccountId, ContactId FROM User WHERE Email = 'test@uniquedomain.com'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Broker Account Name'];
        System.runAs(userRec) {
            TestUtility.runSetupData();
            genesis__Applications__c application = TestUtility.createApplication();
            application.Broker_Contact__c = userRec.ContactId;
            UPDATE application;
        }
    }

    @IsTest
    static void testCountStatusPortal() {
        USER testUser = [SELECT Id FROM USER WHERE Email = 'test@uniquedomain.com'];
        Test.startTest();
        System.runAs(testUser) {
            genesis__Applications__c application = [SELECT Id, Name FROM genesis__Applications__c];
            Account testAccount = [SELECT Id FROM Account WHERE  Name = 'Test Broker Account Name'];
            Contact testContact = [SELECT Id FROM Contact WHERE AccountId = :testAccount.Id];

            clcommon__Party_Type__c partyType = new clcommon__Party_Type__c();
            partyType.Name = 'BROKER';
            insert partyType;

            clcommon__Party__c party = (clcommon__Party__c) JSON.deserialize(
            '{ "portal_bucket__c" : "Application Submitted"}' , clcommon__Party__c.class
            );

            Id applicationId = application.Id;
            Id accountId = testAccount.Id;
            Id contactId = testContact.Id;

            party.genesis__Application__c = applicationId;
            party.clcommon__Contact__c = contactId;
            party.clcommon__Account__c = accountId;
            party.OwnerId = testUser.Id;
            party.Competitor_Amount__c = 100 ;
            party.clcommon__Type__c = partyType.Id;
            insert party;

            clcommon.Response response = new CountStatusPortalAPI().invokeAction('', null, new Map<String, Object>{
                'accountId' => testAccount.Id,
                    'contactId' => testContact.Id,
                    'loanInfo' => JSON.serialize(application)
                    });

            system.assertEquals('SUCCESS',response.Status);

           Test.stopTest();
      }

    }
}