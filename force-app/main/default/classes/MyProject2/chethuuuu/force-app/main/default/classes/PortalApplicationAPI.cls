global class PortalApplicationAPI implements clcommon.PortalCustomRemoteAPI1 {

    /**
     * A portal wrapper to create a application record by using genesis.BorrowerAPI4.createApplication API
     * This API expects to get the stringified application object and stringified contact,account and related objects from portal
     * which will be passed in to the genesis.APIFactory.getBorrowerAPI4().createApplication API to create/update a new application.
     * @param componentStrName no need for this API. Can leave it as a empty string ""
     * @param disclosureNames no need for this API. Can leave it as a null value.
     * @param argumentsFromPortal Should have the corresponding parameter name in order to create a new application.

     * All the values in argumentsFromPortal are stringified JSON .
     * This api will extract application and it's related objects and children by using defined values as the keys from the argumentsFromPortal (Map<String,Object>).
     * Example: given the below parameters from the argumentsFromPortal (Map<String,Object>).
     * It will create an application which associated with new Account and Contact.
     *
     * @return Response.
     *TODO - 1. Put user identifier to identify application for logged in user.
             2. Get the object name dynamically based on Portal Actor/Component Structure.
             3. List insertion
     *Limitations - 1. List insertion is not supported right now.
                    2. If same field is displayed in two different components then field will be over-ridden. One field can't be referred in multiple component structures.
     **/
    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> argumentsFromPortal) {
        SavePoint dbSavePoint = Database.setSavePoint();
        clcommon.Response response = new clcommon.Response();
        genesis__Applications__c application = new genesis__Applications__c();
        String applicationId = (String)argumentsFromPortal.get(CustomConstants.APPLICATION_ID);
        Boolean isValidApp = PortalSecurityUtil.validateUserApplication(applicationId);
        if(isValidApp){
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
                        'borrowerAddr' => 'contact',
                        'borrowerPersonalInfo' => 'contact',
                        'borrowerPersonalInfoName' => 'contact',
                        'borrowerPersonalInfoContact' => 'contact',
                        'borrowerPersonalInfoMoreInfo' => 'contact',
                        'borrowerEmployment' => 'genesis__employment_information__c',
                        'borrowerIncomeList' => 'genesis__income__c',
                        'borrowerIdentification' => 'genesis__identification_information__c',
                        'borrowerPrevAddr' => 'contact'
                };
                Map<String,String> appObjRelationMap = new Map<String,String>{
                        'contact' => 'relatedObj',
                        'genesis__employment_information__c' => 'childObject',
                        'genesis__income__c' => 'childObject',
                        'genesis__identification_information__c' => 'childObject'
                };
                Map<String,Object> sObjectToFieldsMaps = new Map<String,Object>();
                Map<String,sObject> relatedObj =  new map<String,sObject>();
                Map<String,List<SObject>> childObjects =  new Map<String,List<SObject>>();
                List<genesis__income__c> incomeList;
                for(String paramKey : argumentsFromPortal.KeySet()) {
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
                for(String obj : sObjectToFieldsMaps.Keyset()){
                    if(sObjectToFieldsMaps.get(obj) != null){
                        string objAPIName = obj.contains('__c') ? obj : getNamespaceForObjectName()+obj+'__c';
                        if((appObjRelationMap.get(obj)).equalsIgnoreCase('relatedObj')){
                            string jsonString = JSON.serialize(sObjectToFieldsMaps.get(obj));
                            Type t = Type.forName((String)obj) ;
                            if(objAPIName.equalsIgnoreCase('genesis__contact__c')){
                                Map<String, Object> partyMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
                                String emptyStr = '';
                                if(partyMap.get('id') != null){
                                    partyMap.remove('id');
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
                                jsonString = JSON.serialize(partyMap);
                                jsonString = jsonString.replace('clcommon__Contact__r.','') ;
                            }
                            SObject sObj = (SObject) JSON.deserialize(jsonString, t);
                            relatedObj.put(objAPIName, sObj);
                        }else if(appObjRelationMap.get(obj).equalsIgnoreCase('childObject')){
                            string jsonString = JSON.serialize(sObjectToFieldsMaps.get(obj));
                            Type t = Type.forName((String)obj) ;
                            SObject sObj = (SObject) JSON.deserialize(jsonString, t);
                            childObjects.put(objAPIName, new List<SObject>{sObj});
                        }
                    }
                }
                // Handle portal validations.
                //Handle identification Expiration Date.
                if(childObjects.get('genesis__identification_information__c') != null){
                    List<genesis__identification_information__c> identification = childObjects.get('genesis__identification_information__c');
                    if(identification[0].genesis__Expiration_Date__c < Date.today()){
                        return getErrorResponse('Expiration date cant be in a past');
                    }
                }
                List<User> loggedInUser = [Select Id,
                                                   AccountId,
                                                   ContactId
                                                   From User
                                                   Where Id = :UserInfo.getUserId()
                                                   Limit 1];
                Id contactId;
                Id accountId;
                if(loggedInUser != null
                   && loggedInUser.size() > 0
                   && loggedInUser[0].AccountId != null){
                    contactId = loggedInUser[0].ContactId;
                    accountId = loggedInUser[0].AccountId;
                }
                Boolean employerApp = false;
                application = [Select Id,Name,genesis__Contact__c,
                                genesis__Account__c,
                                genesis__Account__r.Id,
                                genesis__Contact__r.Id,
                                genesis__Employee_Application__c,
                                (Select Id from genesis__Incomes__r
                                   Where genesis__Contact__c = :contactId)
                           FROM genesis__Applications__c
                          Where Id = :applicationId];
                //handle previous employment and add current employment in the employmentList.
                Set<Id> empToBeDeleted = new Set<Id>();

                Contact con = (Contact)relatedObj.get('genesis__contact__c');
                if(con.clcommon__Legal_Entity_Type__c == null){
                    //Query legal entity type.
                    List<clcommon__Legal_Entity__c> legalEntity = [Select Id,Name
                                                                    From clcommon__Legal_Entity__c
                                                                   Where Name = :CustomConstants.INDIVIDUAL limit 1];
                    if(legalEntity != null && legalEntity.size() > 0){
                        con.clcommon__Legal_Entity_Type__c =  legalEntity[0].Id;
                    }
                }
                //Handle birth date validation.
                if(con.Birthdate != null){
                    Decimal age = (con.Birthdate.daysBetween(Date.today()))/365.2425;
                    if(con.Birthdate > Date.today()){
                        return getErrorResponse('Enter a valid Date of Birth.');
                    }else if(age <= 18){
                        return getErrorResponse('Age should be more than 18 years.');
                    }
                }
               con.MailingStreet = con.clcommon__Current_Street__c;
               con.MailingCity = con.clcommon__Current_City__c;

               String currentStateName = con.clcommon__Current_State__c.trim().replaceAll('\\s+','_');
               State_Name_Vs_State_Code_Mapping__mdt stateCodeMapping = CustomMetaDataHelper.stateVsStateCodeMap.get(currentStateName);
               if(stateCodeMapping != null){
                con.MailingState = stateCodeMapping.short_code__c;
                con.clcommon__Current_State__c = stateCodeMapping.short_code__c;
               }
               else{
                con.MailingState = con.clcommon__Current_State__c;
               }
               con.MailingCountry = con.clcommon__Current_Country__c;
               con.MailingPostalCode = con.clcommon__Current_Zip_Code__c;
               con.genesis__SSN__c = con.genesis__SSN__c;
               con.ints__Social_Security_Number__c = con.genesis__SSN__c;
               //updating child objects (Identification Info)
               genesis.BorrowerAPI4 bApi = genesis.APIFactory.getBorrowerAPI4();
               application = bApi.updateApplication(application, null, childObjects);
               //Updating Contact directly until updateApplication bug gets fixed
               update con;
               //Update Account in Identification and Contact in Income and Employment
                application = [Select id,Name,
                               genesis__Account__c,
                               genesis__Contact__c,
                               Portal_Stage__c,
                               Portal_Sub_Stage__c,
                               (Select Id,genesis__Account__c
                                  From genesis__Identifications_Information2__r),
                               (Select Id,genesis__Contact__c
                                  From genesis__Employment_Information__r),
                               (Select Id,genesis__Contact__c
                                  From genesis__Incomes__r),
                               (Select Id,clcommon__Account__c,
                                       clcommon__Contact__c
                                From genesis__Parties__r
                                 Where clcommon__Account__c = :accountId limit 1)
                          From genesis__Applications__c
                         Where Id = :application.Id];
                application.Portal_Stage__c = (String)argumentsFromPortal.get('portalStage');
                application.Portal_Sub_Stage__c = (String)argumentsFromPortal.get('portalSubstage');
                update application;
                clcommon__Party__c partyToBeUpdated = application.genesis__Parties__r[0];
                update partyToBeUpdated;

                List<genesis__identification_information__c> identificationList = application.genesis__Identifications_Information2__r;
                for(genesis__identification_information__c identification : identificationList ){
                    if(identification.genesis__Account__c == null)
                        identification.genesis__Account__c = accountId;
                }
                if(identificationList != null && identificationList.size() > 0){
                    update identificationList;
                }
                response.status = clcommon.Constants.SUCCESS;
            } catch (Exception e) {
                Database.rollback(dbSavePoint);
                Error_Log__c errorLog = ErrorLogs.createErrorLog (
                    'PortalApplicationAPI', e.getMessage(), e.getStackTraceString(),
                    null, ErrorLogs.ERROR, application.Id, true);
                errorLogDBInstance.addInsert(errorLog);
                errorLogDBInstance.executeInserts();
                response.status = clcommon.Constants.API_EXCEPTION;
                response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG_MESSAGE;
                return response;
            }
        }else{
            return getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
        }
        Map<String,Object> fields = new Map<String,Object>();
        fields.put('applicationId',application.Id);
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
        String namespace = 'genesis';
        if(String.isEmpty(namespace)){
            return '';
        }else{
            return namespace+'__';
        }
    }
}