global class SMB_PortalPartyAPI implements clcommon.PortalCustomRemoteAPI1 {
    
    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> params) {
        
        clcommon.Response res;
        try{
            system.debug('--params1--'+params );
            if(params != null){
                system.debug('--params--'+params );
                res = setSuccessResponse(params);     
            }else 
            {
                String errorMessage = PortalConstants.ERROR_MESSAGE_PARAM_NOT_FOUND;
                res = PortalUtility.setResponse(clcommon.Constants.ERROR, clcommon.Constants.API_EXCEPTION, errorMessage);
            }  
        }catch(Exception e){                                                                  
            clcommon__Log__c comLog = new clcommon__Log__c(clcommon__Message__c = 'SMB Portal Error: '+e.getMessage()+
                                                           ' at line: '+e.getLineNumber(),
                                                           clcommon__Time__c = System.now());
            Insert comLog; 
            res = PortalUtility.setResponse(clcommon.Constants.ERROR, clcommon.Constants.API_EXCEPTION,PortalConstants.ERROR_MESSAGE  );
        }
        return res;
    }
    
    private clcommon.Response setSuccessResponse(Map<String,Object> params){
        clcommon.Response res = new clcommon.Response();
        
        String firstName = String.valueOf(params.get('firstName'));
        String lastName = String.valueOf(params.get('lastName'));
        String partyType = String.valueOf(params.get('partyType'));
        String email = String.valueOf(params.get('email'));
        String applicationId =  String.valueOf(params.get('applicationId'));
        system.debug('---applicationId---'+applicationId);
        
        List<clcommon__Legal_Entity__c> legalEntityType = [Select Id,name from clcommon__Legal_Entity__c
                                                           Where name='Individual'];
        
        List<Contact> existingContact= [Select Id,AccountId from Contact where FirstName=:firstName and LastName=:lastName and Email=:email];
        System.debug('--ExistingContact---'+existingContact); 
        
        
        clcommon__Party__c party = new clcommon__Party__c();
        
        if(existingContact==null || existingContact.size()<=0){
            //New Account creation
            Account acc = new Account();
            acc.name = firstName+lastName;
            acc.clcommon__Legal_Entity_type__c =legalEntityType[0].Id;
            insert acc;
            System.debug('--account inserted--');
            //New Account creation
            Contact con = new Contact();
            con.FirstName = firstName;
            con.LastName = lastName;
            con.Email = email;
            con.AccountId =acc.Id;
            con.clcommon__Legal_Entity_type__c =legalEntityType[0].Id;
            insert con;
            System.debug('--contact inserted--');
            party.clcommon__Account__c = con.AccountId;
            party.clcommon__Contact__c = con.id;
            party.genesis__Application__c = applicationId;
           
            party.clcommon__Type__c = partyType;
            insert party;
        } else {
            party.clcommon__Account__c = existingContact[0].AccountId;
            party.clcommon__Contact__c = existingContact[0].id;
            List<clcommon__Party__c> existingParty= [Select Id,name from clcommon__Party__c where genesis__Application__c=:applicationId and 
                                                     clcommon__Account__c=:existingContact[0].AccountId and clcommon__contact__c=:existingContact[0].id];
            System.debug('--existingParty---'+existingParty);
            party.genesis__Application__c = applicationId;
            
            party.clcommon__Type__c = partyType;
            if(existingParty==null || existingParty.size()<=0) {
                insert party;
            }    
        }
        List<Contact> contact = [SELECT Id,name from contact where email = :email];        
        List<EmailTemplate> lstEmailTemplates = [SELECT Id, Body, Subject from EmailTemplate where DeveloperName = 'SMB_Email'];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(lstEmailTemplates[0].Id);
        mail.setSaveAsActivity(false);
        //mail.setTargetObjectId('0036g000002URX0AAO');// Any contact or User id of your record
        mail.setTargetObjectId(contact[0].id);
        List<String> PartyList = new List<String>();
        PartyList.add(email);
        System.debug('----PartyList--'+PartyList);
        mail.setToAddresses(PartyList);
        Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        res.status = clcommon.Constants.SUCCESS;
        return res;
    }
}