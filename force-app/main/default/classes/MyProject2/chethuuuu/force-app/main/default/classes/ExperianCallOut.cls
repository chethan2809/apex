public class ExperianCallOut {
    public static API_Detail__mdt apiDetails;

    public static String getAccessToken(API_Detail__mdt apiDetails) {

        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('username', apiDetails.Username__c);
        requestBody.put('password',apiDetails.Password__c);
        requestBody.put('client_id',apiDetails.Client_Id__c);
        requestBody.put('client_secret',apiDetails.Client_Secret__c);
        String body = JSON.serializePretty(requestBody);


        HttpRequest request = CallOutHelper.createRequest(apiDetails.Token_Endpoint_URL__c, 'POST');
        request.setMethod('POST');
        request.setHeader('accept', 'application/json');
        request.setHeader('Content-Type','application/json');
        request.setBody(body);

        HttpResponse response = CallOutHelper.sendRequest(request);

        String responseBody = response.getBody();
        Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        String accessToken = String.valueOf(responseMap.get('access_token'));

        return accessToken;
    }

    public static Map<String,Object> requestExperianBusinessSearch(Account accountObj, String accessToken) {
        API_Detail__mdt apiDetails = Experians.experianBusinessAPIDetails;
        ExperianCalloutParser parser = new ExperianCalloutParser(null, accountObj, apiDetails);

        Map<String, Object> requestBody = parser.businessRequestBody();
        String body = JSON.serializePretty(requestBody);

        HttpRequest request = CallOutHelper.createRequest(apiDetails.Endpoint_URL__c + '/search', 'POST');

        request.setHeader('Authorization', accessToken);
        request.setHeader('Connection', 'keep-alive');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Accept-Encoding', 'gzip, deflate, br');
        request.setHeader('Content-Type','application/json');
        request.setBody(body);

        HttpResponse response = CallOutHelper.sendRequest(request);
        Map<String, Object> resultsMap = parser.businessResponseBody(response);

        return resultsMap;
    }

    public static HttpResponse requestExperianBusinessPremierProfileCreditCheck(
        Account accountObj, Map<String, Object> accountCreditPremierProfile, String accessToken
    ) {
        API_Detail__mdt apiDetails = Experians.experianBusinessAPIDetails;
        ExperianCalloutParser parser = new ExperianCalloutParser(null, accountObj, apiDetails);

        Map<String, Object> requestBody = parser.businessPremierProfilesRequestBody(accountCreditPremierProfile);
        String body = JSON.serializePretty(requestBody);

        HttpRequest request = CallOutHelper.createRequest(apiDetails.Endpoint_URL__c + '/reports/premierprofiles', 'POST');

        request.setHeader('Authorization',accessToken);
        request.setHeader('Connection', 'keep-alive');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Accept-Encoding', 'gzip, deflate, br');
        request.setHeader('Content-Type','application/json');
        request.setBody(body);

        HttpResponse response = CallOutHelper.sendRequest(request);
        return response;
    }

    public static String requestExperianBusinessPremierProfilePdfCreditCheck(Account accountObj,
        Map<String, Object> accountCreditPremierProfile, String accessToken) {

        API_Detail__mdt apiDetails = Experians.experianBusinessAPIDetails;
        ExperianCalloutParser parser = new ExperianCalloutParser(null, accountObj, apiDetails);

        Map<String, Object> requestBody = parser.businessPremierProfilesPDFRequestBody(accountCreditPremierProfile);
        String body = JSON.serializePretty(requestBody);

        HttpRequest request = CallOutHelper.createRequest(apiDetails.Endpoint_URL__c + '/reports/premierprofiles/pdf', 'POST');

        request.setHeader('Authorization',accessToken);
        request.setHeader('Connection', 'keep-alive');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Accept-Encoding', 'gzip, deflate, br');
        request.setHeader('Content-Type','application/json');
        request.setBody(body);

        HttpResponse response = CallOutHelper.sendRequest(request);

        String resultsString = parser.businessPremierProfilesPDFResponseBody(response);

        return resultsString;
    }

    public static HttpResponse requestExperianBusinessAggregates(Account accountObj,
        Map<String, Object> accountCreditAggregates, String accessToken) {

        API_Detail__mdt apiDetails = Experians.experianBusinessAPIDetails;
        ExperianCalloutParser parser = new ExperianCalloutParser(null, accountObj, apiDetails);

        Map<String, Object> requestBody = parser.businessAggregatesRequestBody(accountCreditAggregates);
        String body = JSON.serializePretty(requestBody);

        HttpRequest request = CallOutHelper.createRequest(apiDetails.Endpoint_URL__c + '/aggregates', 'POST');

        request.setHeader('Authorization',accessToken);
        request.setHeader('Connection', 'keep-alive');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Accept-Encoding', 'gzip, deflate, br');
        request.setHeader('Content-Type','application/json');
        request.setBody(body);

        HttpResponse response = CallOutHelper.sendRequest(request);

        return response;
    }

    public static HttpResponse requestExperianConsumerCreditCheck(Contact contact, String accessToken) {
        API_Detail__mdt apiDetails = Experians.experianConsumerAPIDetails;
        ExperianCalloutParser parser = new ExperianCalloutParser(contact, null, apiDetails);
        String body = JSON.serialize(parser.consumerRequestBody());

        HttpRequest request = CallOutHelper.createRequest(apiDetails.Endpoint_URL__c, 'POST');

        request.setHeader('Authorization',accessToken);
        request.setHeader('accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(body);

        HttpResponse response = CallOutHelper.sendRequest(request);
        return response;
    }
}