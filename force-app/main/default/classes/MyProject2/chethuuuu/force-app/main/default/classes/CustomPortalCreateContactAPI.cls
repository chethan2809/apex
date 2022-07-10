global class CustomPortalCreateContactAPI implements clcommon.PortalCustomRemoteAPI1 {

    public static LegalEntityDB legalEntityDBInstance = new LegalEntityDB();
    public static UserDB userDBInstance = new UserDB();
    public static ApplicationDB applicationDBInstance = new ApplicationDB();
    public static ContactDB contactDBInstance = new ContactDB();
    public static LeadDB leadDBInstance = new LeadDB();
    public static AccountDB accountDBInstance = new AccountDB();
    public static OpportunityDB opportunityDBInstance = new OpportunityDB();
    public static PartyDB partyDBInstance = new PartyDB();
    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    public static CLCommonRelationshipDB clCommonRelationshipDBInstance = new CLCommonRelationshipDB();
    public static CLCommonReciprocalRoleDB clCommonReciprocalRoleDBInstance = new CLCommonReciprocalRoleDB();

    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> argumentsFromPortal) {
        SavePoint savePoint;
        clcommon.Response response = new clcommon.Response();
        Map<String,Object> fields = new Map<String,Object>();
        String errorLogOriginText = '';
        Lead leadRecord = new Lead();
        genesis__Applications__c application = new genesis__Applications__c();
        try{
            String firstName = (String)argumentsFromPortal.get('firstName');
            String lastName = (String)argumentsFromPortal.get('lastName');
            String middleName = (String)argumentsFromPortal.get('middleName');
            String title = (String)argumentsFromPortal.get('title');
            String email = (String)argumentsFromPortal.get('email');
            String bizStartDate = (String)argumentsFromPortal.get('bizStartDate');
            String businessName = (String)argumentsFromPortal.get('businessName');
            String legalStructure = (String)argumentsFromPortal.get('legalEntity');
            String industry = (String)argumentsFromPortal.get('industry');
            String phone = (String)argumentsFromPortal.get('mobilePhone');
            Decimal loanAmount = (Decimal)argumentsFromPortal.get('loanAmount');
            String loanPurpose = String.valueOf(argumentsFromPortal.get('loanPurpose'));
            String businessStreet = (String)argumentsFromPortal.get('businessStreet');
            String businessBuildingNumber = (String)argumentsFromPortal.get('businessBuildingNumber');
            String businessState = (String)argumentsFromPortal.get('businessState');
            String businessCity = (String)argumentsFromPortal.get('businessCity');
            String businessPostalCode = (String)argumentsFromPortal.get('businessPostalCode');
            String businessCountry = (String)argumentsFromPortal.get('businessCountry');
            String dba = String.valueOf(argumentsFromPortal.get('dba'));
            String businessPhone = String.valueOf(argumentsFromPortal.get('businessPhone'));
            String taxId = String.valueOf(argumentsFromPortal.get('bizTaxId'));
            String stateOfFormation = (String)argumentsFromPortal.get('stateOfFormation')!=null ? (String)argumentsFromPortal.get('stateOfFormation') : '';
            String contactId = String.valueOf(argumentsFromPortal.get('contactId'));
            String leadId;
            Id individualLegalStructureId;
            Id businessLegalEntityId;
            Date birthDate;
            String socialSecurityNumber;

            if(argumentsFromPortal.containsKey('birthDate')) {
                birthDate  = Date.valueOf(String.valueOf(argumentsFromPortal.get('birthDate')));
            }
            if(argumentsFromPortal.containsKey('socialSecurityNumber')) {
                socialSecurityNumber  = String.valueOf(argumentsFromPortal.get('socialSecurityNumber'));
            }
            String businessStateName = businessState.trim().replaceAll('\\s+','_');
            State_Name_Vs_State_Code_Mapping__mdt stateCodeMapping = CustomMetaDataHelper.stateVsStateCodeMap.get(businessStateName);
            if(stateCodeMapping != null){
                businessState = stateCodeMapping.short_code__c;
            }

            String merchantPortalDefaultOwnerEmail;
            Default_Portal_Owner_Mapping__mdt defaultMerchantPortalOwnerMapping = CustomMetaDataHelper.defaultPortalOwnerMap.get(PortalConstants.DEFAULT_MERCHANT_PORTAL_OWNER);
            if(defaultMerchantPortalOwnerMapping != null){
                merchantPortalDefaultOwnerEmail = defaultMerchantPortalOwnerMapping.Owner_Email__c;
            }

            phone = phone.trim().replaceAll('[\\D]', '');
            businessPhone = businessPhone.trim().replaceAll('[\\D]', '');

            individualLegalStructureId = OriginationHelper.legalNameToId.get(GeneralConstants.LEGAL_TYPE_INDIVIDUAL);
            businessLegalEntityId = OriginationHelper.legalNameToId.get(legalStructure);

            List<Account> existingBorrowerAccountsList = accountDBInstance.getExistingBorrowerAccts(new Set<String>{taxId},
                                                                                            new Set<String>{businessStreet},
                                                                                            new Set<String>{businessCity});
            List<Contact> existingContactsList = contactDBInstance.getExistingGuarantorContacts(new Set<String>{firstName},
                                                                                                new Set<String>{lastName},
                                                                                                new Set<String>{email});
            List<User> defaultMerchantPortalOwnerList = userDBInstance.getDefaultPortalOwnerByEmail(new Set<String>{merchantPortalDefaultOwnerEmail});

            if(contactId == null){
                List<User> userList = userDBInstance.getUsersByUserNames(new Set<String>{email});
                if(userList != null && userList.size() > 0){
                    return getErrorResponse(PortalConstants.ERROR_USER_ALREADY_EXIST +email + ',' + PortalConstants.LOGIN_AGAIN);
                }
            }

            Account borrowerAccount = new Account();
            Account guarantorAccount = new Account();
            Contact guarantorContact = new Contact();
            Opportunity opportunityRecord = new Opportunity();

            leadRecord.Use_of_Funds__c = loanPurpose;
            leadRecord.Title__c = title;
            leadRecord.FirstName = firstName;
            leadRecord.LastName = lastName;
            leadRecord.MiddleName = middleName;
            leadRecord.Email = email;
            leadRecord.MobilePhone = phone;
            if(birthDate != null){
                leadRecord.DOB__c = Date.valueOf(birthDate);
            }
            leadRecord.How_much_do_you_Need__c = Integer.valueOf(loanAmount);
            leadRecord.Street = businessStreet;
            leadRecord.BusinessBuildingNumber__c = businessBuildingNumber;
            leadRecord.City = businessCity;
            leadRecord.State = businessState;
            leadRecord.PostalCode = businessPostalCode;
            leadRecord.Country = businessCountry;
            leadRecord.DBA__c = dba;
            leadRecord.Tax_ID__c = taxId;
            leadRecord.Biz_Phone__c = businessPhone;
            leadRecord.Biz_Structure__c = legalStructure;
            leadRecord.Industry = industry;
            leadRecord.Biz_Start_Date__c = Date.ValueOf(bizStartDate);
            leadRecord.State_of_Incorporation_Organization__c = stateOfFormation;
            if(socialSecurityNumber != null){
                leadRecord.SSN__c = socialSecurityNumber;
            }
            leadRecord.Company = businessName;
            if(OriginationHelper.canIndustryProfile.ContainsKey(industry)) {
                leadRecord.loan__SICCode__c = OriginationHelper.canIndustryProfile.get(industry).Digit_Code__c;
                leadRecord.SIC_Description__c = OriginationHelper.canIndustryProfile.get(industry).Description__c;
            }
            leadRecord.LeadSource = PortalConstants.MERCHANT_PORTAL;
            leadDBInstance.addInsert(leadRecord);
            leadDBInstance.executeInserts();
            leadId = leadRecord.Id;
            if(OriginationHelper.canIndustryProfile.ContainsKey(industry) &&
                OriginationHelper.canIndustryProfile.get(industry).Industry_Rating__c.equals(PortalConstants.PROHIBITED)) {
                leadRecord.Status = PortalConstants.CLOSED_NOT_CONVERTED;
                fields.put(PortalConstants.REJECT_REASON, PortalConstants.INDUSTRY_RESTRICTION);
                leadDBInstance.addUpdate(leadRecord);
                leadDBInstance.executeUpdates();
                return getErrorResponse(PortalConstants.INDUSTRY_RESTRICTION);
            }else if(title.equals(PortalConstants.OTHER_TITLE)) {
                leadRecord.Status = PortalConstants.CLOSED_NOT_CONVERTED;
                fields.put(PortalConstants.REJECT_REASON, PortalConstants.TITLE_RESTRICTION);
                leadDBInstance.addUpdate(leadRecord);
                leadDBInstance.executeUpdates();
                return getErrorResponse(PortalConstants.TITLE_RESTRICTION);
            }else if(!businessCountry.equals(PortalConstants.UNITED_STATES)
                        && (!businessCountry.equalsIgnoreCase(PortalConstants.US))
                        && (!businessCountry.equalsIgnoreCase(PortalConstants.USA))){
                leadRecord.Status = PortalConstants.CLOSED_NOT_CONVERTED;
                fields.put(PortalConstants.REJECT_REASON, PortalConstants.COUNTRY_RESTRICTION);
                leadDBInstance.addUpdate(leadRecord);
                leadDBInstance.executeUpdates();
                return getErrorResponse(PortalConstants.COUNTRY_RESTRICTION);
            }else{
                leadRecord.Status = PortalConstants.OPEN_NEW_LEAD;
            }
            leadRecord.Status = PortalConstants.OPEN_NEW_LEAD;
            leadDBInstance.addUpdate(leadRecord);
            leadDBInstance.executeUpdates();
            savePoint =  Database.setSavePoint();

            if(!leadRecord.Status.equals(PortalConstants.CLOSED_NOT_CONVERTED)){
                if(!existingBorrowerAccountsList.isEmpty()){
                    borrowerAccount = existingBorrowerAccountsList[0];
                }
                else{
                    errorLogOriginText = PortalConstants.MP_BORROWER_ACCOUNT_CREATION_ERROR_TEXT;
                    borrowerAccount = Accounts.createBorrowerAccount(leadRecord, businessLegalEntityId);
                    borrowerAccount.Name = leadRecord.Company;
                    accountDBInstance.addInsert(borrowerAccount);
                    accountDBInstance.executeInserts();
                }
                if(!existingContactsList.isEmpty()){
                    guarantorContact = existingContactsList[0];
                    guarantorAccount.Id = existingContactsList[0].AccountId;
                    leadRecord.Status = PortalConstants.CLOSED_CONVERTED;
                    leadDBInstance.addUpdate(leadRecord);
                    leadDBInstance.executeUpdates();

                    opportunityRecord = Opportunities.getOpportunityRecordForPortal(borrowerAccount.Id, guarantorContact.Id);
                    opportunityRecord.Name = borrowerAccount.Name;
                    opportunityRecord.Requested_Loan_Amount__c = leadRecord.How_much_do_you_Need__c;
                    opportunityRecord.Type = PortalConstants.LOAN_TYPE_NEW;
                    opportunityRecord.LeadSource = leadRecord.LeadSource;
                    opportunityDBInstance.addInsert(opportunityRecord);
                    opportunityDBInstance.executeInserts();
                }
                else{
                    errorLogOriginText = PortalConstants.MP_LEAD_CONVERSION_ERROR_TEXT;
                    Database.LeadConvert leadConvert = new Database.LeadConvert();
                    leadConvert.setLeadId (leadRecord.Id);
                    leadConvert.setConvertedStatus(PortalConstants.CLOSED_CONVERTED);
                    Database.LeadConvertResult leadConvertResult = Database.convertLead(leadConvert);
                    leadRecord.Status = PortalConstants.CLOSED_CONVERTED;

                    errorLogOriginText = PortalConstants.MP_GUARANTOR_ACCOUNT_CREATION_ERROR_TEXT;
                    guarantorAccount = Accounts.createGuarantorAccount(leadRecord, individualLegalStructureId);
                    guarantorAccount.Id = leadConvertResult.getAccountId();
                    accountDBInstance.addUpdate(guarantorAccount);
                    accountDBInstance.executeUpdates();

                    errorLogOriginText = PortalConstants.MP_GUARANTOR_CONTACT_CREATION_ERROR_TEXT;
                    guarantorContact = Contacts.createGuarantorContact(leadRecord, individualLegalStructureId, guarantorAccount);
                    guarantorContact.Id = leadConvertResult.getContactId();
                    contactDBInstance.addUpdate(guarantorContact);
                    contactDBInstance.executeUpdates();

                    errorLogOriginText = PortalConstants.MP_OPPORTUNITY_UPDATE_ERROR_TEXT;
                    opportunityRecord = Opportunities.getOpportunityRecordForPortal(borrowerAccount.Id, guarantorContact.Id);
                    opportunityRecord.Id = leadConvertResult.getOpportunityId();
                    opportunityRecord.Requested_Loan_Amount__c = leadRecord.How_much_do_you_Need__c;
                    opportunityRecord.Type = PortalConstants.LOAN_TYPE_NEW;
                    opportunityRecord.LeadSource = leadRecord.LeadSource;
                    opportunityDBInstance.addUpdate(opportunityRecord);
                    opportunityDBInstance.executeUpdates();
                }

                List<clcommon__Relationship__c> relationshipList = new List<clcommon__Relationship__c>();
                List<clcommon__Reciprocal_Role__c> relationshipRoleList = clCommonReciprocalRoleDBInstance.getCLCommonRelationship(new Set<String> {Leads.GUARANTOR});
                Id relationshipRoleId = relationshipRoleList.isEmpty() ? null : relationshipRoleList[0].Id;
                List<clcommon__Relationship__c> relationshipGuarantorList = clCommonRelationshipDBInstance.getCLCommonRelationships(
                                    new Set<Id> {borrowerAccount.Id}, new Set<Id> {guarantorAccount.Id}, new Set<Id> {relationshipRoleId});
                if(relationshipGuarantorList.isEmpty()) {
                    clcommon__Relationship__c relationship = CLCommonRelationships.createCLCommonRelationships(borrowerAccount.Id, guarantorAccount.Id, relationshipRoleId);
                    relationshipList.add(relationship);
                }

                clCommonRelationshipDBInstance.addInserts(relationshipList);
                clCommonRelationshipDBInstance.executeInserts();
            }
            errorLogOriginText = PortalConstants.MP_APPLICATION_CREATION_ERROR_TEXT;
            genesis.BorrowerAPI4 borrowerApi = genesis.APIFactory.getBorrowerAPI4();
            if(application.Id != null) {
                application = borrowerApi.updateApplication(application, null, null);
            } else if(leadRecord.Status.equals(PortalConstants.CLOSED_CONVERTED)) {
                application = ApplicationManager.createApplicationAndParties(
                    opportunityRecord.Id,opportunityRecord.Requested_Loan_Amount__c, borrowerAccount.Id, guarantorAccount.Id, guarantorContact.Id, null, GeneralConstants.LOAN_TYPE_NEW
                );
                genesis__Applications__c applicationShell = new genesis__Applications__c(Id = application.Id);
                applicationShell.What_is_used_for__c = leadRecord.Use_of_Funds__c;
                applicationShell.Sales_Rep__c = defaultMerchantPortalOwnerList[0].Id;
                applicationDBInstance.addUpdate(applicationShell);
                applicationDBInstance.executeUpdates();
            }
            fields.put('contactId',guarantorContact.Id);
            fields.put('ApplicationId',application.Id);
            fields.put('leadId',leadId);
            fields.put('Status',leadRecord.Status);
            List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
            respList.add(new clcommon.PortalCustomRemoteActionRecord('KEY_RESPONSE', fields));
            response = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
            return response;
        }catch (Exception ex) {
            Error_Log__c errorLog = new Error_Log__c();
            Database.rollback(savePoint);
            try{
                if(leadRecord.Id != null)
                {
                    leadRecord.Portal_Lead_Converted__c = false;
                    leadDBInstance.addUpdate(leadRecord);
                    leadDBInstance.executeUpdates();
                }
            }catch(Exception e){
                errorLog = ErrorLogs.createErrorLog (errorLogOriginText, e.getMessage(), e.getStackTraceString(),
                    null, ErrorLogs.ERROR, null, true);
            }
            if(application.Id != null){
                errorLog = ErrorLogs.createErrorLog (errorLogOriginText, ex.getMessage(), ex.getStackTraceString(),
                    null, ErrorLogs.ERROR, application.Id, true);
            }
            else{
                errorLog = ErrorLogs.createErrorLog (errorLogOriginText, ex.getMessage(), ex.getStackTraceString(),
                    null, ErrorLogs.ERROR, null, true);
            }
            errorLogDBInstance.addInsert(errorLog);
            errorLogDBInstance.executeInserts();
            return getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
        }
    }

    private clcommon.Response getErrorResponse(String errorMessage) {
        clcommon.Response response = new clcommon.Response();
        response.status = clcommon.Constants.ERROR;
        response.errorMessage = errorMessage;
        response.errorCode = clcommon.Constants.API_EXCEPTION;
        return response;
    }
}