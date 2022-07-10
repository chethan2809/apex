@isTest
private class TestPortalInitAPI {

    @IsTest
    private static void testPortalInit() {
        Test.startTest();

        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];

        Account testAccount = TestUtility.createAccount();
        testAccount.Name = 'Test Borrower';

        Update testAccount;

        Profile profile = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = (User) JSON.deserialize(
		'{ "AccountId" : "TestAccountID"}' , User.class
		);
        	portalAccountOwner1.UserRoleId = portalRole.Id;
            portalAccountOwner1.ProfileId = profile.Id;
            portalAccountOwner1.Username = TestUtility.generateFakeName() + '@example.com';
            portalAccountOwner1.Alias = 'batman';
            portalAccountOwner1.Email='bruce.wayne@wayneenterprises.com';
            portalAccountOwner1.EmailEncodingKey='UTF-8';
            portalAccountOwner1.Firstname='Bruce';
            portalAccountOwner1.Lastname='Wayne';
            portalAccountOwner1.LanguageLocaleKey='en_US';
            portalAccountOwner1.LocaleSidKey='en_US';
            portalAccountOwner1.TimeZoneSidKey='America/Chicago';

            clcommon__Party_Type__c partyType =new clcommon__Party_Type__c(Name = CustomConstants.BORROWER);
            insert partyType;
            clcommon__CL_Product__c clProduct = new clcommon__CL_Product__c(clcommon__Product_Name__c = 'Dummy Product');
            insert clProduct;

            Contact testContact = TestUtility.createContact();
             testContact.Lastname = 'Borrower';
             Update testContact;

            TestUtility.runSetupData();
            genesis__Applications__c appln = TestUtility.createApplication();

            clcommon__Party__c party = new clcommon__Party__c();
            party.clcommon__Account__c = testAccount.Id;
            party.genesis__Application__c = appln.Id;
            party.clcommon__Type__c = partyType.Id;
            insert party;

            clcommon.Response response = new PortalInitAPI().invokeAction('', null, new Map<String, Object>{
                    'accountId' => testAccount.Id,
                    'contactId' => testContact.Id,
                    'loanInfo' => JSON.serialize(appln)
            });

            system.assertEquals('SUCCESS',response.Status);

            Test.stopTest();
    }

    @IsTest
    private static void testPortalCollateralException() {

        TestUtility.runSetupData();
        genesis__Applications__c app = TestUtility.createApplication();
        Account testAccount2 = TestUtility.createAccount();
        testAccount2.Name = 'Test Borrower2';
        Update testAccount2;

        Test.startTest();
            clcommon.Response response = new PortalInitAPI().invokeAction('test', null, new Map<String, Object>{'applicationId' => testAccount2});
        Test.stopTest();

        system.assertEquals('ERROR',response.Status);
   }

    @IsTest
    private static void testPortalInit2() {

        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        Test.startTest();
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
            user.Username = TestUtility.generateFakeName() + 'test2@test.com';
            user.CommunityNickname = 'testUser123';
            user.Alias = 't1';
            user.Email = 'no@email.com';
            user.IsActive = true;
            user.ContactId = contact.Id;
            insert user;
            System.runAs(user){
            clcommon__Party_Type__c partyType =new clcommon__Party_Type__c(Name = CustomConstants.BORROWER);
            insert partyType;

            clcommon__CL_Product__c clProduct = new clcommon__CL_Product__c(clcommon__Product_Name__c = 'Dummy Product');
            insert clProduct;

            Account testAccount = TestUtility.createAccount();
            testAccount.Name = 'Test Borrower';
            Update testAccount;

            Contact testContact = TestUtility.createContact();
            testContact.Lastname = 'Borrower';
            Update testContact;

            TestUtility.runSetupData();
            genesis__Applications__c appln = TestUtility.createApplication();

            clcommon__Party__c party = new clcommon__Party__c();
            party.clcommon__Account__c = testAccount.Id;
            party.genesis__Application__c = appln.Id;
            party.clcommon__Type__c = partyType.Id;
            insert party;

            clcommon.Response response = new PortalInitAPI().invokeAction('', null, new Map<String, Object>{
                    'accountId' => testAccount.Id,
                    'contactId' => testContact.Id,
                    'loanInfo' => JSON.serialize(appln),
                    'applicationId' => appln.id
            });
            system.assertEquals(response.Status,'SUCCESS');
            }
        }
        Test.stopTest();
    }
}