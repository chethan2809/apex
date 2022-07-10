public class UCCCalloutMock {
    public class UCCCallOutMockCreateFiling implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'text/xml');
            response.setStatusCode(200);
            response.setStatus('SUCCESS');
            response.setBody('<OrderInfo><OrderID>153405863</OrderID></OrderInfo>');
            return response;
        }
    }

    public class UCCCalloutMockGetOrderInformationByUCCFilingDetail implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'text/xml');
            response.setStatusCode(200);
            response.setStatus('SUCCESS');
            response.setBody('<OrderInfo><OrderID>153405863</OrderID></OrderInfo>');
            return response;
        }
    }

    public class UCCCalloutMockUccFilingContinuation implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('SUCCESS');
            if(request.getEndpoint().endsWith('ContinueFiling')) {
                response.setBody('<OrderInfo><OrderID>153405863</OrderID></OrderInfo>');
            } else if(request.getEndpoint().endsWith('ValidateFiling')) {
                response.setBody('<Message level="0">No Validation Errors</Message>');
            } else if(request.getEndpoint().endsWith('ApproveOrder')) {
                response.setBody('<OrderInfo><OrderID>153405863</OrderID></OrderInfo>');
            }
            return response;
        }
    }

    public class UCCCalloutMockUccValidateApproveFiling implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request) {
           HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'text/xml');
            response.setStatusCode(200);
            response.setStatus('SUCCESS');
            response.setBody('<Message level="0">No Validation Errors</Message><OrderID>153405863</OrderID>');
            return response;
        }
    }

     public class UCCCalloutMockUccValidateFiling implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request) {
           HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'text/xml');
            response.setStatusCode(200);
            response.setStatus('SUCCESS');
            response.setBody('<Messages>DummyString</Messages>');
            return response;
        }
    }

    public class UCCCalloutMockTerminateUCCFiling implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request) {
             HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'text/xml');
            response.setStatusCode(200);
            response.setStatus('SUCCESS');
            response.setBody('<OrderID>153405863</OrderID>');
            return response;
        }
    }

    public class UCCCalloutMockUpdateUCCFiling implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'text/xml');
            response.setStatusCode(200);
            response.setStatus('SUCCESS');
            return response;
       }
   }

    public class UCCCalloutMockGetPlaceID implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'text/xml');
            response.setStatusCode(200);
            response.setStatus('SUCCESS');

            Map<String, string> placeIdMap = new Map<String, string>();
            placeIdMap.put('place_id', 'a01234obf');
            List<Object> placesList =  new List<Object>();
            placesList.add(placeIdMap);
            Map<String, Object> responseBody = new Map<String, Object>();
            responseBody.put('candidates', placesList);

            response.setBody(JSON.serialize(responseBody));

            return response;
        }
    }
    public class UCCCalloutMockGetCountyParishForUCC implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'text/xml');
            response.setStatusCode(200);
            response.setStatus('SUCCESS');

            Map<String, Object> responseBody = new Map<String, Object>();
            responseBody.put('Message', 'Get Country Parish For UCC Successful');
            responseBody.put('status', 200);
            responseBody.put('address_Components : {types : {administrative_area_level2}}', 200);
            response.setBody(JSON.serialize(responseBody));

            return response;
        }
    }
    public class UCCCalloutMockValidateStringValue implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'text/xml');
            response.setStatusCode(200);
            response.setStatus('SUCCESS');
            return response;
        }
    }
    public class UCCCalloutMockGetUCCAttachmentsByAttachmentId implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'text/xml');
            response.setStatusCode(200);
            response.setStatus('SUCCESS');
            return response;
        }
    }

    public class UCCCalloutMockGetUCCAttachmentsFromExternalURL implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'text/xml');
            response.setStatusCode(200);
            response.setStatus('SUCCESS');

            Map<String, Object> responseBody = new Map<String, Object>();
            responseBody.put('Message', 'Get UCCAttachments From ExternalURL Successful');
            responseBody.put('status', 200);

            response.setBody(JSON.serialize(responseBody));

            return response;
        }
    }
}