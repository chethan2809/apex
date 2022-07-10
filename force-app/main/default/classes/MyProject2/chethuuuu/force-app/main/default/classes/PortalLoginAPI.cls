global class PortalLoginAPI implements clcommon.PortalCustomRemoteAPI1 {

    global clcommon.Response invokeAction(String componentStrName,
                                          String[] disclosureNames,
                                          Map<String, Object> argumentsFromPortal) {
        
        String username = (String)argumentsFromPortal.get('username');
        String password = (String)argumentsFromPortal.get('password');                                      
        SYSTEM.debug('--username--'+username);
        SYSTEM.debug('--password--'+password);                                      
                                              
        clcommon.Response response = new clcommon.Response();  
        //response = clcommon.PortalActions.loginV3(username, password);
        PageReference pr;
        if(System.Test.isRunningTest()){
            if(username.equals('testUser')){
                pr = new PageReference('test.salesforce.com');
                pr.setRedirect(true);
            }
        }else{
             pr = Site.login(username,password,'/');                                     
        } 
        system.debug('--pr--'+pr); 
        if(pr != null){
            String userIdNew = UserInfo.getUserId();
            String sessionId = UserInfo.getSessionId();                                      
            Map<String,Object> fields = new Map<String,Object>();
            fields.put('loggedInUserId',userIdNew);
            fields.put('sessionId',sessionId);  
            fields.put('redirectUrl',pr);
            response.status = clcommon.Constants.SUCCESS;
            List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
            respList.add(new clcommon.PortalCustomRemoteActionRecord('KEY_RESPONSE', fields));
            response = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
            return response;     
        } else{
            return getErrorResponse('Please check your username and password.');
        }                                                                                                        
    }
    private clcommon.Response getErrorResponse(String errorMessage) {
        clcommon.Response response = new clcommon.Response();
        response.status = clcommon.Constants.ERROR;
        response.errorMessage = errorMessage;
        response.errorCode = clcommon.Constants.API_EXCEPTION;
        return response;
    }
}