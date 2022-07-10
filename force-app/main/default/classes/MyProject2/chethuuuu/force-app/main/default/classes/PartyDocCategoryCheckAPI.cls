global class PartyDocCategoryCheckAPI implements clcommon.PortalCustomRemoteAPI1{
	 global clcommon.Response invokeAction(String componentStrName,
            String[] disclosureNames,
            Map<String, Object> argumentsFromPortal) {
        
        // Init parameter.
        SavePoint dbSavePoint = Database.setSavepoint();
        clcommon.Response response = new clcommon.Response();

        String applicationId = (String)argumentsFromPortal.get(CustomConstants.APPLICATION_ID);
        
        List<clcommon__Party__c> partyList = [SELECT Id, Name,
                                              		 clcommon__Account__c, 
                                              		 genesis__Application__c,
                                              		 clcommon__Contact__c 
                                                FROM clcommon__Party__c 
                                               WHERE genesis__Application__c =: applicationId
                                              AND clcommon__Type__r.Name = :CustomConstants.COSIGNER]; 
        if(partyList != null && partyList.size()>0){
        	List<clcommon__Document_Category__c> docCategory = [SELECT Id,clcommon__Account__c,genesis__Application__c,clcommon__Active__c
                                                                  FROM clcommon__Document_Category__c
                                                                 WHERE clcommon__Account__c =: partyList[0].clcommon__Account__c
                                                                   AND genesis__Application__c =: applicationId
                                                                   AND clcommon__Parent_Document_Category__c != null
                                                                   AND clcommon__Active__c = true];
        	if(docCategory != null && docCategory.size()>0){
        		response.status = clcommon.Constants.SUCCESS;
        	}else{
            	response.status = clcommon.Constants.PENDING;
        	} 
        }
        Map<String,Object> fields = new Map<String,Object>();
        List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
        respList.add(new clcommon.PortalCustomRemoteActionRecord('KEY_RESPONSE', fields));
        response = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
        return response;
	}
}