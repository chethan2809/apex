@isTest
private class ACHReturnsAPITests {

    static final String ENDPOINT_URL = '/services/apexrest/v1/achreturns/';

    @isTest
    private static void processACHReturns() {
        Map<String, Object> returnRecords = new Map<String, Object>();
        returnRecords.put('fileContentList', setUpReturnPayloadData());

        RestRequest req = new RestRequest();
        req.requestURI = ENDPOINT_URL;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(returnRecords));
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Integer filesProcessed = 10;
        DateTime currentSystemDateTime = DateTime.now().addSeconds(15);
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        Exception ex;

        Test.startTest();
                ACHReturnsAPI.processACHReturns();
        Test.stopTest();

        TestUtility.assertNullException(ex);
    }

    @isTest
    private static void processACHReturnsException() {
        Map<String, Object> returnRecords = new Map<String, Object>();

        RestRequest req = new RestRequest();
        req.requestURI = ENDPOINT_URL;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(returnRecords));
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Integer filesProcessed = 10;

        Exception ex;

        Test.startTest();
                ACHReturnsAPI.processACHReturns();
        Test.stopTest();

        TestUtility.assertNullException(ex);
    }

    private static Object setUpReturnPayloadData() {
        List<Integer> contentList = new List<Integer> {84, 104, 105, 115, 32, 105, 115, 32, 65, 66, 67, 32, 102, 105, 108, 101, 13, 10, 70};
        List<Object> returnPayload = new List<Object> ();
        returnPayload.add(contentList);

        return returnPayload;
    }
}