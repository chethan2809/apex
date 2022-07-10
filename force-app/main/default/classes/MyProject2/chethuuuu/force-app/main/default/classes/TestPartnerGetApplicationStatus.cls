@isTest(isParallel=true)
private class TestPartnerGetApplicationStatus {

    @isTest
    private static void validateRequest(){
        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        account.Name = 'TestPartnerCal';
        account.Partner_API_Key__c = GeneralHelper.generateUniqueReferenceId(account.Id);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        PartnerAPIHelpers.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Contact contact = new Contact();
        contact.LastName = 'test';
        contact.AccountId = account.Id;
        contact.Id = TestUtility.getFakeId(Contact.getSObjectType());

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{contact};
        PartnerAPIHelpers.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        Map<String, String> testUserMap = new Map<String, String>();
        testUserMap.put('Id', TestUtility.getFakeId(User.getSObjectType()));
        testUserMap.put('ContactId', contact.Id);
        testUserMap.put('AccountId', contact.AccountId);
        testUserMap.put('Email', 'no@email.com');
        String strUser = JSON.serialize(testUserMap);
        User testUser = (User) JSON.deserialize(strUser, User.class);

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{testUser};
        PartnerAPIHelpers.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        Map<String, String> applicationMap = new Map<String, String>();
        applicationMap.put('Id', TestUtility.getFakeId(genesis__Applications__c.getSObjectType()));
        applicationMap.put('Name', 'APP-0000000678');
        applicationMap.put('Broker_Contact__c', testUser.ContactId);
        applicationMap.put('genesis__Status__c', Applications.STATUS_APPROVED);
        applicationMap.put('Overall_Status__c', Applications.STATUS_APPROVED);
        String jsonString = JSON.serialize(applicationMap);
        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(jsonString, genesis__Applications__c.class);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        PartnerAPIHelpers.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        RestRequest request = new RestRequest();

        request.addHeader('httpMethod', 'GET');
        request.requestUri = '/services/apexrest/v1/partner/applicationstatus/';
        request.addParameter('application', application.Name);
        request.addParameter('partnerEmail', testUser.Email);
        request.addParameter('partnerAPIKey', account.Partner_API_Key__c);

        Test.startTest();
            genesis__Applications__c applicationRecord = PartnerGetApplicationStatus.validateRequest(request);
        Test.stopTest();

        System.assert(applicationRecord != null);
    }

    @isTest
    private static void buildResponse() {
        Contact contact = new Contact();
        contact.LastName = 'test';
        contact.AccountId = TestUtility.getFakeId(Account.getSObjectType());
        contact.Id = TestUtility.getFakeId(Contact.getSObjectType());

        User testUser = (User) JSON.deserialize(
            '{ "AccountId" : "accountId"}' , User.class
        );
        testUser.Email = 'no@email.com';
        testUser.ContactId = contact.Id;
        testUser.Id = TestUtility.getFakeId(User.getSObjectType());

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{testUser};
        PartnerAPIHelpers.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
         '{ "Name" : "APP-0000000678"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Broker_Contact__c = testUser.ContactId;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        PartnerAPIHelpers.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Application__c = application.Id;
        pricingDetail.Term__c = 14;
        pricingDetail.Industry_Rating__c = 'B';
        pricingDetail.SC4_Tier__c = 'TIER 2';
        pricingDetail.Loan_Type__c = 'New';
        pricingDetail.Maximum_Exception_Amount__c = 10000;
        pricingDetail.Selected_Amount__c = 10000;
        pricingDetail.Origination_Fee_Percentage__c = 5;
        pricingDetail.Status__c = 'Sent To Customer';

        STIPS_Checklist__c stipsCheckList = new STIPS_Checklist__c();
        stipsCheckList.Application__c = application.Id;
        stipsCheckList.Additional_Banks__c = true;
        stipsCheckList.Bank_Verification_Call__c = true;
        stipsCheckList.Borrower_Interview__c = true;
        stipsCheckList.Competitors__c = true;
        stipsCheckList.Federal_Tax_ID__c = true;
        stipsCheckList.Identification__c = true;
        stipsCheckList.Month_to_Date_Bank_Statement__c = true;
        stipsCheckList.Proof_of_Ownership__c = true;
        stipsCheckList.Verification_Call__c = true;
        stipsCheckList.Voided_Check__c = true;
        stipsCheckList.experian_fraud_check__c = true;
        stipsCheckList.business_loan_agreement__c = true;
        stipsCheckList.certification_of_beneficial_owners__c = true;
        stipsCheckList.refinance_agreement__c = true;
        stipsCheckList.third_party_agreement__c = true;
        stipsCheckList.proof_of_business_location__c = true;


        Test.startTest();
            Map<String, Object> responseMap= PartnerGetApplicationStatus.buildResponse(new List<CAN_Pricing_Detail__c>{pricingDetail}, new List<STIPS_Checklist__c>{stipsCheckList}, application);
        Test.stopTest();

        System.assert(responseMap != null);
    }

    @isTest
    private static void buildResponseWithoutStips() {
        Contact contact = new Contact();
        contact.LastName = 'test';
        contact.AccountId = TestUtility.getFakeId(Account.getSObjectType());
        contact.Id = TestUtility.getFakeId(Contact.getSObjectType());

        User testUser = (User) JSON.deserialize(
            '{ "AccountId" : "accountId"}' , User.class
        );
        testUser.Email = 'no@email.com';
        testUser.ContactId = contact.Id;
        testUser.Id = TestUtility.getFakeId(User.getSObjectType());

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{testUser};
        PartnerAPIHelpers.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
         '{ "Name" : "APP-0000000678"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Broker_Contact__c = testUser.ContactId;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        PartnerAPIHelpers.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Application__c = application.Id;
        pricingDetail.Term__c = 14;
        pricingDetail.Industry_Rating__c = 'B';
        pricingDetail.SC4_Tier__c = 'TIER 2';
        pricingDetail.Loan_Type__c = 'New';
        pricingDetail.Maximum_Exception_Amount__c = 10000;
        pricingDetail.Selected_Amount__c = 10000;
        pricingDetail.Origination_Fee_Percentage__c = 5;
        pricingDetail.Status__c = 'Sent To Customer';

        STIPS_Checklist__c stipsCheckList = new STIPS_Checklist__c();
        stipsCheckList.Application__c = application.Id;

        Test.startTest();
            Map<String, Object> responseMap= PartnerGetApplicationStatus.buildResponse(new List<CAN_Pricing_Detail__c>{pricingDetail}, new List<STIPS_Checklist__c>{stipsCheckList}, application);
        Test.stopTest();

        System.assert(responseMap != null);
    }
}