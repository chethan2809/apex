@isTest
private class ErrorLogAPITests {

    static final String ENDPOINT_URL = '/services/apexrest/v1/createLog/awsocrolus';
    static final String ERROR_ENDPOINT_URL = '/services/apexrest/v1/createLog/';

    @isTest
    private static void processErrorLogRequestForSuccess() {

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Status__c = Applications.STATUS_BANK_STATEMENT_PROCESSING_FAILED;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Analytics_PK__c = '12872807';
        ocrolusReport.Max_Daily_Payment__c = 851.2645;
        ocrolusReport.Document_Status__c = Ocrolus.OCROLUS_DOC_STATUS_VERIFYING;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        ErrorLogManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        ocrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c> {ocrolusReport};
        ErrorLogManager.ocrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        ErrorLogManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Map<String, Object> returnRecords = new Map<String, Object>();
        returnRecords.put('pk', 12872807);
        returnRecords.put('TransactionId', 'Test1234');
        returnRecords.put('Message', 'TestMessage');

        RestRequest req = new RestRequest();
        req.requestURI = ENDPOINT_URL;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(returnRecords));
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        ErrorLogAPI.processErrorLogRequest();
        Test.stopTest();

        System.assertEquals(200, res.statusCode);

    }

    @isTest
    private static void processErrorLogRequestForFailure() {

        Map<String, Object> returnRecords = new Map<String, Object>();
        returnRecords.put('pk', 12872807);
        returnRecords.put('TransactionId', 'Test1234');
        returnRecords.put('Message', 'TestMessage');

        RestRequest req = new RestRequest();
        req.requestURI = ERROR_ENDPOINT_URL;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(returnRecords));
        RestContext.request = req;

        Exception ex;
        Test.startTest();
        try{
            ErrorLogAPI.processErrorLogRequest();
        } catch(Exception e) {
            ex = e;
        }
        Test.stopTest();

        System.assertEquals(ex.getMessage(), 'Invalid Request EndPoint');
    }
}