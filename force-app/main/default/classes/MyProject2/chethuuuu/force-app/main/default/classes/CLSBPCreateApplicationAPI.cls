global class CLSBPCreateApplicationAPI implements clcommon.PortalCustomRemoteAPI1 {
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
                return CLSBPUtil.getErrorResponse(CLSBPPortalConstants.UNAUTHORIZED_ACTION);
            }
            
            
            Account acc = new Account();
            acc.Name = 'Broker Portal';
            insert acc;
            
            Map<String,sobject> relatedObjs =  new map<String,sobject>();
            Map<String,List<SObject>> childObjects =  new Map<String,List<SObject>>();
            Map<String, Object> loanInfo = (Map<String, Object>)JSON.deserializeUntyped((String)argumentsFromPortal.get(CLSBPPortalConstants.LOAN_INFO));
            
            app = (genesis__Applications__c)JSON.deserialize((String)argumentsFromPortal.get(CLSBPPortalConstants.LOAN_INFO),genesis__Applications__c.class);
            app.genesis__Account__c = acc.Id;
            app.genesis__Expected_Start_Date__c = system.today();
            app.genesis__Expected_First_Payment_Date__c = system.today();
            app.genesis__Due_Day__c = system.today().day();
            system.debug(LoggingLevel.Error,'--app--'+app);
            
            genesis.BorrowerAPI4 bApi = genesis.APIFactory.getBorrowerAPI4(); 
            if(app.Id != null){
                app = bApi.updateApplication(app, relatedObjs, childObjects);
            }else{ 
                app = bApi.createApplication(app, relatedObjs, childObjects); 
            }
            
            
            List<clcommon__party_Type__c> type = [SELECT Name,Id 
                                               FROM clcommon__party_Type__c
                                               WHERE Name = 'BORROWER' limit 1];
                    clcommon__Party__c party = new clcommon__Party__c();
                    party.clcommon__Account__c = acc.Id;
                    party.genesis__Application__c = app.Id;
                    if(type != null && type.size() > 0){
                        party.clcommon__Type__c = type[0].Id;
                    } 
                    insert party;
            response.status = clcommon.Constants.SUCCESS;
        } catch (Exception e) {
            system.debug(e.getMessage() + '---'+e.getStackTraceString());
            Database.rollback(dbSavePoint);
            response = CLSBPUtil.getErrorResponse(CLSBPPortalConstants.SOMETHING_WENT_WRONG);
            return response;
        }
        Map<String,Object> fields = new Map<String,Object>();
        fields.put(CLSBPPortalConstants.APPLICATION_ID,app.Id);
        List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
        respList.add(new clcommon.PortalCustomRemoteActionRecord('KEY_RESPONSE', fields));
        response = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
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