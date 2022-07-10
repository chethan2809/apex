@isTest
private class SFTPScoringRawDataCallOutTests {

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
    private static void uploadSFTPRawData() {

        Test.setMock(HttpCalloutMock.class, new RestMock());
        Blob fileBody = Blob.valueOf('Dummy File Body');

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Date todaysDate = GeneralHelper.currentSystemDate;

        String fileName =  todaysDate+ '.ach';
        String fileType = 'txt';
        String folderName = 'Test Folder';

        Test.startTest();
            Integer statusCode = SFTPScoringRawDataCallOut.uploadSFTPRawData(folderName, fileBody, fileType, fileName);
        Test.stopTest();

        System.assertEquals(200, statusCode);
    }
}