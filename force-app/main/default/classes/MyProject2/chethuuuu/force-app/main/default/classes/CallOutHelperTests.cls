@isTest
private class CallOutHelperTests {

    private static String endpoint = 'https://cognito-idp.us-east-2.amazonaws.com/';

    @isTest
    private static void createRequest() {

        Test.startTest();
            HttpRequest request = CallOutHelper.createRequest(endpoint, 'POST');
        Test.stopTest();

        System.assert(request != null);
    }

    @isTest
    private static void createLambdaRequestContentTypeEquals() {
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Date todaysDate = GeneralHelper.currentSystemDate;
        String fileName =  todaysDate+ '.ach';
        String fileType = 'txt=';
        API_Detail__mdt apiDetails = CustomMetaDataHelper.apiDetailsByName.get('SFTP_Document_Upload_API_Sandbox');
        String fileBody = 'Dummy File Body=';
        Blob body = Blob.ValueOf(fileBody);

        Test.startTest();
            HttpRequest request = CallOutHelper.createLambdaRequest(endpoint, 'POST', 'webbank', apiDetails, body, fileName, fileType);
        Test.stopTest();

        System.assert(request != null);
    }

    @isTest
    private static void createLambdaRequestContentTypeDoubleEquals() {
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Date todaysDate = GeneralHelper.currentSystemDate;
        String fileName =  todaysDate+ '.ach';
        String fileType = 'txt==';
        API_Detail__mdt apiDetails = CustomMetaDataHelper.apiDetailsByName.get('SFTP_Document_Upload_API_Sandbox');
        String fileBody = 'Dummy File Body==';
        Blob body = Blob.ValueOf(fileBody);

        Test.startTest();
            HttpRequest request = CallOutHelper.createLambdaRequest(endpoint, 'POST', 'webbank', apiDetails, body, fileName, fileType);
        Test.stopTest();

        System.assert(request != null);
    }

    @isTest
    private static void createLambdaRequestFileType() {
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Date todaysDate = GeneralHelper.currentSystemDate;
        String fileName =  todaysDate+ '.ach';
        String fileType = 'txt';
        API_Detail__mdt apiDetails = CustomMetaDataHelper.apiDetailsByName.get('SFTP_Document_Upload_API_Sandbox');
        String fileBody = 'Dummy File Body';
        Blob body = Blob.ValueOf(fileBody);

        Test.startTest();
            HttpRequest request = CallOutHelper.createLambdaRequest(endpoint, 'POST', 'webbank', apiDetails, body, fileName, fileType);
        Test.stopTest();

        System.assert(request != null);
    }

    @isTest
    private static void sendRequest() {
        Test.setMock(HttpCalloutMock.class, new WasabiHTTPCallOutMocks.WasabiSendDocumentSuccessResponse());
        HttpRequest request = CallOutHelper.createRequest(endpoint, 'POST');

        request.setHeader('accept', 'application/json');
        request.setHeader('Content-Type', 'application/x-amz-json-1.1');
        request.setHeader('x-amz-target', 'AWSCognitoIdentityProviderService.InitiateAuth');

        Test.startTest();
            HttpResponse response = CallOutHelper.sendRequest(request);
        Test.stopTest();

        System.assert(response != null);
    }

    @isTest
    private static void sendRequestException() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        HttpRequest request = CallOutHelper.createRequest(endpoint, 'POST');

        request.setHeader('accept', 'application/json');
        request.setHeader('Content-Type', 'application/x-amz-json-1.1');
        request.setHeader('x-amz-target', 'AWSCognitoIdentityProviderService.InitiateAuth');

        Exception ex;
        HttpResponse response;
        Test.startTest();
        try{
            response = CallOutHelper.sendRequest(request);
        }catch(Exception e){
            ex = e;
        }
        Test.stopTest();

        System.assert(ex.getMessage() != null);
    }

    @isTest
    private static void sendUCCRequest(){
        String fileType = 'text/xml';

        Test.startTest();
            HttpRequest request = CallOutHelper.createUCCRequest(endpoint, 'POST', fileType);
        Test.stopTest();

        System.assert(request != null);

    }

    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            Map<String, Object> responseBody = new Map<String, Object>();
            Map<String, Object> authenticationResult = new Map<String, Object>();
            authenticationResult.put('IdToken', 'bookDetails');
            responseBody.put('AuthenticationResult', authenticationResult);

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-amz-json-1.1');
            res.setBody(JSON.serialize(responseBody));
            res.setStatusCode(400);
            return res;
        }
    }
}