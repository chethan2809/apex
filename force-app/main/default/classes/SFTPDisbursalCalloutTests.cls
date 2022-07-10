@isTest
private class SFTPDisbursalCalloutTests {

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
    private static void uploadSFTPDisbursal() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Blob fileBody = Blob.valueOf('Dummy File Body');

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Date todaysDate = GeneralHelper.currentSystemDate;

        String fileName =  todaysDate+ '.ach';
        String fileType = 'txt';

        Test.startTest();
            Integer statusCode = SFTPDisbursalCallout.uploadSFTPDisbursal(fileBody, fileName, fileType);
        Test.stopTest();

        System.assertEquals(200, statusCode);
    }

    @isTest
    private static void getFileType(){
        Test.startTest();
            String fileType = SFTPDisbursalCallout.getFileType('text');
        Test.stopTest();

        System.assertEquals('text/csv', fileType);
    }
}