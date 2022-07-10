global class CLSBPCollateralInfoAPI implements clcommon.PortalCustomRemoteAPI1{
    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> argumentsFromPortal) {
        
        // Init parameter.
        SavePoint dbSavePoint = Database.setSavepoint();
        clcommon.Response response = new clcommon.Response();
        
        system.debug('--argumentsFromPortal--'+argumentsFromPortal);
		Map<String,Object> fields = new Map<String,Object>();        
        try{
            //Check object/fields access permission
                if (false == Schema.getGlobalDescribe().get(getNamespaceForObjectName()+'Applications__c').getDescribe().isCreateable()) {
                    return CLSBPUtil.getErrorResponse('UNAUTHORIZED_ACTION');
                }
                
                if (false == Schema.getGlobalDescribe().get('clcommon__Collateral__c').getDescribe().isCreateable()) {
                    return CLSBPUtil.getErrorResponse('Label.UNAUTHORIZED_ACTION');
                }
                
                if (false == Schema.getGlobalDescribe().get('genesis__Application_Collateral__c').getDescribe().isCreateable()) {
                    return CLSBPUtil.getErrorResponse('Label.UNAUTHORIZED_ACTION');
                }
            String appId = (String)argumentsFromPortal.get(CLSBPPortalConstants.APPLICATION_ID); 
            Boolean isValidApplication;
            if(appId != null){
                isValidApplication = CLSPBPortalSecurity.validApplication(appId);
                if(isValidApplication){
                    clcommon__Collateral__c collateral = new clcommon__Collateral__c();
                    clcommon__Collateral_location__c collateralLocation = new clcommon__Collateral_location__c();
                    if(argumentsFromPortal.containsKey(CLSBPPortalConstants.COLLATERAL_TYPES)){
                        String collateralTypes = (String)argumentsFromPortal.get(CLSBPPortalConstants.COLLATERAL_TYPES);
                        if(collateralTypes.equals(CLSBPPortalConstants.ADD_COLLATERALS)){
                            
                            Map<String,Object> addressMap = new Map<String,Object>();
                            Map<String,Object> collateralMap = new Map<String,Object>();
                            if(argumentsFromPortal.containsKey('CLXBrokerAddCollateralAddress') && argumentsFromPortal.get('CLXBrokerAddCollateralAddress') != null){
                                collateralLocation  = (clcommon__Collateral_location__c)JSON.deserialize((String)argumentsFromPortal.get('CLXBrokerAddCollateralAddress'),clcommon__Collateral_location__c.class);                                              
                            }
                            
                            if(argumentsFromPortal.containsKey('CLXBrokerAddCollateralDetails') && argumentsFromPortal.get('CLXBrokerAddCollateralDetails') != null){
                                collateral  = (clcommon__Collateral__c)JSON.deserialize((String)argumentsFromPortal.get('CLXBrokerAddCollateralDetails'),clcommon__Collateral__c.class);                                      
                            }
                            //string jsonstring = JSON.serialize(collateralMap);
                            //collateral = (clcommon__Collateral__c)JSON.deserialize(jsonstring,clcommon__Collateral__c.class);
                            collateral.genesis__Application__c = appId;
                            if(collateral.Id !=null)
                            {
                                update collateral;
                            }
                            else{
                                insert collateral;
                            }
                            
                            if(collateralLocation.clcommon__Collateral__c == null){
                            collateralLocation.clcommon__Collateral__c = collateral.Id;
                                
                            }
                            if(collateralLocation.id != null){
                                update collateralLocation;
                            }else{
                                insert collateralLocation;
                            }
                            
                            
                            fields.put('collateralId',collateral.Id);
                            response.status = clcommon.Constants.SUCCESS;
                        }
                        else if(collateralTypes.equals(CLSBPPortalConstants.ADD_OWNER)){
                            clcommon__Collateral_Owner__c collateralOwnerMap = new clcommon__Collateral_Owner__c();
                            if(argumentsFromPortal.containsKey('CLXBrokerCollateralOwnershipDetails') && argumentsFromPortal.get('CLXBrokerCollateralOwnershipDetails') != null){
                                collateralOwnerMap  = (clcommon__Collateral_Owner__c)JSON.deserialize((String)argumentsFromPortal.get('CLXBrokerCollateralOwnershipDetails'),clcommon__Collateral_Owner__c.class);                                               
                            }
                            String collateralId = (String)argumentsFromPortal.get('collateralId');
                            List<clcommon__Collateral_Owner__c> existingOwnerList = [SELECT Id,Name,clcommon__Account__c FROM clcommon__Collateral_Owner__c WHERE clcommon__Collateral__c =:collateralId];
                            if(existingOwnerList != null && existingOwnerList.size() > 0){
                                for(clcommon__Collateral_Owner__c owner:existingOwnerList){
                                    if(owner.clcommon__Account__c.equals(collateralOwnerMap.clcommon__Account__c)){
                                        if((collateralOwnerMap.id != null  && !owner.Id.equals(collateralOwnerMap.Id)) || collateralOwnerMap.id == null){ 
                                            return CLSBPUtil.getErrorResponse('Selected party is already an owner of the collateral');
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
                    }
                }
                else{
                    return CLSBPUtil.getErrorResponse(CLSBPPortalConstants.UNAUTHORIZED_ACTION);
                }
            }else{
                return CLSBPUtil.getErrorResponse(CLSBPPortalConstants.APP_ID_IS_NULL);
            }                 
        }catch (Exception e) {
            system.debug(e.getMessage() + '---'+e.getStackTraceString());
            Database.rollback(dbSavePoint);
            response = CLSBPUtil.getErrorResponse('Something went wrong.');
            return response;
        }
         List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
        respList.add(new clcommon.PortalCustomRemoteActionRecord('KEY_RESPONSE', fields));
        response = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
        return response;
    }
    private String getNamespaceForObjectName(){
        String namespace = 'genesis';
        if(String.isEmpty(namespace)){
            return '';
        }else{
            return namespace+'__';
        }
    }
}