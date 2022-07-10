@isTest
private class CreditReportDetailTriggerTests {

    @isTest
    private static void beforeInsertCreditReportDetailTrigger(){
        TestUtility.runSetupData();
        genesis__Applications__c application = TestUtility.createApplication();

        Credit_Report_Detail__c creReport = new Credit_Report_Detail__c();
        creReport.Competitor_Judgement__c = true;
        creReport.Application__c = application.Id;

        Exception ex;
        Test.startTest();
        try{
            insert creReport;
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();

        creReport.Competitor_Judgement__c = false;
        update creReport;

        list<Credit_Report_Detail__c> actualCreditReport = [
            SELECT Id, Competitor_Judgement__c
            FROM Credit_Report_Detail__c
        ];

        System.assert(creReport.Id != null);
        System.assertEquals(1, actualCreditReport.size());
        System.assertEquals(false, actualCreditReport[0].Competitor_Judgement__c);
    }
}