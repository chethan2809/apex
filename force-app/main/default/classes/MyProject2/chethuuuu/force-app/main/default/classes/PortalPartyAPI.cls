global class PortalPartyAPI implements clcommon.PortalCustomRemoteAPI1 {

    /**
     * A portal wrapper to create a party record.
     * This API expects to get the stringified contact,account and related objects from portal
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

    static final String APPLICATION_ID_PARAM_NAME = 'applicationId';
    static final String LEGAL_ENTITY_ID_PARAM_NAME = 'legalEntityId';
    static final String ACCOUNT_PARAM_NAME_FOR_SKUID = 'account';
    static final String PARTY_PARAM_NAME_FOR_SKUID = 'party';
    static final String BUSINESS_PARAM_NAME_FOR_SKUID = 'business';
    static final String CONTACT_PARAM_NAME_FOR_SKUID = 'contact';
    static final String COLLATERAL_PARAM_NAME_FOR_SKUID = 'collateralOwners';
    
    global clcommon.Response invokeAction(String componentStrName,
            String[] disclosureNames,
            Map<String, Object> argumentsFromPortal) {
        
        
        // Init parameter.
        SavePoint dbSavePoint = Database.setSavepoint();
        clcommon.Response response = new clcommon.Response();

        String applicationId = (String)argumentsFromPortal.get(CustomConstants.APPLICATION_ID);
        Map<String,Object> fields = new Map<String,Object>();
        try {
            //Check object/fields access permission
            if (false == Schema.getGlobalDescribe().get(getNamespaceForObjectName()+'Applications__c').getDescribe().isCreateable()) {
                return getErrorResponse('UNAUTHORIZED_ACTION');
            }

            if (false == Schema.getGlobalDescribe().get('Account').getDescribe().isCreateable()) {
                return getErrorResponse('Label.UNAUTHORIZED_ACTION');
            }

            if (false == Schema.getGlobalDescribe().get('Contact').getDescribe().isCreateable()) {
                return getErrorResponse('Label.UNAUTHORIZED_ACTION');
            }
            
            // Prepare default params
            Map<String, String> args = new Map<String, String>{
                    'coborrowerAddr' => 'contact',
                    'coborrowerPersonalInfo' => 'contact',
                    'coborrowerEmployment' => 'genesis__employment_information__c',
                    'coborrowerIncomeList' => 'genesis__income__c',
                    'coborrowerIdentification' => 'genesis__identification_information__c',
                    'coborrowerPrevAddr' => 'contact',
                    'coborrowerMailingAddr' => 'contact'
            };
            
            Map<String,String> appObjRelationMap = new Map<String,String>{
                    'contact' => 'relatedObj',
                    'genesis__employment_information__c' => 'childObject',
                    'genesis__income__c' => 'childObject',
                    'genesis__identification_information__c' => 'childObject'
            };
            
            Map<String,Object> sObjectToFieldsMaps = new Map<String,Object>();
            Map<String,sobject> relatedObjs =  new map<String,sobject>();
            Map<String,List<SObject>> childObjects =  new Map<String,List<SObject>>();
            
            system.debug('--argumentsFromPortal.KeySet()--'+argumentsFromPortal.KeySet());
            List<genesis__income__c> incomeList = new List<genesis__income__c>();
            for(String paramKey : argumentsFromPortal.KeySet()) {
                system.debug('--paramKey--'+paramKey);
                if(argumentsFromPortal.get(paramKey) != null && args.get(paramKey) != null){
                    if(paramKey.contains('List')){
                        if(args.get(paramKey).equalsIgnoreCase('genesis__income__c')){
                            incomeList = (List<genesis__income__c>)JSON.deserialize((String)argumentsFromPortal.get(paramKey),List<genesis__income__c>.class);
                            childObjects.put(args.get(paramKey),incomeList);
                        }   
                    }else{
                        Map<String, Object> portalObject = (Map<String, Object>)JSON.deserializeUntyped((String)argumentsFromPortal.get(paramKey)); 
                        if(sObjectToFieldsMaps.containsKey(args.get(paramKey))){
                           Map<String,Object> oldMap = (Map<String,Object>)sObjectToFieldsMaps.get(args.get(paramKey));
                           oldMap.putAll(portalObject);
                        }else{
                            sObjectToFieldsMaps.put(args.get(paramKey),portalObject);
                        }
                    }
                }        
            }
            String partyRelationship;
            for(String obj : sObjectToFieldsMaps.Keyset()){
                if(sObjectToFieldsMaps.get(obj) != null){
                    string objAPIName = obj.contains('__c') ? obj : getNamespaceForObjectName()+obj+'__c';
                    if((appObjRelationMap.get(obj)).equalsIgnoreCase('relatedObj')){
                        string jsonstring = JSON.serialize(sObjectToFieldsMaps.get(obj));
                        system.debug('--jsonstring--'+jsonstring);
                        Type t = Type.forName((String)obj) ;
                        if(objAPIName.equalsIgnoreCase('genesis__contact__c')){
                            Map<String, Object> partyMap = (Map<String, Object>)JSON.deserializeUntyped(jsonstring);
                            system.debug('--partyMap--'+partyMap);
                            String emptyStr = '';
                            if(partyMap.get('id') != null){
                                partyMap.remove('id');
                            }
                            if(partyMap.get('Relationship__c') != null){
                                partyRelationship = (String)partyMap.get('Relationship__c');
                                partyMap.remove('Relationship__c');
                            }
                            if(partyMap.get('clcommon__Contact__r.clcommon__Years_At_Current_Address__c') != null
                             && (Integer)(partyMap.get('clcommon__Contact__r.clcommon__Years_At_Current_Address__c')) >= 1){
                                partyMap.put('clcommon__Contact__r.OtherStreet',emptyStr);    
                                partyMap.put('clcommon__Contact__r.OtherCity',emptyStr);  
                                partyMap.put('clcommon__Contact__r.OtherState',emptyStr); 
                                partyMap.put('clcommon__Contact__r.OtherPostalCode',emptyStr);  
                                partyMap.put('clcommon__Contact__r.OtherCountry',emptyStr);  
                            }
                            if(partyMap.get('clcommon__Contact__r.clcommon__Mailing_Address_Same_as_Current_Address__c') != null
                             && partyMap.get('clcommon__Contact__r.clcommon__Mailing_Address_Same_as_Current_Address__c') == true){
                              partyMap.put('clcommon__Contact__r.MailingStreet',emptyStr);    
                                partyMap.put('clcommon__Contact__r.MailingCity',emptyStr);  
                                partyMap.put('clcommon__Contact__r.MailingState',emptyStr); 
                                partyMap.put('clcommon__Contact__r.MailingPostalCode',emptyStr);  
                                partyMap.put('clcommon__Contact__r.MailingCountry',emptyStr);
                            }
                            
                            jsonstring = JSON.serialize(partyMap);
                            system.debug('--jsonstring--'+ jsonstring );
                            jsonstring = jsonstring.replace('clcommon__Contact__r.','') ;  
                        }
                        SObject sObj = (SObject) JSON.deserialize(jsonstring, t);
                        relatedObjs.put(objAPIName, sObj);    
                    
                    }else if(appObjRelationMap.get(obj).equalsIgnoreCase('childObject')){
                        string jsonstring = JSON.serialize(sObjectToFieldsMaps.get(obj));
                        Type t = Type.forName((String)obj) ;
                        SObject sObj = (SObject) JSON.deserialize(jsonstring, t);
                        childObjects.put(objAPIName, new List<SObject>{sObj});    
                    }
                }   
            }
            // Handle protal validations.
            //Handle identification Expiration Date.
            if(childObjects.get('genesis__identification_information__c') != null){
                List<genesis__identification_information__c> identification = childObjects.get('genesis__identification_information__c');
                if(identification[0].genesis__Expiration_Date__c < Date.today()){
                    return getErrorResponse('Expiration date cant be in a past.');
                }
            }
            
            Boolean employerApplication = false;
            Set<Id> empToBeDeleted = new Set<Id>();

            //Query employment to be deleted.
            List<genesis__employment_information__c> empToBeDeletedList = [Select Id 
                                                                             from genesis__employment_information__c
                                                                            Where id In :empToBeDeleted];
            if(empToBeDeletedList != null && empToBeDeletedList.size() > 0){
                delete empToBeDeletedList;
            }
            Contact pContact = (Contact)relatedObjs.get('genesis__contact__c');
            String existingContactInfo = getExistingContact(pContact.FirstName,
                                                            pContact.LastName,
                                                            pContact.ints__Social_Security_Number__c);
            
            System.debug('--existingContactInfo--'+existingContactInfo);
            if(!existingContactInfo.equalsIgnoreCase('Contact not exist')){
                pContact.Id = existingContactInfo ; 
            }
            //Handle birth date validation.
            if(pContact.Birthdate != null){
                Decimal age = (pContact.Birthdate.daysBetween(Date.today()))/365.2425;
                system.debug('--age--'+age);                                                                
                if(pContact.Birthdate > Date.today()){
                    return getErrorResponse('Enter a valid Date of Birth.');
                }else if(age <= 18){
                    return getErrorResponse('Age should be more than 18 years.');
                }
            }
            
                
                clcommon__Party__c primaryParty = [Select Id,Name,
                                                         clCommon__Contact__r.clcommon__Current_City__c,
                                                         clCommon__Contact__r.clcommon__Current_Country__c,
                                                         clCommon__Contact__r.clcommon__Current_State__c,
                                                         clCommon__Contact__r.clcommon__Current_Street__c,
                                                         clCommon__Contact__r.clcommon__Current_Zip_Code__c,
                                                         clCommon__Contact__r.MailingStreet,
                                                         clCommon__Contact__r.MailingCity,
                                                         clCommon__Contact__r.MailingState,
                                                         clCommon__Contact__r.MailingPostalCode,
                                                         clCommon__Contact__r.MailingCountry,
                                                         clCommon__Contact__r.OtherStreet,
                                                         clCommon__Contact__r.OtherCity,
                                                         clCommon__Contact__r.OtherState,
                                                         clCommon__Contact__r.OtherPostalCode,
                                                         clCommon__Contact__r.OtherCountry,
                                                         clCommon__Contact__r.clcommon__Months_at_current_address__c,
                                                         clCommon__Contact__r.clcommon__Years_At_Current_Address__c,
                                                         clCommon__Contact__r.clcommon__Monthly_Residential_Payment_Amount__c,
                                                         clCommon__Contact__r.clcommon__Residential_Status__c
                                                    From clcommon__Party__c 
                                                   where genesis__Application__c = :applicationId
                                                     AND clcommon__Type__r.Name = :CustomConstants.BORROWER limit 1];
                                                 
                 pContact.clcommon__Current_City__c = primaryParty.clCommon__Contact__r.clcommon__Current_City__c;
                 pContact.clcommon__Current_Country__c = primaryParty.clCommon__Contact__r.clcommon__Current_Country__c;
                 pContact.clcommon__Current_State__c = primaryParty.clCommon__Contact__r.clcommon__Current_State__c;
                 pContact.clcommon__Current_Street__c = primaryParty.clCommon__Contact__r.clcommon__Current_Street__c;
                 pContact.clcommon__Current_Zip_Code__c = primaryParty.clCommon__Contact__r.clcommon__Current_Zip_Code__c;
                 pContact.MailingStreet = primaryParty.clCommon__Contact__r.MailingStreet;
                 pContact.MailingCity = primaryParty.clCommon__Contact__r.MailingCity;
                 pContact.MailingState = primaryParty.clCommon__Contact__r.MailingState;
                 pContact.MailingPostalCode = primaryParty.clCommon__Contact__r.MailingPostalCode;
                 pContact.MailingCountry = primaryParty.clCommon__Contact__r.MailingCountry;
                 pContact.OtherStreet =  primaryParty.clCommon__Contact__r.OtherStreet; 
                 pContact.OtherCity = primaryParty.clCommon__Contact__r.OtherCity;
                 pContact.OtherState = primaryParty.clCommon__Contact__r.OtherState;
                 pContact.OtherPostalCode = primaryParty.clCommon__Contact__r.OtherPostalCode;
                 pContact.OtherCountry  = primaryParty.clCommon__Contact__r.OtherCountry;    
                 pContact.clcommon__Months_at_current_address__c = primaryParty.clCommon__Contact__r.clcommon__Months_at_current_address__c;
                 pContact.clcommon__Years_At_Current_Address__c  = primaryParty.clCommon__Contact__r.clcommon__Years_At_Current_Address__c;
                 pContact.clcommon__Monthly_Residential_Payment_Amount__c = primaryParty.clCommon__Contact__r.clcommon__Monthly_Residential_Payment_Amount__c;
                 pContact.clcommon__Residential_Status__c  = primaryParty.clCommon__Contact__r.clcommon__Residential_Status__c;
            
          
            if(employerApplication){
                pContact.clcommon__Employee__c = true;
                pContact.clcommon__Insider_Relationship__c = CustomConstants.INSIDER;
            }
            List<clcommon__party_Type__c> type = [SELECT Name,Id 
                                               FROM clcommon__party_Type__c
                                               WHERE Name = :CustomConstants.COSIGNER limit 1];
            
            //Query legal entity type.
            List<clcommon__Legal_Entity__c> legalEntity = [Select Id,Name
                                                            From clcommon__Legal_Entity__c 
                                                           Where Name = :CustomConstants.INDIVIDUAL limit 1];
            if(legalEntity != null && legalEntity.size() > 0){
                pContact.clcommon__Legal_Entity_Type__c =  legalEntity[0].Id;   
            }
            clcommon__Party__c party = new clcommon__Party__c();
            //argsMap.put(PARTY_PARAM_NAME_FOR_SKUID, JSON.serialize(party));
            system.debug('--pContact--'+pContact);
            clcommon.BankingModelBorrowerAPI handler = clcommon.APIFactory.getBankingModelBorrowerAPI();
            Map<String,sObject> result;
            Map<String, sObject> relatedObjects = new Map<String, sObject>();
            result = handler.handleAccountAndContact(null, relatedObjects, pContact, NULL);
            
            system.debug('--result--'+result);        
            
            
            if(result != NULL && result.size() > 0){
                if(result.get('contact') != NULL){
                    pContact = (Contact)result.get('contact');
                    //Check if party is already present.
                    List<clcommon__Party__c> existingParty = [Select Id from clcommon__Party__c
                                                               Where clcommon__Contact__c = :pContact.Id
                                                                 AND genesis__Application__c = :applicationId];
                    if(existingParty != null && existingParty.size() <= 0){
                        party.clcommon__Account__c = pContact.AccountId;
                        party.clcommon__Contact__c = pContact.Id;
                        party.genesis__Application__c = applicationId;
                        if(type != null && type.size() > 0){
                            party.clcommon__Type__c = type[0].Id;
                        }
                        insert party;
                    }
                }
            }
                       
            System.debug('--childObjects--'+childObjects);
            
            fields.put('coborrowerContactId',pContact.Id);
            fields.put('coborrowerAccountId',pContact.AccountId);
            
            for(String key : childObjects.Keyset()){
                
                if(key.equalsIgnoreCase('genesis__income__c') 
                   && childObjects.get('genesis__income__c') != null){
                 
                    List<genesis__income__c> incomeListToBeUpdated = childObjects.get('genesis__income__c');
                    for(genesis__income__c income : incomeListToBeUpdated){
                        income.genesis__Contact__c = pContact.Id;
                    }
                    childObjects.put('genesis__income__c',incomeListToBeUpdated);
                }
                if(key.equalsIgnoreCase('genesis__employment_information__c') 
                   && childObjects.get('genesis__employment_information__c') != null){
                
                    List<genesis__Employment_Information__c> empList = childObjects.get('genesis__employment_information__c');
                    for(genesis__Employment_Information__c emp : empList){
                        emp.genesis__Contact__c = pContact.Id;
                    }
                    childObjects.put('genesis__employment_information__c',empList);
                }
                if(key.equalsIgnoreCase('genesis__identification_information__c') 
                   && childObjects.get('genesis__identification_information__c') != null){
                
                    List<genesis__Identification_Information__c> identityInfoList = childObjects.get('genesis__identification_information__c');
                    for(genesis__Identification_Information__c identity : identityInfoList ){
                        identity.genesis__Account__c = pContact.AccountId;
                    }
                    childObjects.put('genesis__identification_information__c',identityInfoList);
                }
                
            }
            
            
            Map<String, sObject> relatedObjectsAppUpdate = new Map<String, sObject>();

            
            genesis__Applications__c appln = [Select Id,Name,
                                                     genesis__Contact__c,
                                              	     Portal_Stage__c,
                                              		 Portal_Sub_Stage__c,
                                                     genesis__Contact__r.Id,
                                                     genesis__Account__c,
                                                     genesis__Account__r.Id,
                                                     genesis__Employee_Application__c,
                                                     (Select Id from genesis__Incomes__r 
                                                               Where genesis__Contact__c = :pContact.Id)
                                                From genesis__Applications__c 
                                               Where Id = :applicationId] ;
            
            appln.Portal_Stage__c = (String)argumentsFromPortal.get('portalStage');
            appln.Portal_Sub_Stage__c = (String)argumentsFromPortal.get('portalSubstage');
            /*if(employerApplication){
                appln.genesis__Employee_Application__c = employerApplication;
            }*/
            //Delete existing income because we will get the latest income list from portal.
            Set<Id> incomeIdsSet = new Set<Id>();
            for(genesis__Income__c income : appln.genesis__Incomes__r){
                incomeIdsSet.add(income.Id);
            }
            Set<Id> portalIncomeIdsSet = new Set<Id>();
            for(genesis__Income__c income : incomeList){
                portalIncomeIdsSet.add(income.Id);
            }
            Set<Id> incomeToBeDeletedIds = new Set<Id>();
            for(Id incomeId : incomeIdsSet){
                if(!portalIncomeIdsSet.contains(incomeId)){
                    incomeToBeDeletedIds.add(incomeId);
                }
            }
            
            List<genesis__Income__c> incomeToBeDeletedList = [Select Id 
                                                                from genesis__Income__c
                                                               Where Id In :incomeToBeDeletedIds ];
            if(incomeToBeDeletedList != null && incomeToBeDeletedList.size() > 0){
                delete incomeToBeDeletedList;
            }
            system.debug(LoggingLevel.Error,'--childObjects--'+childObjects);
            system.debug(LoggingLevel.Error,'--relatedObjs--'+relatedObjs);
               
            genesis.BorrowerAPI4 bApi = genesis.APIFactory.getBorrowerAPI4();  
            genesis__Applications__c appl = bApi.updateApplication(appln, relatedObjectsAppUpdate , childObjects); 
            
            system.debug(LoggingLevel.Error,'--appl--'+appl );
            
            response.status = clcommon.Constants.SUCCESS;
        } catch (Exception e) {
            system.debug(e.getMessage() + '---'+e.getStackTraceString());
            Database.rollback(dbSavePoint);
            return getErrorResponse(e.getMessage() + '---'+e.getStackTraceString());
           
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
    
    private String getExistingContact(String firstName, 
                                       String lastName,
                                       String ssn){
        
        
        List<Contact> conList = [Select Id,
                                        FirstName,
                                        LastName, 
                                        AccountId,
                                        ints__Social_Security_Number__c
                                   From Contact 
                                  Where FirstName = :firstName
                                    AND LastName = :lastName];
                                
        for(Contact con : conList){
            if(con.ints__Social_Security_Number__c != null
             && ssn != null
             && ssn.equalsIgnoreCase(con.ints__Social_Security_Number__c)){
                return con.id;        
              
            }
        
        }                        
        return 'Contact not exist';
    }
}