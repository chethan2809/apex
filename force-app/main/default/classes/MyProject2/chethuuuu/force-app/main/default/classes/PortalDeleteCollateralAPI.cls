global class PortalDeleteCollateralAPI implements clcommon.PortalCustomRemoteAPI1 {

    /**
     * A portal API to delete the collateral.
     * This API expects to get the stringified applicationId and collateral list from portal.
     * @param componentStrName no need for this API. Can leave it as a empty string ""
     * @param disclosureNames no need for this API. Can leave it as a null value.
     * @param argumentsFromPortal Should have the corresponding parameter name in order to update application.

     * All the values in argumentsFromPortal are stringified JSON .
     * This api will extract applicationId by using defined values as the keys from the argumentsFromPortal (Map<String,Object>).
     * Example: given the below parameters from the argumentsFromPortal (Map<String,Object>).
     *
     * @return Response.
     
     **/

    global clcommon.Response invokeAction(String componentStrName,
            String[] disclosureNames,
            Map<String, Object> argumentsFromPortal) {
        
        
        clcommon.Response response = new clcommon.Response();
        genesis__Applications__c app = new genesis__Applications__c();
        String applicationId = (Id)argumentsFromPortal.get(CustomConstants.APPLICATION_ID);
        system.debug('--applicationId--'+applicationId);
        system.debug('--Collaterals--'+argumentsFromPortal.get('collaterals'));
        try {
            genesis__Application_Collateral__c portalAppCollateral;
            portalAppCollateral = (genesis__Application_Collateral__c)JSON.deserialize((String)argumentsFromPortal.get('collaterals'),genesis__Application_Collateral__c.class);
                                                                             
            List<clcommon__Collateral__c> collateralToBeDeletedList = [Select Id
                                                                         From clcommon__Collateral__c
                                                                        Where Id =:portalAppCollateral.genesis__Collateral__r.Id];   
            
            List<clcommon__Collateral_Location__c> collateralLocationToBeDeletedList = [Select Id
                                                                         From clcommon__Collateral_Location__c
                                                                        Where clcommon__Collateral__c =:portalAppCollateral.genesis__Collateral__r.Id]; 
            
			List<clcommon__Document_Category__c> docCategoriesToBeDeleted = [SELECT Id 
                                                                               from clcommon__Document_Category__c 
                                                                              where clcommon__Collateral__c =:portalAppCollateral.genesis__Collateral__r.Id
                                                                                AND genesis__Application__c = :applicationId];
            
            system.debug('-- collateralToBeDeletedList--'+collateralToBeDeletedList);                                                                                                                   
            if(portalAppCollateral != null){
                delete portalAppCollateral;
            }
            
            if(collateralToBeDeletedList != null && collateralToBeDeletedList.size() > 0){
                delete collateralToBeDeletedList;
            }
            
            if(collateralLocationToBeDeletedList != null && collateralLocationToBeDeletedList.size() > 0){
                delete collateralLocationToBeDeletedList;
            }
            
            if(docCategoriesToBeDeleted != null && docCategoriesToBeDeleted.size() > 0){
                delete docCategoriesToBeDeleted;
            }
            
            system.debug(LoggingLevel.Error,'--appl--'+app);
            response.status = clcommon.Constants.SUCCESS;
        } catch (Exception e) {
            system.debug(e.getMessage() + '---'+e.getStackTraceString());
            response = getErrorResponse('Something went wrong');
            return response;
        }
        Map<String,Object> fields = new Map<String,Object>();
        fields.put('applicationId',app.Id);
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