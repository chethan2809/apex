@isTest
private class CANPricingDetailManagerTests {

    @isTest
    private static void archiveExistingCANPricingDetails() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Id pricingDetailId = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());
        Id unArchivedPricingDetailId = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Origination_Fee_Amount__c" : "299"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        application.Opportunity__c = TestUtility.getFakeId(Opportunity.getSObjectType());
        application.Industry_Rating__c = 'A+ Medical';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 1413777;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 1;
        application.genesis__Payment_Frequency__c = 'DAILY';

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Application__c = applicationId;
        pricingDetail.Id = pricingDetailId;
        pricingDetail.Status__c = 'Sent To Customer';

        DBManagerTestsStub canPricingDBStubInstance = new DBManagerTestsStub();
        canPricingDBStubInstance.genericReturnObject = new List<CAN_Pricing_Detail__c>{pricingDetail};
        CANPricingDetailManager.canPricingDetailDBInstance = (CANPricingDetailDB) Test.createStub(CANPricingDetailDB.class, canPricingDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CANPricingDetailManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Set<Id> applicationIdToPricingIdForArchiveSet = new Set<Id>();
        applicationIdToPricingIdForArchiveSet.add(applicationId);

        Map<Id, Id> applicationIdToPricingIdForArchive = new Map<Id, Id>();
        applicationIdToPricingIdForArchive.put(pricingDetail.Application__c, unArchivedPricingDetailId);

        Test.startTest();
            CANPricingDetailManager.archiveExistingCANPricingDetails(applicationIdToPricingIdForArchive);
        Test.stopTest();

        System.assertEquals(1, canPricingDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void createInitialCANPricingDetail() {
        TestUtility.runSetupData();
        Id pricingDetailId = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());
        Id brokerContactId = TestUtility.getFakeId(Contact.getSObjectType());

        Account account = TestUtility.createAccount();
        account.New_Max_Broker_Commission__c = 20.00;
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        Contact contact = TestUtility.createContact();
        contact.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contact.AccountId = account.Id;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Broker_Contact__c = contact.Id;
        application.Type__c =  'New';
        application.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        application.Opportunity__c = TestUtility.getFakeId(Opportunity.getSObjectType());
        application.Industry_Rating__c = 'A+ Medical';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 808456;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 23;
        application.genesis__Payment_Frequency__c = 'DAILY';

        CAN_Pricing_Matrix_Detail__c pricingMatrixDetail = new CAN_Pricing_Matrix_Detail__c();
        pricingMatrixDetail.Pricing_Type__c = CANPricingDetails.PRICING_TYPE_STANDARD_PARTNER_NEW;
        pricingMatrixDetail.Term__c = 14;
        pricingMatrixDetail.Loan_Type__c = 'New';
        pricingMatrixDetail.SC4_Tier__c = 'TIER 1';
        pricingMatrixDetail.Industry_Rating__c = 'A+ Medical';
        pricingMatrixDetail.Pricing_Rate__c = 1.2;

        CAN_GAV_Matrix_Detail__c gavMatrixDetail = new CAN_GAV_Matrix_Detail__c();
        gavMatrixDetail.Term__c = 14;
        gavMatrixDetail.SC4_Tier__c = 'TIER 1';
        gavMatrixDetail.Industry_Rating__c = 'A+ Medical';
        gavMatrixDetail.GAV__c = 24;

        DBManagerTestsStub pricingMatrixDetailDBStubInstance = new DBManagerTestsStub();
        pricingMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_Pricing_Matrix_Detail__c> {pricingMatrixDetail};
        OriginationHelper.pricingMatrixDetailDBInstance = (PricingMatrixDetailDB) Test.createStub(PricingMatrixDetailDB.class, pricingMatrixDetailDBStubInstance);

        DBManagerTestsStub gavMatrixDetailDBStubInstance = new DBManagerTestsStub();
        gavMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_GAV_Matrix_Detail__c> {gavMatrixDetail};
        OriginationHelper.gavMatrixDetailDBInstance = (GAVMatrixDetailDB) Test.createStub(GAVMatrixDetailDB.class, gavMatrixDetailDBStubInstance);

        CAN_Max_Amount_And_Max_Term_Mapping__c maxAmountAndMaxTerm = new CAN_Max_Amount_And_Max_Term_Mapping__c();
        maxAmountAndMaxTerm.Pricing_Type__c = CANPricingDetails.PRICING_TYPE_STANDARD_PARTNER_NEW;
        maxAmountAndMaxTerm.Maximum_Amount_Multi_Location__c = 300000;
        maxAmountAndMaxTerm.Maximum_Amount_Single_Location__c = 250000;
        maxAmountAndMaxTerm.Maximum_Term__c = 14;
        maxAmountAndMaxTerm.Loan_Type__c = GeneralConstants.LOAN_TYPE_NEW;
        maxAmountAndMaxTerm.Industry_Rating__c = 'A+ Medical';
        maxAmountAndMaxTerm.SC4_Tier__c = 'TIER 1';

        DBManagerTestsStub maxAmountAndMaxTermMappingDBStubInstance = new DBManagerTestsStub();
        maxAmountAndMaxTermMappingDBStubInstance.genericReturnObject = new List<CAN_Max_Amount_And_Max_Term_Mapping__c> {maxAmountAndMaxTerm};
        OriginationHelper.maxAmountAndMaxTermMappingDBInstance = (MaxAmountAndMaxTermMappingDB) Test.createStub(MaxAmountAndMaxTermMappingDB.class, maxAmountAndMaxTermMappingDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        CANPricingDetailManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Max_Daily_Payment__c = 851.2645;

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        ocrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c>{ocrolusReport};
        CANPricingDetailManager.canOcrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        DBManagerTestsStub canPricingDBStubInstance = new DBManagerTestsStub();
        CANPricingDetailManager.canPricingDetailDBInstance = (CANPricingDetailDB) Test.createStub(CANPricingDetailDB.class, canPricingDBStubInstance);

        LoanCalculatorManagerTestStub loanCalculatorManagerTestStubInstance = new LoanCalculatorManagerTestStub();
        Applications.loanCalculatorManagerInstance = (LoanCalculatorManager) Test.createStub(
            LoanCalculatorManager.class, loanCalculatorManagerTestStubInstance
        );

        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(application.Id);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CANPricingDetailManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Boolean isSingleLocation = true;

        Test.startTest();
            CANPricingDetailManager.createInitialCANPricingDetail(applicationIds);
        Test.stopTest();

        System.assertEquals(1, applicationDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void createInitialCANPricingDetailException() {
        TestUtility.runSetupData();
        Id pricingDetailId = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());
        Id brokerContactId = TestUtility.getFakeId(Contact.getSObjectType());

        Account account = TestUtility.createAccount();
        account.New_Max_Broker_Commission__c = 20.00;
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        Contact contact = TestUtility.createContact();
        contact.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contact.AccountId = account.Id;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Broker_Contact__c = contact.Id;
        application.Type__c =  'New';
        application.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        application.Opportunity__c = TestUtility.getFakeId(Opportunity.getSObjectType());
        application.Industry_Rating__c = 'A+ Medical';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 808456;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 23;
        application.genesis__Payment_Frequency__c = 'DAILY';

        CAN_Pricing_Matrix_Detail__c pricingMatrixDetail = new CAN_Pricing_Matrix_Detail__c();
        pricingMatrixDetail.Pricing_Type__c = CANPricingDetails.PRICING_TYPE_DIRECT_NEW;
        pricingMatrixDetail.Term__c = 14;
        pricingMatrixDetail.Loan_Type__c = 'New';
        pricingMatrixDetail.SC4_Tier__c = 'TIER 1';
        pricingMatrixDetail.Industry_Rating__c = 'A+ Medical';
        pricingMatrixDetail.Pricing_Rate__c = 1.2;

        CAN_GAV_Matrix_Detail__c gavMatrixDetail = new CAN_GAV_Matrix_Detail__c();
        gavMatrixDetail.Term__c = 14;
        gavMatrixDetail.SC4_Tier__c = 'TIER 1';
        gavMatrixDetail.Industry_Rating__c = 'A+ Medical';
        gavMatrixDetail.GAV__c = 24;

        DBManagerTestsStub pricingMatrixDetailDBStubInstance = new DBManagerTestsStub();
        pricingMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_Pricing_Matrix_Detail__c> {pricingMatrixDetail};
        OriginationHelper.pricingMatrixDetailDBInstance = (PricingMatrixDetailDB) Test.createStub(PricingMatrixDetailDB.class, pricingMatrixDetailDBStubInstance);

        DBManagerTestsStub gavMatrixDetailDBStubInstance = new DBManagerTestsStub();
        gavMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_GAV_Matrix_Detail__c> {gavMatrixDetail};
        OriginationHelper.gavMatrixDetailDBInstance = (GAVMatrixDetailDB) Test.createStub(GAVMatrixDetailDB.class, gavMatrixDetailDBStubInstance);


        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        CANPricingDetailManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Max_Daily_Payment__c = 851.2645;

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        ocrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c>{ocrolusReport};
        CANPricingDetailManager.canOcrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        DBManagerTestsStub canPricingDBStubInstance = new DBManagerTestsStub();
        CANPricingDetailManager.canPricingDetailDBInstance = (CANPricingDetailDB) Test.createStub(CANPricingDetailDB.class, canPricingDBStubInstance);

        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(application.Id);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CANPricingDetailManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Boolean isSingleLocation = true;

        Test.startTest();
            CANPricingDetailManager.createInitialCANPricingDetail(applicationIds);
        Test.stopTest();

        System.assertEquals(1, applicationDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void handleBeforeInsertExceptionAndManualPricing() {
        TestUtility.runSetupData();
        Id pricingDetailId = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        application.Opportunity__c = TestUtility.getFakeId(Opportunity.getSObjectType());
        application.Industry_Rating__c = 'A+ Medical';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 808456;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 23;
        application.genesis__Payment_Frequency__c = 'DAILY';

        CAN_Pricing_Matrix_Detail__c pricingMatrixDetail = new CAN_Pricing_Matrix_Detail__c();
        pricingMatrixDetail.Pricing_Type__c = CANPricingDetails.PRICING_TYPE_DIRECT_NEW;
        pricingMatrixDetail.Term__c = 14;
        pricingMatrixDetail.Loan_Type__c = 'New';
        pricingMatrixDetail.SC4_Tier__c = 'TIER 1';
        pricingMatrixDetail.Industry_Rating__c = 'A+ Medical';
        pricingMatrixDetail.Pricing_Rate__c = 1.2;

        CAN_GAV_Matrix_Detail__c gavMatrixDetail = new CAN_GAV_Matrix_Detail__c();
        gavMatrixDetail.Term__c = 14;
        gavMatrixDetail.SC4_Tier__c = 'TIER 1';
        gavMatrixDetail.Industry_Rating__c = 'A+ Medical';
        gavMatrixDetail.GAV__c = 24;

        DBManagerTestsStub pricingMatrixDetailDBStubInstance = new DBManagerTestsStub();
        pricingMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_Pricing_Matrix_Detail__c> {pricingMatrixDetail};
        OriginationHelper.pricingMatrixDetailDBInstance = (PricingMatrixDetailDB) Test.createStub(PricingMatrixDetailDB.class, pricingMatrixDetailDBStubInstance);

        DBManagerTestsStub gavMatrixDetailDBStubInstance = new DBManagerTestsStub();
        gavMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_GAV_Matrix_Detail__c> {gavMatrixDetail};
        OriginationHelper.gavMatrixDetailDBInstance = (GAVMatrixDetailDB) Test.createStub(GAVMatrixDetailDB.class, gavMatrixDetailDBStubInstance);

        CAN_Max_Amount_And_Max_Term_Mapping__c maxAmountAndMaxTerm = new CAN_Max_Amount_And_Max_Term_Mapping__c();
        maxAmountAndMaxTerm.Pricing_Type__c = CANPricingDetails.PRICING_TYPE_DIRECT_NEW;
        maxAmountAndMaxTerm.Maximum_Amount_Multi_Location__c = 300000;
        maxAmountAndMaxTerm.Maximum_Amount_Single_Location__c = 250000;
        maxAmountAndMaxTerm.Maximum_Term__c = 14;
        maxAmountAndMaxTerm.Loan_Type__c = GeneralConstants.LOAN_TYPE_NEW;
        maxAmountAndMaxTerm.Industry_Rating__c = 'A+ Medical';
        maxAmountAndMaxTerm.SC4_Tier__c = 'TIER 1';

        DBManagerTestsStub maxAmountAndMaxTermMappingDBStubInstance = new DBManagerTestsStub();
        maxAmountAndMaxTermMappingDBStubInstance.genericReturnObject = new List<CAN_Max_Amount_And_Max_Term_Mapping__c> {maxAmountAndMaxTerm};
        OriginationHelper.maxAmountAndMaxTermMappingDBInstance = (MaxAmountAndMaxTermMappingDB) Test.createStub(MaxAmountAndMaxTermMappingDB.class, maxAmountAndMaxTermMappingDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        CANPricingDetailManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Max_Daily_Payment__c = 851.2645;

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        ocrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c>{ocrolusReport};
        CANPricingDetailManager.canOcrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        LoanCalculatorManagerTestStub loanCalculatorManagerTestStubInstance = new LoanCalculatorManagerTestStub();
        Applications.loanCalculatorManagerInstance = (LoanCalculatorManager) Test.createStub(
            LoanCalculatorManager.class, loanCalculatorManagerTestStubInstance
        );

        List<CAN_Pricing_Detail__c> pricingDetailList = new List<CAN_Pricing_Detail__c>();
        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Application__c = application.Id;
        pricingDetail.Id = pricingDetailId;
        pricingDetail.Offer_Type__c = 'Exception Offer';
        pricingDetail.Maximum_Amount__c = 250001;
        pricingDetail.Term__c = 14;
        pricingDetail.Maximum_Term__c = 14;
        pricingDetail.Industry_Rating__c = 'A+ Medical';
        pricingDetail.SC4_Tier__c = 'TIER 1';
        pricingDetail.Buy_Rate__c = 1.2;
        pricingDetail.Pricing_Factor__c = 1.2;
        pricingDetail.Ocrolus_Max_Daily_Payment__c = 85123.2645;
        pricingDetail.Maximum_Exception_Amount__c = 23278;
        pricingDetail.Selected_Amount__c = 2314;
        pricingDetail.Pricing_Type__c = CANPricingDetails.PRICING_TYPE_DIRECT_NEW;
        pricingDetail.Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        pricingDetailList.add(pricingDetail);

        CAN_Max_Amount_And_Max_Term_Mapping__c canMaxAmountMaxTerm = new CAN_Max_Amount_And_Max_Term_Mapping__c();
        canMaxAmountMaxTerm.Id = TestUtility.getFakeId(CAN_Max_Amount_And_Max_Term_Mapping__c.getSObjectType());
        canMaxAmountMaxTerm.Loan_Type__c = 'New';
        canMaxAmountMaxTerm.Industry_Rating__c = 'A+ Medical';
        canMaxAmountMaxTerm.SC4_Tier__c = 'TIER 1';

        GeneralHelper.currentSystemDate = Date.today();

        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(application.Id);

        Test.startTest();
            CANPricingDetailManager.handleBeforeInsertExceptionAndManualPricing(pricingDetailList, applicationIds);
        Test.stopTest();

        System.assertEquals(851.2645, ocrolusReport.Max_Daily_Payment__c);
    }
}