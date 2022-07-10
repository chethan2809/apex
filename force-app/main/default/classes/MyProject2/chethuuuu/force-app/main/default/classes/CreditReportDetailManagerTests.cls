@isTest
private class CreditReportDetailManagerTests {

    @isTest
    private static void setSICCodeAndTimeInBusiness() {

        TestUtility.runSetupData();
        Account account = TestUtility.createAccount();
        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        genesis__Applications__c application = TestUtility.createApplication();
        application.genesis__Account__c = account.Id;
        application.Business_Start_Date__c = GeneralHelper.currentSystemDate.addYears(-4);
        applicationList.add(application);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        CreditReportDetailManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Date businessStartDate = GeneralHelper.currentSystemDate.addDays(10);

        List<Credit_Report_Detail__c> creditReportDetailList = new List<Credit_Report_Detail__c>();
        Credit_Report_Detail__c creditReportDetail = new Credit_Report_Detail__c();
        creditReportDetail.Account__c = account.Id;
        creditReportDetail.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        creditReportDetail.Type__c = 'Experian Consumer';
        creditReportDetail.Industry_Type__c = 'Incorporated';
        creditReportDetail.SIC_Code__c = '5999';
        creditReportDetail.Business_Start_Date__c = businessStartDate;
        creditReportDetail.Business_First_Seen_YYYY__c = '2018';
        creditReportDetail.Application__c = application.Id;
        creditReportDetailList.add(creditReportDetail);

        Map<Id, List<Credit_Report_Detail__c>> creditReportsByAccountId = new Map<Id, List<Credit_Report_Detail__c>>();
        creditReportsByAccountId.put(creditReportDetail.Account__c, creditReportDetailList);

        DBManagerTestsStub creditReportDetailDBStubInstance = new DBManagerTestsStub();
        creditReportDetailDBStubInstance.genericReturnObject = new List<Credit_Report_Detail__c>{creditReportDetail};
        CreditReportDetailManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBStubInstance);

        Test.startTest();
            CreditReportDetailManager.setSICCodeAndTimeInBusiness(applicationList);
        Test.stopTest();

        System.assert(creditReportDetailDBStubInstance.forUpdateSObjects.isEmpty());
    }
}