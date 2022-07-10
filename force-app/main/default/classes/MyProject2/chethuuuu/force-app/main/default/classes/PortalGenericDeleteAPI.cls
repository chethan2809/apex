global class PortalGenericDeleteAPI implements clcommon.PortalCustomRemoteAPI1 {
    
    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> argumentsFromPortal) {
        clcommon.Response response = new clcommon.Response();
        
        try {
            //Below check needs to be rectified and logged in user chek should also be put -Anurag 24/6
            //Check object/fields access permission
            /*if (false == Schema.getGlobalDescribe().get(getNamespaceForObjectName()+'Applications__c').getDescribe().isCreateable()) {
return getErrorResponse('UNAUTHORIZED_ACTION');
}*/
            
            
            Map<String, String> portalArgMapKeyToSobjectNameMap = new Map<String, String> {
                    'collateral' => 'clcommon__Collateral__c',
                    'appCollateral' => 'genesis__Application_Collateral__c',
                    'address' => 'clcommon__Address__c',
                    'asset' => 'genesis__Income__c',
                    'liability' => 'genesis__Liability__c',
                    'income' => 'genesis__Income__c',
                    'expense' => 'genesis__Liability__c',
                    'employment' => 'genesis__Employment_Information__c',
                    'party' => 'clcommon__Party__c',
                    'colOwnership' => 'clcommon__Collateral_Owner__c'
                    };
            
            if(((Id)argumentsFromPortal.get('objectId')) != null && ((String)argumentsFromPortal.get('objectName'))!= null && portalArgMapKeyToSobjectNameMap.containsKey((String)argumentsFromPortal.get('objectName'))){
                Database.delete((String)argumentsFromPortal.get('objectId'));
            }
           
            response.status = clcommon.Constants.SUCCESS;
        } catch (Exception e) {
            //response = PortalUtility.getErrorResponse('Something went wrong.'+e.getLineNumber() + e.getMessage() + '---'+e.getStackTraceString());
            response = PortalUtility.getErrorResponse('Something went wrong.');
            return response;
        }
        return response;
    }
    
}