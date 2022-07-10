public class WasabiHTTPCallOutMocks {

    public class WasabiSendDocumentSuccessResponse implements HttpCalloutMock
    {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('SUCCESS');
            return res;
        }
    }

    public class WasabiGetDocumentSuccessResponse implements HttpCalloutMock
    {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody('Attachment example. Upload it today');
            res.setStatusCode(200);
            res.setStatus('SUCCESS');
            return res;
        }
    }

    public class WasabiErrorResponse implements HttpCalloutMock
    {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setStatus('FAILURE');
            return res;
        }
    }
}