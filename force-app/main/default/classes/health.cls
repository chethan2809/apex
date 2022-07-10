@RestResource(urlMapping='/v1/healthcheck/')
global class health {
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    @HttpPost
    global static void processhealthRequest() {
        RestResponse response = RestContext.response;
        RestRequest request = RestContext.request;

        if(APIHelpers.isRequestBodyEmpty(request, response)) {
            return;
        }
        String requestBody = APIHelpers.sanitizeString(request.requestBody.toString());
        Map<String, Object> requesthealth = (Map<String, Object>) APIHelpers.objectValidation(
            JSON.deserializeUntyped(requestBody), 'Map', 'Request body'
        );

        if(requesthealth == null || requesthealth.keySet().isEmpty()) {
            Blob responseBody = Blob.valueOf('{"message" : "' + 'No records found in payload' + '"}');
            APIHelpers.constructRestResponse(response, 400, responseBody);
            return;
        }
        
        if(GeneralHelper.getDateFromUntypedString(requesthealth.Date, 0, 1, 2, '-') != GeneralHelper.currentSystemDateTime){
            Blob responseBody = Blob.valueOf('{"status" : "' + '"Failed",' + '"}');
            APIHelpers.constructRestResponse(response, 400, responseBody);
            return;
        }
    


        try {
            OcrolusManager.processhealth(requesthealth);
            APIHelpers.setSuccessResponse(response, null);
        } catch (Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'health API', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                null, false
            );
            errorLogDBInstance.addInsert(errorLog);
            APIHelpers.setErrorResponse(response, e);
        }

        errorLogDBInstance.executeInserts();
    }
}