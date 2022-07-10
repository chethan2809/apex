global class PortalResetPasswordAPI implements clcommon.PortalCustomRemoteAPI1 {

    global clcommon.Response invokeAction(String componentStrName,
                                          String[] disclosureNames,
                                          Map<String, Object> argumentsFromPortal) {
        
        clcommon.Response response = new clcommon.Response(); 
        Map<String,Object> fields = new Map<String,Object>();
                                                   
        try{
            String password = (String)argumentsFromPortal.get('password');
            String userId = (String)argumentsFromPortal.get('userId');
                                                
            SYSTEM.debug('--userId--'+userId);
            
            if(password != null){
                
                system.setPassword(userId, password);
            }
            System.debug(Site.getBaseSecureUrl());
            fields.put('redirectUrl',Site.getBaseSecureUrl());
            response.status = clcommon.Constants.SUCCESS;
        }catch(Exception e){
            system.debug('--exp--'+e.getMessage());
            return getErrorResponse(e.getMessage());
        }
                
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