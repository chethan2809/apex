public class CANScoringCallOut {

    private static String token;

    public static Map<String, Object> requestCANScore(
        genesis__Applications__c application, Map<Id, Map<String, Credit_Report_Detail__c>> creditReportDetailByApplicationId,
        Account accountDetail
    ) {
        API_Detail__mdt apiDetails;
        if(GeneralHelper.getOrgInformation.isSandbox){
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(CanScorings.CAN_SCORING_API_SANDBOX);
        }else{
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(CanScorings.CAN_SCORING_API_PRODUCTION);
        }

        String body = JSON.serialize(CANScoringCallOutParser.buildRequest(application, creditReportDetailByApplicationId, accountDetail));

        HttpRequest request = CallOutHelper.createRequest(apiDetails.Endpoint_URL__c, 'POST');

        if(token == null) {
            token = CANAuthorization.getIdToken(apiDetails.Username__c, apiDetails.Password__c, apiDetails.Client_Id__c);
        }

        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(body);

        HttpResponse response = CallOutHelper.sendRequest(request);

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

        if((String) responseMap.get('status') != 'OK') {
            throw new CANScoringCallOutException(
                (String) responseMap.get('message') + 'Reference: ' + (String) responseMap.get('reference') + ' | Request: ' + body +
                    + ' | Response: ' + response.getBody()
            );
        }

        Map<String, Object> resultData = (Map<String, Object>) responseMap.get('data');
        return resultData;
    }

    private class CANScoringCallOutException extends Exception {}
}