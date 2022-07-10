@isTest
private class ErrorLogManagerTests {
    @isTest
    private static void processErrorLogAnalyticsForSuccess() {

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Status__c = Applications.STATUS_BANK_STATEMENT_PROCESSING_FAILED;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Analytics_PK__c = '12872807';
        ocrolusReport.Max_Daily_Payment__c = 851.2645;
        ocrolusReport.Document_Status__c = Ocrolus.OCROLUS_DOC_STATUS_FAILED;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        ErrorLogManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        ocrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c> {ocrolusReport};
        ErrorLogManager.ocrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        ErrorLogManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Map<String, Object> errorLogAnalyticsMap = new Map<String, Object>();
        errorLogAnalyticsMap.put('pk', ocrolusReport.Analytics_PK__c);
        errorLogAnalyticsMap.put('TransactionId', 'Test1234');
        errorLogAnalyticsMap.put('Message', 'TestMessage');

        Test.startTest();
            ErrorLogManager.createAWSOcrolusErrorLog(errorLogAnalyticsMap);
        Test.stopTest();

        System.assertEquals(1, ErrorLogDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void processErrorLogAnalyticsForFailure() {

        String pk = '12875632';
        Map<String, Object> errorLogAnalyticsMap = new Map<String, Object>();
        errorLogAnalyticsMap.put('pk', 12875632);

        Exception ex;
        Test.startTest();

        try{
            ErrorLogManager.createAWSOcrolusErrorLog(errorLogAnalyticsMap);
        } catch(Exception e){
            ex = e;
        }

        Test.stopTest();

        System.assertEquals(ex.getMessage(), 'There was no ocrolus report found for PK : ' + pk );
    }

}