global class PortalCollateralAPI implements clcommon.PortalCustomRemoteAPI1 {

    /**
     * A portal wrapper to create a application collateral and collateral record.
     * This API expects to get the stringified collateral objects from portal
     * @param componentStrName no need for this API. Can leave it as a empty string ""
     * @param disclosureNames no need for this API. Can leave it as a null value.
     * @param argumentsFromPortal Should have the corresponding parameter name in order to create a new application.

     * All the values in argumentsFromPortal are stringified JSON .
     * This api will extract application and it's related objects and children by using defined values as the keys from the argumentsFromPortal (Map<String,Object>).
     * Example: given the below parameters from the argumentsFromPortal (Map<String,Object>).
     * It will create an application which associated with new Account and Contact.
     *
     * @return Response.
     
     **/

    global clcommon.Response invokeAction(String componentStrName,
            String[] disclosureNames,
            Map<String, Object> argumentsFromPortal) {
        System.debug(argumentsFromPortal);
        
        // Init parameter.
        SavePoint dbSavePoint = Database.setSavepoint();
        clcommon.Response response = new clcommon.Response();

        String applicationId = (String)argumentsFromPortal.get(CustomConstants.APPLICATION_ID);
        String appCollateralId;
        Map<String,Object> fields = new Map<String,Object>();
        try {
            Boolean isValidApp = PortalSecurityUtil.validateUserApplication(applicationId);  
            system.debug('--isValidApp--'+isValidApp);        
            if(isValidApp){
                
                //Check object/fields access permission
                if (false == Schema.getGlobalDescribe().get(getNamespaceForObjectName()+'Applications__c').getDescribe().isCreateable()) {
                    return getErrorResponse('UNAUTHORIZED_ACTION');
                }
                
                if (false == Schema.getGlobalDescribe().get('clcommon__Collateral__c').getDescribe().isCreateable()) {
                    return getErrorResponse('Label.UNAUTHORIZED_ACTION');
                }
                
                if (false == Schema.getGlobalDescribe().get('genesis__Application_Collateral__c').getDescribe().isCreateable()) {
                    return getErrorResponse('Label.UNAUTHORIZED_ACTION');
                }
                String action = (String)argumentsFromPortal.get('ActionType');
                
                if(action.equals('AddCollateral')){
                    // Prepare default params
                    Map<String, String> args = new Map<String, String>{
                        'applicationCollateralDetails' => 'clcommon__Collateral__c'
                            };
                                system.debug('--argumentsFromPortal--'+argumentsFromPortal);            
                    system.debug('--argumentsFromPortal.KeySet()--'+argumentsFromPortal.KeySet());
                    clcommon__Collateral__c collateral = new clcommon__Collateral__c();
                    
                    for(String paramKey : argumentsFromPortal.KeySet()) {
                        system.debug('--paramKey--'+paramKey);
                        if(argumentsFromPortal.get(paramKey) != null && args.get(paramKey) != null){
                            
                            Map<String, Object> appCollatralMap = (Map<String, Object>)JSON.deserializeUntyped((String)argumentsFromPortal.get(paramKey)); 
                            system.debug('--appCollatralMap--'+appCollatralMap);
                            
                            //string jsonstring = JSON.serialize(argumentsFromPortal.get(paramKey));
                            //system.debug('--jsonstring--'+jsonstring);
                            //Map<String, Object> appCollatralMap = (Map<String, Object>)JSON.deserializeUntyped(jsonstring);
                            //system.debug('--appCollatralMap--'+appCollatralMap);
                            if(appCollatralMap.get('id') != null){
                                appCollateralId = (String)appCollatralMap.get('id');
                                appCollatralMap.remove('id');
                            }
                            
                            String jsonstring = JSON.serialize(appCollatralMap);
                            system.debug('--jsonstring--'+ jsonstring );
                            jsonstring = jsonstring.replace('genesis__Collateral__r.','') ;  
                            Type t = Type.forName('clcommon__Collateral__c') ;
                            collateral = (clcommon__Collateral__c) JSON.deserialize(jsonstring, t);
                        }
                    }
                    
                    system.debug('--collateral--'+collateral); 
                    
                    
                    genesis__Applications__c appln = [Select Id,Name,
                                                      genesis__Contact__c,
                                                      Portal_Stage__c,
                                                      genesis__Loan_Amount__c,
                                                      Portal_Sub_Stage__c,
                                                      genesis__Contact__r.Id,
                                                      genesis__Account__c,
                                                      genesis__Account__r.Id,
                                                      genesis__Employee_Application__c
                                                      From genesis__Applications__c 
                                                      Where Id = :applicationId] ;
                    
                    appln.Portal_Stage__c = (String)argumentsFromPortal.get('portalStage');
                    appln.Portal_Sub_Stage__c = (String)argumentsFromPortal.get('portalSubstage');
                    
                    if(appCollateralId != null && collateral.Id != null){
                        //Update the collateral 
                        //collateral.genesis__Pledge_Amount__c = appln.genesis__Loan_Amount__c;
                        update collateral;   
                        
                    }else{
                        //Insert the collateral
                        insert collateral;
                        genesis__Application_Collateral__c appCollateral = new genesis__Application_Collateral__c();
                        appCollateral.genesis__Application__c = applicationId;
                        appCollateral.genesis__Collateral__c = collateral.Id;
                        appCollateral.genesis__Pledge_Amount__c = appln.genesis__Loan_Amount__c;
                        
                        insert appCollateral;
                        
                    }
                    
                    clcommon__Collateral_Location__c collateralLocation = (clcommon__Collateral_Location__c) JSON.deserialize((String)argumentsFromPortal.get('collateralLocation'), clcommon__Collateral_Location__c.class);
                    if(collateralLocation.clcommon__Collateral__c == null){
                         collateralLocation.clcommon__Collateral__c = collateral.Id;
                    }
                    if(collateralLocation.id != null){
                        update collateralLocation;
                    }else{
                        insert collateralLocation;
                    }
                   
                    update appln;
                    fields.put('collateralId',collateral.Id);
                    system.debug(LoggingLevel.Error,'--appl--'+appln );
                    
                    response.status = clcommon.Constants.SUCCESS;
                    
                }else if(action.equals('AddOwner')){
                    clcommon__Collateral_Owner__c collateralOwnerMap = new clcommon__Collateral_Owner__c();
                    if(argumentsFromPortal.containsKey('CollateralOwnershipDetails') && argumentsFromPortal.get('CollateralOwnershipDetails') != null){
                        collateralOwnerMap  = (clcommon__Collateral_Owner__c)JSON.deserialize((String)argumentsFromPortal.get('CollateralOwnershipDetails'),clcommon__Collateral_Owner__c.class);                                               
                    }
                    String collateralId = (String)argumentsFromPortal.get('collateralId');
                    List<clcommon__Collateral_Owner__c> existingOwnerList = [SELECT Id,Name,clcommon__Account__c FROM clcommon__Collateral_Owner__c WHERE clcommon__Collateral__c =:collateralId];
                    if(existingOwnerList != null && existingOwnerList.size() > 0){
                        for(clcommon__Collateral_Owner__c owner:existingOwnerList){
                            if(owner.clcommon__Account__c.equals(collateralOwnerMap.clcommon__Account__c)){
                                if((collateralOwnerMap.id != null  && !owner.Id.equals(collateralOwnerMap.Id)) || collateralOwnerMap.id == null){ 
                                    return getErrorResponse('Selected party is already an owner of the collateral');
                                }
                            }
                        }
                    }
                    collateralOwnerMap.clcommon__Collateral__c = collateralId;
                    if(collateralOwnerMap.Id !=null)
                    {
                        update collateralOwnerMap;
                    }
                    else{
                        insert collateralOwnerMap;
                    } 
                    fields.put('collateraOwnerlId',collateralOwnerMap.Id);
                    response.status = clcommon.Constants.SUCCESS;
                }
            }else{
                return getErrorResponse(PortalConstants.ERROR_MESSAGE);
            } 
        }catch (Exception e) {
            system.debug(e.getMessage() + '---'+e.getStackTraceString());
            Database.rollback(dbSavePoint);
            if(e.getMessage().equals(PortalConstants.SYSTEM_TIME_OUT)){
                return getErrorResponse(PortalConstants.SYSTEM_TIME_OUT);
            }else{
                return getErrorResponse(PortalConstants.ERROR_MESSAGE);
            }
        }
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

    private String getNamespaceForObjectName(){
        //String namespace = PortalApplicationAPIV2.class.getName().substringBefore('PortalApplicationAPIV2').substringBefore('.');
        String namespace = 'genesis';
        if(String.isEmpty(namespace)){
            return '';
        }else{
            return namespace+'__';
        }
    }
}