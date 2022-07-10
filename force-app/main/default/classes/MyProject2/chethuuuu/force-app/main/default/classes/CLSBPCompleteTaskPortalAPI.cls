global class CLSBPCompleteTaskPortalAPI implements clcommon.PortalCustomRemoteAPI1 {
	global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> argumentsFromPortal) {            
            
            // Init parameter.
            SavePoint dbSavePoint = Database.setSavepoint();
            clcommon.Response response = new clcommon.Response();
            Task taskRec = new Task();
            String applicationId = (String)argumentsFromPortal.get(CLSBPPortalConstants.APPLICATION_ID);
            String taskId = (String)argumentsFromPortal.get(CLSBPPortalConstants.TASK_ID);
            Boolean isValidApp = CLSPBPortalSecurity.validApplication(applicationId);
            if(isValidApp){
                try {

                    if(argumentsFromPortal.containsKey(CLSBPPortalConstants.TASK_ID)){
                        taskRec = [Select Id 
                                        FROM Task 
                                        WHERE genesis__Application__c = :applicationId 
                                        AND Id = :taskId 
                                        AND genesis__Department__c = null LIMIT 1];
                                
                        if(taskRec != null){
                            taskRec.Status = 'Completed';
                        }
                        else{
                            return CLSBPUtil.getErrorResponse('Invalid Task Id');
                        } 
                    }
                    
                    if(taskId != NULL)
                    UPDATE taskRec;
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
                return CLSBPUtil.getErrorResponse(PortalConstants.ERROR_MESSAGE);
            }    
            Map<String,Object> fields = new Map<String,Object>();
            List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
            respList.add(new clcommon.PortalCustomRemoteActionRecord('KEY_RESPONSE', fields));
            response = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
            return response;
        }
}