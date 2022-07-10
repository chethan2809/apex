/*
* This portal API is implemented when the borrower clicks continue on Customer_Applies_Approved portal page.
* File Name : CLS_OfferAcceptportalAPI
* Description : Offer Accept portal API recives the offer Id selected at the portal end and updates the same at the back end.
* @author : Anagha Gowda
* Version : 1.0
* Parameters : params - type Map<String, Object>
* Return Type : clcommon.Response 
*/
global without sharing class PortalSelectOfferAPI  implements clcommon.PortalCustomRemoteAPI1{
    /*
     * This function gets the Id of the offer selected at portla side sand updates the same at the back end.
     * It calls the getBankAccounts class to get all the recent bank account related to the appliction borrower.
     * Updates the Portal stage to - Customer closes Deal and returns the same.
     */
    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> argumentsFromPortal) {
        clcommon.Response res;
        genesis__Applications__c app;
        String applicationId = (String)argumentsFromPortal.get(CustomConstants.APPLICATION_ID);
        String selectedOfferId = (String)argumentsFromPortal.get('selectedOfferId');
        try{
            if(argumentsFromPortal != null){
            	app = [Select id,Name,Portal_Stage__c,
                      		  Portal_Sub_Stage__c
                        From genesis__Applications__c
                       Where id = :applicationId] ;
                
                app.Portal_Stage__c = (String)argumentsFromPortal.get('portalStage');
        		app.Portal_Sub_Stage__c = (String)argumentsFromPortal.get('portalSubstage');
                
                app = updatePricingdetails(app,selectedOfferId);
        
                update app ;
                
                Map<String,Object> fields = createResponseMap(app);
                
                List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
                respList.add(new clcommon.PortalCustomRemoteActionRecord(PortalConstants.KEY_RESPONSE, fields));
                res = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
                return res;
                 
            } 
        }catch(Exception e) { 
            
        }
        return res;
    }
    
    private Map<String,Object> createResponseMap(genesis__Applications__c app){
        Map<String,Object> fields = new Map<String,Object>();
        
        if(app.Portal_Stage__c != null){
            fields.put(PortalConstants.PORTALSTAGE, app.Portal_Stage__c);
        }
        return fields;
    }
    public static genesis__Applications__c  updatePricingdetails(genesis__Applications__c app, String SelectedOfferId){
        
        List<genesis__Application_Pricing_Detail__c> existingSelectedPricingList =  [SELECT id, 
                                                                                     Name, 
                                                                                     genesis__Application__c, 
                                                                                     genesis__Selected__c 
                                                                                     FROM genesis__Application_Pricing_Detail__c
                                                                                     WHERE genesis__Application__c =: app.Id 
                                                                                     AND genesis__Selected__c =: true];
        List<genesis__Application_Pricing_Detail__c> updateExistingSelectedPricingList = new List<genesis__Application_Pricing_Detail__c>();
        if(existingSelectedPricingList.size() != null && existingSelectedPricingList.size()>0){
            for(genesis__Application_Pricing_Detail__c pricing : existingSelectedPricingList){
                pricing.genesis__Selected__c = false;
                updateExistingSelectedPricingList.add(pricing);
            }
            update updateExistingSelectedPricingList;
        }
        List<genesis__Application_Pricing_Detail__c> newselectedPricingList = [SELECT id, 
                                                                               Name,
                                                                               genesis__Application__c, 
                                                                              // APR__c,
                                                                               genesis__Selected__c,
                                                                               //Estimated_Interest__c,
                                                                               genesis__Interest_Rate__c,
                                                                               genesis__Payment_Amount_Derived__c,
                                                                               genesis__Payment_Frequency__c,
                                                                               genesis__Term__c 
                                                                               FROM genesis__Application_Pricing_Detail__c
                                                                               WHERE genesis__Application__c =: App.Id 
                                                                               AND id =: SelectedOfferId];
        if(newselectedPricingList.size() != null && newselectedPricingList.size()>0){
            newselectedPricingList[0].genesis__Selected__c = true;
            update newselectedPricingList[0];
            //app.genesis__Total_Estimated_Interest__c = newselectedPricingList[0].Estimated_Interest__c;
            app.genesis__Interest_Rate__c = newselectedPricingList[0].genesis__Interest_Rate__c;
            app.genesis__Payment_Amount__c = newselectedPricingList[0].genesis__Payment_Amount_Derived__c;
            app.genesis__Payment_Frequency__c = newselectedPricingList[0].genesis__Payment_Frequency__c;
            app.genesis__Term__c =  newselectedPricingList[0].genesis__Term__c; 
            //app.genesis__APR__c = newselectedPricingList[0].APR__c;
            //app.APR_value__c = newselectedPricingList[0].APR__c;
        	
        }
        
        return app;
    }
}