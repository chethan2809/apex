global class CLSBPNotificationBannerAPI implements clcommon.PortalCustomRemoteAPI1 {
    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> argumentsFromPortal) {
        
        // Init parameter.
        SavePoint dbSavePoint = Database.setSavepoint();
        clcommon.Response response = new clcommon.Response();
        
        system.debug('--argumentsFromPortal--'+argumentsFromPortal);
        List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
        Map<String,Object> fields = new Map<String,Object>();
        
        genesis__org_parameters__c orgParams = new genesis__org_parameters__c();
        try {
            
                    if(argumentsFromPortal.get('notificationBanner')!=null){
                        orgParams = (genesis__org_parameters__c)JSON.deserialize((String)argumentsFromPortal.get('notificationBanner'),genesis__org_parameters__c.class); 
                    }
            
            		if(orgParams.Id != null){
                		Update orgParams;
            			}
            		            
            
             }catch (Exception e) {
            system.debug(e.getMessage() + '---'+e.getStackTraceString());
            Database.rollback(dbSavePoint);
            response = CLSBPUtil.getErrorResponse('Something went wrong.');
            return response;
        }    
        //respList.add(new clcommon.PortalCustomRemoteActionRecord('KEY_RESPONSE', fields));
        response = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
        return response;
    }


}