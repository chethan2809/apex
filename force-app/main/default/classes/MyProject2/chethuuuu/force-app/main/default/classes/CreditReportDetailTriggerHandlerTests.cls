@isTest
private class CreditReportDetailTriggerHandlerTests {

    @isTest
    private static void beforeInsert() {
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Date businessStartDate = GeneralHelper.currentSystemDate.addDays(10);

        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        List<Credit_Report_Detail__c> creditReportDetailList = new List<Credit_Report_Detail__c>();
        Credit_Report_Detail__c creditReportDetail = new Credit_Report_Detail__c();
        creditReportDetail.Account__c = accountId;
        creditReportDetail.Type__c = 'Experian Consumer';
        creditReportDetail.Industry_Type__c = 'Incorporated';
        creditReportDetail.SIC_Code__c = '5999';
        creditReportDetail.Business_Start_Date__c = businessStartDate;
        creditReportDetail.Business_First_Seen_YYYY__c = '2018';
        creditReportDetail.Application__c = applicationId;
        creditReportDetailList.add(creditReportDetail);

        Test.startTest();
            CreditReportDetailTriggerHandler creditReportDetailTrigger = new CreditReportDetailTriggerHandler();
            creditReportDetailTrigger.beforeInsert(creditReportDetailList);
        Test.stopTest();

        system.assert(creditReportDetail.RecordTypeId != null);
    }
}