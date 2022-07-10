global class CLSBPClientInfoAPI  implements clcommon.PortalCustomRemoteAPI1 {
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames,Map<String, Object> argumentsFromPortal) {
        // Init parameter.
        SavePoint dbSavePoint = Database.setSavepoint();
        clcommon.Response response = new clcommon.Response();
        
        system.debug('--argumentsFromPortal--'+argumentsFromPortal);
        Map<String,Object> fields = new Map<String,Object>();
        genesis__Applications__c app = new genesis__Applications__c();
        try {
            //Check object/fields access permission
            if (false == Schema.getGlobalDescribe().get(getNamespaceForObjectName()+'Applications__c').getDescribe().isCreateable()) {
                return CLSBPUtil.getErrorResponse(CLSBPPortalConstants.UNAUTHORIZED_ACTION);
            }
            
            Map<String,Object> businessInfoMap = new Map<String,Object>();
            
            if(argumentsFromPortal.containsKey(CLSBPPortalConstants.CLIENT_TYPE)){
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
                    system.debug('--Account--'+account);
                    
                    if(account.Id != null){
                        update account;
                    }else{
                        insert account;
                    }
                   
                    Map<String,sobject> relatedObjs =  new map<String,sobject>();
                    Map<String,List<SObject>> childObjects =  new Map<String,List<SObject>>();
                    Map<String, Object> loanInfo = (Map<String, Object>)JSON.deserializeUntyped((String)argumentsFromPortal.get(CLSBPPortalConstants.LOAN_INFO));
                    
                    app = (genesis__Applications__c)JSON.deserialize((String)argumentsFromPortal.get(CLSBPPortalConstants.LOAN_INFO),genesis__Applications__c.class);
                    app.genesis__Account__c = account.Id;
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
                    
                    fields.put('clientType',CLSBPPortalConstants.BUSINESS);
                    fields.put('AccountId',account.Id);
                    response.status = clcommon.Constants.SUCCESS;
                }       
                else if(clientType.equals(CLSBPPortalConstants.INDIVIDUAL)){                           
                    
                    if(argumentsFromPortal.get(CLSBPPortalConstants.IND_ACC_DETAILS)!=null){
                        contact = (Contact)JSON.deserialize((String)argumentsFromPortal.get(CLSBPPortalConstants.IND_ACC_DETAILS),Contact.class);                        
                    }                           
                    
                    account.Name = contact.FirstName + ' ' + contact.LastName;
                    insert account;
                    
                    
                    contact.AccountId = account.Id;
                    
                    if(contact.id != null){                             
                        update contact;
                    }else{
                        insert contact;
                    }
                    
                    Map<String,sobject> relatedObjs =  new map<String,sobject>();
                    Map<String,List<SObject>> childObjects =  new Map<String,List<SObject>>();
                    Map<String, Object> loanInfo = (Map<String, Object>)JSON.deserializeUntyped((String)argumentsFromPortal.get(CLSBPPortalConstants.LOAN_INFO));
                    
                    app = (genesis__Applications__c)JSON.deserialize((String)argumentsFromPortal.get(CLSBPPortalConstants.LOAN_INFO),genesis__Applications__c.class);
                    app.genesis__Account__c = account.Id;
                    app.genesis__Contact__c = contact.Id;
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
                    
                    fields.put('clientType',CLSBPPortalConstants.INDIVIDUAL);
                    fields.put('AccountId',account.Id);
                    fields.put('ContactId',contact.Id);
                    response.status = clcommon.Constants.SUCCESS;                                               
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
                List<clcommon__Party__c> partyList = [SELECT Name,Id,clcommon__Type__r.Name 
                                                      FROM clcommon__Party__c
                                                      WHERE clcommon__Type__r.Name = 'BROKER' AND genesis__Application__c=:app.Id limit 1];
                
                if(partyList != null && partyList.size() > 0){
                    //do nothing               
                }else{
                    List<clcommon__party_Type__c> partyType = [SELECT Name,Id 
                                                               FROM clcommon__party_Type__c
                                                               WHERE Name = 'BROKER' limit 1];
                    clcommon__Party__c party = new clcommon__Party__c();
                    party.clcommon__Account__c = loggedInUser[0].AccountId;
                    party.clcommon__Contact__c = loggedInUser[0].ContactId;
                    party.genesis__Application__c = app.Id;
                    party.clcommon__Type__c = partyType[0].Id;  
                    insert party;
                }
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