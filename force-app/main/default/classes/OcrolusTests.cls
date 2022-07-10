@isTest(isParallel=true)
private class OcrolusTests {

    @isTest
    private static void createCANOcrolusReportDetailTest() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        CAN_Ocrolus_Report__c ocrolusReport = New CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());

        Map<String,Object> ocrolusResponseMap = new Map<String,Object>();
        ocrolusResponseMap.put('pk', '12872807');
        ocrolusResponseMap.put('uuid', 'c0d78d78-7536-4f95-8241-e8cdc1cde360');
        ocrolusResponseMap.put('name', '00D17000000L7TQEA0-APP-0000000102');

        Test.startTest();
            Ocrolus.createCANOcrolusReportDetail(ocrolusResponseMap, application, ocrolusReport);
        Test.stopTest();

        System.assertEquals('00D17000000L7TQEA0-APP-0000000102', ocrolusReport.Book_Name__c);
        System.assertEquals('12872807', ocrolusReport.Analytics_PK__c);
    }

    @isTest
    private static void setOcrolusReportTest(){
        clcommon__Legal_Entity__c legalEntity = new clcommon__Legal_Entity__c();
        legalEntity.Id = TestUtility.getFakeId(clcommon__Legal_Entity__c.getSObjectType());
        legalEntity.Name = 'Sole Proprietorship';
        legalEntity.clcommon__Legal_Entity_Type__c = 'Corporation';

        Account account = new Account();
        account.id = TestUtility.getFakeId(Account.getSObjectType());
        account.clcommon__Legal_Entity_Type__c = legalEntity.Id;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = account.Id;

        Map<String,Object> ocrolusAnalyticsMap = new Map<String,Object>();
        Map<String, Object> ocrolusIndicatorsForBusinessType = new Map<String, Object> ();
        Map<String, Object> ocrolusIndicators = new Map<String, Object> ();
        ocrolusIndicatorsForBusinessType.put('OfferGAV', 808708.2436);
        ocrolusIndicatorsForBusinessType.put('MaxDailyPayment', 851.2645);
        ocrolusIndicatorsForBusinessType.put('Volatility', null);
        ocrolusIndicatorsForBusinessType.put('NumberOfDeposits', 10);
        ocrolusIndicatorsForBusinessType.put('NumberOfBankStatements', 11);
        ocrolusIndicatorsForBusinessType.put('PrimaryBankAccountNumber', null);
        ocrolusIndicatorsForBusinessType.put('PrimaryBankAccountName', '128642520 CENTRIS FEDERAL CREDIT UNION CHECKING');

        ocrolusIndicators.put('non_sole', ocrolusIndicatorsForBusinessType);
        ocrolusIndicators.put('sole', ocrolusIndicatorsForBusinessType);
        ocrolusIndicators.put('NumberOfCompetitors', 1);
        ocrolusIndicators.put('DebtConsolidator', false);
        ocrolusIndicators.put('SuspiciousActivity', false);
        ocrolusIndicators.put('PotentialFraud', false);
        ocrolusIndicators.put('EndingBalanceMismatch', false);
        ocrolusIndicators.put('BeginEndingBalanceMismatch', true);

        List<String> competitorList = new List<String>();
        competitorList.add('Vader Servicing');

        ocrolusAnalyticsMap.put('pk', 12872807);
        ocrolusAnalyticsMap.put('Indicators', ocrolusIndicators);
        ocrolusAnalyticsMap.put('competitors', competitorList);

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Max_Weekly_Payment__c = 851.2645;

        Test.startTest();
                Ocrolus.setOcrolusReport(ocrolusAnalyticsMap, application, ocrolusReport);
        Test.stopTest();

        System.assertEquals(4256.3225, ocrolusReport.Max_Weekly_Payment__c);
    }

    @isTest
    private static void setOcrolusReportForRenewalTest() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;

        Map<String,Object> ocrolusAnalyticsMap = new Map<String,Object>();
        Map<String, Object> ocrolusIndicatorsForBusinessType = new Map<String, Object> ();
        Map<String, Object> ocrolusIndicators = new Map<String, Object> ();
        ocrolusIndicatorsForBusinessType.put('OfferGAV', 808708.2436);
        ocrolusIndicatorsForBusinessType.put('MaxDailyPayment', 851.2645);
        ocrolusIndicatorsForBusinessType.put('Volatility', null);
        ocrolusIndicatorsForBusinessType.put('NumberOfDeposits', 10);
        ocrolusIndicatorsForBusinessType.put('NumberOfBankStatements', 11);
        ocrolusIndicatorsForBusinessType.put('PrimaryBankAccountNumber', null);
        ocrolusIndicatorsForBusinessType.put('PrimaryBankAccountName', '128642520 CENTRIS FEDERAL CREDIT UNION CHECKING');

        ocrolusIndicators.put('non_sole', ocrolusIndicatorsForBusinessType);
        ocrolusIndicators.put('sole', ocrolusIndicatorsForBusinessType);
        ocrolusIndicators.put('NumberOfCompetitors', 1);
        ocrolusIndicators.put('DebtConsolidator', false);
        ocrolusIndicators.put('SuspiciousActivity', false);
        ocrolusIndicators.put('PotentialFraud', false);
        ocrolusIndicators.put('EndingBalanceMismatch', false);
        ocrolusIndicators.put('BeginEndingBalanceMismatch', true);

        List<String> competitorList = new List<String>();
        competitorList.add('Vader Servicing');

        ocrolusAnalyticsMap.put('pk', 12872807);
        ocrolusAnalyticsMap.put('Indicators', ocrolusIndicators);
        ocrolusAnalyticsMap.put('competitors', competitorList);

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Max_Weekly_Payment__c = 851.2645;

        Test.startTest();
                Ocrolus.setOcrolusReport(ocrolusAnalyticsMap, application, ocrolusReport);
        Test.stopTest();

        System.assertEquals(499995, ocrolusReport.Max_Weekly_Payment__c);
    }

    @isTest
    static void isCANVerificationCompletedTest(){
        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Offer_GAV_Amount__c = 808708.2436;
        ocrolusReport.Max_Daily_Payment__c = 851.2645;
        ocrolusReport.Number_Of_Bank_Statements__c = 3;
        ocrolusReport.Number_Of_Deposits__c = 4;

        CAN_Ocrolus_Report__c oldOcrolusReport = new CAN_Ocrolus_Report__c();
        oldOcrolusReport.Id = ocrolusReport.Id;
        oldOcrolusReport.Offer_GAV_Amount__c = 808709.2436;
        oldOcrolusReport.Max_Daily_Payment__c = 852.2645;
        oldOcrolusReport.Number_Of_Bank_Statements__c = 4;
        oldOcrolusReport.Number_Of_Deposits__c = 5;

        Test.startTest();
            Boolean isVerificationComplete = Ocrolus.isCANVerificationCompleted(ocrolusReport, oldOcrolusReport);
        Test.stopTest();

        System.assertEquals(true, isVerificationComplete);
    }

    @isTest
    static void isCANVerificationCompletedMaxDaily(){
        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Offer_GAV_Amount__c = 808709.2436;
        ocrolusReport.Max_Daily_Payment__c = 851.2645;
        ocrolusReport.Number_Of_Bank_Statements__c = 3;
        ocrolusReport.Number_Of_Deposits__c = 4;

        CAN_Ocrolus_Report__c oldOcrolusReport = new CAN_Ocrolus_Report__c();
        oldOcrolusReport.Id = ocrolusReport.Id;
        oldOcrolusReport.Offer_GAV_Amount__c = 808709.2436;
        oldOcrolusReport.Max_Daily_Payment__c = 852.2645;
        oldOcrolusReport.Number_Of_Bank_Statements__c = 4;
        oldOcrolusReport.Number_Of_Deposits__c = 5;

        Test.startTest();
            Boolean isVerificationComplete = Ocrolus.isCANVerificationCompleted(ocrolusReport, oldOcrolusReport);
        Test.stopTest();

        System.assertEquals(true, isVerificationComplete);
    }

    @isTest
    static void isCANVerificationCompletedBankStatement(){
        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Offer_GAV_Amount__c = 808709.2436;
        ocrolusReport.Max_Daily_Payment__c = 852.2645;
        ocrolusReport.Number_Of_Bank_Statements__c = 3;
        ocrolusReport.Number_Of_Deposits__c = 4;

        CAN_Ocrolus_Report__c oldOcrolusReport = new CAN_Ocrolus_Report__c();
        oldOcrolusReport.Id = ocrolusReport.Id;
        oldOcrolusReport.Offer_GAV_Amount__c = 808709.2436;
        oldOcrolusReport.Max_Daily_Payment__c = 852.2645;
        oldOcrolusReport.Number_Of_Bank_Statements__c = 4;
        oldOcrolusReport.Number_Of_Deposits__c = 5;

        Test.startTest();
            Boolean isVerificationComplete = Ocrolus.isCANVerificationCompleted(ocrolusReport, oldOcrolusReport);
        Test.stopTest();

        System.assertEquals(true, isVerificationComplete);
    }

    @isTest
    static void isCANVerificationCompletedDeposits(){
        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Offer_GAV_Amount__c = 808709.2436;
        ocrolusReport.Max_Daily_Payment__c = 852.2645;
        ocrolusReport.Number_Of_Bank_Statements__c = 4;
        ocrolusReport.Number_Of_Deposits__c = 4;

        CAN_Ocrolus_Report__c oldOcrolusReport = new CAN_Ocrolus_Report__c();
        oldOcrolusReport.Id = ocrolusReport.Id;
        oldOcrolusReport.Offer_GAV_Amount__c = 808709.2436;
        oldOcrolusReport.Max_Daily_Payment__c = 852.2645;
        oldOcrolusReport.Number_Of_Bank_Statements__c = 4;
        oldOcrolusReport.Number_Of_Deposits__c = 5;

        Test.startTest();
            Boolean isVerificationComplete = Ocrolus.isCANVerificationCompleted(ocrolusReport, oldOcrolusReport);
        Test.stopTest();

        System.assertEquals(true, isVerificationComplete);
    }

    @isTest
    private static void setOcrolusReportCompetitorsTest() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;

        Map<String,Object> ocrolusAnalyticsMap = new Map<String,Object>();
        Map<String, Object> ocrolusIndicatorsForBusinessType = new Map<String, Object> ();
        Map<String, Object> ocrolusIndicators = new Map<String, Object> ();

        Map<String, Object> NumberOfCompetitorsDetails = new Map<String, Object> ();
        List<Object> NumberOfCompetitorsDetailsList = new List<Object> ();
        Map<String, Object> competitorDetail1 = new Map<String, Object> ();
        Map<String, Object> competitorDetail2 = new Map<String, Object> ();
        List<String> frequencyList1 = new List<String>();
        List<String> frequencyList2 = new List<String>();
        List<String> payOffCompetitorsList = new List<String>();

        ocrolusIndicatorsForBusinessType.put('OfferGAV', 808708.2436);
        ocrolusIndicatorsForBusinessType.put('MaxDailyPayment', 851.2645);
        ocrolusIndicatorsForBusinessType.put('Volatility', null);
        ocrolusIndicatorsForBusinessType.put('NumberOfDeposits', 10);
        ocrolusIndicatorsForBusinessType.put('NumberOfBankStatements', 11);
        ocrolusIndicatorsForBusinessType.put('PrimaryBankAccountNumber', null);
        ocrolusIndicatorsForBusinessType.put('PrimaryBankAccountName', '128642520 CENTRIS FEDERAL CREDIT UNION CHECKING');

        frequencyList1.add('Random');
        frequencyList2.add('Weekly');
        competitorDetail1.put('lender_name', 'Kalamata Capital');
        competitorDetail2.put('lender_name', 'BlueVine Capital');

        competitorDetail1.put('frequency', frequencyList1);
        competitorDetail2.put('frequency', frequencyList2);

        NumberOfCompetitorsDetailsList.add(competitorDetail1);
        NumberOfCompetitorsDetailsList.add(competitorDetail2);

        NumberOfCompetitorsDetails.put('NumberOfCompetitorsDetails', NumberOfCompetitorsDetailsList);

        ocrolusIndicators.put('non_sole', ocrolusIndicatorsForBusinessType);
        ocrolusIndicators.put('sole', ocrolusIndicatorsForBusinessType);
        ocrolusIndicators.put('NumberOfCompetitors', 2);
        ocrolusIndicators.put('NumberOfCompetitorsDetails', NumberOfCompetitorsDetailsList);
        ocrolusIndicators.put('DebtConsolidator', false);
        ocrolusIndicators.put('SuspiciousActivity', false);
        ocrolusIndicators.put('PotentialFraud', false);
        ocrolusIndicators.put('EndingBalanceMismatch', false);
        ocrolusIndicators.put('BeginEndingBalanceMismatch', true);

        List<String> competitorList = new List<String>();
        competitorList.add('BlueVine Capital');

        ocrolusAnalyticsMap.put('pk', 12872807);
        ocrolusAnalyticsMap.put('Indicators', ocrolusIndicators);
        ocrolusAnalyticsMap.put('competitors', competitorList);

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());

        Test.startTest();
                Ocrolus.setOcrolusReport(ocrolusAnalyticsMap, application, ocrolusReport);
        Test.stopTest();

        System.assertEquals('Kalamata Capital (Random), BlueVine Capital', ocrolusReport.All_Competitors__c);
    }

}