global class CLSBPBusinessInfoAPI implements clcommon.PortalCustomRemoteAPI1 {
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames,Map<String, Object> argumentsFromPortal) {
        // Init parameter.
        SavePoint dbSavePoint = Database.setSavepoint();
        clcommon.Response response = new clcommon.Response();
        
        system.debug('--argumentsFromPortal--'+argumentsFromPortal);
        Map<String,Object> fields = new Map<String,Object>();
        genesis__applications__c app = new genesis__applications__c();                                     
        try {
            //Check object/fields access permission
            if (false == Schema.getGlobalDescribe().get(getNamespaceForObjectName()+'Applications__c').getDescribe().isCreateable()) {
                return CLSBPUtil.getErrorResponse(CLSBPPortalConstants.UNAUTHORIZED_ACTION);
            }
            
            Map<String,Object> businessInfoMap = new Map<String,Object>();
            
            String appId = (String)argumentsFromPortal.get(CLSBPPortalConstants.APPLICATION_ID);
            Boolean isValidApplication;
            if(appId != null){
                isValidApplication = CLSPBPortalSecurity.validApplication(appId);
                if(isValidApplication){
                    if(argumentsFromPortal.containsKey(CLSBPPortalConstants.CLIENT_TYPE)){
                        app = [SELECT Id,Name, genesis__account__c,genesis__Contact__c,(SELECT Id,Name,clcommon__Account__c, clcommon__Contact__c FROM genesis__Parties__r WHERE clcommon__Type__r.Name = 'BORROWER' ) from genesis__applications__c where Id =:appId];
                        clcommon__party__c party = app.genesis__Parties__r;
                        Account account = new Account();
                        Contact contact = new Contact(); 
                        String clientType = (String)argumentsFromPortal.get(CLSBPPortalConstants.CLIENT_TYPE);
                        if(clientType.equals(CLSBPPortalConstants.BUSINESS)){
                            
                            if(argumentsFromPortal.get(CLSBPPortalConstants.BI_BASIC_INFO) != null){
                                Map<String, Object> basicInfo = (Map<String, Object>)JSON.deserializeUntyped((String)argumentsFromPortal.get(CLSBPPortalConstants.BI_BASIC_INFO));
                                businessInfoMap.putAll(basicInfo);
                            }
                            if(argumentsFromPortal.get(CLSBPPortalConstants.BI_BINNING_ADDRESS)!=null){
                                Map<String, Object> billingAddress = (Map<String, Object>)JSON.deserializeUntyped((String)argumentsFromPortal.get(CLSBPPortalConstants.BI_BINNING_ADDRESS));
                                businessInfoMap.putAll(billingAddress);
                            }
                            if(argumentsFromPortal.get(CLSBPPortalConstants.BI_MAILING_ADDRESS)!=null){
                                Map<String, Object> mailingAddress = (Map<String, Object>)JSON.deserializeUntyped((String)argumentsFromPortal.get(CLSBPPortalConstants.BI_MAILING_ADDRESS));
                                businessInfoMap.putAll(mailingAddress);
                            }
                            if(argumentsFromPortal.get(CLSBPPortalConstants.BI_ESTD_DETAILS)!=null){
                                Map<String, Object> otherDetails = (Map<String, Object>)JSON.deserializeUntyped((String)argumentsFromPortal.get(CLSBPPortalConstants.BI_ESTD_DETAILS));
                                businessInfoMap.putAll(otherDetails);
                            }
                            string jsonstring = JSON.serialize(businessInfoMap);
                            account = (Account)JSON.deserialize(jsonstring,Account.class);
                            account.Id = app.genesis__account__c ;
                            system.debug('--Account--'+account);
                            
                            if(account != null){
                                update account;
                            }
                            party.clcommon__Account__c = account.Id;
                            party.clcommon__Contact__c = null;
                            fields.put('clientType',CLSBPPortalConstants.BUSINESS);
                            fields.put('AccountId',account.Id);
                            response.status = clcommon.Constants.SUCCESS;
                        }       
                        else if(clientType.equals(CLSBPPortalConstants.INDIVIDUAL)){                           
                            
                            if(argumentsFromPortal.get(CLSBPPortalConstants.IND_ACC_DETAILS)!=null){
                                contact = (Contact)JSON.deserialize((String)argumentsFromPortal.get(CLSBPPortalConstants.IND_ACC_DETAILS),Contact.class);                        
                            }                           
                            
                            account.Name = contact.FirstName + ' ' + contact.LastName;
                            account.Id = app.genesis__account__c;
                            update account;
                            
                            
                            contact.AccountId = account.Id;
                            
                            if(contact.id != null){								
                                update contact;
                            }else{
                                insert contact;
                            }
                            party.clcommon__Account__c = account.Id;
                            party.clcommon__Contact__c = contact.Id;
                            fields.put('clientType',CLSBPPortalConstants.INDIVIDUAL);
                            fields.put('AccountId',account.Id);
                            fields.put('ContactId',contact.Id);
                            response.status = clcommon.Constants.SUCCESS;                       						
                        }
                        update party;
                    }
                }else{
                    return CLSBPUtil.getErrorResponse(CLSBPPortalConstants.UNAUTHORIZED_ACTION);
                }
            }else{
                return CLSBPUtil.getErrorResponse(CLSBPPortalConstants.APP_ID_IS_NULL);
            }
        } catch (Exception e) {
            system.debug(e.getMessage() + '---'+e.getStackTraceString());
            Database.rollback(dbSavePoint);
            response = CLSBPUtil.getErrorResponse(CLSBPPortalConstants.SOMETHING_WENT_WRONG);
            return response;
        }
        
        fields.put('applicationId',app.Id);
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