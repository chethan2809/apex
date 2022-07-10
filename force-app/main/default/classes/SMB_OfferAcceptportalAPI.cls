global without sharing class SMB_OfferAcceptportalAPI implements clcommon.PortalCustomRemoteAPI1{
    
    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> params) {
        clcommon.Response res;
        String appId;
        genesis__applications__c app = new genesis__applications__c();
        try{
            if(params != null){
                system.debug('--params--'+params );
                System.debug(params);
                appId = (String)params.get('applicationId');
                app.id=appId;
                String SelectedOfferId = (String) params.get('SelectedPaymentPlan');
                //SelectedOfferId = 'a5h0m000003VtPR';   
                if(appId != null){
                    res = setSuccessResponse(app,SelectedOfferId);
                } else {
                    res = PortalUtility.setResponse(clcommon.Constants.ERROR, clcommon.Constants.API_EXCEPTION, 'Contract not found');
                }                                
            } else {
                String errorMessage = PortalConstants.ERROR_MESSAGE_PARAM_NOT_FOUND;
                res = PortalUtility.setResponse(clcommon.Constants.ERROR, clcommon.Constants.API_EXCEPTION, errorMessage);
            }
        } catch(Exception e) {   
            res = PortalUtility.setResponse(clcommon.Constants.ERROR, clcommon.Constants.API_EXCEPTION, PortalConstants.ERROR_MESSAGE);
        }
        return res;
    }
    private clcommon.Response setSuccessResponse(genesis__applications__c app, String SelectedOfferId){
        clcommon.Response res = new clcommon.Response();
        List<genesis__Application_Pricing_Detail__c> AllPricingList = [SELECT id, Name, genesis__Application__c, genesis__Selected__c, genesis__Term__c,genesis__Payment_Amount_Per_Period__c 
                                                                       FROM genesis__Application_Pricing_Detail__c
                                                                       WHERE genesis__Application__c= :app.Id];
        
        for(genesis__Application_Pricing_Detail__c pL : AllPricingList ){
            pL.genesis__Selected__c = false;
        }
        update AllPricingList;
        List<genesis__Application_Pricing_Detail__c> SelectPricingList = [SELECT id, Name, genesis__Application__c, genesis__Selected__c, genesis__Term__c,genesis__Payment_Amount_Per_Period__c 
                                                                          FROM genesis__Application_Pricing_Detail__c
                                                                          WHERE Id= :SelectedOfferId  limit 1];
        
        genesis__Application_Pricing_Detail__c selectedOffer = SelectPricingList[0];                                               
        if(selectedOffer<>null){
            selectedOffer.genesis__Selected__c=true;
            update selectedOffer;
        }
        
        app.portal_stage__c = 'DocusignPage' ;         
        update app ;                                                          
        
        //genesis__applications__c refApp = [select id,portal_stage__c from genesis__applications__c where Id = :app.Id];
        
        Map<String,Object> fields = createResponseMap(app );
        
        List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
        respList.add(new clcommon.PortalCustomRemoteActionRecord(PortalConstants.KEY_RESPONSE, fields));
        res = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
        res.status = clcommon.Constants.SUCCESS;
        return res;
    }
    
    private Map<String,Object> createResponseMap(genesis__Applications__c app){
        Map<String,Object> fields = new Map<String,Object>();
        if(app.Portal_Stage__c != null){
            fields.put(PortalConstants.PORTALSTAGE, app.Portal_Stage__c);
        }
        system.debug('--fields--'+fields);
        return fields;
    }
}