global class PortalPartyDeleteAPI implements clcommon.PortalCustomRemoteAPI1{

    global clcommon.Response invokeAction(String componentStrName,
            String[] disclosureNames,
            Map<String, Object> argumentsFromPortal) {
        
        
        // Init parameter.
        SavePoint dbSavePoint = Database.setSavepoint();
        clcommon.Response response = new clcommon.Response();
        String applicationId = (String)argumentsFromPortal.get('applicationId');
        String contactId = (String)argumentsFromPortal.get('contactId');
        try {
            List<clcommon__Party__c> partyToBeDeleted = [Select Id,
                                                             clcommon__Contact__c,
                                                             clcommon__Account__c
                                                             From clcommon__Party__c
                                                             Where genesis__Application__c = :applicationId
                                                             AND clcommon__Contact__c = :contactId limit 1];
                
                if(partyToBeDeleted != null && partyToBeDeleted.size() > 0){
                    PartyUtil pUtil = new PartyUtil(partyToBeDeleted[0].Id);
                    pUtil.deleteParty();
                }
                genesis__Applications__c appln = [Select Id,
                                                  Portal_Stage__c,
                                                  Portal_Sub_Stage__c
                                                  From genesis__Applications__c 
                                                  Where Id = :applicationId] ;
                
                appln.Portal_Stage__c = (String)argumentsFromPortal.get('portalStage');
                appln.Portal_Sub_Stage__c = (String)argumentsFromPortal.get('portalSubstage');
                update appln;
                
                response.status = clcommon.Constants.SUCCESS;
        } catch (Exception e) {
            system.debug(e.getMessage() + '---'+e.getStackTraceString());
            Database.rollback(dbSavePoint);
            return getErrorResponse(PortalConstants.ERROR_MESSAGE);
            
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