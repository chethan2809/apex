global class CCBPCongaAPICaller implements clcommon.PortalCustomRemoteAPI1 {

        public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

        global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> argumentsFromPortal) {
            clcommon.Response res = new clcommon.Response();
            Boolean isValidApplication;
            Id applicationId = (Id)argumentsFromPortal.get(PortalConstants.APPLICATION_ID);
            try {
                isValidApplication = CLSPBPortalSecurity.validApplication(applicationId);
                if(isValidApplication) {
                    Http http = new Http();
                    HttpRequest req = new HttpRequest();
                    string jsonBody = '{"parentId":"' + applicationId +'","sendForESign":true,"templateType":"Loan Agreement"}';
                    req.setEndpoint('callout:Portal_Conga_API/services/apexrest/v1/congaautomation');
                    req.setMethod('POST');
                    req.setHeader('Content-Type', 'application/json;charset=UTF-8');
                    req.setBody(jsonBody);
                    req.setTimeout(60000);
                    HttpResponse response = http.send(req);
                    if(response.getStatusCode() == 200){
                        res.Status = PortalConstants.API_RESPONSE_STATUS_SUCCESS;
                        res.errorMessage = null;
                    }else{
                        res.status = PortalConstants.API_RESPONSE_STATUS_FAILED;
                        res.errorMessage = PortalConstants.CONGA_API_CALL_FAILED_STATUS;
                    }
                }
                else {
                     Error_Log__c errorLog = ErrorLogs.createErrorLog (
                                PortalConstants.ACCESS_DENIED_ACCESSING_APP, null, null,
                                null, ErrorLogs.ERROR, applicationId, true);
                    errorLogDBInstance.addInsert(errorLog);
                    errorLogDBInstance.executeInserts();
                    return getErrorResponse(PortalConstants.ACCESS_DENIED_ACCESSING_APP);
                }
            } catch (Exception e) {
                Error_Log__c errorLog = ErrorLogs.createErrorLog (
                        PortalConstants.ERROR_ADD_PARTY_CATCH_BP, e.getMessage(), e.getStackTraceString(),
                        null, ErrorLogs.ERROR, applicationId, true);
                errorLogDBInstance.addInsert(errorLog);
                errorLogDBInstance.executeInserts();
                res = getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
                return res;
            }
        return res;
    }

     private clcommon.Response getErrorResponse(String errorMessage) {
        clcommon.Response response = new clcommon.Response();
        response.status = clcommon.Constants.ERROR;
        response.errorMessage = errorMessage;
        response.errorCode = clcommon.Constants.API_EXCEPTION;
        return response;
    }
}