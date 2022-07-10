@isTest
private class TestPartnerCreateApplicationAPI {

    @testSetup
    private static void setup() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        UserRole userRole = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'CEO' LIMIT 1];

        User adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;

        System.runAs(adminUser){
            Account account = TestUtility.generateAccount();
            account.Name = 'Test Account Name';
            account.Legacy_AccountID__c = '23456789';
            insert account;

            Contact contact = TestUtility.generateContact();
            contact.LastName = 'Contact Last Name';
            contact.AccountId = account.Id;
            insert contact;

            Default_Portal_Owner_Mapping__mdt defaultPortalOwner = [Select DeveloperName, Owner_Email__c FROM Default_Portal_Owner_Mapping__mdt WHERE DeveloperName = 'Default_Broker_Portal_Owner' LIMIT 1];

            User user = new User();
            user.ProfileID = [Select Id From Profile Where Name='BrokerCommunityPlus'].Id;
            user.EmailEncodingKey = 'ISO-8859-1';
            user.LanguageLocaleKey = 'en_US';
            user.TimeZoneSidKey = 'America/New_York';
            user.LocaleSidKey = 'en_US';
            user.FirstName = 'first';
            user.LastName = 'last';
            user.Username = TestUtility.generateFakeName() + 'test5@test.com';
            user.CommunityNickname = 'testUser123';
            user.Alias = 't1';
            user.Email = defaultPortalOwner.Owner_Email__c;
            user.IsActive = true;
            user.ContactId = contact.Id;
            insert user;
        }

        User userRec = [SELECT Id, AccountId, ContactId FROM User WHERE LastName = 'last' LIMIT 1];

        System.runAs(userRec){
            TestUtility.runSetupData();
            TestUtility.createCompany();

            clcommon__Company__c clCompany = new clcommon__Company__c();
            clCompany.clcommon__Company_Name__c = 'CAN Capital';
            clCompany.clcommon__Branch_Date__c = date.newInstance(2020, 01, 01);
            insert clCompany;

            Account acc = [SELECT Id FROM Account WHERE Name = 'Web Bank'];
            acc.Merchant_ID__c = '999999999';
            Update acc;
        }
    }

    @isTest
    static void createApplication () {
        String userEmail = [SELECT DeveloperName, Owner_Email__c FROM Default_Portal_Owner_Mapping__mdt WHERE DeveloperName = 'Default_Broker_Portal_Owner' LIMIT 1].Owner_Email__c;

        clcommon__Legal_Entity__c legalEntity = new clcommon__Legal_Entity__c(Name = 'Corporation', clcommon__Legal_Entity_Type__c = 'Corporation');
        INSERT legalEntity;

        loan__Loan_Product__c loanProduct = [Select Id FROM loan__Loan_Product__c];
        loanProduct.loan__Default_Number_of_Installments__c=6;
        loanProduct.loan__Frequency_of_Loan_Payment__c = 'Daily';
        Update loanProduct;
        clcommon__CL_Product__c cpl= new clcommon__CL_Product__c(clcommon__Product_Name__c='CAN Capital', loan__Lending_Product__c = loanProduct.Id);
        Insert cpl;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        String str = '{"loanDetails":{"loanPurpose":"Expansion","loanAmount":"20000.00"},"partnerDetails":{"partnerAPIKey":"12345555","partnerEmail":"'+userEmail+'"},"accountDetails":{"name":"BorrowerAcc989","phone":"8454243000","industry":"Business Services","taxId":"45456699","dba":"Test Business Trading Name","businessStructureName":"Corporation","stateOfFormation":"AZ","bizStartDate":"1990-06-07","billingStreet":"1123 Old Albany Post Road","billingBuildingNumber":"108","billingCity":"Garrison","billingState":"NY","billingPostalCode":"10524","billingCountry":"US","legalEntityType":"Test"},"contactDetails":{"title":"CEO","firstName":"Ira989","lastName":"Boyar989","email":"iraboyar998@mailinator.com","phone":"8454243000","birthDate":"1998-10-06","socialSecurityNumber":"45456298","mailingStreet":"627 Horseblock Rd","mailingBuildingNumber":"108","mailingCity":"Farmingville","mailingState":"NY","mailingCountry":"US","mailingPostalCode":"11738"}}';

        req.addHeader('httpMethod', 'POST');
        req.addHeader('Content-Type', 'application/json');
        req.requestUri = '/services/apexrest/v1/partner/createapplication/';
        req.requestBody = Blob.valueof(str);

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
            PartnerCreateApplicationAPI.createApplication();
        Test.stopTest();

        RestResponse resVal = RestContext.response;
        System.assert(resVal != null);
    }

    @isTest
    static void doNotCreateApplicationForMissingSection() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        String str = '{"partnerDetails":{"partnerEmail":"testuser11@gmail.com"},"accountDetails":{"name":"BorrowerAcc64","phone":"8454243000","industry":"Business Services","taxId":"45456664","dba":"Test Business Trading Name","businessStructureName":"Corporation","stateOfFormation":"AZ","bizStartDate":"1990-06-07","billingStreet":"1123 Old Albany Post Road","billingBuildingNumber":"108","billingCity":"Garrison","billingState":"NY","billingPostalCode":"10524","billingCountry":"US","legalEntityType":""},"contactDetails":{"title":"CEO","firstName":"Ira64","lastName":"Boyar64","email":"iraboyar64@mailinator.com","phone":"8454243000","birthDate":"1998-10-06","socialSecurityNumber":"45456264","mailingStreet":"627 Horseblock Rd","mailingBuildingNumber":"108","mailingCity":"Farmingville","mailingState":"NY","mailingCountry":"US","mailingPostalCode":"11738"}}';

        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/v1/partner/createapplication/';
        req.requestBody = Blob.valueof(str);

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
            PartnerCreateApplicationAPI.createApplication();
        Test.stopTest();

        RestResponse resVal = RestContext.response;
        System.assertEquals(400, resVal.statusCode);
    }

    @isTest
    static void createApplicationErrorOne() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        String str = '{"loanDetails":{"loanPurpose":"Expansion","loanAmount":"20000.00"},"partnerDetails":{"partnerEmail":"testuser11@gmail.com"},"accountDetails":{"name":"BorrowerAcc64","phone":"8454243000","industry":"Business Services","taxId":"45456664","dba":"Test Business Trading Name","businessStructureName":"Corporation","stateOfFormation":"AZ","bizStartDate":"1990-06-07","billingStreet":"1123 Old Albany Post Road","billingBuildingNumber":"108","billingCity":"Garrison","billingState":"NY","billingPostalCode":"10524","billingCountry":"US","legalEntityType":""},"contactDetails":{"title":"CEO","firstName":"Ira64","lastName":"Boyar64","email":"iraboyar64@mailinator.com","phone":"8454243000","birthDate":"1998-10-06","socialSecurityNumber":"45456264","mailingStreet":"627 Horseblock Rd","mailingBuildingNumber":"108","mailingCity":"Farmingville","mailingState":"NY","mailingCountry":"US","mailingPostalCode":"11738"}}';

        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/v1/partner/createapplication/';
        req.requestBody = Blob.valueof(str);

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
            PartnerCreateApplicationAPI.createApplication();
        Test.stopTest();

        RestResponse resVal = RestContext.response;
        System.assertEquals(400, resVal.statusCode);
    }

    @isTest
    static void createApplicationEmptyBody() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String str = '{}';

        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/v1/partner/createapplication/';
        req.requestBody = Blob.valueof(str);

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
            PartnerCreateApplicationAPI.createApplication();
        Test.stopTest();

        RestResponse resVal = RestContext.response;
        System.assertEquals(400, resVal.statusCode);
    }
}