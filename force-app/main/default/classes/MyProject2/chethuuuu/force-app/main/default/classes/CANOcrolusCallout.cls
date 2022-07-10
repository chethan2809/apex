public class CANOcrolusCallout {

    @TestVisible
    private static String token;
    private static final String CAN_OCROLUS_API_SANDBOX = 'CAN_Ocrolus_API_Sandbox';
    private static final String CAN_OCROLUS_API_PRODUCTION = 'CAN_Ocrolus_API_Production';

    public static Map<String, Object> uploadFile(String pkId, String filePath) {
        API_Detail__mdt apiDetails;
        if(GeneralHelper.getOrgInformation.isSandbox){
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(CAN_OCROLUS_API_SANDBOX);
        }else{
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(CAN_OCROLUS_API_PRODUCTION);
        }

        String pathReference = filePath.substringAfter('com/');

        Map<String, Object> bodyMap = new Map<String, Object>();
        bodyMap.put('bookPK', Integer.valueOf(pkId));
        bodyMap.put('filePath', pathReference);
        String body = JSON.serialize(bodyMap);

        HttpRequest request = CallOutHelper.createRequest(apiDetails.Endpoint_URL__c, 'POST');

        if(token == null) {
            token = CANAuthorization.getIdToken(apiDetails.Username__c, apiDetails.Password__c, apiDetails.Client_Id__c);
        }

        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('accept', '*/*');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(body);

        HttpResponse response = CallOutHelper.sendRequest(request);

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

        validateResponseFromCANOcrolus(responseMap, response, body);

        return responseMap;
    }

    private static void validateResponseFromCANOcrolus(Map<String, Object> responseMap, HttpResponse response, String body) {
        if(responseMap.get('STATUS') == 'OK') {
            Map<String, Object> resultData = (Map<String, Object>) responseMap.get('Data');

            if((String) resultData.get('message') != 'OK') {
                throw new CANOcrolusCallOutException(
                    (String) responseMap.get('MESSAGE') + 'Reference: ' + (String) responseMap.get('REFERENCE') + ' | Request: ' + body
                        + ' | Response: ' + response.getBody()
                );
            }

        } else {
            throw new CANOcrolusCallOutException('Status Code: ' + responseMap.get('STATUS') + ' | Message: ' + responseMap.get('MESSAGE'));
        }
    }

    private class CANOcrolusCallOutException extends Exception {}
}