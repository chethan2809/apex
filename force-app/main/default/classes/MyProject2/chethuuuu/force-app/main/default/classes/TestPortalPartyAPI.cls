@isTest
public with sharing class TestPortalPartyAPI {
    @IsTest
    static void testPortalParty() {

        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        Test.StartTest();
        Profile profile = [Select Id from Profile where name = 'System Administrator'];
        User testUser = new User(
            ProfileId = profile.Id,
            Username = TestUtility.generateFakeName() + '@example.com',
            Alias = 'test',
            Email=System.now().millisecond() + 'test1@test.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        insert testUser;

        System.runAs ( testUser ) {
            clcommon__Party_Type__c partyType =new clcommon__Party_Type__c(Name = CustomConstants.BORROWER);
            insert partyType;

            clcommon__CL_Product__c clProduct = new clcommon__CL_Product__c(clcommon__Product_Name__c = 'Dummy Product');
            insert clProduct;

            clcommon__Reciprocal_Role__c recRole = new clcommon__Reciprocal_Role__c();
            recRole.Name = 'test role';
            recRole.clcommon__Inverse_Role__c = 'Team member';
            insert recRole;

            Account testAccount = new Account(Name = 'Test Borrower');
            insert testAccount;

            Contact testContact = new Contact(FirstName = 'Test', LastName = 'Borrower', ints__SSN__c = 'ASN098239M',
                                              AccountId = testAccount.Id, genesis__SSN__c = 'WDH982335W',
                                             clcommon__Years_At_Current_Address__c = 2, BirthDate = Date.newInstance(1976, 12, 9));
            insert testContact ;

            TestUtility.runSetupData();
            genesis__Applications__c appln = TestUtility.createApplication();

            List<genesis__income__c> incomeList = new List<genesis__income__c>();
            genesis__income__c income;
            income = new genesis__income__c(
                    genesis__Amount__c = 5000,
                    genesis__Application__c = appln.Id,
                    genesis__Contact__c = testcontact.Id,
                    Name = 'Cash');
            incomeList.add(income);

            income = new genesis__income__c(
                    genesis__Amount__c = 7000,
                    genesis__Application__c = appln.Id,
                    genesis__Contact__c = testcontact.Id,
                    Name = 'Sale');
            incomeList.add(income);
            insert incomeList;

            genesis__Employment_Information__c empInfo = new genesis__Employment_Information__c();
            empInfo.genesis__Contact__c = testcontact.Id;
            empInfo.genesis__Application__c = appln.Id;
            empInfo.genesis__Employer_City__c = 'Bengaluru';
            empInfo.genesis__Position__c = 'Manager';
            empInfo.genesis__Type_of_business__c = 'Self';
            insert empInfo;

            genesis__Identification_Information__c idInfo = new genesis__Identification_Information__c();
            idInfo.genesis__Application2__c = appln.Id;
            idInfo.genesis__Account__c = testaccount.Id;
            idInfo.genesis__Identification_Comments__c = 'No Comments';
            idInfo.genesis__Identification_Type__c = 'Passport';
            insert idInfo;

            clcommon__Party__c party = new clcommon__Party__c();
            party.clcommon__Account__c = testAccount.Id;
            party.genesis__Application__c = appln.Id;
            party.clcommon__Type__c = partyType.Id;
            insert party;

            clcommon.Response response = new PortalPartyAPI().invokeAction('', null, new Map<String, Object>{
                    'applicationId' => appln.Id,
                    'coborrowerAddr' => JSON.serialize(testContact),
                    'coborrowerPersonalInfo' => JSON.serialize(testContact),
                    'coborrowerEmployment' => JSON.serialize(empInfo),
                    'coborrowerIdentification' => JSON.serialize(idInfo),
                    'coborrowerPrevAddr' => JSON.serialize(testContact),
                    'coborrowerMailingAddr' => JSON.serialize(testContact),
                    'coborrowerIncomeList' => JSON.serialize(incomeList),
                    'Account' => testAccount.Id,
                    'Contact' => testContact.Id
             });

            system.debug('--response--'+response);
            system.assertEquals(response.Status,'SUCCESS');

            Test.StopTest();
        }
    }

     @IsTest
    static void testPortalPartyException() {

        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        Test.StartTest();
        Profile profile = [Select Id from Profile where name = 'Read Only'];
        User ReadOnlyUser = new User(
            ProfileId = profile.Id,
            Username = TestUtility.generateFakeName() + '@example.com',
            Alias = 'testing',
            Email=System.now().millisecond() + 'test2@test.com',
            EmailEncodingKey='UTF-8',
            Firstname='Tom',
            Lastname='Tim',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        insert ReadOnlyUser;

        System.runAs ( ReadOnlyUser ) {

            clcommon.Response response = new PortalPartyAPI().invokeAction(null, null, new Map<String, Object>{

             });

            system.debug('--response--'+response);
            system.assertEquals(response.Status,'ERROR');
        }
        Test.StopTest();
    }
}