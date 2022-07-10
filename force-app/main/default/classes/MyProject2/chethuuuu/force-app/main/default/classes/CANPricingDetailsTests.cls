@isTest(isParallel=true)
private class CANPricingDetailsTests {

    @isTest
    private static void createPricingDetail() {

        Account brokerAccount = new Account();
        brokerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        brokerAccount.Commision_Based_On__c = Brokers.COMMISSION_CALC_METHOD_FLAT;
        brokerAccount.Is_Flat_Renewal__c = true;
        brokerAccount.New_Max_Broker_Commission__c = 500;
        brokerAccount.Renewal_Amount_Commission__c = Brokers.COMMISSION_CALC_METHOD_FLAT;

        Contact brokerContact = new Contact();
        brokerContact.Id = TestUtility.getFakeId(Contact.getSObjectType());
        brokerContact.Account = brokerAccount;

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Origination_Fee_Amount__c" : "299", "Max_Broker_Commission__c" : "500" }' ,
            genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Status__c = Applications.STATUS_NEW_ENTERED;
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        application.Opportunity__c = TestUtility.getFakeId(Account.getSObjectType());
        application.Industry_Rating__c = 'A+ Medical';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 13412312;
        application.Origination_Fee_Percentage__c = 12;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.Broker_Contact__c = brokerContact.Id;
        application.Broker_Contact__r = brokerContact;

        CAN_Max_Amount_And_Max_Term_Mapping__c canMaxAmountMaxTerm = new CAN_Max_Amount_And_Max_Term_Mapping__c();
        canMaxAmountMaxTerm.Loan_Type__c = GeneralConstants.LOAN_TYPE_NEW;
        canMaxAmountMaxTerm.Industry_Rating__c = 'A+ Medical';
        canMaxAmountMaxTerm.SC4_Tier__c = 'TIER 1';
        canMaxAmountMaxTerm.Pricing_Type__c = 'Standard Partner New';

        DBManagerTestsStub maxAmountAndMaxTermMappingDBStubInstance = new DBManagerTestsStub();
        maxAmountAndMaxTermMappingDBStubInstance.genericReturnObject = new List<CAN_Max_Amount_And_Max_Term_Mapping__c> {canMaxAmountMaxTerm};
        OriginationHelper.maxAmountAndMaxTermMappingDBInstance = (MaxAmountAndMaxTermMappingDB) Test.createStub(MaxAmountAndMaxTermMappingDB.class, maxAmountAndMaxTermMappingDBStubInstance);

        CAN_Pricing_Detail__c pricingDetail = generateCANPricing();
        pricingDetail.Broker_Commission_Based_On__c = Brokers.COMMISSION_CALC_METHOD_FLAT;
        pricingDetail.Application__c = application.Id;

        Decimal ocrolusMaxDailyPayment = pricingDetail.Ocrolus_Max_Daily_Payment__c;

        Test.startTest();
            CAN_Pricing_Detail__c canPricingDetail = CANPricingDetails.createPricingDetail(application,pricingDetail, ocrolusMaxDailyPayment);
        Test.stopTest();

        System.assertEquals(CANPricingDetails.STATUS_DRAFT, canPricingDetail.Status__c);
        System.assertEquals(299, canPricingDetail.Origination_Fee_Amount__c);
    }

    @isTest
    private static void createPricingDetailForRenewal() {

        Account brokerAccount = new Account();
        brokerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        brokerAccount.Commision_Based_On__c = Brokers.COMMISSION_CALC_METHOD_FLAT;
        brokerAccount.Is_Flat_Renewal__c = true;
        brokerAccount.New_Max_Broker_Commission__c = 500;
        brokerAccount.Renewal_Amount_Commission__c = Brokers.COMMISSION_CALC_METHOD_FLAT;

        Contact brokerContact = new Contact();
        brokerContact.Id = TestUtility.getFakeId(Contact.getSObjectType());
        brokerContact.Account = brokerAccount;

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Origination_Fee_Amount__c" : "299", "Max_Broker_Commission__c" : "500" }' ,
            genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Status__c = Applications.STATUS_NEW_ENTERED;
        application.Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;
        application.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        application.Opportunity__c = TestUtility.getFakeId(Account.getSObjectType());
        application.Industry_Rating__c = 'A+ Medical';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 13412312;
        application.Origination_Fee_Percentage__c = 12;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.Broker_Contact__c = brokerContact.Id;
        application.Broker_Contact__r = brokerContact;

        CAN_Max_Amount_And_Max_Term_Mapping__c canMaxAmountMaxTerm = new CAN_Max_Amount_And_Max_Term_Mapping__c();
        canMaxAmountMaxTerm.Loan_Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;
        canMaxAmountMaxTerm.Industry_Rating__c = 'A+ Medical';
        canMaxAmountMaxTerm.SC4_Tier__c = 'TIER 1';
        canMaxAmountMaxTerm.Pricing_Type__c = 'Partner Renewal';

        DBManagerTestsStub maxAmountAndMaxTermMappingDBStubInstance = new DBManagerTestsStub();
        maxAmountAndMaxTermMappingDBStubInstance.genericReturnObject = new List<CAN_Max_Amount_And_Max_Term_Mapping__c> {canMaxAmountMaxTerm};
        OriginationHelper.maxAmountAndMaxTermMappingDBInstance = (MaxAmountAndMaxTermMappingDB) Test.createStub(MaxAmountAndMaxTermMappingDB.class, maxAmountAndMaxTermMappingDBStubInstance);

        CAN_Pricing_Detail__c pricingDetail = generateCANPricing();
        pricingDetail.Broker_Commission_Based_On__c = Brokers.COMMISSION_CALC_METHOD_FLAT;
        pricingDetail.Application__c = application.Id;

        Decimal ocrolusMaxDailyPayment = pricingDetail.Ocrolus_Max_Daily_Payment__c;

        Test.startTest();
            CAN_Pricing_Detail__c canPricingDetail = CANPricingDetails.createPricingDetail(application,pricingDetail, ocrolusMaxDailyPayment);
        Test.stopTest();

        System.assertEquals(CANPricingDetails.STATUS_DRAFT, canPricingDetail.Status__c);
        System.assertEquals(299, canPricingDetail.Origination_Fee_Amount__c);
    }

    @isTest
    private static void createPricingDetailMaxAmountException() {

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Origination_Fee_Amount__c" : "299" }' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Status__c = Applications.STATUS_NEW_ENTERED;
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        application.Opportunity__c = TestUtility.getFakeId(Account.getSObjectType());
        application.Industry_Rating__c = 'A+ Medical';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 13412312;
        application.Origination_Fee_Percentage__c = 12;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.Broker_Contact__c = TestUtility.getFakeId(Contact.getSObjectType());

        CAN_Max_Amount_And_Max_Term_Mapping__c canMaxAmountMaxTerm = new CAN_Max_Amount_And_Max_Term_Mapping__c();
        canMaxAmountMaxTerm.Loan_Type__c = GeneralConstants.LOAN_TYPE_NEW;
        canMaxAmountMaxTerm.Industry_Rating__c = 'A+ Medical';
        canMaxAmountMaxTerm.SC4_Tier__c = 'TIER 2';

        DBManagerTestsStub maxAmountAndMaxTermMappingDBStubInstance = new DBManagerTestsStub();
        maxAmountAndMaxTermMappingDBStubInstance.genericReturnObject = new List<CAN_Max_Amount_And_Max_Term_Mapping__c> {canMaxAmountMaxTerm};
        OriginationHelper.maxAmountAndMaxTermMappingDBInstance = (MaxAmountAndMaxTermMappingDB) Test.createStub(MaxAmountAndMaxTermMappingDB.class, maxAmountAndMaxTermMappingDBStubInstance);

        CAN_Pricing_Detail__c pricingDetail = generateCANPricing();
        pricingDetail.Broker_Commission_Based_On__c = Brokers.COMMISSION_CALC_METHOD_FLAT;
        pricingDetail.Application__c = application.Id;

        Decimal ocrolusMaxDailyPayment = pricingDetail.Ocrolus_Max_Daily_Payment__c;

        Exception ex;
        Test.startTest();
        try {
            CAN_Pricing_Detail__c canPricingDetail = CANPricingDetails.createPricingDetail(application,pricingDetail, ocrolusMaxDailyPayment);
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        System.assertEquals
        (
            'There was no Max Amount And Max Term Mapping found for Type: ' + application.Type__c +
            + ' Rating: ' +  application.Industry_Rating__c + ' SC4_Tier: ' + application.SC4_Tier__c, ex.getMessage()
        );
    }

    @isTest
    private static void createPricingDetailException() {
        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Origination_Fee_Amount__c" : "299"}' , genesis__Applications__c.class
        );

        CAN_Pricing_Detail__c pricingDetail = generateCANPricing();
        pricingDetail.Application__c = application.Id;

        Decimal ocrolusMaxDailyPayment = null;

        Exception ex;
        CAN_Pricing_Detail__c canPricingDetail;
        Test.startTest();
        try{
            CANPricingDetails.createPricingDetail(application,pricingDetail, ocrolusMaxDailyPayment);
        }catch(Exception e){
            ex = e;
        }
        Test.stopTest();

        System.assert(canPricingDetail == null);
        System.assert(ex.getMessage() != null);
        System.assertEquals('Ocrolus Max Daily Payment field should not be null', ex.getMessage());
    }

    @isTest
    private static void calculateCANPricing() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        CAN_Pricing_Detail__c pricingDetail = generateCANPricing();
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

        Test.startTest();
            CAN_Pricing_Detail__c canPricingDetail = CANPricingDetails.calculateCANPricing(pricingDetail);
        Test.stopTest();
        System.assertEquals(canGavMatrix.GAV__c, canPricingDetail.Max_GAV__c);
        System.assertEquals(canPricingMatrixDetail.Pricing_Rate__c, canPricingDetail.Floor_Buy_Rate__c);
    }

    @isTest
    private static void calculateCANPricingForRenewal() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.Legacy_Percent_Paid__c = 85;

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Origination_Fee_Amount__c" : "299"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = borrowerAccount.Id;
        application.genesis__Account__r = borrowerAccount;

        CAN_Pricing_Detail__c pricingDetail = (CAN_Pricing_Detail__c) JSON.deserialize(
            '{"Oldest_Unpaid_Due_As_Of_Today__c" : "200"}', CAN_Pricing_Detail__c.class
        );
        pricingDetail.Id = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());
        pricingDetail.Offer_Type__c = null;
        pricingDetail.Ocrolus_Max_Daily_Payment__c = 1000;
        pricingDetail.Buy_Rate__c = 10;
        pricingDetail.GAV__c = 20;
        pricingDetail.Overwrite_Policy_Default__c = false;
        pricingDetail.Application__c = application.Id;
        pricingDetail.Loan_Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;
        pricingDetail.Overwrite_Policy_Default__c = true;
        pricingDetail.Standard_Commission__c = 100;
        pricingDetail.Selected_Amount__c = 5000;
        pricingDetail.Broker_Commission_Based_On__c = Brokers.COMMISSION_CALC_METHOD_PERCENTAGE;
        pricingDetail.Industry_Rating__c = 'A+ Medical';
        pricingDetail.SC4_Tier__c = 'TIER 1';
        pricingDetail.Term__c = 6;
        pricingDetail.Maximum_Exception_Amount__c = null;
        pricingDetail.Policy_Maximum_Amount__c = 100;
        pricingDetail.Pricing_Factor__c = 1.2;
        pricingDetail.Maximum_Amount__c = 9000;
        pricingDetail.Annual_Volume__c = 1235000;
        pricingDetail.Origination_Fee_Percentage__c = 12;
        pricingDetail.Pricing_Type__c = CANPricingDetails.PRICING_TYPE_DIRECT_RENEWAL;

        CAN_Pricing_Matrix_Detail__c canPricingMatrixDetail = new CAN_Pricing_Matrix_Detail__c();
        canPricingMatrixDetail.Pricing_Type__c = CANPricingDetails.PRICING_TYPE_DIRECT_RENEWAL;
        canPricingMatrixDetail.Term__c = 6;
        canPricingMatrixDetail.Loan_Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;
        canPricingMatrixDetail.SC4_Tier__c = 'TIER 1';
        canPricingMatrixDetail.Industry_Rating__c = null;
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

        Test.startTest();
            CAN_Pricing_Detail__c canPricingDetail = CANPricingDetails.calculateCANPricing(pricingDetail);
        Test.stopTest();

        System.assertEquals(canGavMatrix.GAV__c, canPricingDetail.Max_GAV__c);
        System.assertEquals(canPricingMatrixDetail.Pricing_Rate__c, canPricingDetail.Floor_Buy_Rate__c);
    }

    @isTest
    private static void isPolicyParameterModified() {
        CAN_Pricing_Detail__c oldPricingDetails = generateCANPricing();
        oldPricingDetails.Term__c = 6;

        CAN_Pricing_Detail__c newPricingDetails = oldPricingDetails;
        newPricingDetails.Term__c = 6;

        Test.startTest();
            Boolean actualPolicyParameter = CANPricingDetails.isPolicyParameterModified(newPricingDetails, oldPricingDetails);
        Test.stopTest();

        System.assertEquals(false, actualPolicyParameter);
    }

    @isTest
    private static void isPricingModified() {
        CAN_Pricing_Detail__c oldPricingDetails = generateCANPricing();

        CAN_Pricing_Detail__c pricingDetail = oldPricingDetails;
        pricingDetail.Maximum_Exception_Amount__c = 1000;
        pricingDetail.Id = oldPricingDetails.Id;
        pricingDetail.Buy_Rate__c = 100;
        pricingDetail.Overwrite_Policy_Default__c = true;

        Test.startTest();
            Boolean actualPricingModified = CANPricingDetails.isPricingModified(pricingDetail, oldPricingDetails);
        Test.stopTest();

        System.assertNotEquals(true, actualPricingModified);
    }

    @isTest
    private static void setGAVAndPricingFactorExceptionPricing() {
        CAN_Pricing_Detail__c oldPricingDetails = generateCANPricing();

        CAN_Pricing_Detail__c pricingDetail = oldPricingDetails;
        pricingDetail.Maximum_Exception_Amount__c = 1000;
        pricingDetail.Id = oldPricingDetails.Id;
        pricingDetail.Buy_Rate__c = 100;
        pricingDetail.Overwrite_Policy_Default__c = true;
        pricingDetail.Standard_Commission__c = 100;

        Exception ex;
        Test.startTest();
            try {
                CANPricingDetails.setGAVAndPricingFactorFromPolicyExhibit(pricingDetail);
            } catch (Exception e) {
                ex = e;
            }
        Test.stopTest();
        System.assertEquals
        (
            'There was no Pricing Matrix Detail found to get Pricing Rate for key : ' + null, ex.getMessage()
        );
    }

    private static void setGAVAndPricingFactorExceptionGAV() {
        CAN_Pricing_Detail__c oldPricingDetails = generateCANPricing();

        CAN_Pricing_Detail__c pricingDetail = oldPricingDetails;
        pricingDetail.Maximum_Exception_Amount__c = 1000;
        pricingDetail.Id = oldPricingDetails.Id;
        pricingDetail.Buy_Rate__c = 100;
        pricingDetail.GAV__c = 11.6;
        pricingDetail.Overwrite_Policy_Default__c = true;
        pricingDetail.Standard_Commission__c = 100;

        CAN_Pricing_Matrix_Detail__c canPricingMatrixDetail = new CAN_Pricing_Matrix_Detail__c();
        canPricingMatrixDetail.Term__c = 6;
        canPricingMatrixDetail.Loan_Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;
        canPricingMatrixDetail.SC4_Tier__c = 'TIER 1';
        canPricingMatrixDetail.Industry_Rating__c = 'A+ Medical';
        canPricingMatrixDetail.Pricing_Rate__c = 2.2;

        DBManagerTestsStub pricingMatrixDetailDBStubInstance = new DBManagerTestsStub();
        pricingMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_Pricing_Matrix_Detail__c> {canPricingMatrixDetail};
        OriginationHelper.pricingMatrixDetailDBInstance = (PricingMatrixDetailDB) Test.createStub(PricingMatrixDetailDB.class, pricingMatrixDetailDBStubInstance);


        Exception ex;
        Test.startTest();
            try {
                CANPricingDetails.setGAVAndPricingFactorFromPolicyExhibit(pricingDetail);
            } catch (Exception e) {
                ex = e;
            }
        Test.stopTest();
        System.assertEquals
        (
            'There was no GAV Matrix Detail found to get GAV for key : ' + pricingDetail.Term__c + pricingDetail.SC4_Tier__c +
            pricingDetail.Industry_Rating__c, ex.getMessage()
        );
    }

    @isTest
    private static void validatePricingBrokerCommission() {
        CAN_Pricing_Detail__c pricingDetail = generateCANPricing();
        pricingDetail.Standard_Commission__c = 2000;
        pricingDetail.Max_Broker_Commission__c = 1000;

        Exception ex;
        Test.startTest();
        try {
            CANPricingDetails.validatePricing(pricingDetail);
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        System.assertEquals(CANPricingDetails.MAXIMUM_COMMISSION_ERROR_MSG + pricingDetail.Max_Broker_Commission__c, ex.getMessage());
    }

    @isTest
    private static void validatePricingMaxAmount() {
        CAN_Pricing_Detail__c pricingDetail = generateCANPricing();
        pricingDetail.Standard_Commission__c = 20;
        pricingDetail.Max_Broker_Commission__c = 50;
        pricingDetail.Maximum_Amount__c = 5000;
        pricingDetail.Selected_Amount__c = 6000;

        Exception ex;
        Test.startTest();
        try {
            CANPricingDetails.validatePricing(pricingDetail);
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        System.assertEquals(CANPricingDetails.MAXIMUM_AMOUNT_ERROR_MSG + pricingDetail.Maximum_Amount__c , ex.getMessage());
    }

    @isTest
    private static void validatePricingTerm() {
        CAN_Pricing_Detail__c pricingDetail = generateCANPricing();
        pricingDetail.Standard_Commission__c = 20;
        pricingDetail.Max_Broker_Commission__c = 50;
        pricingDetail.Maximum_Amount__c = 5000;
        pricingDetail.Selected_Amount__c = 2000;
        pricingDetail.Term__c = 5;

        Exception ex;
        Test.startTest();
        try {
            CANPricingDetails.validatePricing(pricingDetail);
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        System.assertEquals('Term should be greater 6', ex.getMessage());
    }

    @isTest
    private static void validatePricingTermButArchived() {
        CAN_Pricing_Detail__c pricingDetail = generateCANPricing();
        pricingDetail.Standard_Commission__c = 20;
        pricingDetail.Max_Broker_Commission__c = 50;
        pricingDetail.Maximum_Amount__c = 5000;
        pricingDetail.Selected_Amount__c = 2000;
        pricingDetail.Term__c = 5;
        pricingDetail.Status__c = CANPricingDetails.STATUS_ARCHIVED;

        Exception ex;
        Test.startTest();
        try {
            CANPricingDetails.validatePricing(pricingDetail);
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        TestUtility.assertNullException(ex);
        System.assertEquals(5, pricingDetail.Term__c);
    }

    @isTest
    private static void setPricingTypeForNewPartnerChannel() {

        Account brokerAccount = new Account();
        brokerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        brokerAccount.Pricing_Partner_Type__c = CANPricingDetails.PRICING_TYPE_STANDARD_PARTNER_NEW;

        Contact brokerContact = new Contact();
        brokerContact.Id = TestUtility.getFakeId(Contact.getSObjectType());
        brokerContact.Account = brokerAccount;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        application.Broker_Contact__c = brokerContact.Id;
        application.Broker_Contact__r = brokerContact;

        CAN_Pricing_Detail__c pricingDetail = generateCANPricing();
        pricingDetail.Broker_Commission_Based_On__c = Brokers.COMMISSION_CALC_METHOD_FLAT;
        pricingDetail.Loan_Type__c = GeneralConstants.LOAN_TYPE_NEW;
        pricingDetail.Application__c = application.Id;
        pricingDetail.Channel__c = CANPricingDetails.PARTNER_CHANNEL;

        Test.startTest();
            CANPricingDetails.setPricingType(pricingDetail, application);
        Test.stopTest();

        System.assertEquals(CANPricingDetails.PRICING_TYPE_STANDARD_PARTNER_NEW, pricingDetail.Pricing_Type__c);
    }

    @isTest
    private static void setPricingTypeForNewDirectChannel() {

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;

        CAN_Pricing_Detail__c pricingDetail = generateCANPricing();
        pricingDetail.Broker_Commission_Based_On__c = Brokers.COMMISSION_CALC_METHOD_FLAT;
        pricingDetail.Application__c = application.Id;
        pricingDetail.Channel__c = CANPricingDetails.DIRECT_CHANNEL;
        pricingDetail.Loan_Type__c = GeneralConstants.LOAN_TYPE_NEW;

        Test.startTest();
            CANPricingDetails.setPricingType(pricingDetail, application);
        Test.stopTest();

        System.assertEquals(CANPricingDetails.PRICING_TYPE_DIRECT_NEW, pricingDetail.Pricing_Type__c);
    }

    @isTest
    private static void setPricingTypeForRenewalPartnerChannel() {

        Account brokerAccount = new Account();
        brokerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        brokerAccount.Pricing_Partner_Type__c = CANPricingDetails.PRICING_TYPE_STANDARD_PARTNER_NEW;

        Contact brokerContact = new Contact();
        brokerContact.Id = TestUtility.getFakeId(Contact.getSObjectType());
        brokerContact.Account = brokerAccount;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;
        application.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        application.Broker_Contact__c = brokerContact.Id;
        application.Broker_Contact__r = brokerContact;

        CAN_Pricing_Detail__c pricingDetail = generateCANPricing();
        pricingDetail.Broker_Commission_Based_On__c = Brokers.COMMISSION_CALC_METHOD_FLAT;
        pricingDetail.Application__c = application.Id;
        pricingDetail.Channel__c = CANPricingDetails.PARTNER_CHANNEL;
        pricingDetail.Loan_Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;

        Test.startTest();
            CANPricingDetails.setPricingType(pricingDetail, application);
        Test.stopTest();

        System.assertEquals(CANPricingDetails.PRICING_TYPE_PARTNER_RENEWAL, pricingDetail.Pricing_Type__c);
    }

    @isTest
    private static void setPricingTypeForRenewalDirectChannelLegacyPercentPaidGreaterThan90() {

        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.Legacy_Percent_Paid__c = 100;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;
        application.genesis__Account__c = borrowerAccount.Id;
        application.genesis__Account__r = borrowerAccount;

        CAN_Pricing_Detail__c pricingDetail = generateCANPricing();
        pricingDetail.Broker_Commission_Based_On__c = Brokers.COMMISSION_CALC_METHOD_FLAT;
        pricingDetail.Application__c = application.Id;
        pricingDetail.Channel__c = CANPricingDetails.DIRECT_CHANNEL;
        pricingDetail.Loan_Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;

        Test.startTest();
            CANPricingDetails.setPricingType(pricingDetail, application);
        Test.stopTest();

        System.assertEquals(CANPricingDetails.PRICING_TYPE_WINBACK_RENEWAL, pricingDetail.Pricing_Type__c);
    }

    @isTest
    private static void setPricingTypeForRenewalDirectChannelLegacyPercentPaidLessThan90() {

        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.Legacy_Percent_Paid__c = 85;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;
        application.genesis__Account__c = borrowerAccount.Id;
        application.genesis__Account__r = borrowerAccount;

        CAN_Pricing_Detail__c pricingDetail = generateCANPricing();
        pricingDetail.Broker_Commission_Based_On__c = Brokers.COMMISSION_CALC_METHOD_FLAT;
        pricingDetail.Application__c = application.Id;
        pricingDetail.Channel__c = CANPricingDetails.DIRECT_CHANNEL;
        pricingDetail.Loan_Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;

        Test.startTest();
            CANPricingDetails.setPricingType(pricingDetail, application);
        Test.stopTest();

        System.assertEquals(CANPricingDetails.PRICING_TYPE_DIRECT_RENEWAL, pricingDetail.Pricing_Type__c);
    }

    private static CAN_Pricing_Detail__c generateCANPricing(){
        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Id = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());
        pricingDetail.Maximum_Exception_Amount__c = 10000;
        pricingDetail.Offer_Type__c = null;
        pricingDetail.Ocrolus_Max_Daily_Payment__c = 1000;
        pricingDetail.Buy_Rate__c = 10;
        pricingDetail.GAV__c = 20;
        pricingDetail.Overwrite_Policy_Default__c = false;
        return pricingDetail;
    }
}