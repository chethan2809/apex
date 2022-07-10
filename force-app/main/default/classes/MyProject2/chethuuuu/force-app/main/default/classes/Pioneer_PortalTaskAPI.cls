global class Pioneer_PortalTaskAPI implements clcommon.PortalCustomRemoteAPI1 {

        global clcommon.Response invokeAction(String componentStrName,
                String[] disclosureNames,
                Map<String, Object> argumentsFromPortal) {            
            
            // Init parameter.
            SavePoint dbSavePoint = Database.setSavepoint();
            clcommon.Response response = new clcommon.Response();
            String applicationId = (String)argumentsFromPortal.get(CustomConstants.APPLICATION_ID);  
            List<clcommon__Document_Category__c> docCategories = New List<clcommon__Document_Category__c>();
            List<Attachment> attchements = New List<Attachment>();
            Boolean isValidApp = PortalSecurityUtil.validateUserApplication(applicationId);  
            system.debug('--isValidApp--'+isValidApp);
            if(isValidApp){
                try {
                    if(argumentsFromPortal.containsKey('documentCatogories')){
                        docCategories = (List<clcommon__Document_Category__c>) JSON.deserialize((String) argumentsFromPortal.get('documentCatogories'), List<clcommon__Document_Category__c>.class);
                        for(clcommon__Document_Category__c doc: docCategories){
                            attchements  =  [SELECT Id FROM Attachment WHERE ParentId = :doc.Id];
                            if(attchements.size() == 0){
                                return getErrorResponse('Please upload all the requested documents');                           
                            }
                            else{
                                doc.clcommon__Status__c = 'SUBMITTED';
                            }
                        }
                    }
                    if(docCategories.size() > 0)
                    UPDATE docCategories;
                    response.status = clcommon.Constants.SUCCESS;
                } catch (Exception e) {
                    system.debug(e.getMessage() + '---'+e.getStackTraceString());
                    Database.rollback(dbSavePoint);
                    response.status = clcommon.Constants.API_EXCEPTION;
                    response.errorMessage = PortalConstants.ERROR_MESSAGE;
                    //response.errorMessage = e.getLineNumber() + ' ' + e.getMessage() + ' ' + e.getStackTraceString();
                    return response;                
                }
            }else{
                return getErrorResponse(PortalConstants.ERROR_MESSAGE);
            }    
            Map<String,Object> fields = new Map<String,Object>();
            //fields.put('applicationId',appln.Id);
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