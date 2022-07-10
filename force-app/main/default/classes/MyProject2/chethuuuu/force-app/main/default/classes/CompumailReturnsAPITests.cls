@isTest(isParallel=true)
private class CompumailReturnsAPITests {
    static final String ENDPOINT_URL = '/services/apexrest/v1/ncoareturns/';

    @isTest
    private static void processNCOAReturns() {
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
            CompumailReturnsAPI.processNCOAReturns();
        Test.stopTest();

        TestUtility.assertNullException(ex);
        System.assertEquals(200, res.statusCode);
    }

    @isTest
    private static void processNCOAReturnsException() {
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
            CompumailReturnsAPI.processNCOAReturns();
        Test.stopTest();

        TestUtility.assertNullException(ex);
        System.assertEquals(500, res.statusCode);
    }

    private static Object setUpReturnPayloadData() {
        List<Integer> contentList = new List<Integer> {84, 104, 105, 115, 32, 105, 115, 32, 65, 66, 67, 32, 102, 105, 108, 101, 13, 10, 70};
        List<Object> returnPayload = new List<Object> ();
        returnPayload.add(contentList);

        return returnPayload;
    }
}