@isTest
private class PartnerPricingSecureLinkControllerTests {

    @isTest
    private static void getApplicationIdTest() {

        genesis__Applications__c genesisApplicationOne = new genesis__Applications__c();
        genesisApplicationOne.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('applicationId',  genesisApplicationOne.Id);

        String key = 'rWCV4l71cN6wvog3Hrthsw==';
        CAN_General_Settings__c generalSettings = new CAN_General_Settings__c();
        generalSettings.Partner_Pricing_Secure_Link_Key__c = key;
        CustomSettingsHelper.generalSettings = generalSettings;

        Blob data = Blob.valueOf(JSON.serialize(requestMap));
        Blob encrypted = Crypto.encryptWithManagedIV('AES128', EncodingUtil.base64Decode(key), data);
        String encryptedString = EncodingUtil.convertToHex(encrypted);

        Test.startTest();
            Id applicationId = PartnerPricingSecureLinkController.getApplicationId(encryptedString);
        Test.stopTest();

        System.assertEquals(genesisApplicationOne.Id, applicationId);
    }

    @isTest
    private static void getCANGeneralSetting() {

        CAN_General_Settings__c canGeneralSettings = new CAN_General_Settings__c();
        canGeneralSettings.Partner_Pricing_Generate_Doc_Count_Limit__c = 30;
        CustomSettingsHelper.generalSettings = canGeneralSettings;

        Test.startTest();
            CAN_General_Settings__c actualCanGeneralSettings = PartnerPricingSecureLinkController.getCANGeneralSetting();
        Test.stopTest();

        System.assertEquals(
            canGeneralSettings.Partner_Pricing_Generate_Doc_Count_Limit__c,
            actualCanGeneralSettings.Partner_Pricing_Generate_Doc_Count_Limit__c
        );
    }

    @isTest
    private static void getApplicationDetailsTest() {
        genesis__Applications__c genesisApplication = new genesis__Applications__c();
        genesisApplication.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        genesisApplication.genesis__Status__c = Applications.STATUS_OFFER_SENT;
        genesisApplication.Type__c = GeneralConstants.LOAN_TYPE_NEW;

        DBManagerTestsStub applicationDBInstance = new DBManagerTestsStub();
        applicationDBInstance.genericReturnObject = new List<genesis__Applications__c>{genesisApplication};
        PartnerPricingSecureLinkController.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBInstance);

        Test.startTest();
            Map<String, Object> actualApplication = PartnerPricingSecureLinkController.getApplicationDetails(genesisApplication.Id);
        Test.stopTest();

        System.assertEquals(false, actualApplication.isEmpty());
        System.assertEquals(genesisApplication.Id, actualApplication.get('Id'));
    }

    @isTest
    private static void getApplicationDetailsNoRecordsFoundTest() {
        Set<Id> applicationId = new Set<Id>();
        genesis__Applications__c genesisApplication = new genesis__Applications__c();
        genesisApplication.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        DBManagerTestsStub applicationDBInstance = new DBManagerTestsStub();
        applicationDBInstance.genericReturnObject = new List<genesis__Applications__c>();
        PartnerPricingSecureLinkController.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBInstance);

        Exception ex;
        Test.startTest();
        try {
            PartnerPricingSecureLinkController.getApplicationDetails(genesisApplication.Id);
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        TestUtility.assertException(ex);
        System.assertEquals('There was no Application found for this request', ex.getMessage());
    }

    @isTest
    private static void validateApplicationTest() {
        Account brokerAccount = new Account();
        brokerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        brokerAccount.Is_Broker_Active__c = true;
        brokerAccount.Enable_Secure_Partner_Links__c = true;

        genesis__Applications__c genesisApplication = new genesis__Applications__c();
        genesisApplication.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        genesisApplication.Broker_Account__r = brokerAccount;
        genesisApplication.Broker_Account__c = brokerAccount.Id ;
        genesisApplication.genesis__Status__c = 'OFFER SENT';

        Map<String, Object> applicationMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(genesisApplication));

        Test.startTest();
            Boolean validateApplication = PartnerPricingSecureLinkController.validateApplication(applicationMap);
        Test.stopTest();

        System.assert(validateApplication);
    }

    @isTest
    private static void validateApplicationFailedTest() {
        Account brokerAccount = new Account();
        brokerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        brokerAccount.Is_Broker_Active__c = false;
        brokerAccount.Enable_Secure_Partner_Links__c = true;

        genesis__Applications__c genesisApplication = new genesis__Applications__c();
        genesisApplication.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        genesisApplication.Broker_Account__r = brokerAccount;
        genesisApplication.Broker_Account__c = brokerAccount.Id ;
        genesisApplication.genesis__Status__c = 'OFFER SENT';

        Map<String, Object> applicationMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(genesisApplication));

        Test.startTest();
            Boolean validateApplication = PartnerPricingSecureLinkController.validateApplication(applicationMap);
        Test.stopTest();

        System.assert(!validateApplication);
    }

    @isTest
    private static void getPricingDetailsTest() {
        genesis__Applications__c genesisApplication = new genesis__Applications__c();
        genesisApplication.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Id = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());
        pricingDetail.Application__c = genesisApplication.Id ;
        pricingDetail.Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        pricingDetail.Term__c = 12;

        DBManagerTestsStub canPricingDetailDBInstance = new DBManagerTestsStub();
        canPricingDetailDBInstance.genericReturnObject = new List<CAN_Pricing_Detail__c>{pricingDetail};
        PartnerPricingSecureLinkController.canPricingDetailDBInstance = (canPricingDetailDB) Test.createStub(canPricingDetailDB.class, canPricingDetailDBInstance);

        Test.startTest();
            Map<String, Object> actualPricing = PartnerPricingSecureLinkController.getPricingDetails(genesisApplication.Id);
        Test.stopTest();

        System.assertEquals(pricingDetail.Id, actualPricing.get('Id'));
    }

    @isTest
    private static void getPricingDetailsNoRecordsFoundTest() {
        genesis__Applications__c genesisApplication = new genesis__Applications__c();
        genesisApplication.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        DBManagerTestsStub canPricingDetailDBInstance = new DBManagerTestsStub();
        canPricingDetailDBInstance.genericReturnObject = new List<CAN_Pricing_Detail__c>();
        PartnerPricingSecureLinkController.canPricingDetailDBInstance = (canPricingDetailDB) Test.createStub(canPricingDetailDB.class, canPricingDetailDBInstance);

        Exception ex;
        Test.startTest();
        try {
            Map<String, Object> actualPricing = PartnerPricingSecureLinkController.getPricingDetails(genesisApplication.Id);
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        TestUtility.assertException(ex);
        System.assertEquals('There was no Pricing Detail record found', ex.getMessage());
    }

    @isTest
    private static void calculateCANPricing() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Id = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());
        pricingDetail.Maximum_Exception_Amount__c = 10000;
        pricingDetail.Offer_Type__c = null;
        pricingDetail.Ocrolus_Max_Daily_Payment__c = 1000;
        pricingDetail.Buy_Rate__c = 10;
        pricingDetail.GAV__c = 20;
        pricingDetail.Overwrite_Policy_Default__c = false;
        pricingDetail.Application__c = application.Id;
        pricingDetail.Loan_Type__c = GeneralConstants.LOAN_TYPE_NEW;
        pricingDetail.Overwrite_Policy_Default__c = true;
        pricingDetail.Standard_Commission__c = 100;
        pricingDetail.Selected_Amount__c = 5000;
        pricingDetail.Broker_Commission_Based_On__c = Brokers.COMMISSION_CALC_METHOD_PERCENTAGE;
        pricingDetail.Industry_Rating__c = 'A+ Medical';
        pricingDetail.SC4_Tier__c = 'TIER 1';
        pricingDetail.Loan_Type__c =  GeneralConstants.LOAN_TYPE_NEW;
        pricingDetail.Term__c = 6;
        pricingDetail.Maximum_Exception_Amount__c = null;
        pricingDetail.Policy_Maximum_Amount__c = 100;
        pricingDetail.Annual_Volume__c = 1235000;
        pricingDetail.Origination_Fee_Percentage__c = 12;
        pricingDetail.Pricing_Type__c = CANPricingDetails.PRICING_TYPE_DIRECT_NEW;

        CAN_Pricing_Matrix_Detail__c canPricingMatrixDetail = new CAN_Pricing_Matrix_Detail__c();
        canPricingMatrixDetail.Pricing_Type__c = CANPricingDetails.PRICING_TYPE_DIRECT_NEW;
        canPricingMatrixDetail.Term__c = 6;
        canPricingMatrixDetail.Loan_Type__c = GeneralConstants.LOAN_TYPE_NEW;
        canPricingMatrixDetail.SC4_Tier__c = 'TIER 1';
        canPricingMatrixDetail.Industry_Rating__c = 'A+ Medical';
        canPricingMatrixDetail.Pricing_Rate__c = 2.2;

        CAN_GAV_Matrix_Detail__c canGavMatrix = new CAN_GAV_Matrix_Detail__c();
        canGavMatrix.Term__c = 6;
        canGavMatrix.SC4_Tier__c = 'TIER 1';
        canGavMatrix.Industry_Rating__c = 'A+ Medical';
        canGavMatrix.GAV__c = 3;

        DBManagerTestsStub pricingMatrixDetailDBStubInstance = new DBManagerTestsStub();
        pricingMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_Pricing_Matrix_Detail__c> {canPricingMatrixDetail};
        OriginationHelper.pricingMatrixDetailDBInstance = (PricingMatrixDetailDB) Test.createStub(PricingMatrixDetailDB.class, pricingMatrixDetailDBStubInstance);

        DBManagerTestsStub gavMatrixDetailDBStubInstance = new DBManagerTestsStub();
        gavMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_GAV_Matrix_Detail__c> {canGavMatrix};
        OriginationHelper.gavMatrixDetailDBInstance = (GAVMatrixDetailDB) Test.createStub(GAVMatrixDetailDB.class, gavMatrixDetailDBStubInstance);

        Map<String, Object> pricingDetailMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(pricingDetail));

        Test.startTest();
            Map<String, Object> actualPricingDetail = PartnerPricingSecureLinkController.calculatePricing(pricingDetailMap);
        Test.stopTest();

        System.assertEquals(canGavMatrix.GAV__c, actualPricingDetail.get('Max_GAV__c'));
        System.assertEquals(canPricingMatrixDetail.Pricing_Rate__c, actualPricingDetail.get('Floor_Buy_Rate__c'));
    }

    @isTest
    private static void acceptPricingOfferTest() {
        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Id = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());
        pricingDetail.Standard_Commission__c = 90;
        pricingDetail.Commission_Amount__c = 200;
        pricingDetail.Max_Broker_Commission__c = 50;
        pricingDetail.Broker_Commission_Based_On__c = 'Flat Amount';
        pricingDetail.Renewal_Amount_Commission__c = 'Gross Amount';
        pricingDetail.Is_Flat_Renewal__c = true;
        pricingDetail.Loan_Type__c = 'New';
        pricingDetail.Term__c = 2;
        pricingDetail.SC4_Tier__c = 'TIER 1';
        pricingDetail.Industry_Rating__c = 'A';
        pricingDetail.Pricing_Type__c = 'Standard Partner New';

        CAN_Pricing_Matrix_Detail__c pricingMatrix = new CAN_Pricing_Matrix_Detail__c();
        pricingMatrix.Id = TestUtility.getFakeId(CAN_Pricing_Matrix_Detail__c.getSObjectType());
        pricingMatrix.Pricing_Rate__c = 22;
        pricingMatrix.Industry_Rating__c = 'A';

        DBManagerTestsStub canPricingDetailDBInstance = new DBManagerTestsStub();
        canPricingDetailDBInstance.genericReturnObject = new List<CAN_Pricing_Detail__c>{pricingDetail};
        PartnerPricingSecureLinkController.canPricingDetailDBInstance = (canPricingDetailDB) Test.createStub(canPricingDetailDB.class, canPricingDetailDBInstance);

        Map<String, Object> pricingDetailMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(pricingDetail));

        Test.startTest();
            String result = PartnerPricingSecureLinkController.acceptPricingOffer(pricingDetailMap);
        Test.stopTest();

        System.assertEquals('Success', result);
    }

    @isTest
    private static void acceptPricingOfferFailedTest() {
        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Id = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());

        Map<String, Object> pricingDetailMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(pricingDetail));

        Exception ex;
        Test.startTest();
        String result;
        try {
            result = PartnerPricingSecureLinkController.acceptPricingOffer(pricingDetailMap);
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        TestUtility.assertException(ex);
        System.assertNotEquals('Success', result);
    }

    @isTest
    private static void generateDocumentTest() {
        genesis__Applications__c genesisApplication = new genesis__Applications__c();
        genesisApplication.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        DBManagerTestsStub applicationDBInstance = new DBManagerTestsStub();
        applicationDBInstance.genericReturnObject = new List<genesis__Applications__c> {genesisApplication};
        PartnerPricingSecureLinkController.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBInstance);

        System.Test.setMock(HttpCalloutMock.class, new CongaCalloutMock.CongaCalloutSuccessResponse());

        Test.startTest();
            String result = PartnerPricingSecureLinkController.generateDocument(genesisApplication.Id);
        Test.stopTest();

        System.assertEquals('Success', result);
    }

    @isTest
    private static void generateDocumentFailedTest() {
        genesis__Applications__c genesisApplication = new genesis__Applications__c();
        genesisApplication.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        System.Test.setMock(HttpCalloutMock.class, new CongaCalloutMock.CongaCalloutFailureResponse());

        Test.startTest();
            String result = PartnerPricingSecureLinkController.generateDocument(genesisApplication.Id);
        Test.stopTest();

        System.assertEquals('FAILED', result);
    }
}