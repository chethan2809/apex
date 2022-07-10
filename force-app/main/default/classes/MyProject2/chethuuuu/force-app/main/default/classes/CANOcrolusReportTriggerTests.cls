@isTest
private class CANOcrolusReportTriggerTests {

   @isTest
    private static void updateCANOcrolusReport(){
        TestUtility.runSetupData();
        genesis__Applications__c application = TestUtility.createApplication();

        CAN_Ocrolus_Report__c canReport = new CAN_Ocrolus_Report__c();
        canReport.Application__c = application.Id;
        canReport.Book_Name__c = 'HMTC';

        Exception ex;
        Test.startTest();
        try {
            insert canReport;
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        canReport.Book_Name__c = 'HMTC';
        update canReport;

        list<CAN_Ocrolus_Report__c>  canReportList = [
            SELECT Id, Book_Name__c, Application__c
            FROM CAN_Ocrolus_Report__c
        ];

        System.assert(canReport.Id != null);
        System.assertEquals(1, canReportList.size());
        System.assertEquals('HMTC', canReportList[0].Book_Name__c);
    }
}