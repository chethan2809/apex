global class PortalCreateApplicationAPI implements clcommon.PortalCustomRemoteAPI1 {

    global clcommon.Response invokeAction(String componentStrName,
            String[] disclosureNames,
            Map<String, Object> argumentsFromPortal) {
        
        
        // Init parameter.
        SavePoint dbSavePoint = Database.setSavepoint();
        clcommon.Response response = new clcommon.Response();
        genesis__Applications__c app = new genesis__Applications__c();
            
        system.debug('--argumentsFromPortal--'+argumentsFromPortal);
        try {
            //Check object/fields access permission
            if (false == Schema.getGlobalDescribe().get(getNamespaceForObjectName()+'Applications__c').getDescribe().isCreateable()) {
                return getErrorResponse('UNAUTHORIZED_ACTION');
            }
              
            String loggedInUserId = UserInfo.getUserId();
            //query user
            List<User> loggedInUser = [Select Id,
                                              AccountId,
                                             UserType,
                                              ContactId
                                         From User
                                        Where Id = :loggedInUserId
                                        Limit 1]; 
                                        
            Map<String,Object> sObjectToFieldsMaps = new Map<String,Object>();
            Map<String,sobject> relatedObjs =  new map<String,sobject>();
            Map<String,List<SObject>> childObjects =  new Map<String,List<SObject>>();
            Map<String, Object> loanInfo = (Map<String, Object>)JSON.deserializeUntyped((String)argumentsFromPortal.get('loanInfo')); 
            sObjectToFieldsMaps.put('application',loanInfo);
            Map<String,Object> oldMap = (Map<String,Object>)sObjectToFieldsMaps.get('application');
            if(argumentsFromPortal.get('autoDebitInfo') != null){
                Map<String, Object> autoDebitInfo = (Map<String, Object>)JSON.deserializeUntyped((String)argumentsFromPortal.get('autoDebitInfo'));
                oldMap.putAll(autoDebitInfo);
            }
            string jsonstring = JSON.serialize(sObjectToFieldsMaps.get('application'));
            
            app = (genesis__Applications__c)JSON.deserialize(jsonstring,genesis__Applications__c.class);
            system.debug('--app--'+app);
            
            app.Portal_Stage__c = (String)argumentsFromPortal.get('portalStage');
            app.Portal_Sub_Stage__c = (String)argumentsFromPortal.get('portalSubstage');
            genesis.BorrowerAPI4 bApi = genesis.APIFactory.getBorrowerAPI4(); 
            if(app.Id != null){
                app = bApi.updateApplication(app, relatedObjs, childObjects);
            }else{ 
                app.genesis__Product_Type__c = genesis.LendingConstants.LOAN;
                app.genesis__Account__c = loggedInUser[0].AccountId;
                //app.genesis__Contact__c = loggedInUser[0].ContactId;
                app.genesis__Term__c =  0;
                app.genesis__Interest_Rate__c = 0;
                app.Is_Portal_Application__c = true;
            	app = bApi.createApplication(app, relatedObjs, childObjects); 
            }
            system.debug(LoggingLevel.Error,'--appl--'+app);
            
            /*For business accounts logged in user details to be saved are coborrower So changing the party type to Cosigner.
            List<String> businessProducts = new List<String>{'Business Credit Card','CREDIT LINE','REAL ESTATE (TERM) - FIXED','TERM LOAN FIXED'};
            if(businessProducts.contains(app.genesis__CL_Product_Name__c)){
                clcommon__Party_Type__c coBorrowerPartyType = [SELECT Id FROM clcommon__Party_Type__c WHERE Name ='CO-BORROWER'];
                List<clcommon__Party__c> party = [SELECT Id,clcommon__Type__r.Name FROM clcommon__Party__c where genesis__Application__c =:app.Id AND clcommon__Type__r.Name = 'BORROWER' AND clcommon__Contact__c != null];
                if(party != null && party.size() > 0){
                    party[0].clcommon__Type__r.Name = coBorrowerPartyType.Id;
                    update party;
                }
            }*/
            
            response.status = clcommon.Constants.SUCCESS;
        } catch (Exception e) {
            system.debug(e.getMessage() + '---'+e.getStackTraceString());
            Database.rollback(dbSavePoint);
            response = getErrorResponse('Something went wrong.');
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