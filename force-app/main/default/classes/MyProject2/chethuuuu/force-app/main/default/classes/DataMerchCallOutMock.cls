@isTest
public class DataMerchCallOutMock {
    public class DataMerchSuccessResponse implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setStatus('SUCCESS');
            response.setBody('{"token":"ABC1234567890"}');

            if(request.getEndpoint().endsWith('get_token')) {
                dataMerchTokenSuccessResponse(response);
            } else {
                dataMerchSuccessResponse(response);
            }
            return response;
        }

        public HttpResponse dataMerchTokenSuccessResponse(HttpResponse response){
            Map<String, Object> responseBody = new Map<String, Object>();
            responseBody.put('token', 'ABC1234567890');
            response.setBody(JSON.serialize(responseBody));
            return response;
        }

        public HttpResponse dataMerchSuccessResponse(HttpResponse response){
            response.setBody('[{"merchant": {"fein": "12-3456789", "legal_name": "Legal Name", "dba": "", "address": null, "street1": null, "street2": null, "city": "City Name", "state": "TX", "business_phone": "", "business_startdate": null, "industry": "", "notes": [{"note": { "note": "Default account", "category": "Default Account", "added_by": "Reporter Name", "created_at": "2022-03-02T19:52:49.803Z" }}]} }]');
            return response;
        }
    }

}