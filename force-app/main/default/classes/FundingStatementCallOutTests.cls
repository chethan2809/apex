@isTest
private class FundingStatementCallOutTests {

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
    private static void uploadFundingStatement() {

        Test.setMock(HttpCalloutMock.class, new RestMock());
        String fileBody = 'Dummy File Body';

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Date todaysDate = GeneralHelper.currentSystemDate;

        String fileName =  todaysDate+ '.ach';
        String fileType = 'txt';

        Test.startTest();
            Integer statusCode = FundingStatementCallOut.uploadFundingStatement(fileBody, fileName, fileType);
        Test.stopTest();

        System.assertEquals(200, statusCode);
    }
}