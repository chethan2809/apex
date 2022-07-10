global class PortalSaveAPI  implements clcommon.PortalCustomRemoteAPI1{
    global clcommon.Response invokeAction(String componentStrName,
            String[] disclosureNames,
            Map<String, Object> argumentsFromPortal) {
        
        SavePoint dbSavePoint = Database.setSavepoint();
        clcommon.Response response = new clcommon.Response();
        String applicationId;
        if(argumentsFromPortal.containsKey(CustomConstants.APPLICATION_ID) && argumentsFromPortal.get(CustomConstants.APPLICATION_ID) != ''){
            applicationId = (Id)argumentsFromPortal.get(CustomConstants.APPLICATION_ID);
        
            system.debug('--applicationId--'+applicationId);
            try {
                Boolean isValidApp = PortalSecurityUtil.validateUserApplication(applicationId);  
                system.debug('--isValidApp--'+isValidApp);        
                if(isValidApp) {
                    genesis__Applications__c appln = [Select Id,Name,
                                                      Portal_Stage__c,
                                                      Portal_Sub_Stage__c,
                                                      genesis__Status__c
                                                      From genesis__Applications__c 
                                                      Where Id = :applicationId] ;
                    if(argumentsFromPortal.containsKey('portalStage') && argumentsFromPortal.get('portalStage') != null){
                        appln.Portal_Stage__c = (String)argumentsFromPortal.get('portalStage');
                    }
                    if(argumentsFromPortal.containsKey('portalSubstage') && argumentsFromPortal.get('portalSubstage') != null){
                        appln.Portal_Sub_Stage__c = (String)argumentsFromPortal.get('portalSubstage');
                    }
                     if(argumentsFromPortal.containsKey('status') && argumentsFromPortal.get('status') != null){
                        appln.genesis__Status__c = (String)argumentsFromPortal.get('status');
                    }
                    update appln;
                    response.status = clcommon.Constants.SUCCESS;
                } else {
                    return getErrorResponse(PortalConstants.ERROR_MESSAGE);
                }
            } catch (Exception e) {
                system.debug(e.getMessage() + '---'+e.getStackTraceString());
                Database.rollback(dbSavePoint);
                 clcommon__Log__c comLog = new clcommon__Log__c(clcommon__Message__c = 'SMB Portal Error: '+e.getMessage()+
                                                           ' at line: '+e.getLineNumber(),
                                                           clcommon__Time__c = System.now());
            Insert comLog;
                if(e.getMessage().equals(PortalConstants.SYSTEM_TIME_OUT)){
                    return getErrorResponse(PortalConstants.SYSTEM_TIME_OUT);
                }else{
                    return getErrorResponse(PortalConstants.ERROR_MESSAGE);
                }
            }
        }else{
            response.status = clcommon.Constants.SUCCESS;
        }
        Map<String,Object> fields = new Map<String,Object>();
        List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
        respList.add(new clcommon.PortalCustomRemoteActionRecord('KEY_RESPONSE', fields));
        response = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
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