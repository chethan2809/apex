global class PortalGenericSaveAPI implements clcommon.PortalCustomRemoteAPI1 {
    
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
                    'coladdress' => 'clcommon__Collateral_Location__c',
                    'asset' => 'genesis__Income__c',
                    'liability' => 'genesis__Liability__c',
                    'income' => 'genesis__Income__c',
                    'expense' => 'genesis__Liability__c',
                    'employment' => 'genesis__Employment_Information__c',
                    'borrowerParty' => 'clcommon__Party__c',
                    'borrowerDisclosure' => 'clcommon__Disclosure_Acknowledgement__c',
                    'colOwnership' => 'clcommon__Collateral_Owner__c'
                    };
         
            Type t = Type.forName(portalArgMapKeyToSobjectNameMap.get((String)argumentsFromPortal.get('objectName')));
            SObject sobj = (SObject) JSON.deserialize((String)argumentsFromPortal.get('objectData'), t);
            System.debug('=sobj='+sobj);
            UPSERT  sobj;
            
            Map<String,String> objectIdMap = new Map<String,String>();                                      
            objectIdMap.put('objectId',sobj.Id);       
            
            List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
            respList.add(new clcommon.PortalCustomRemoteActionRecord('KEY_RESPONSE',objectIdMap));
            response = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
            response.status = clcommon.Constants.SUCCESS;
        } catch (Exception e) {
            response = PortalUtility.getErrorResponse('Something went wrong.'+e.getLineNumber() + e.getMessage() + '---'+e.getStackTraceString());
            return response;
        }
        return response;
    }

    @TestVisible
    private String getNamespaceForObjectName(){
        //needs to be rectified
        //String namespace = PortalApplicationAPIV2.class.getName().substringBefore('PortalApplicationAPIV2').substringBefore('.');
        String namespace = 'genesis';
        if(String.isEmpty(namespace)){
            return '';
        }else{
            return namespace+'__';
        }
    }
}