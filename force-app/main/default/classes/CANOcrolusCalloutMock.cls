@isTest
public class CANOcrolusCalloutMock {
    public class CANOcrolusCallOutMockUploadFileSuccessResponse implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setStatus('Success');

            Map<String, Object> responseBody = new Map<String, Object>();
            Map<String, Object> bookDetails = new Map<String, Object>();
            List<Object> documentList = new List<Object>();
            Map<String, Object> dataMap = new Map<String, Object> ();

            Map<String, Object> documentMap = new Map<String, Object> ();
            documentMap.put('name', 'BankStatement.pdf');
            documentMap.put('pk', '23524722');
            documentList.add(documentMap);
            bookDetails.put('uploaded_docs', documentList);
            dataMap.put('response', bookDetails);
            dataMap.put('status', 200);
            dataMap.put('message', 'OK');

            responseBody.put('Data', dataMap);
            responseBody.put('STATUS', 'OK');
            responseBody.put('MESSAGE', 'SUCCESS');
            responseBody.put('REFERENCE', '0234SDF3LCN22R');

            response.setBody(JSON.serialize(responseBody));
            return response;
        }
    }

    public class CANOcrolusCallOutMockUploadFileFailureResponse implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setStatus('Success');

            Map<String, Object> responseBody = new Map<String, Object>();

            responseBody.put('Data', null);
            responseBody.put('STATUS', 'Failed');
            responseBody.put('MESSAGE', 'BookPK is Required');
            responseBody.put('REFERENCE', '0234SDF3LCN22R');

            response.setBody(JSON.serialize(responseBody));

            return response;
        }
    }

    public class CANOcrolusCallOutMockUploadOcrolusFailureResponse implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setStatus('Success');

            Map<String, Object> responseBody = new Map<String, Object>();
            Map<String, Object> dataMap = new Map<String, Object>();
            dataMap.put('status', 400);
            dataMap.put('message', 'Failed');

            responseBody.put('Data', dataMap);
            responseBody.put('STATUS', 'OK');
            responseBody.put('MESSAGE', 'SUCCESS');
            responseBody.put('REFERENCE', '0234SDF3LCN22R');

            response.setBody(JSON.serialize(responseBody));

            return response;
        }
    }

    public class CANOcrolusCallOutMockUploadFileToBookErrorResponse implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest request){
        HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setStatus('SUCCESS');

            Map<String, Object> responseBody = new Map<String, Object>();
            Map<String, Object> bookDetails = new Map<String, Object>();
            Map<String, Object> dataMap = new Map<String, Object>();

            bookDetails.put('uploaded_docs', null);
            dataMap.put('response', bookDetails);
            dataMap.put('status', 200);
            dataMap.put('message', 'OK');

            responseBody.put('Data', dataMap);
            responseBody.put('STATUS', 'OK');

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
            Map<String, Object> dataMap = new Map<String, Object>();
            List<Object> documentList = new List<Object>();

            Map<String, Object> documentMap = new Map<String, Object> ();
            documentList.add(documentMap);
            bookDetails.put('uploaded_docs', documentList);
            bookDetails.put('status', 'Failed to upload');
            bookDetails.put('message', 'Failed');
            dataMap.put('response', bookDetails);
            dataMap.put('status', 200);
            dataMap.put('message', 'OK');
            responseBody.put('Data', dataMap);
            responseBody.put('STATUS', 'OK');

            response.setBody(JSON.serialize(responseBody));

            return response;
        }
    }
}