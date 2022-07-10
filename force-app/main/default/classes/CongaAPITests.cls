@isTest
private class CongaAPITests {
    static final String ENDPOINT_URL = '/services/apexrest/v1/congaautomation/';

    @isTest
    private static void processCongaDocuments() {
        Map<String, Object> returnRecords = new Map<String, Object>();
        returnRecords.put('parentId', TestUtility.getFakeId(genesis__Applications__c.getSObjectType()));
        returnRecords.put('templateType', 'Loan Agreement-A Application');
        returnRecords.put('sendForESign', true);

        RestRequest req = new RestRequest();
        req.requestURI = ENDPOINT_URL;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(returnRecords));
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Total_Competitors_Amount__c = 1000;
        application.Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        CongaManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        CAN_Conga_Settings__c congaSettings = new CAN_Conga_Settings__c();
        congaSettings.Id = TestUtility.getFakeId(CAN_Conga_Settings__c.getSObjectType());
        congaSettings.Conga_Sign_BLA_Subject__c = 'Please sign your document';
        CustomSettingsHelper.congaSettings = congaSettings;

        System.Test.setMock(HttpCalloutMock.class, new CongaCalloutMock.CongaCalloutSuccessResponse());

        Test.startTest();
            CongaAPI.processCongaDocuments();
        Test.stopTest();

        RestResponse resVal = RestContext.response;
        System.assertEquals(200, resVal.statusCode);
    }

    @isTest
    private static void processCongaDocumentsExeption() {
        Map<String, Object> returnRecords = new Map<String, Object>();

        RestRequest req = new RestRequest();
        req.requestURI = ENDPOINT_URL;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(returnRecords));
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Exception ex;
        Test.startTest();
        try {
            CongaAPI.processCongaDocuments();
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        RestResponse resVal = RestContext.response;
        System.assertEquals(500, resVal.statusCode);
    }
}