global without sharing class PortalDocLinkUnLinkPortalAPI implements clcommon.PortalCustomRemoteAPI1{
    public final Static String KEY_RESPONSE;
    global clcommon.Response invokeAction(String componentStrName,
            String[] disclosureNames,
            Map<String, Object> argumentsFromPortal) {
        
        SavePoint dbSavePoint = Database.setSavepoint();
        clcommon.Response response = new clcommon.Response();
        
        try {
            String applicationId = (Id)argumentsFromPortal.get(CustomConstants.APPLICATION_ID);
            system.debug('--applicationId--'+applicationId);
            Boolean isValidApp = PortalSecurityUtil.validateUserApplication(applicationId);  
            system.debug('--isValidApp--'+isValidApp);        
            if(isValidApp) {
                response = new genesis.PortalApplicationDocumentManagement().invokeAction(componentStrName,disclosureNames,argumentsFromPortal);
            } else {
                return getErrorResponse(PortalConstants.ERROR_MESSAGE);
            }
        } catch (Exception e) {
            system.debug(e.getMessage() + '---'+e.getStackTraceString());
            Database.rollback(dbSavePoint);
            return getErrorResponse(PortalConstants.ERROR_MESSAGE);
        }
        return response;
    }
    private clcommon.Response getErrorResponse(String errorMessage) {
        clcommon.Response response = new clcommon.Response();
        response.status = clcommon.Constants.ERROR;
        response.errorMessage = errorMessage;
        response.errorCode = clcommon.Constants.API_EXCEPTION;
        return response;
    }
}