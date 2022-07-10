@isTest
private class CANAuthorizationTests {

    @isTest
    private static void getIdToken(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        API_Detail__mdt apiDetails = CustomMetaDataHelper.apiDetailsByName.get(CanScorings.CAN_SCORING_API_SANDBOX);

        Test.startTest();
            String token = CANAuthorization.getIdToken(apiDetails.Username__c, apiDetails.Password__c, apiDetails.Client_Id__c);
        Test.stopTest();

        System.assertEquals('bookDetails', token);
    }

    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            Map<String, Object> responseBody = new Map<String, Object>();
            Map<String, Object> authenticationResult = new Map<String, Object>();
            authenticationResult.put('IdToken', 'bookDetails');
            responseBody.put('AuthenticationResult', authenticationResult);

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/x-amz-json-1.1');
            res.setBody(JSON.serialize(responseBody));
            res.setStatusCode(200);
            return res;
        }
    }
}