@isTest
public class OcrolusCallOutMock{
    public class OcrolusCallOutMockCreateBookByNameSuccessResponse implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setStatus('SUCCESS');

            Map<String, Object> responseBody = new Map<String, Object>();
            Map<String, Object> bookDetails = new Map<String, Object>();
            bookDetails.put('msg', 'Book Created Successfully');
            responseBody.put('response', bookDetails);
            responseBody.put('status', 200);

            response.setBody(JSON.serialize(responseBody));

            return response;
        }
    }

    public class OcrolusCallOutMockUploadFileToBookSuccessResponse implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request){
        HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setStatus('SUCCESS');

            Map<String, Object> responseBody = new Map<String, Object>();
            Map<String, Object> bookDetails = new Map<String, Object>();
            List<Object> documentList = new List<Object>();

            Map<String, Object> documentMap = new Map<String, Object> ();
            documentMap.put('name', 'BankStatement.pdf');
            documentMap.put('pk', '23524722');
            documentList.add(documentMap);
            bookDetails.put('uploaded_docs', documentList);
            responseBody.put('response', bookDetails);
            responseBody.put('status', 200);

            response.setBody(JSON.serialize(responseBody));

            return response;
        }
    }

    public class OcrolusCallOutMockUploadFileToBookErrorResponse implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request){
        HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setStatus('SUCCESS');

            Map<String, Object> responseBody = new Map<String, Object>();
            Map<String, Object> bookDetails = new Map<String, Object>();

            bookDetails.put('uploaded_docs', null);
            responseBody.put('response', bookDetails);
            responseBody.put('status', 200);

            response.setBody(JSON.serialize(responseBody));

            return response;
        }
    }

    public class OcrolusCallOutMockUploadFileToBookErrorStatusResponse implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request){
        HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setStatus('SUCCESS');

            Map<String, Object> responseBody = new Map<String, Object>();
            Map<String, Object> bookDetails = new Map<String, Object>();
            List<Object> documentList = new List<Object>();

            Map<String, Object> documentMap = new Map<String, Object> ();
            documentList.add(documentMap);
            bookDetails.put('uploaded_docs', documentList);
            bookDetails.put('status', 'Failed to upload');
            bookDetails.put('message', 'Failed');
            responseBody.put('response', bookDetails);
            responseBody.put('status', 200);

            response.setBody(JSON.serialize(responseBody));

            return response;
        }
    }

    public class OcrolusCallOutMockGetBookStatusSuccessResponse implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setStatus('SUCCESS');

            Map<String, Object> responseBody = new Map<String, Object>();
            List<Object> documentList = new List<Object>();
            Map<String, Object> documentMap = new Map<String, Object> ();
            Map<String, Object> documentResponse = new Map<String, Object> ();

            documentMap.put('pk', '26509187');
            documentMap.put('status', 'VERIFICATION_COMPLETE');
            documentList.add(documentMap);

            documentResponse.put('docs', documentList);
            responseBody.put('response', documentResponse);
            responseBody.put('status', 200);

            response.setBody(JSON.serialize(responseBody));

            return response;
        }
    }

    public class OcrolusCallOutMockRequestAsyncAnalyticsSuccessResponse implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setStatus('SUCCESS');

            Map<String, Object> responseBody = new Map<String, Object>();
            Map<String, Object> documentMap = new Map<String, Object> ();
            documentMap.put('analytics_request_id', 'b735f9e3-8d97-4978-a72b-fe76fbe44584');
            responseBody.put('response', documentMap);
            responseBody.put('status', 200);

            response.setBody(JSON.serialize(responseBody));

            return response;
        }
    }

    public class OcrolusCallOutMockGetOcrolusAnalyticsExcelSuccessResponse implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setStatus('SUCCESS');

            Map<String, Object> responseBody = new Map<String, Object>();
            response.setBodyAsBlob(Blob.valueOf('Attachment example. Upload it today'));

            return response;
        }
    }

    public class OcrolusCallOutMockGetdeleteFileSuccessResponse implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setStatus('SUCCESS');

            Map<String, Object> responseBody = new Map<String, Object>();
            Map<String, Object> documentDetails = new Map<String, Object>();

            documentDetails.put('document_status', 'DELETING');
            responseBody.put('message', 'OK');
            responseBody.put('response', documentDetails);
            responseBody.put('status', 200);

            response.setBody(JSON.serialize(responseBody));

            return response;
        }
    }

    public class OcrolusCallOutMockGetdeleteFileFailureResponse implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(400);
            response.setStatus('Fail');

            Map<String, Object> responseBody = new Map<String, Object>();

            responseBody.put('status', 400);
            responseBody.put('message', 'No permission to access this doc');
            responseBody.put('response', null);

            response.setBody(JSON.serialize(responseBody));

            return response;
        }
    }
}