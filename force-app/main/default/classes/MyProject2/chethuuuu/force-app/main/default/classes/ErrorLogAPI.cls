@RestResource(urlMapping='/v1/createLog/*')
global class ErrorLogAPI {
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    @HttpPost
    global static void processErrorLogRequest() {
        RestResponse response = RestContext.response;
        RestRequest request = RestContext.request;

        String requestBody = APIHelpers.sanitizeString(request.requestBody.toString());
        Map<String, Object> responseMap = new Map<String, Object>();

        Map<String, Object> errorLogAPIAnalytics = (Map<String, Object>) APIHelpers.objectValidation(
        JSON.deserializeUntyped(requestBody), 'Map', 'Request body'
        );

        if(!APIHelpers.validateBodyRequiredFields(response, errorLogAPIAnalytics, ErrorLogs.KEYS_TO_VALIDATE)){
            return;
        }

        String ocrolusURI = request.requestURI.substring(
            request.requestURI.lastIndexOf('/') + 1);

        if(ocrolusURI == ErrorLogs.LOG_TYPE_AWS_OCROLUS) {
            ErrorLogManager.createAWSOcrolusErrorLog(errorLogAPIAnalytics);
            response.statusCode = 200;
        }
        else {
            throw new ErrorLogAPIException('Invalid Request EndPoint');
        }
    }
    private class ErrorLogAPIException extends Exception {}
}