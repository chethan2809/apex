global class CLSBPReviewPageAPI implements clcommon.PortalCustomRemoteAPI1 {
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames,Map<String, Object> argumentsFromPortal) {
        // Init parameter.
        SavePoint dbSavePoint = Database.setSavepoint();
        clcommon.Response response = new clcommon.Response();
        
        system.debug('--argumentsFromPortal--'+argumentsFromPortal);
        genesis__Applications__c app = new genesis__Applications__c();
        try{
            
        String appId = (String)argumentsFromPortal.get(CLSBPPortalConstants.APPLICATION_ID);
            Boolean isValidApplication;
            if(appId != null){
                isValidApplication = CLSPBPortalSecurity.validApplication(appId);
                if(isValidApplication){
                    Map<String,sobject> relatedObjs =  new map<String,sobject>();
                    Map<String,List<SObject>> childObjects =  new Map<String,List<SObject>>(); 

                    if(argumentsFromPortal.get(CLSBPPortalConstants.REVIEW_COMMENT)!=null){   
                        app = (genesis__Applications__c)JSON.deserialize((String)argumentsFromPortal.get(CLSBPPortalConstants.REVIEW_COMMENT),genesis__Applications__c.class);
                    }
                    
                    if(app.Id != null){
                        update app;
                    }
                    /*clcommon__document_category__c doccat = [select id,name from clcommon__document_category__c where id ='a1R3h000000mIe9EAE'];
                    attachment att = new attachment();
                    att.name =  'test.pdf';
                    att.body = Blob.valueOf('testsrrijgsfdsjdfcsdmnc');
                    att.parentId = 'a1R3h000000mIe9EAE';
                    insert att;*/
                                        
                }else{
                    return CLSBPUtil.getErrorResponse(CLSBPPortalConstants.UNAUTHORIZED_ACTION);
                }
            }else{
                return CLSBPUtil.getErrorResponse(CLSBPPortalConstants.APP_ID_IS_NULL);
            }
        } catch (Exception e) {
            system.debug(e.getMessage() + '---'+e.getStackTraceString());
            Database.rollback(dbSavePoint);
            response = CLSBPUtil.getErrorResponse(CLSBPPortalConstants.SOMETHING_WENT_WRONG);
            return response;
        }
        
       	Map<String,Object> fields = new Map<String,Object>();
        //fields.put(CLSBPPortalConstants.APPLICATION_ID,app.Id);
        List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
        respList.add(new clcommon.PortalCustomRemoteActionRecord('KEY_RESPONSE', fields));
        response = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
        return response; 

    }
    
}