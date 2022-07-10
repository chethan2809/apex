@isTest(isParallel=true)
private class ApplicationDailyUpdateManagerTests {

    @isTest
    private static void updateApplicationAndPricing(){
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);
        Date expectedStartDate = GeneralHelper.currentSystemDate;
        Date expectedCloseDate = GeneralHelper.currentSystemDate.addDays(100);
        Date expectedFirstPaymentDate = GeneralHelper.currentSystemDate.addDays(10);

        Origination_Settings__mdt originationSetting = new Origination_Settings__mdt();
        originationSetting.Pricing_Expire_Days__c = 3;
        CustomMetaDataHelper.defaultOriginationSetting = originationSetting;

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Status__c = 'NEW ENTERED';
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Expected_Start_Date__c = GeneralHelper.currentSystemDate;
        application.genesis__Expected_Close_Date__c = GeneralHelper.currentSystemDate.addDays(-3);
        applicationList.add(application);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationDailyUpdateManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        LoanCalculatorManagerTestStub loanCalculatorManagerTestStubInstance = new LoanCalculatorManagerTestStub();
        Applications.loanCalculatorManagerInstance = (LoanCalculatorManager) Test.createStub(
            LoanCalculatorManager.class, loanCalculatorManagerTestStubInstance
        );

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Application__c = application.Id;
        pricingDetail.Id = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());
        pricingDetail.Status__c = 'Sent To Customer';
        pricingDetail.Selected_Amount__c = 7000;
        pricingDetail.Pricing_Factor__c = 7.5;
        pricingDetail.Repayment_Amount__c = 2500;
        pricingDetail.Term__c = 16;
        pricingDetail.Daily_Payment_Amount__c = 150;
        pricingDetail.Weekly_Payment_Amount__c = 350;
        pricingDetail.Start_Date__c = GeneralHelper.currentSystemDate;
        pricingDetail.Number_Of_Daily_Payments__c = 5;
        pricingDetail.Number_Of_Daily_Payments__c = 2;
        pricingDetail.Maximum_Amount__c = 7000;
        pricingDetail.Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;

        DBManagerTestsStub canPricingDetailDBInstance = new DBManagerTestsStub();
        canPricingDetailDBInstance.genericReturnObject = new List<CAN_Pricing_Detail__c>{pricingDetail};
        ApplicationDailyUpdateManager.canPricingDetailDBInstance = (CANPricingDetailDB) Test.createStub(CANPricingDetailDB.class, canPricingDetailDBInstance);

        DBManagerTestsStub applicationDBInstance = new DBManagerTestsStub();
        applicationDBInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationDailyUpdateManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        ApplicationDailyUpdateManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Exception ex;
        Test.startTest();
            try{
                ApplicationDailyUpdateManager.updateApplicationAndPricingByApplicationId(application.Id);
            }
            catch(Exception e){
                ex = e;
            }
        Test.stopTest();

        System.assertEquals(1, applicationDBInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void updateApplicationAndPricingForPartialUpdates(){
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);
        Date expectedStartDate = GeneralHelper.currentSystemDate;
        Date expectedCloseDate = GeneralHelper.currentSystemDate.addDays(100);
        Date expectedFirstPaymentDate = GeneralHelper.currentSystemDate.addDays(10);

        Origination_Settings__mdt originationSetting = new Origination_Settings__mdt();
        originationSetting.Pricing_Expire_Days__c = 3;
        CustomMetaDataHelper.defaultOriginationSetting = originationSetting;

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Status__c = 'CLOSED - DECLINED';
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        applicationList.add(application);

        LoanCalculatorManagerTestStub loanCalculatorManagerTestStubInstance = new LoanCalculatorManagerTestStub();
        Applications.loanCalculatorManagerInstance = (LoanCalculatorManager) Test.createStub(
            LoanCalculatorManager.class, loanCalculatorManagerTestStubInstance
        );

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        ApplicationDailyUpdateManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Exception ex;
        Test.startTest();
            try{
                ApplicationDailyUpdateManager.updateApplicationAndPricing(applicationList);
            }
            catch(Exception e){
                ex = e;
            }
        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void pricingUpdateFailed() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);
        Date expectedStartDate = GeneralHelper.currentSystemDate;
        Date expectedCloseDate = GeneralHelper.currentSystemDate.addDays(100);
        Date expectedFirstPaymentDate = GeneralHelper.currentSystemDate.addDays(10);

        Origination_Settings__mdt originationSetting = new Origination_Settings__mdt();
        originationSetting.Pricing_Expire_Days__c = 3;
        CustomMetaDataHelper.defaultOriginationSetting = originationSetting;

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Status__c = 'CLOSED - DECLINED';
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        applicationList.add(application);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationDailyUpdateManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        LoanCalculatorManagerTestStub loanCalculatorManagerTestStubInstance = new LoanCalculatorManagerTestStub();
        Applications.loanCalculatorManagerInstance = (LoanCalculatorManager) Test.createStub(
            LoanCalculatorManager.class, loanCalculatorManagerTestStubInstance
        );

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Application__c = application.Id;
        pricingDetail.Id = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());
        pricingDetail.Status__c = 'Accepted';
        pricingDetail.Selected_Amount__c = 7000;
        pricingDetail.Pricing_Factor__c = 7.5;
        pricingDetail.Repayment_Amount__c = 2500;
        pricingDetail.Term__c = 16;
        pricingDetail.Daily_Payment_Amount__c = 150;
        pricingDetail.Weekly_Payment_Amount__c = 350;
        pricingDetail.Start_Date__c = GeneralHelper.currentSystemDate;
        pricingDetail.Number_Of_Daily_Payments__c = 5;
        pricingDetail.Number_Of_Daily_Payments__c = 2;
        pricingDetail.Maximum_Amount__c = 7000;
        pricingDetail.Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;

        DBManagerTestsStub canPricingDetailDBInstance = new DBManagerTestsStub();
        canPricingDetailDBInstance.genericReturnObject = new List<CAN_Pricing_Detail__c>{pricingDetail};
        ApplicationDailyUpdateManager.canPricingDetailDBInstance = (CANPricingDetailDB) Test.createStub(CANPricingDetailDB.class, canPricingDetailDBInstance);

        DBManagerTestsStub applicationDBInstance = new DBManagerTestsStub();
        applicationDBInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationDailyUpdateManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        ApplicationDailyUpdateManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Exception ex;
        Test.startTest();
            try{
                ApplicationDailyUpdateManager.updateApplicationAndPricingByApplicationId(application.Id);
            }
            catch(Exception e){
                ex = e;
            }
        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void updateApplicationAndPricingForExpiredDeclineRule() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);
        Date expectedStartDate = GeneralHelper.currentSystemDate;
        Date expectedCloseDate = GeneralHelper.currentSystemDate.addDays(100);
        Date expectedFirstPaymentDate = GeneralHelper.currentSystemDate.addDays(10);

        Origination_Settings__mdt originationSetting = new Origination_Settings__mdt();
        originationSetting.Pricing_Expire_Days__c = 3;
        CustomMetaDataHelper.defaultOriginationSetting = originationSetting;

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Status__c = Applications.STATUS_OFFER_SENT;
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Expected_Start_Date__c = GeneralHelper.currentSystemDate;
        application.genesis__Expected_Close_Date__c = GeneralHelper.currentSystemDate.addDays(-3);
        application.Last_Status_Update_Date__c = GeneralHelper.currentSystemDate.addDays(-5);
        applicationList.add(application);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationDailyUpdateManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        LoanCalculatorManagerTestStub loanCalculatorManagerTestStubInstance = new LoanCalculatorManagerTestStub();
        Applications.loanCalculatorManagerInstance = (LoanCalculatorManager) Test.createStub(
            LoanCalculatorManager.class, loanCalculatorManagerTestStubInstance
        );

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Application__c = application.Id;
        pricingDetail.Id = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());
        pricingDetail.Status__c = 'Sent To Customer';
        pricingDetail.Selected_Amount__c = 7000;
        pricingDetail.Pricing_Factor__c = 7.5;
        pricingDetail.Repayment_Amount__c = 2500;
        pricingDetail.Term__c = 16;
        pricingDetail.Daily_Payment_Amount__c = 150;
        pricingDetail.Weekly_Payment_Amount__c = 350;
        pricingDetail.Start_Date__c = GeneralHelper.currentSystemDate;
        pricingDetail.Number_Of_Daily_Payments__c = 5;
        pricingDetail.Number_Of_Daily_Payments__c = 2;
        pricingDetail.Maximum_Amount__c = 7000;

        DBManagerTestsStub canPricingDetailDBInstance = new DBManagerTestsStub();
        canPricingDetailDBInstance.genericReturnObject = new List<CAN_Pricing_Detail__c>{pricingDetail};
        ApplicationDailyUpdateManager.canPricingDetailDBInstance = (CANPricingDetailDB) Test.createStub(CANPricingDetailDB.class, canPricingDetailDBInstance);

        DBManagerTestsStub applicationDBInstance = new DBManagerTestsStub();
        applicationDBInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationDailyUpdateManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        ApplicationDailyUpdateManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Exception ex;
        Test.startTest();
            try{
                ApplicationDailyUpdateManager.updateApplicationAndPricingByApplicationId(application.Id);
            }
            catch(Exception e){
                ex = e;
            }
        Test.stopTest();

        System.assertEquals(1, applicationDBInstance.forUpdateSObjects.size());
    }
}