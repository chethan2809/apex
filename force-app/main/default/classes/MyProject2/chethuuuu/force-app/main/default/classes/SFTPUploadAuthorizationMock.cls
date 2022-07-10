@isTest
public class SFTPUploadAuthorizationMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        response.setStatus('OK');
        response.setBody('tokenAuthorization');
        return response;
    }
}