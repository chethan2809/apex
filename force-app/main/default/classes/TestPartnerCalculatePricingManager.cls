@isTest(isParallel=true)
private class TestPartnerCalculatePricingManager {

    @isTest
    private static void calculatePricing(){
        GeneralHelper.currentSystemDate = Date.newInstance(2019, 01, 01);
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

        CAN_GAV_Matrix_Detail__c gavMatrixDetail = new CAN_GAV_Matrix_Detail__c();
        gavMatrixDetail.Industry_Rating__c = 'B';
        gavMatrixDetail.SC4_Tier__c = 'TIER 2';
        gavMatrixDetail.Term__c = 14;
        gavMatrixDetail.GAV__c = 10.95;
        gavMatrixDetail.Id = TestUtility.getFakeId(CAN_GAV_Matrix_Detail__c.getSObjectType());

        DBManagerTestsStub gavMatrixDetailDBStubInstance = new DBManagerTestsStub();
        gavMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_GAV_Matrix_Detail__c>{gavMatrixDetail};
        OriginationHelper.gavMatrixDetailDBInstance = (GAVMatrixDetailDB) Test.createStub(GAVMatrixDetailDB.class, gavMatrixDetailDBStubInstance);

        CAN_Pricing_Matrix_Detail__c pricingMatrixDetail = new CAN_Pricing_Matrix_Detail__c();
        pricingMatrixDetail.Loan_Type__c = 'New';
        pricingMatrixDetail.Industry_Rating__c = 'B';
        pricingMatrixDetail.SC4_Tier__c = 'TIER 2';
        pricingMatrixDetail.Term__c = 14;
        pricingMatrixDetail.Pricing_Rate__c = 1.28;
        pricingMatrixDetail.Id = TestUtility.getFakeId(CAN_Pricing_Matrix_Detail__c.getSObjectType());

        DBManagerTestsStub pricingMatrixDetailDBStubInstance = new DBManagerTestsStub();
        pricingMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_Pricing_Matrix_Detail__c>{pricingMatrixDetail};
        OriginationHelper.pricingMatrixDetailDBInstance = (PricingMatrixDetailDB) Test.createStub(PricingMatrixDetailDB.class, pricingMatrixDetailDBStubInstance);

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Id = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());
        pricingDetail.Application__c = application.Id;
        pricingDetail.Term__c = 14;
        pricingDetail.Industry_Rating__c = 'B';
        pricingDetail.SC4_Tier__c = 'TIER 2';
        pricingDetail.Loan_Type__c = 'New';
        pricingDetail.Maximum_Exception_Amount__c = 10000;
        pricingDetail.Selected_Amount__c = 10000;
        pricingDetail.Origination_Fee_Percentage__c = 5;
        pricingDetail.Annual_Volume__c = 100000;

        DBManagerTestsStub canPricingDetailDBStubInstance = new DBManagerTestsStub();
        canPricingDetailDBStubInstance.genericReturnObject = new List<CAN_Pricing_Detail__c>{pricingDetail};
        PartnerCalculatePricingManager.canPricingDetailDBInstance = (CANPricingDetailDB) Test.createStub(CANPricingDetailDB.class, canPricingDetailDBStubInstance);

        RestRequest request = new RestRequest();
        request.addHeader('httpMethod', 'GET');
        request.requestUri = '/services/apexrest/v1/partner/calculatepricing/';
        request.addParameter('application', application.Name);
        request.addParameter('partnerEmail', testUser.Email);
        request.addParameter('partnerAPIKey', account.Partner_API_Key__c);
        request.addParameter('term', '14');

        Test.startTest();
            Map<String, Object> responseMap = PartnerCalculatePricingManager.calculatePricing(request);
        Test.stopTest();

        System.assert(responseMap != null);
    }
}