@isTest
public class CongaCalloutMock {
    public class CongaCalloutSuccessResponse implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setStatus('SUCCESS');

            Map<String, Object> responseBody = new Map<String, Object>();

            response.setBody(JSON.serialize(responseBody));

            return response;
        }
    }

    public class CongaCalloutFailureResponse implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(400);
            response.setStatus('FAILED');

            Map<String, Object> responseBody = new Map<String, Object>();

            response.setBody(JSON.serialize(responseBody));

            return response;
        }
    }
}