@isTest
private class CANOcrolusReportsTests {

    @isTest
    private static void calculateGAV() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Annual_Volume__c = 234567;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Number_Of_Bank_Statements__c = 15;
        ocrolusReport.Offer_GAV_Amount__c = 0;

        Test.startTest();
            Decimal actualGAV = CANOcrolusReports.calculateGAV(application, ocrolusReport);
        Test.stopTest();

        System.assertEquals(CANOcrolusReports.DEFAULT_VALUE, actualGAV);
    }

    @isTest
    private static void calculateGAV2() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Annual_Volume__c = 200;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Number_Of_Bank_Statements__c = 15;
        ocrolusReport.Offer_GAV_Amount__c = 2000;

        Test.startTest();
            Decimal actualGAV = CANOcrolusReports.calculateGAV(application, ocrolusReport);
        Test.stopTest();

        System.assertEquals(ocrolusReport.Offer_GAV_Amount__c, actualGAV);
    }

    @isTest
    private static void calculateGAV3() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Annual_Volume__c = 200;

        Decimal systemGAV = application.Annual_Volume__c;
        Decimal expectedSystemGAVMax = systemGAV * 1.10;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Number_Of_Bank_Statements__c = 10;
        ocrolusReport.Offer_GAV_Amount__c = 2000;

        Test.startTest();
            Decimal actualGAV = CANOcrolusReports.calculateGAV(application, ocrolusReport);
        Test.stopTest();

        System.assertEquals(expectedSystemGAVMax, actualGAV);
    }

    @isTest
    private static void calculateGAV4() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Annual_Volume__c = 2000;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Number_Of_Bank_Statements__c = 10;
        ocrolusReport.Offer_GAV_Amount__c = 1700;

        Test.startTest();
            Decimal actualGAV = CANOcrolusReports.calculateGAV(application, ocrolusReport);
        Test.stopTest();

        System.assertEquals(application.Annual_Volume__c, actualGAV);
    }

    @isTest
    private static void calculateGAV5() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Annual_Volume__c = 200;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Number_Of_Bank_Statements__c = 10;
        ocrolusReport.Offer_GAV_Amount__c = 20;

        Test.startTest();
            Decimal actualGAV = CANOcrolusReports.calculateGAV(application, ocrolusReport);
        Test.stopTest();

        System.assertEquals(ocrolusReport.Offer_GAV_Amount__c, actualGAV);
    }

    @isTest
    private static void calculateGAV6() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Annual_Volume__c = 200;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Number_Of_Bank_Statements__c = 10;
        ocrolusReport.Offer_GAV_Amount__c = 20;

        Test.startTest();
            Decimal actualGAV = CANOcrolusReports.calculateGAV(application, ocrolusReport);
        Test.stopTest();

        System.assertEquals(ocrolusReport.Offer_GAV_Amount__c, actualGAV);
    }

    @isTest
    private static void calculateGAV7() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Annual_Volume__c = 1999;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Number_Of_Bank_Statements__c = 10;
        ocrolusReport.Offer_GAV_Amount__c = 2000;

        Test.startTest();
            Decimal actualGAV = CANOcrolusReports.calculateGAV(application, ocrolusReport);
        Test.stopTest();

        System.assertEquals(ocrolusReport.Offer_GAV_Amount__c, actualGAV);
    }

    @isTest
    private static void getOcrolusReportByApplicationId() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Annual_Volume__c = 234567;

        List<CAN_Ocrolus_Report__c> ocrolusReportList = new List<CAN_Ocrolus_Report__c>();
        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Number_Of_Bank_Statements__c = 15;
        ocrolusReport.Offer_GAV_Amount__c = 0;
        ocrolusReport.Application__c = application.Id;
        ocrolusReportList.add(ocrolusReport);

        Test.startTest();
            Map<Id, CAN_Ocrolus_Report__c> ocrolusReportByApplicationId = CANOcrolusReports.getOcrolusReportByApplicationId(ocrolusReportList);
        Test.stopTest();

        System.assertEquals(ocrolusReport, ocrolusReportByApplicationId.get(ocrolusReport.Application__c));
    }

    @isTest
    private static void createRenewalApplicationOcrolusReport() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Number_Of_Bank_Statements__c = 15;
        ocrolusReport.Offer_GAV_Amount__c = 0;

        Test.startTest();
            CAN_Ocrolus_Report__c canOcrolus = CANOcrolusReports.createRenewalApplicationOcrolusReport(ocrolusReport, applicationId);
        Test.stopTest();

        System.assert(canOcrolus != null);
    }

    @isTest
    private static void createEISRenewalApplicationOcrolusReport() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        EIS_Default_Ocrolus_Report__mdt ocrolusDefaultReport = new EIS_Default_Ocrolus_Report__mdt();

        ocrolusDefaultReport.Offer_GAV__c = 99999.00;
        ocrolusDefaultReport.Max_Daily_Payment__c = 99999.00;
        ocrolusDefaultReport.Max_Weekly_Payment__c = 499995.00;
        ocrolusDefaultReport.Volatility_w_out_ADB_support__c = 0;
        ocrolusDefaultReport.Number_Of_Deposits__c = 3;
        ocrolusDefaultReport.Number_Of_Bank_Statements__c = 3;
        ocrolusDefaultReport.Primary_Bank_Account_Number__c = null;
        ocrolusDefaultReport.Primary_Bank_Account_Name__c = null;

        ocrolusDefaultReport.Number_Of_Competitors__c = 0;
        ocrolusDefaultReport.Is_Debt_Consolidator__c = false;
        ocrolusDefaultReport.Has_Suspicious_Activity__c = false;
        ocrolusDefaultReport.Is_Potential_Fraud__c = false;
        ocrolusDefaultReport.Has_Ending_Balance_Mismatch__c = false;
        ocrolusDefaultReport.Has_Begin_Ending_Balance_Mismatch__c = false;

        CustomMetaDataHelper.defaultEISOcrolusReport = ocrolusDefaultReport;

        Test.startTest();
            CAN_Ocrolus_Report__c renewalOcrolusReport = CANOcrolusReports.createEISRenewalApplicationOcrolusReport(applicationId, 99999.00);
        Test.stopTest();

        System.assertEquals(99999.00, renewalOcrolusReport.Offer_GAV_Amount__c);
        System.assertEquals(Ocrolus.OCROLUS_DOC_STATUS_COMPLETE, renewalOcrolusReport.Document_Status__c);
    }
}