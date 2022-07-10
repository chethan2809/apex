global without sharing class GetDocumentCategoryPortalAPI implements clcommon.PortalCustomRemoteAPI1{
    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> params) {
        clcommon.Response res;
        try{
            String applicationId = String.valueOf(params.get('appId'));
            genesis__applications__c app = PortalUtility.fetchApplication(applicationId);
            system.debug('fetch applications - '+app);
            String partyType = String.valueOf(params.get('party'));
            if(app<>null){
                res = setSuccessResponse(app, partyType);
            }else {
                res = setSuccessResponse(new genesis__applications__c(), partyType);
            }                                  
        } catch(Exception e) {                                                                  
            res = PortalUtility.setResponse(clcommon.Constants.ERROR, clcommon.Constants.API_EXCEPTION, 'ERROR_MESSAGE_SOMETHING_WENT_WRONG');
        } 
        return res;
    }
    
    private clcommon.Response setSuccessResponse(genesis__Applications__c app, String PartyType){
        clcommon.Response res = new clcommon.Response();
        List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
        
        List<clcommon__Party__c> partyList = [SELECT Id,
                                                     clcommon__Account__c,
                                                     genesis__Application__c,
                                                     clcommon__Contact__c,
                                                     clcommon__Type__r.Name,
                                                     genesis__Party_Name__c 
                                                FROM clcommon__Party__c
                                               WHERE genesis__Application__c =: app.Id
                                                 AND clcommon__Type__r.Name =: partyType];
        List<Map<String,Object>> docList;
        docList =PortalUtility.fetchUploadedDocuments(app, partyList[0].genesis__Party_Name__c);
        
        if(docList<>null && !docList.isEmpty()){
            for(Map<String,Object> doc : docList){
                doc.put('accountId',app.genesis__account__c);
                respList.add(new clcommon.PortalCustomRemoteActionRecord(doc));
            }
        }else{
            Map<String,Object> doc = new Map<String,Object>();
            doc.put('accountId',app.genesis__account__c);
            respList.add(new clcommon.PortalCustomRemoteActionRecord(doc));   
        }            
        system.debug('resplist 2'+respList);
        res = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
        system.debug('res '+res);
        res.status = clcommon.Constants.SUCCESS;
        return res;
    }
}