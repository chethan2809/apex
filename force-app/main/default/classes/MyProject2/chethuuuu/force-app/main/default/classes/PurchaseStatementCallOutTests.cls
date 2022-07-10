@isTest
private class PurchaseStatementCallOutTests {

    private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    private static void uploadPurchaseStatement() {

        Test.setMock(HttpCalloutMock.class, new RestMock());
        String fileBody = 'Dummy File Body';

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Date todaysDate = GeneralHelper.currentSystemDate;

        String fileName =  todaysDate+ '.ach';
        String fileType = 'txt';

        Test.startTest();
            Integer statusCode = PurchaseStatementCallOut.uploadPurchaseStatement(fileBody, fileName, fileType);
        Test.stopTest();

        System.assertEquals(200, statusCode);
    }
}