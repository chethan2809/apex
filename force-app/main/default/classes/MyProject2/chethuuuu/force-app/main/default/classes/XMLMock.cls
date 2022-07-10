@isTest
global class XMLMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/xml');
        response.setStatusCode(200);
        response.setStatus('OK');
        //response.setBody('{"responseMessage":[{"bin": "a", "reliabilityCode": 1}],"results":[{"bin": "a", "reliabilityCode": 86}]}');
        return response;
    }
}