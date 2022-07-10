@isTest(isParallel=true)
private class CreditReportDetailsTests {

    @isTest
    static void calculateSICCodeAndTimeInBusinessForNew() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        Credit_Report_Detail__c businessReport = new Credit_Report_Detail__c();
        businessReport.SIC_Code__c = '1234';
        businessReport.Type__c = CreditReportDetails.TYPE_EXPERIAN_BUSINESS;
        businessReport.Business_Start_Date__c = GeneralHelper.currentSystemDate.addYears(-1);

        Credit_Report_Detail__c lexisNexisReport = new Credit_Report_Detail__c();
        lexisNexisReport.SIC_Code__c = '1234';
        lexisNexisReport.Type__c = CreditReportDetails.TYPE_LEXISNEXIS;
        lexisNexisReport.Business_First_Seen_YYYY__c = '2019';
        List<Credit_Report_Detail__c> creditReportList = new List<Credit_Report_Detail__c>();
        creditReportList.add(businessReport);
        creditReportList.add(lexisNexisReport);

        genesis__Applications__c application = new genesis__Applications__c();
        application.Business_Start_Date__c = GeneralHelper.currentSystemDate.addYears(-4);
        application.SIC_Code__c = '1234';
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;

        Test.startTest();
            CreditReportDetails.calculateSICCodeAndTimeInBusiness(creditReportList, application);
        Test.stopTest();

        System.assertEquals(businessReport.Business_Start_Date__c, application.Business_Start_Date__c);
    }

    @isTest
    static void calculateSICCodeAndTimeInBusinessForRenewal(){
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        Credit_Report_Detail__c businessReport = new Credit_Report_Detail__c();
        businessReport.SIC_Code__c = '1234';
        businessReport.Type__c = CreditReportDetails.TYPE_EXPERIAN_BUSINESS;
        businessReport.Business_Start_Date__c = GeneralHelper.currentSystemDate.addYears(-1);

        Credit_Report_Detail__c lexisNexisReport = new Credit_Report_Detail__c();
        lexisNexisReport.SIC_Code__c = '45678';
        lexisNexisReport.Type__c = CreditReportDetails.TYPE_LEXISNEXIS;
        lexisNexisReport.Business_First_Seen_YYYY__c = '2019';
        List<Credit_Report_Detail__c> creditReportList = new List<Credit_Report_Detail__c>();
        creditReportList.add(businessReport);
        creditReportList.add(lexisNexisReport);

        genesis__Applications__c application = new genesis__Applications__c();
        application.Business_Start_Date__c = GeneralHelper.currentSystemDate.addYears(-4);
        application.SIC_Code__c = '34567';
        application.Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;

        Test.startTest();
            CreditReportDetails.calculateSICCodeAndTimeInBusiness(creditReportList, application);
        Test.stopTest();

        System.assertnotEquals(businessReport.SIC_Code__c, application.SIC_Code__c);
    }


    @isTest
    static void getSICCode() {
        String experianSICCode = '1234';
        String lexisNexisSICCod = '1234';
        String applicationSICCode = '9876';

        Test.startTest();
            String actualSICCode = CreditReportDetails.getSICCode(experianSICCode, lexisNexisSICCod, applicationSICCode);
        Test.stopTest();

        System.assertEquals(experianSICCode, actualSICCode);
    }

    @isTest
    static void getSICCodeDefaultCode() {
        String experianSICCode = '1111';
        String lexisNexisSICCod = '5555';
        String applicationSICCode = '6666';

        Test.startTest();
            String actualSICCode = CreditReportDetails.getSICCode(experianSICCode, lexisNexisSICCod, applicationSICCode);
        Test.stopTest();

        System.assertEquals(GeneralConstants.DEFAULT_SIC_CODE, actualSICCode);
    }

    @isTest
    static void getSICCodeWhenLexisNexisSICNullAndOthersNotMatched() {
        String experianSICCode = '1111';
        String lexisNexisSICCod = null;
        String applicationSICCode = '6666';

        Test.startTest();
            String actualSICCode = CreditReportDetails.getSICCode(experianSICCode, lexisNexisSICCod, applicationSICCode);
        Test.stopTest();

        System.assertEquals(GeneralConstants.DEFAULT_SIC_CODE, actualSICCode);
    }

    @isTest
    static void getSICCodeWhenLexisNexisSICNullAndOthersMatched() {
        String experianSICCode = '1111';
        String lexisNexisSICCod = null;
        String applicationSICCode = '2222';

        Test.startTest();
            String actualSICCode = CreditReportDetails.getSICCode(experianSICCode, lexisNexisSICCod, applicationSICCode);
        Test.stopTest();

        System.assertEquals(GeneralConstants.DEFAULT_SIC_CODE, actualSICCode);
    }

    @isTest
    static void getSICCodeWhenExperianSICNull() {
        String experianSICCode = null;
        String lexisNexisSICCod = '1111';
        String applicationSICCode = '2222';

        Test.startTest();
            String actualSICCode = CreditReportDetails.getSICCode(experianSICCode, lexisNexisSICCod, applicationSICCode);
        Test.stopTest();

        System.assertEquals(GeneralConstants.DEFAULT_SIC_CODE, actualSICCode);
    }

    @isTest
    static void getSICCodeWhenAllTwoDigitSICMatched() {
        String experianSICCode = '7322';
        String lexisNexisSICCod = '7311';
        String applicationSICCode = '7354';

        Test.startTest();
            String actualSICCode = CreditReportDetails.getSICCode(experianSICCode, lexisNexisSICCod, applicationSICCode);
        Test.stopTest();

        System.assertEquals(GeneralConstants.DEFAULT_SIC_CODE, actualSICCode);
    }

    @isTest
    static void getSICCodeWhenAllTwoDigitSICNotMatched() {
        String experianSICCode = '7322';
        String lexisNexisSICCod = '7311';
        String applicationSICCode = '5454';

        Test.startTest();
            String actualSICCode = CreditReportDetails.getSICCode(experianSICCode, lexisNexisSICCod, applicationSICCode);
        Test.stopTest();

        System.assertEquals(experianSICCode, actualSICCode);
    }

    @isTest
    static void getSICCodeWhenExperianIsNullAndThreeDigitSICNotMatched() {
        String experianSICCode = null;
        String lexisNexisSICCod = '7311';
        String applicationSICCode = '7354';

        Test.startTest();
            String actualSICCode = CreditReportDetails.getSICCode(experianSICCode, lexisNexisSICCod, applicationSICCode);
        Test.stopTest();

        System.assertEquals(GeneralConstants.DEFAULT_SIC_CODE, actualSICCode);
    }

    @isTest
    static void getSICCodeWhenLexisIsNullAndThreeDigitSICNotMatched() {
        String experianSICCode = '7311';
        String lexisNexisSICCod = null;
        String applicationSICCode = '7354';

        Test.startTest();
            String actualSICCode = CreditReportDetails.getSICCode(experianSICCode, lexisNexisSICCod, applicationSICCode);

        System.assertEquals(GeneralConstants.DEFAULT_SIC_CODE, actualSICCode);
    }
}