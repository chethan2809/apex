@RestResource(urlMapping='/v1/ocrolus/analytics/*')
global class OcrolusAnalyticsAPI {
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    @HttpPost
    global static void processOcrolusAnalyticsRequest() {
        RestResponse response = RestContext.response;
        RestRequest request = RestContext.request;

        if(APIHelpers.isRequestBodyEmpty(request, response)) {
            return;
        }
        String requestBody = APIHelpers.sanitizeString(request.requestBody.toString());
        Map<String, Object> requestOcrolusAnalytics = (Map<String, Object>) APIHelpers.objectValidation(
            JSON.deserializeUntyped(requestBody), 'Map', 'Request body'
        );

        if(requestOcrolusAnalytics == null || requestOcrolusAnalytics.keySet().isEmpty()) {
            Blob responseBody = Blob.valueOf('{"message" : "' + 'No records found in payload' + '"}');
            APIHelpers.constructRestResponse(response, 400, responseBody);
            return;
        }

        try {
            OcrolusManager.processOcrolusAnalytics(requestOcrolusAnalytics);
            APIHelpers.setSuccessResponse(response, null);
        } catch (Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'Ocrolus Analytics API', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                null, false
            );
            errorLogDBInstance.addInsert(errorLog);
            APIHelpers.setErrorResponse(response, e);
        }

        errorLogDBInstance.executeInserts();
    }
}