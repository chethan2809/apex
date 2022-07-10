public class CANAuthorization {
    public static string getIdToken(String username, String password , String clientId) {
        String body = '{"AuthParameters" : {"USERNAME" : "' + username + '", "PASSWORD" : "' + password + '"}, ' +
            + '"AuthFlow" : "USER_PASSWORD_AUTH", "ClientId" : "' + clientId + '"}';

        String endpoint = 'https://cognito-idp.us-east-2.amazonaws.com/';

        HttpRequest request = CallOutHelper.createRequest(endpoint, 'POST');

        request.setHeader('accept', 'application/json');
        request.setHeader('Content-Type', 'application/x-amz-json-1.1');
        request.setHeader('x-amz-target', 'AWSCognitoIdentityProviderService.InitiateAuth');
        request.setBody(body);

        HttpResponse response = CallOutHelper.sendRequest(request);

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

        Map<String, Object> responseMapValues = (Map<String, Object>) responseMap.get('AuthenticationResult');
        String idTokenValue = String.valueOf(responseMapValues.get('IdToken'));
        return idTokenValue;
    }
}