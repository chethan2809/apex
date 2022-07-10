global class CCBPCreatePartiesAPI implements clcommon.PortalCustomRemoteAPI1{

    public static LegalEntityDB legalEntityDBInstance = new LegalEntityDB();
    public static ContactDB contactDBInstance = new ContactDB();
    public static PartyDB partyDBInstance = new PartyDB();
    public static AccountDB accountDB = new AccountDB();
    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    public static ApplicationDB applicationDBInstance = new ApplicationDB();
    public static CLCommonReciprocalRoleDB clCommonReciprocalRoleDBInstance = new CLCommonReciprocalRoleDB();
    public static CLCommonRelationshipDB clCommonRelationshipDBInstance = new CLCommonRelationshipDB();
    public static UserDB userDBInstance = new UserDB();
    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> argumentsFromPortal) {
        SavePoint dbSavePoint = Database.setSavePoint();
        clcommon.Response response = new clcommon.Response();
        Map<String,Object> fields = new Map<String,Object>();
        Id applicationId = (Id)argumentsFromPortal.get(PortalConstants.APPLICATION_ID);
        try {
            //Check object/fields access permission
            if (false == Schema.getGlobalDescribe().get(getNamespaceForObjectName()+'Applications__c').getDescribe().isCreateable()) {
                return getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
            }
            if (false == Schema.getGlobalDescribe().get('Account').getDescribe().isCreateable()) {
                return getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
            }
            if (false == Schema.getGlobalDescribe().get('Contact').getDescribe().isCreateable()) {
                return getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
            }
            Contact newContact = new Contact();
            Account newAccount = new Account();
            clcommon__Party__c party = new clcommon__Party__c();
            Boolean isValidApplication;
            if(applicationId != null){
                isValidApplication = CLSPBPortalSecurity.validApplication(applicationId);
                if(isValidApplication){
                    if(argumentsFromPortal.containsKey(PortalConstants.PARTY_PERSONAL_DETAILS) && argumentsFromPortal.get(PortalConstants.PARTY_PERSONAL_DETAILS) != null){
                        Map<String,Object> contactMap = new Map<String,Object>();
                        Map<String,Object> personalDetailsMap  = (Map<String, Object>)JSON.deserializeUntyped((String)argumentsFromPortal.get(PortalConstants.PARTY_PERSONAL_DETAILS));
                        for(String str:personalDetailsMap.keySet()){
                            if(str.containsIgnoreCase('clcommon__Contact__r.')){
                                contactMap.put(str, personalDetailsMap.get(str));
                            }
                        }
                        string jsonString = JSON.serialize(contactMap);
                        jsonString = jsonString.replace('clcommon__Contact__r.','');
                        newContact = (Contact)JSON.deserialize(jsonString,Contact.class);
                        String firstName = ((String)newContact.get('FirstName')).trim();
                        String lastName = ((String)newContact.get('LastName')).trim();
                        String email = (String)newContact.get('Email');
                        String partyType = ((String)newContact.get('loan__Contact_Type__c')).toUppercase();
                        String mailingState = (String)newContact.get('MailingState');
                        String socialSecurityNumber = (String)newContact.get('genesis__SSN__c');
                        String beneficialOwnerType = (String)newContact.get('Beneficial_Owner_type__c');
                        String mobilePhone = (String)newContact.get('MobilePhone');

                        String brokerPortalDefaultOwnerEmail;
                        Default_Portal_Owner_Mapping__mdt defaultBrokerPortalOwnerMapping = CustomMetaDataHelper.defaultPortalOwnerMap.get(PortalConstants.DEFAULT_BROKER_PORTAL_OWNER);
                        if(defaultBrokerPortalOwnerMapping != null){
                            brokerPortalDefaultOwnerEmail = defaultBrokerPortalOwnerMapping.Owner_Email__c;
                        }
                        String mailingStateName = mailingState.trim().replaceAll('\\s+','_');
                        State_Name_Vs_State_Code_Mapping__mdt mailingStateCodeMapping = CustomMetaDataHelper.stateVsStateCodeMap.get(mailingStateName);
                        if(mailingStateCodeMapping != null){
                            mailingState = mailingStateCodeMapping.short_code__c;
                        }

                        mobilePhone = mobilePhone.trim().replaceAll('[\\D]', '');

                        Date birthDate = Date.valueOf(newContact.get('Birthdate'));
                        Integer totalDays = birthDate.daysBetween(System.today());
                        Integer age = (integer)(math.Floor(totalDays/365.2425));
                        if(age < PortalConstants.OWNER_MIN_AGE){
                            return getErrorResponse(PortalConstants.AGE_RESTRICTION);
                        }
                        List<Contact> existingContactList = contactDBInstance.getExistingContactByNameAndEmail(new Set<String>{firstName},
                                                                                                               new Set<String>{lastName},
                                                                                                               new Set<String>{email});
                        List<genesis__Applications__c> applicationsList = applicationDBInstance.getApplicationsByIds(new Set<Id> {applicationId});

                        List<User> defaultBrokerPortalOwnerList = userDBInstance.getDefaultPortalOwnerByEmail(new Set<String>{brokerPortalDefaultOwnerEmail});

                        List<User> loggedInBrokerUsersList = userDBInstance.getBrokerUserDetailsByLoggedInId();

                        Id individualLegalStructureId = OriginationHelper.legalNameToId.get(GeneralConstants.LEGAL_TYPE_INDIVIDUAL);
                        Id partyTypeId = OriginationHelper.partyTypeToId.get(partyType);
                        if(existingContactList == null || existingContactList.size() <= 0){
                            newAccount.Name = newContact.FirstName + ' ' + newContact.LastName;
                            newAccount.Type = newContact.loan__Contact_Type__c;
                            if(newContact.loan__Contact_Type__c != null) {
                                newAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(newContact.loan__Contact_Type__c.toUpperCase()).getRecordTypeId();
                            }
                            newAccount.clcommon__Legal_Entity_type__c = individualLegalStructureId;
                            newAccount.OwnerId = defaultBrokerPortalOwnerList[0].Id;
                            accountDB.addInsert(newAccount);
                            accountDB.executeInserts();
                            newContact.AccountId = newAccount.Id;
                            newContact.clcommon__Legal_Entity_type__c = individualLegalStructureId;
                            newContact.MailingState = mailingState;
                            newContact.ints__Social_Security_Number__c = socialSecurityNumber;
                            newContact.MobilePhone = mobilePhone;
                            newContact.LeadSource = PortalConstants.BROKER_PORTAL;
                            contactDBInstance.addInsert(newContact);
                            contactDBInstance.executeInserts();
                            newContact.OwnerId = defaultBrokerPortalOwnerList[0].Id;
                            contactDBInstance.addUpdate(newContact);
                            contactDBInstance.executeUpdates();
                            party.clcommon__Contact__c = newContact.Id;
                            party.clcommon__Account__c = newContact.AccountId;
                            party.genesis__Application__c = applicationId;
                            party.clcommon__Type__c = (Id)partyTypeId;
                            party.Beneficial_Owner_Type__c = beneficialOwnerType;
                            partyDBInstance.addInsert(party);
                            partyDBInstance.executeInserts();
                            fields.put(PortalConstants.CO_BORROWER_ACCOUNT_ID, newAccount.Id);
                            fields.put(PortalConstants.CO_BORROWER_CONTACT_ID, newContact.Id);
                        }
                        else{
                            party.clcommon__Account__c = existingContactList[0].AccountId;
                            party.clcommon__Contact__c = existingContactList[0].Id;
                            List<clcommon__Party__c> existingParty= [SELECT Id,name FROM clcommon__Party__c
                                                                     WHERE genesis__Application__c=:applicationId AND
                                                                     clcommon__Account__c=:existingContactList[0].AccountId AND
                                                                     clcommon__contact__c=:existingContactList[0].Id];
                            party.genesis__Application__c = applicationId;
                            party.clcommon__Type__c = (Id)partyTypeId;
                            if(existingParty == null || existingParty.size() <= 0){
                                partyDBInstance.addInsert(party);
                                partyDBInstance.executeInserts();
                                fields.put(PortalConstants.CO_BORROWER_ACCOUNT_ID, newAccount.Id);
                                fields.put(PortalConstants.CO_BORROWER_CONTACT_ID, newContact.Id);
                            }
                        }
                        List<clcommon__Relationship__c> relationshipList = new List<clcommon__Relationship__c>();
                        List<clcommon__Reciprocal_Role__c> relationshipRoleList = clCommonReciprocalRoleDBInstance.getCLCommonRelationship
                                                                                                (new Set<String> {partyType});
                        Id relationshipRoleId = relationshipRoleList.isEmpty() ? null : relationshipRoleList[0].Id;
                        List<clcommon__Relationship__c> relationshipPartyList = clCommonRelationshipDBInstance.getCLCommonRelationships(
                                    new Set<Id> {applicationsList[0].genesis__Account__c}, new Set<Id> {newAccount.Id}, new Set<Id> {relationshipRoleId});
                        if(relationshipPartyList.isEmpty()) {
                            clcommon__Relationship__c relationship = CLCommonRelationships.createCLCommonRelationships
                                                                                (applicationsList[0].genesis__Account__c, newAccount.Id, relationshipRoleId);
                            relationshipList.add(relationship);
                        }
                        clCommonRelationshipDBInstance.addInserts(relationshipList);
                        clCommonRelationshipDBInstance.executeInserts();
                    }
                    else{
                        return getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
                    }
                }else{
                    Error_Log__c errorLog = ErrorLogs.createErrorLog (
                                PortalConstants.ERROR_ADD_PARTY_APP_NOT_VALID_BP, null, null,
                                null, ErrorLogs.ERROR, applicationId, true);
                    errorLogDBInstance.addInsert(errorLog);
                    errorLogDBInstance.executeInserts();
                    return getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
                }
            }
        }catch (Exception e) {
            Database.rollback(dbSavePoint);
            Error_Log__c errorLog = ErrorLogs.createErrorLog (
                    PortalConstants.ERROR_ADD_PARTY_CATCH_BP, e.getMessage(), e.getStackTraceString(),
                    null, ErrorLogs.ERROR, applicationId, true);
            errorLogDBInstance.addInsert(errorLog);
            errorLogDBInstance.executeInserts();
            response = getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
            return response;
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
        String namespace = 'genesis';
        if(String.isEmpty(namespace)){
            return '';
        }else{
            return namespace+'__';
        }
    }
}