global class CCMPCreatePartiesAPI implements clcommon.PortalCustomRemoteAPI1 {

    public static LegalEntityDB legalEntityDBInstance = new LegalEntityDB();
    public static ContactDB contactDBInstance = new ContactDB();
    public static PartyDB partyDBInstance = new PartyDB();
    public static AccountDB accountDBInstance = new AccountDB();
    public static ApplicationDB applicationDBInstance = new ApplicationDB();
    public static CLCommonReciprocalRoleDB clCommonReciprocalRoleDBInstance = new CLCommonReciprocalRoleDB();
    public static CLCommonRelationshipDB clCommonRelationshipDBInstance = new CLCommonRelationshipDB();
    public static UserDB userDBInstance = new UserDB();
    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    String applicationId = '';
    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> params) {
        clcommon.Response res;
        applicationId = String.valueOf(params.get('applicationId'));
        try{
            if(params != null){
                Boolean isValidApp = PortalSecurityUtil.validateUserApplication(applicationId);
                if(isValidApp){
                    res = setSuccessResponse(params);
                }
                else{
                    Error_Log__c errorLog = ErrorLogs.createErrorLog ('SMP Create Parties', PortalConstants.NO_PERMISSION_ERROR_MSG, null,
                    null, ErrorLogs.ERROR, applicationId, true);
                    errorLogDBInstance.addInsert(errorLog);
                    errorLogDBInstance.executeInserts();
                    res = PortalUtility.setResponse(clcommon.Constants.ERROR, clcommon.Constants.API_EXCEPTION,PortalConstants.NO_PERMISSION_ERROR_MSG);
                }
            }else
            {
                String errorMessage = PortalConstants.ERROR_MESSAGE_PARAM_NOT_FOUND;
                res = PortalUtility.setResponse(clcommon.Constants.ERROR, clcommon.Constants.API_EXCEPTION, errorMessage);
            }
        }catch(Exception e){
            Error_Log__c errorLog = ErrorLogs.createErrorLog ('SMP Create Parties', e.getMessage(), e.getStackTraceString(),
                null, ErrorLogs.ERROR, applicationId, true);
                errorLogDBInstance.addInsert(errorLog);
                errorLogDBInstance.executeInserts();
                res = PortalUtility.setResponse(clcommon.Constants.ERROR, clcommon.Constants.API_EXCEPTION,PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
        }
        return res;
    }
    private clcommon.Response setSuccessResponse(Map<String,Object> params){
        clcommon.Response res = new clcommon.Response();
        String partyType = String.valueOf(params.get('partyType')).toUpperCase();
        String title = String.valueOf(params.get('title'));
        String firstName = String.valueOf(params.get('firstName')).trim();
        String lastName = String.valueOf(params.get('lastName')).trim();
        String email = String.valueOf(params.get('email'));
        String mobilePhone = String.valueOf(params.get('mobilePhone'));
        String birthDate = String.valueOf(params.get('birthDate'));
        String socialSecurityNumber = String.valueOf(params.get('socialSecurityNumber'));
        String coBorrowerStreet = String.valueOf(params.get('coBorrowerStreet'));
        String coBorrowerBuilding = String.valueOf(params.get('coBorrowerBuilding'))!=null ? String.valueOf(params.get('coBorrowerBuilding')): '';
        String coBorrowerCity = String.valueOf(params.get('coBorrowerCity'));
        String coBorrowerState = String.valueOf(params.get('coBorrowerState'));
        String coBorrowerPostalCode = String.valueOf(params.get('coBorrowerPostalCode'));
        String coBorrowerCountry = String.valueOf(params.get('coBorrowerCountry'));
        String coBorrowerStateName = coBorrowerState.trim().replaceAll('\\s+','_');

        mobilePhone = mobilePhone.trim().replaceAll('[\\D]', '');

        State_Name_Vs_State_Code_Mapping__mdt stateCodeMapping = CustomMetaDataHelper.stateVsStateCodeMap.get(coBorrowerStateName);
        if(stateCodeMapping != null){
            coBorrowerState = stateCodeMapping.short_code__c;
        }
        String merchantPortalDefaultOwnerEmail;
        Default_Portal_Owner_Mapping__mdt defaultMerchantPortalOwnerMapping = CustomMetaDataHelper.defaultPortalOwnerMap.get(PortalConstants.DEFAULT_MERCHANT_PORTAL_OWNER);
        if(defaultMerchantPortalOwnerMapping != null){
            merchantPortalDefaultOwnerEmail = defaultMerchantPortalOwnerMapping.Owner_Email__c;
        }
        List<User> defaultMerchantPortalOwnerList = userDBInstance.getDefaultPortalOwnerByEmail(new Set<String>{merchantPortalDefaultOwnerEmail});
        Id individualLegalStructureId = OriginationHelper.legalNameToId.get(GeneralConstants.LEGAL_TYPE_INDIVIDUAL);
        Id partyTypeId = OriginationHelper.partyTypeToId.get(partyType);
        List<Contact> existingContactList = contactDBInstance.getExistingContactByNameAndEmail(new Set<String>{firstName},
                                                                                            new Set<String>{lastName},
                                                                                            new Set<String>{email});
        List<genesis__Applications__c> applicationsList = applicationDBInstance.getApplicationsByIds(new Set<Id> {(Id)applicationId});
        clcommon__Party__c newParty = new clcommon__Party__c();
        if(existingContactList == null || existingContactList.size() <= 0){
            Account newAccount = new Account();
            newAccount.name = firstName+ ' ' +lastName;
            newAccount.Type = partyType;
            if(newAccount.Type != null) {
                newAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(newAccount.Type.toUpperCase()).getRecordTypeId();
            }
            newAccount.clcommon__Legal_Entity_type__c =individualLegalStructureId;
            newAccount.OwnerId = defaultMerchantPortalOwnerList[0].Id;
            accountDBInstance.addInsert(newAccount);
            accountDBInstance.executeInserts();
            Contact newContact = new Contact();
            newContact.FirstName = firstName;
            newContact.LastName = lastName;
            newContact.Email = email;
            newContact.loan__Contact_Type__c = partyType;
            newContact.Title__c = title;
            newContact.MobilePhone = mobilePhone;
            newContact.Birthdate = Date.valueOf(birthDate);
            newContact.genesis__SSN__c = socialSecurityNumber;
            newContact.MailingStreet = coBorrowerStreet;
            newContact.MailingBuildingNumber__c = coBorrowerBuilding;
            newContact.MailingCity = coBorrowerCity;
            newContact.MailingState = coBorrowerState;
            newContact.MailingPostalCode = coBorrowerPostalCode;
            newContact.MailingCountry = coBorrowerCountry;
            newContact.AccountId =newAccount.Id;
            newContact.clcommon__Legal_Entity_type__c =individualLegalStructureId;
            newContact.LeadSource = PortalConstants.MERCHANT_PORTAL;
            contactDBInstance.addInsert(newContact);
            contactDBInstance.executeInserts();
            newParty.clcommon__Account__c = newContact.AccountId;
            newParty.clcommon__Contact__c = newContact.Id;
            newParty.genesis__Application__c = applicationId;
            newParty.clcommon__Type__c = (Id)partyTypeId;
            partyDBInstance.addInsert(newParty);
            partyDBInstance.executeInserts();
            List<clcommon__Relationship__c> relationshipList = new List<clcommon__Relationship__c>();
            List<clcommon__Reciprocal_Role__c> relationshipRoleList = clCommonReciprocalRoleDBInstance.getCLCommonRelationship(new Set<String> {partyType});
            Id relationshipRoleId = relationshipRoleList.isEmpty() ? null : relationshipRoleList[0].Id;
            List<clcommon__Relationship__c> relationshipGuarantorList = clCommonRelationshipDBInstance.getCLCommonRelationships(
                                    new Set<Id> {applicationsList[0].genesis__Account__c}, new Set<Id> {newAccount.Id}, new Set<Id> {relationshipRoleId});
            if(relationshipGuarantorList.isEmpty()) {
                clcommon__Relationship__c relationship = CLCommonRelationships.createCLCommonRelationships(applicationsList[0].genesis__Account__c, newAccount.Id, relationshipRoleId);
                relationshipList.add(relationship);
            }
            clCommonRelationshipDBInstance.addInserts(relationshipList);
            clCommonRelationshipDBInstance.executeInserts();
        } else {
            newParty.clcommon__Account__c = existingContactList[0].AccountId;
            newParty.clcommon__Contact__c = existingContactList[0].Id;
            List<clcommon__Party__c> existingParty= [SELECT Id,name FROM clcommon__Party__c WHERE genesis__Application__c=:applicationId AND
                                                    clcommon__Account__c=:existingContactList[0].AccountId AND
                                                    clcommon__contact__c=:existingContactList[0].Id];
            newParty.genesis__Application__c = applicationId;
            newParty.clcommon__Type__c = (Id)partyTypeId;
            if(existingParty == null || existingParty.size() <= 0) {
                partyDBInstance.addInsert(newParty);
                partyDBInstance.executeInserts();
            }
        }
        res.status = clcommon.Constants.SUCCESS;
        return res;
    }
}