@isTest
global class MockCANScoringCallOut implements HttpCalloutMock{
	global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        response.setStatus('OK');
        response.setBody('{"response":"SUCCESS","AuthenticationResult":{"IdToken":"IdToken"},"status":"OK"}');
        return response;
    }
}