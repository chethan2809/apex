@isTest
private class CompuMailCallOutTests {
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
    private static void uploadCompuMailTest() {

        Test.setMock(HttpCalloutMock.class, new CompuMailCalloutMock());
        String fileBody = 'Dummy File Body';

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Date todaysDate = GeneralHelper.currentSystemDate;

        GeneralHelper.domainUrl = 'https://cancapital2020--uat.my.salesforce.com/';
        API_Detail__mdt apiDetails = CustomMetaDataHelper.apiDetailsByName.get(CompuMailCallOut.COMPUMAIL_DOCUMENT_UPLOAD_API_SANDBOX);

        String fileName =  todaysDate+ '.ach';
        String fileType = 'txt';

        Test.startTest();
            Integer statusCode = CompuMailCallOut.uploadCompuMail(fileBody, fileName, fileType);
        Test.stopTest();

        System.assertEquals(200, statusCode);
    }
}