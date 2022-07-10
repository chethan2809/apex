@isTest
private class CANPricingDetailTriggerHandlerTests {
    @TestSetup
    static void makeData() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        TestUtility.runSetupData();
        genesis__Applications__c application = TestUtility.createApplication();

        application.Pricing_Factor__c = 1.2;
        application.Type__c = 'New';
        application.Industry_Rating__c = 'A+ Medical';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 23896470;
        application.Origination_Fee_Percentage__c = 2.99;
        application.genesis__Status__c = Applications.STATUS_NEW_ENTERED;
        application.Credit_Check_Consent__c = true;
        application.SIC_Code__c = '073';
        application.Business_Start_Date__c = TestUtility.currentSystemDate;
        update application;
    }

    @isTest
    private static void beforeInsertTests() {
        genesis__Applications__c application = [
            SELECT Id, Name, Bank_Account__c, Owner.Email, Owner.Name, Annual_Volume__c, SC4_Tier__c, Broker_Contact__r.Account.Name,
                Industry_Rating__c, Origination_Fee_Percentage__c, genesis__Account__r.Name, Type__c, Auto_Renewed__c,
                Maximum_Funding_Amount__c, genesis__Account__r.Merchant_ID__c, Sales_Rep__c, Sales_Rep__r.Email, Broker_Contact__c,
                Broker_Contact__r.Email, genesis__Requested_Loan_Amount__c, Max_Term__c, Buy_Rate__c, Pricing_Factor__c,
                Max_Broker_Commission__c, genesis__Payment_Frequency__c ,Opportunity__c, Origination_Fee_Amount__c, genesis__Loan_Amount__c
            FROM genesis__Applications__c
        ];

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Analytics_PK__c = '12872807';
        ocrolusReport.Max_Daily_Payment__c = 851.2645;

        List<CAN_Pricing_Detail__c> pricingDetailList = new List<CAN_Pricing_Detail__c>();
        CAN_Pricing_Detail__c pricingDetail =  new CAN_Pricing_Detail__c();
        pricingDetail.Application__c = application.Id;
        pricingDetail.Account__c = application.genesis__Account__c;
        pricingDetail.Opportunity__c = application.Opportunity__c;
        pricingDetail.Industry_Rating__c = application.Industry_Rating__c;
        pricingDetail.SC4_Tier__c = application.SC4_Tier__c;
        pricingDetail.Annual_Volume__c = application.Annual_Volume__c;
        pricingDetail.Loan_Type__c = application.Type__c;
        pricingDetail.Origination_Fee_Percentage__c = application.Origination_Fee_Percentage__c;
        pricingDetail.Origination_Fee_Amount__c = application.Origination_Fee_Amount__c;
        pricingDetail.Payment_Frequency__c = application.genesis__Payment_Frequency__c;
        pricingDetail.Status__c = 'Sent To Customer';
        pricingDetail.Ocrolus_Max_Daily_Payment__c = 132462;
        pricingDetailList.add(pricingDetail);

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        ocrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c> {ocrolusReport};
        CANPricingDetailManager.canOcrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        Test.startTest();
            CANPricingDetailTriggerHandler pricingDetailTrigger = new CANPricingDetailTriggerHandler();
            pricingDetailTrigger.beforeInsert(pricingDetailList);
        Test.stopTest();

        System.assertEquals(CANPricingDetails.STATUS_SENT_TO_CUSTOMER, pricingDetail.Status__c);
    }

    @isTest
    private static void afterInsertStatusSent() {
        genesis__Applications__c application = [
            SELECT Id, Name, Bank_Account__c, Owner.Email, Owner.Name, Annual_Volume__c, SC4_Tier__c, Broker_Contact__r.Account.Name,
                Industry_Rating__c, Origination_Fee_Percentage__c, genesis__Account__r.Name, Type__c, Auto_Renewed__c,
                Maximum_Funding_Amount__c, genesis__Account__r.Merchant_ID__c, Sales_Rep__c, Sales_Rep__r.Email, Broker_Contact__c,
                Broker_Contact__r.Email, genesis__Requested_Loan_Amount__c, Max_Term__c, Buy_Rate__c, Pricing_Factor__c,
                Max_Broker_Commission__c, genesis__Payment_Frequency__c , Opportunity__c, Origination_Fee_Amount__c, genesis__Loan_Amount__c
            FROM genesis__Applications__c
        ];

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Analytics_PK__c = '12872807';
        ocrolusReport.Max_Daily_Payment__c = 851.2645;

        CAN_Pricing_Detail__c pricingDetail =  new CAN_Pricing_Detail__c();
        pricingDetail.Application__c = application.Id;
        pricingDetail.Account__c = application.genesis__Account__c;
        pricingDetail.Opportunity__c = application.Opportunity__c;
        pricingDetail.Industry_Rating__c = application.Industry_Rating__c;
        pricingDetail.SC4_Tier__c = application.SC4_Tier__c;
        pricingDetail.Annual_Volume__c = application.Annual_Volume__c;
        pricingDetail.Loan_Type__c = application.Type__c;
        pricingDetail.Origination_Fee_Percentage__c = application.Origination_Fee_Percentage__c;
        pricingDetail.Origination_Fee_Amount__c = application.Origination_Fee_Amount__c;
        pricingDetail.Payment_Frequency__c = application.genesis__Payment_Frequency__c;
        pricingDetail.Status__c = 'Sent To Customer';
        pricingDetail.Ocrolus_Max_Daily_Payment__c = 132462;
        insert pricingDetail;

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        ocrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c> {ocrolusReport};
        CANPricingDetailManager.canOcrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        Map<Id, CAN_Pricing_Detail__c> pricingDetailMap = new Map<Id, CAN_Pricing_Detail__c>();
        pricingDetailMap.put(pricingDetail.Id, pricingDetail);

        Test.startTest();
            CANPricingDetailTriggerHandler pricingDetailTrigger = new CANPricingDetailTriggerHandler();
            pricingDetailTrigger.afterInsert(pricingDetailMap);
        Test.stopTest();

        CAN_Pricing_Detail__c pricingDetailRecord = [SELECT Id, Status__c FROM CAN_Pricing_Detail__c LIMIT 1];
        System.assertEquals(CANPricingDetails.STATUS_SENT_TO_CUSTOMER, pricingDetailRecord.Status__c);
    }

    @isTest
    private static void afterInsertStatusRequired() {
        genesis__Applications__c application = [
            SELECT Id, Name, Bank_Account__c, Owner.Email, Owner.Name, Annual_Volume__c, SC4_Tier__c, Broker_Contact__r.Account.Name,
                Industry_Rating__c, Origination_Fee_Percentage__c, genesis__Account__r.Name, Type__c, Auto_Renewed__c,
                Maximum_Funding_Amount__c, genesis__Account__r.Merchant_ID__c, Sales_Rep__c, Sales_Rep__r.Email, Broker_Contact__c,
                Broker_Contact__r.Email, genesis__Requested_Loan_Amount__c, Max_Term__c, Buy_Rate__c, Pricing_Factor__c,
                Max_Broker_Commission__c, genesis__Payment_Frequency__c , Opportunity__c, Origination_Fee_Amount__c,
                genesis__Expected_Start_Date__c, genesis__Loan_Amount__c, genesis__Term__c, Random_Number__c
            FROM genesis__Applications__c
        ];

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Analytics_PK__c = '12872807';
        ocrolusReport.Max_Daily_Payment__c = 851.2645;

        CAN_GAV_Matrix_Detail__c gavMatrix = new CAN_GAV_Matrix_Detail__c();
        gavMatrix.Id = TestUtility.getFakeId(CAN_GAV_Matrix_Detail__c.getSObjectType());
        gavMatrix.Industry_Rating__c = 'A+ Medical';
        gavMatrix.SC4_Tier__c = 'TIER 1';
        gavMatrix.Term__c = 6;
        gavMatrix.GAV__c = 9.2;

        CAN_Pricing_Matrix_Detail__c pricingMatrixDetail = new CAN_Pricing_Matrix_Detail__c();
        pricingMatrixDetail.Id = TestUtility.getFakeId(CAN_Pricing_Matrix_Detail__c.getSObjectType());
        pricingMatrixDetail.Pricing_Type__c = CANPricingDetails.PRICING_TYPE_DIRECT_NEW;
        pricingMatrixDetail.Loan_Type__c = 'New';
        pricingMatrixDetail.Industry_Rating__c = 'A+ Medical';
        pricingMatrixDetail.SC4_Tier__c = 'TIER 1';
        pricingMatrixDetail.Term__c = 6;
        pricingMatrixDetail.Pricing_Rate__c = 1.4;

        CAN_Max_Amount_And_Max_Term_Mapping__c maxAmountMaxTerm = new CAN_Max_Amount_And_Max_Term_Mapping__c();
        maxAmountMaxTerm.Id = TestUtility.getFakeId(CAN_Max_Amount_And_Max_Term_Mapping__c.getSObjectType());
        maxAmountMaxTerm.Pricing_Type__c = CANPricingDetails.PRICING_TYPE_DIRECT_NEW;
        maxAmountMaxTerm.Loan_Type__c = 'New';
        maxAmountMaxTerm.Industry_Rating__c = 'A+ Medical';
        maxAmountMaxTerm.SC4_Tier__c = 'TIER 1';
        maxAmountMaxTerm.Maximum_Term__c = 6;
        maxAmountMaxTerm.Maximum_Amount_Single_Location__c = 1231433;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        CANPricingDetailManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        ocrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c> {ocrolusReport};
        CANPricingDetailManager.canOcrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        DBManagerTestsStub pricingMatrixDetailDBStubInstance = new DBManagerTestsStub();
        pricingMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_Pricing_Matrix_Detail__c> {pricingMatrixDetail};
        OriginationHelper.pricingMatrixDetailDBInstance = (PricingMatrixDetailDB) Test.createStub(PricingMatrixDetailDB.class, pricingMatrixDetailDBStubInstance);

        DBManagerTestsStub gavMatrixDetailDBStubInstance = new DBManagerTestsStub();
        gavMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_GAV_Matrix_Detail__c> {gavMatrix};
        OriginationHelper.gavMatrixDetailDBInstance = (GAVMatrixDetailDB) Test.createStub(GAVMatrixDetailDB.class, gavMatrixDetailDBStubInstance);

        DBManagerTestsStub maxAmountAndMaxTermMappingDBStubInstance = new DBManagerTestsStub();
        maxAmountAndMaxTermMappingDBStubInstance.genericReturnObject = new List<CAN_Max_Amount_And_Max_Term_Mapping__c> {maxAmountMaxTerm};
        OriginationHelper.maxAmountAndMaxTermMappingDBInstance = (MaxAmountAndMaxTermMappingDB) Test.createStub(MaxAmountAndMaxTermMappingDB.class, maxAmountAndMaxTermMappingDBStubInstance);

        CAN_Pricing_Detail__c pricingDetail =  new CAN_Pricing_Detail__c();
        pricingDetail.Application__c = application.Id;
        pricingDetail.Account__c = application.genesis__Account__c;
        pricingDetail.Opportunity__c = application.Opportunity__c;
        pricingDetail.Industry_Rating__c = application.Industry_Rating__c;
        pricingDetail.SC4_Tier__c = application.SC4_Tier__c;
        pricingDetail.Annual_Volume__c = application.Annual_Volume__c;
        pricingDetail.Loan_Type__c = application.Type__c;
        pricingDetail.Origination_Fee_Percentage__c = application.Origination_Fee_Percentage__c;
        pricingDetail.Origination_Fee_Amount__c = application.Origination_Fee_Amount__c;
        pricingDetail.Payment_Frequency__c = application.genesis__Payment_Frequency__c;
        pricingDetail.Status__c = 'Review Required';
        pricingDetail.Ocrolus_Max_Daily_Payment__c = 132462;
        pricingDetail.Maximum_Term__c = 6;
        pricingDetail.Maximum_Exception_Amount__c = 132462;
        pricingDetail.Pricing_Type__c = CANPricingDetails.PRICING_TYPE_DIRECT_NEW;
        insert pricingDetail;

        Map<Id, CAN_Pricing_Detail__c> pricingDetailMap = new Map<Id, CAN_Pricing_Detail__c>();
        pricingDetailMap.put(pricingDetail.Id, pricingDetail);

        Test.startTest();
            CANPricingDetailTriggerHandler pricingDetailTrigger = new CANPricingDetailTriggerHandler();
            pricingDetailTrigger.afterInsert(pricingDetailMap);
        Test.stopTest();

        genesis__Applications__c applicationRecord = [SELECT Id, genesis__Status__c FROM genesis__Applications__c LIMIT 1];
        System.assertEquals(Applications.STATUS_GUARANTOR_CREDIT_CHECK, applicationRecord.genesis__Status__c);
    }

    @isTest
    private static void afterInsertStatusAccepted() {
        genesis__Applications__c application = [
            SELECT Id, Name, Bank_Account__c, Owner.Email, Owner.Name, Annual_Volume__c, SC4_Tier__c, Broker_Contact__r.Account.Name,
                Industry_Rating__c, Origination_Fee_Percentage__c, genesis__Account__r.Name, Type__c, Auto_Renewed__c,
                Maximum_Funding_Amount__c, genesis__Account__r.Merchant_ID__c, Sales_Rep__c, Sales_Rep__r.Email, Broker_Contact__c,
                Broker_Contact__r.Email, genesis__Requested_Loan_Amount__c, Max_Term__c, Buy_Rate__c, Pricing_Factor__c,
                Max_Broker_Commission__c, genesis__Payment_Frequency__c , Opportunity__c, Origination_Fee_Amount__c, genesis__Loan_Amount__c,
                genesis__Term__c, genesis__Expected_Start_Date__c, genesis__Expected_Close_Date__c, genesis__Expected_First_Payment_Date__c,
                Random_Number__c
            FROM genesis__Applications__c
        ];

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Analytics_PK__c = '12872807';
        ocrolusReport.Max_Daily_Payment__c = 851.2645;

        CAN_GAV_Matrix_Detail__c gavMatrix = new CAN_GAV_Matrix_Detail__c();
        gavMatrix.Id = TestUtility.getFakeId(CAN_GAV_Matrix_Detail__c.getSObjectType());
        gavMatrix.Industry_Rating__c = 'A+ Medical';
        gavMatrix.SC4_Tier__c = 'TIER 1';
        gavMatrix.Term__c = 6;
        gavMatrix.GAV__c = 9.2;

        CAN_Pricing_Matrix_Detail__c pricingMatrixDetail = new CAN_Pricing_Matrix_Detail__c();
        pricingMatrixDetail.Id = TestUtility.getFakeId(CAN_Pricing_Matrix_Detail__c.getSObjectType());
        pricingMatrixDetail.Pricing_Type__c = CANPricingDetails.PRICING_TYPE_DIRECT_NEW;
        pricingMatrixDetail.Loan_Type__c = 'New';
        pricingMatrixDetail.Industry_Rating__c = 'A+ Medical';
        pricingMatrixDetail.SC4_Tier__c = 'TIER 1';
        pricingMatrixDetail.Term__c = 6;
        pricingMatrixDetail.Pricing_Rate__c = 1.4;

        CAN_Max_Amount_And_Max_Term_Mapping__c maxAmountMaxTerm = new CAN_Max_Amount_And_Max_Term_Mapping__c();
        maxAmountMaxTerm.Id = TestUtility.getFakeId(CAN_Max_Amount_And_Max_Term_Mapping__c.getSObjectType());
        maxAmountMaxTerm.Loan_Type__c = 'New';
        maxAmountMaxTerm.Industry_Rating__c = 'A+ Medical';
        maxAmountMaxTerm.SC4_Tier__c = 'TIER 1';
        maxAmountMaxTerm.Maximum_Term__c = 6;
        maxAmountMaxTerm.Maximum_Amount_Single_Location__c = 1231433;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        ocrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c> {ocrolusReport};
        CANPricingDetailManager.canOcrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        DBManagerTestsStub pricingMatrixDetailDBStubInstance = new DBManagerTestsStub();
        pricingMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_Pricing_Matrix_Detail__c> {pricingMatrixDetail};
        OriginationHelper.pricingMatrixDetailDBInstance = (PricingMatrixDetailDB) Test.createStub(PricingMatrixDetailDB.class, pricingMatrixDetailDBStubInstance);

        DBManagerTestsStub gavMatrixDetailDBStubInstance = new DBManagerTestsStub();
        gavMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_GAV_Matrix_Detail__c> {gavMatrix};
        OriginationHelper.gavMatrixDetailDBInstance = (GAVMatrixDetailDB) Test.createStub(GAVMatrixDetailDB.class, gavMatrixDetailDBStubInstance);

        DBManagerTestsStub maxAmountAndMaxTermMappingDBStubInstance = new DBManagerTestsStub();
        maxAmountAndMaxTermMappingDBStubInstance.genericReturnObject = new List<CAN_Max_Amount_And_Max_Term_Mapping__c> {maxAmountMaxTerm};
        OriginationHelper.maxAmountAndMaxTermMappingDBInstance = (MaxAmountAndMaxTermMappingDB) Test.createStub(MaxAmountAndMaxTermMappingDB.class, maxAmountAndMaxTermMappingDBStubInstance);

        LoanCalculatorManagerTestStub loanCalculatorManagerTestStubInstance = new LoanCalculatorManagerTestStub();
        Applications.loanCalculatorManagerInstance = (LoanCalculatorManager) Test.createStub(
            LoanCalculatorManager.class, loanCalculatorManagerTestStubInstance
        );

        CAN_Pricing_Detail__c pricingDetail =  new CAN_Pricing_Detail__c();
        pricingDetail.Application__c = application.Id;
        pricingDetail.Account__c = application.genesis__Account__c;
        pricingDetail.Opportunity__c = application.Opportunity__c;
        pricingDetail.Industry_Rating__c = application.Industry_Rating__c;
        pricingDetail.SC4_Tier__c = application.SC4_Tier__c;
        pricingDetail.Annual_Volume__c = application.Annual_Volume__c;
        pricingDetail.Loan_Type__c = application.Type__c;
        pricingDetail.Origination_Fee_Percentage__c = application.Origination_Fee_Percentage__c;
        pricingDetail.Origination_Fee_Amount__c = application.Origination_Fee_Amount__c;
        pricingDetail.Payment_Frequency__c = application.genesis__Payment_Frequency__c;
        pricingDetail.Status__c = 'Accepted';
        pricingDetail.Ocrolus_Max_Daily_Payment__c = 132462;
        pricingDetail.Maximum_Exception_Amount__c = 132462;
        pricingDetail.Pricing_Type__c = CANPricingDetails.PRICING_TYPE_DIRECT_NEW;
        pricingDetail.Selected_Amount__c = 1000;
        pricingDetail.Maximum_Amount__c = 1000;
        pricingDetail.Term__c = 12;
        pricingDetail.Pricing_Factor__c = 1.28;
        insert pricingDetail;

        Map<Id, CAN_Pricing_Detail__c> pricingDetailMap = new Map<Id, CAN_Pricing_Detail__c>();
        pricingDetailMap.put(pricingDetail.Id, pricingDetail);

        Test.startTest();
            CANPricingDetailTriggerHandler pricingDetailTrigger = new CANPricingDetailTriggerHandler();
            pricingDetailTrigger.afterInsert(pricingDetailMap);
        Test.stopTest();

        genesis__Applications__c applicationRecord = [SELECT Id, genesis__Status__c FROM genesis__Applications__c LIMIT 1];
        System.assertEquals(Applications.STATUS_OFFER_ACCEPTED, applicationRecord.genesis__Status__c);
    }

    @isTest
    private static void beforeUpdate() {
        genesis__Applications__c application = [
            SELECT Id, Name, Bank_Account__c, Owner.Email, Owner.Name, Annual_Volume__c, SC4_Tier__c, Broker_Contact__r.Account.Name,
                Industry_Rating__c, Origination_Fee_Percentage__c, genesis__Account__r.Name, Type__c, Auto_Renewed__c,
                Maximum_Funding_Amount__c, genesis__Account__r.Merchant_ID__c, Sales_Rep__c, Sales_Rep__r.Email, Broker_Contact__c,
                Broker_Contact__r.Email, genesis__Requested_Loan_Amount__c, Max_Term__c, Buy_Rate__c, Pricing_Factor__c,
                Max_Broker_Commission__c, genesis__Payment_Frequency__c , Opportunity__c, Origination_Fee_Amount__c,
                genesis__Expected_Start_Date__c, genesis__Loan_Amount__c, Random_Number__c
            FROM genesis__Applications__c
        ];

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Analytics_PK__c = '12872807';
        ocrolusReport.Max_Daily_Payment__c = 851.2645;

        CAN_GAV_Matrix_Detail__c gavMatrix = new CAN_GAV_Matrix_Detail__c();
        gavMatrix.Id = TestUtility.getFakeId(CAN_GAV_Matrix_Detail__c.getSObjectType());
        gavMatrix.Industry_Rating__c = 'A+ Medical';
        gavMatrix.SC4_Tier__c = 'TIER 1';
        gavMatrix.Term__c = 6;
        gavMatrix.GAV__c = 9.2;

        CAN_Pricing_Matrix_Detail__c pricingMatrixDetail = new CAN_Pricing_Matrix_Detail__c();
        pricingMatrixDetail.Id = TestUtility.getFakeId(CAN_Pricing_Matrix_Detail__c.getSObjectType());
        pricingMatrixDetail.Pricing_Type__c = CANPricingDetails.PRICING_TYPE_DIRECT_NEW;
        pricingMatrixDetail.Loan_Type__c = 'New';
        pricingMatrixDetail.Industry_Rating__c = 'A+ Medical';
        pricingMatrixDetail.SC4_Tier__c = 'TIER 1';
        pricingMatrixDetail.Term__c = 6;
        pricingMatrixDetail.Pricing_Rate__c = 1.4;

        CAN_Max_Amount_And_Max_Term_Mapping__c maxAmountMaxTerm = new CAN_Max_Amount_And_Max_Term_Mapping__c();
        maxAmountMaxTerm.Id = TestUtility.getFakeId(CAN_Max_Amount_And_Max_Term_Mapping__c.getSObjectType());
        maxAmountMaxTerm.Pricing_Type__c = CANPricingDetails.PRICING_TYPE_DIRECT_NEW;
        maxAmountMaxTerm.Loan_Type__c = 'New';
        maxAmountMaxTerm.Industry_Rating__c = 'A+ Medical';
        maxAmountMaxTerm.SC4_Tier__c = 'TIER 1';
        maxAmountMaxTerm.Maximum_Term__c = 6;
        maxAmountMaxTerm.Maximum_Amount_Single_Location__c = 1231433;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        CANPricingDetailManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        ocrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c> {ocrolusReport};
        CANPricingDetailManager.canOcrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        DBManagerTestsStub pricingMatrixDetailDBStubInstance = new DBManagerTestsStub();
        pricingMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_Pricing_Matrix_Detail__c> {pricingMatrixDetail};
        OriginationHelper.pricingMatrixDetailDBInstance = (PricingMatrixDetailDB) Test.createStub(PricingMatrixDetailDB.class, pricingMatrixDetailDBStubInstance);

        DBManagerTestsStub gavMatrixDetailDBStubInstance = new DBManagerTestsStub();
        gavMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_GAV_Matrix_Detail__c> {gavMatrix};
        OriginationHelper.gavMatrixDetailDBInstance = (GAVMatrixDetailDB) Test.createStub(GAVMatrixDetailDB.class, gavMatrixDetailDBStubInstance);

        DBManagerTestsStub maxAmountAndMaxTermMappingDBStubInstance = new DBManagerTestsStub();
        maxAmountAndMaxTermMappingDBStubInstance.genericReturnObject = new List<CAN_Max_Amount_And_Max_Term_Mapping__c> {maxAmountMaxTerm};
        OriginationHelper.maxAmountAndMaxTermMappingDBInstance = (MaxAmountAndMaxTermMappingDB) Test.createStub(MaxAmountAndMaxTermMappingDB.class, maxAmountAndMaxTermMappingDBStubInstance);

        LoanCalculatorManagerTestStub loanCalculatorManagerTestStubInstance = new LoanCalculatorManagerTestStub();
        Applications.loanCalculatorManagerInstance = (LoanCalculatorManager) Test.createStub(
            LoanCalculatorManager.class, loanCalculatorManagerTestStubInstance
        );

        CAN_Pricing_Detail__c pricingDetail =  new CAN_Pricing_Detail__c();
        pricingDetail.Application__c = application.Id;
        pricingDetail.Account__c = application.genesis__Account__c;
        pricingDetail.Opportunity__c = application.Opportunity__c;
        pricingDetail.Industry_Rating__c = application.Industry_Rating__c;
        pricingDetail.SC4_Tier__c = application.SC4_Tier__c;
        pricingDetail.Annual_Volume__c = application.Annual_Volume__c;
        pricingDetail.Loan_Type__c = application.Type__c;
        pricingDetail.Origination_Fee_Percentage__c = application.Origination_Fee_Percentage__c;
        pricingDetail.Origination_Fee_Amount__c = application.Origination_Fee_Amount__c;
        pricingDetail.Payment_Frequency__c = application.genesis__Payment_Frequency__c;
        pricingDetail.Status__c = 'Draft';
        pricingDetail.Offer_Type__c = CANPricingDetails.OFFER_TYPE_MANUAL_OFFER;
        pricingDetail.Term__c = 6;
        pricingDetail.Selected_Amount__c = 1000;
        pricingDetail.Maximum_Amount__c = 10000;
        pricingDetail.Standard_Commission__c = 100;
        pricingDetail.Max_Broker_Commission__c = 200;
        pricingDetail.Ocrolus_Max_Daily_Payment__c = 132462;
        pricingDetail.Maximum_Term__c = 8;
        pricingDetail.Maximum_Exception_Amount__c = 132462;
        pricingDetail.Pricing_Type__c = CANPricingDetails.PRICING_TYPE_DIRECT_NEW;
        pricingDetail.Pricing_Factor__c = 1.28;
        insert pricingDetail;

        Test.startTest();
            pricingDetail.Status__c = CANPricingDetails.STATUS_SENT_TO_CUSTOMER;
            pricingDetail.Maximum_Exception_Amount__c = 250001;
            update pricingDetail;
        Test.stopTest();

        genesis__Applications__c actualApplication = [SELECT Id, genesis__Status__c FROM genesis__Applications__c LIMIT 1];
        System.assertEquals(Applications.STATUS_UW_EXCEPTION_REVIEW, actualApplication.genesis__Status__c);
    }
}