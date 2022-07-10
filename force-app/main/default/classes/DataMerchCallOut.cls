public class DataMerchCallOut {
    public static String getAccessToken(API_Detail__mdt apiDetails) {
        Map<String, Object> requestBody = new Map<String, Object>();
        Map<String, Object> requestBodyAuth = new Map<String, Object>();
        requestBody.put('authentication_token', apiDetails.Client_Secret__c);
        requestBody.put('authentication_key', apiDetails.Client_Id__c);
        requestBodyAuth.put('auth', requestBody);
        String body = JSON.serializePretty(requestBodyAuth);


        HttpRequest request = CallOutHelper.createRequest(apiDetails.Token_Endpoint_URL__c, 'POST');
        request.setMethod('POST');
        request.setHeader('Content-Type','application/json');
        request.setBody(body);

        HttpResponse response = CallOutHelper.sendRequest(request);

        String responseBody = response.getBody();
        Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        String accessToken = String.valueOf(responseMap.get('token'));

        return accessToken;
    }

    public static HttpResponse requestDataMerch(Account accountObj, String accessToken) {
        API_Detail__mdt apiDetails = DataMerch.dataMerchAPIDetails;
        DataMerchCalloutParser parser = new DataMerchCalloutParser(accountObj);

        HttpRequest request = CallOutHelper.createRequest(apiDetails.Endpoint_URL__c + '/' + parser.merchantEIN, 'GET');
        request.setHeader('Authorization', accessToken);

        return CallOutHelper.sendRequest(request);
    }
}