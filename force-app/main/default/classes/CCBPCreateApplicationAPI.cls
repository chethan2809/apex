global class CCBPCreateApplicationAPI implements clcommon.PortalCustomRemoteAPI1 {
    public static LegalEntityDB legalEntityDBInstance = new LegalEntityDB();
    public static UserDB userDBInstance = new UserDB();
    public static ContactDB contactDBInstance = new ContactDB();
    public static LeadDB leadDBInstance = new LeadDB();
    public static AccountDB accountDBInstance = new AccountDB();
    public static AccountContactRelationDB accountContactRelationDBInstance = new AccountContactRelationDB();
    public static OpportunityDB opportunityDBInstance = new OpportunityDB();
    public static PartyDB partyDBInstance = new PartyDB();
    public static ApplicationDB applicationDBInstance = new ApplicationDB();
    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    public static CLCommonReciprocalRoleDB clCommonReciprocalRoleDBInstance = new CLCommonReciprocalRoleDB();
    public static CLCommonRelationshipDB clCommonRelationshipDBInstance = new CLCommonRelationshipDB();
    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> argumentsFromPortal) {
        SavePoint dbSavePoint = Database.setSavePoint();
        clcommon.Response response = new clcommon.Response();
        Lead leadRecord = new Lead();
        genesis__Applications__c application = new genesis__Applications__c();
        String errorLogOriginText = '';
        try {
            //Check object/fields access permission
            if (false == Schema.getGlobalDescribe().get(getNamespaceForObjectName()+'Applications__c').getDescribe().isCreateable()) {
                return getErrorResponse(PortalConstants.UNAUTHORIZED_ACTION);
            }
            //Getting all the arguments of personalDetails actor from the broker portal
            Map<String,Object> contactMap = new Map<String,Object>();
            Map<String,Object> personalContactDetailsMap  = (Map<String, Object>)JSON.deserializeUntyped((String)argumentsFromPortal.get(PortalConstants.INDIVIDUAL_DETAILS));
            for(String str:personalContactDetailsMap.keySet()){
                if(str.containsIgnoreCase('clcommon__Contact__r.')){
                    contactMap.put(str, personalContactDetailsMap.get(str));
                }
            }
            String jsonContactString = JSON.serialize(contactMap);
            jsonContactString = jsonContactString.replace('clcommon__Contact__r.','');
            Contact personalContactDetails = (Contact)JSON.deserialize(jsonContactString,Contact.class);
            String title = (String)personalContactDetails.get('Title__c');
            String firstName = (String)personalContactDetails.get('FirstName');
            String lastName = (String)personalContactDetails.get('LastName');
            String email = (String)personalContactDetails.get('Email');
            String phone = (String)personalContactDetails.get('MobilePhone');
            String birthDate = String.valueOf(personalContactDetails.get('Birthdate'));
            String socialSecurityNumber = (String)personalContactDetails.get('genesis__SSN__c');
            String mailingStreet = (String)personalContactDetails.get('MailingStreet');
            String MailingBuildingNumber = (String)personalContactDetails.get('MailingBuildingNumber__c')!=null ? (String)personalContactDetails.get('MailingBuildingNumber__c') : '';
            String mailingCity = (String)personalContactDetails.get('MailingCity');
            String mailingState = (String)personalContactDetails.get('MailingState');
            String mailingCountry = String.valueOf(personalContactDetails.get('MailingCountry'));
            String mailingPostalCode = (String)personalContactDetails.get('MailingPostalCode');

            //Getting all the arguments of LoanDetails actor from the broker portal
            Map<String, Object> loanDetailsMap = (Map<String, Object>)JSON.deserializeUntyped((String)argumentsFromPortal.get(PortalConstants.LOAN_INFO));
            String loanPurpose = (String)loanDetailsMap.get('What_is_used_for__c');
            String loanAmount = String.valueOf(loanDetailsMap.get('genesis__Loan_Amount__c'));

            if(loanPurpose == null || loanPurpose == ''){
                loanPurpose = PortalConstants.LOAN_PURPOSE_WORKING_CAPITAL;
            }

            //Getting all the arguments of BusinessDetails actors from the broker portal
            Map<String,Object> businessInfoMap = new Map<String,Object>();
            if(argumentsFromPortal.get(PortalConstants.BUSINESS_BASIC_INFORMATION) != null){
                Map<String, Object> basicInfoMap = (Map<String, Object>)JSON.deserializeUntyped((String)argumentsFromPortal.get(PortalConstants.BUSINESS_BASIC_INFORMATION));
                businessInfoMap.putAll(basicInfoMap);
            }
            if(argumentsFromPortal.get(PortalConstants.BUSINESS_BILLING_ADDRESS)!=null){
                Map<String, Object> billingAddressMap = (Map<String, Object>)JSON.deserializeUntyped((String)argumentsFromPortal.get(PortalConstants.BUSINESS_BILLING_ADDRESS));
                businessInfoMap.putAll(billingAddressMap);
            }
            if(argumentsFromPortal.get(PortalConstants.BUSINESS_ESTABLISHMENT_DETAILS)!=null){
                Map<String, Object> otherDetailsMap = (Map<String, Object>)JSON.deserializeUntyped((String)argumentsFromPortal.get(PortalConstants.BUSINESS_ESTABLISHMENT_DETAILS));
                businessInfoMap.putAll(otherDetailsMap);
            }
            string jsonAccountString = JSON.serialize(businessInfoMap);
            jsonAccountString = jsonAccountString.replace('clcommon__Entity__r.','');
            Account businessDetails = (Account)JSON.deserialize(jsonAccountString,Account.class);
            String businessName = (String)businessDetails.get('Name');
            String industry = (String)businessDetails.get('Industry');
            String taxId = (String)businessDetails.get('Business_Tax_ID__c')!=null ? (String)businessDetails.get('Business_Tax_ID__c') : '';
            String dba = (String)businessDetails.get('Doing_Business_As_Name__c')!=null ? (String)businessDetails.get('Doing_Business_As_Name__c') : '';
            String businessLegalStructureName = (String)argumentsFromPortal.get('businessLegalStructureName');
            String stateOfFormation = (String)businessDetails.get('State_of_Incorporation_Organization__c')!=null ? (String)businessDetails.get('State_of_Incorporation_Organization__c') : '';
            String bizStartDate = String.valueOf(businessDetails.get('Biz_Start_Date__c'));
            String businessPhone = (String)businessDetails.get('Phone');
            String businessStreet = (String)businessDetails.get('BillingStreet');
            String businessBuildingNumber = (String)businessDetails.get('BillingBuildingNumber__c')!=null ? (String)businessDetails.get('BillingBuildingNumber__c') : '';
            String businessCity = (String)businessDetails.get('BillingCity');
            String businessState = (String)businessDetails.get('BillingState');
            String businessPostalCode = (String)businessDetails.get('BillingPostalCode');
            String businessCountry = (String)businessDetails.get('BillingCountry');
            String leadId;

            String businessStateName = businessState.trim().replaceAll('\\s+','_');
            State_Name_Vs_State_Code_Mapping__mdt businessStateCodeMapping = CustomMetaDataHelper.stateVsStateCodeMap.get(businessStateName);
            if(businessStateCodeMapping != null){
                businessState = businessStateCodeMapping.short_code__c;
            }

            String mailingStateName = mailingState.trim().replaceAll('\\s+','_');
            State_Name_Vs_State_Code_Mapping__mdt mailingStateCodeMapping = CustomMetaDataHelper.stateVsStateCodeMap.get(mailingStateName);
            if(mailingStateCodeMapping != null){
                mailingState = mailingStateCodeMapping.short_code__c;
            }

            phone = phone.trim().replaceAll('[\\D]', '');
            businessPhone = businessPhone.trim().replaceAll('[\\D]', '');

            String brokerPortalDefaultOwnerEmail;
            Default_Portal_Owner_Mapping__mdt defaultBrokerPortalOwnerMapping = CustomMetaDataHelper.defaultPortalOwnerMap.get(PortalConstants.DEFAULT_BROKER_PORTAL_OWNER);
            if(defaultBrokerPortalOwnerMapping != null){
                brokerPortalDefaultOwnerEmail = defaultBrokerPortalOwnerMapping.Owner_Email__c;
            }

            Id businessLegalStructureId = OriginationHelper.legalNameToId.get(businessLegalStructureName);
            Id individualLegalStructureId = OriginationHelper.legalNameToId.get(GeneralConstants.LEGAL_TYPE_INDIVIDUAL);
            List<Account> existingBorrowerAccountsList = accountDBInstance.getExistingBorrowerAccts(new Set<String>{taxId},
                                                                                            new Set<String>{businessStreet},
                                                                                            new Set<String>{businessCity});
            List<Contact> existingContactsList = contactDBInstance.getExistingGuarantorContacts(new Set<String>{firstName},
                                                                                                new Set<String>{lastName},
                                                                                                new Set<String>{email});
            List<User> loggedInBrokerUsersList = new List<User>();
            if(argumentsFromPortal.containsKey(PartnerAPIConstants.PARTNER_INFO)) {
                loggedInBrokerUsersList = userDBInstance.getDefaultPortalOwnerByEmail(PartnerCreateApplications.getPartnerEmail(argumentsFromPortal));
            } else {
                loggedInBrokerUsersList = userDBInstance.getBrokerUserDetailsByLoggedInId();
            }
            List<User> defaultBrokerPortalOwnerList = userDBInstance.getDefaultPortalOwnerByEmail(new Set<String>{brokerPortalDefaultOwnerEmail});

            //With this logic we are changing the Broker Owner ID. If there is a PAM related to logged user in BP, he will be the owner ID
            //If not, owner will be default Broker Portal Owner defined in Default_Portal_Owner_Mapping__mdt
            Id partnerAccountManagerID;
            if(loggedInBrokerUsersList[0].Partner_Account_Manager__c != null){
                partnerAccountManagerID = loggedInBrokerUsersList[0].Partner_Account_Manager__c;
            } else {
                partnerAccountManagerID = defaultBrokerPortalOwnerList[0].Id;
            }

            Account borrowerAccount = new Account();
            Account guarantorAccount = new Account();
            Contact guarantorContact = new Contact();
            Opportunity opportunityRecord = new Opportunity();
            Map<String,Object> fields = new Map<String,Object>();

            Integer totalDays = Date.valueOf(birthDate).daysBetween(System.today());
            Integer age = (integer)(math.Floor(totalDays/365.2425));

            errorLogOriginText = PortalConstants.LEAD_CREATION_ORIGIN_CC_BP_CREATE_APPLICATION;
            leadRecord.Use_of_Funds__c = loanPurpose;
            leadRecord.How_much_do_you_Need__c = Integer.valueOf(loanAmount);
            leadRecord.Title__c = title;
            leadRecord.FirstName = firstName;
            leadRecord.LastName = lastName;
            leadRecord.Email = email;
            leadRecord.MobilePhone = phone;
            leadRecord.DOB__c = Date.valueOf(birthDate);
            leadRecord.SSN__c = socialSecurityNumber;
            leadRecord.Street__c = mailingStreet;
            leadRecord.PersonalBuildingNumber__c = MailingBuildingNumber;
            leadRecord.City__c = mailingCity;
            leadRecord.State__c = mailingState;
            leadRecord.Country__c = mailingCountry;
            leadRecord.Postal_Code__c = mailingPostalCode;
            leadRecord.Company = businessName;
            leadRecord.Industry = industry;
            leadRecord.Tax_ID__c = taxId;
            leadRecord.DBA__c = dba;
            leadRecord.Biz_Structure__c = businessLegalStructureName;
            leadRecord.Biz_Start_Date__c = Date.ValueOf(bizStartDate);
            leadRecord.Biz_Phone__c = businessPhone;
            leadRecord.Street = businessStreet;
            leadRecord.BusinessBuildingNumber__c = businessBuildingNumber;
            leadRecord.City = businessCity;
            leadRecord.State = businessState;
            leadRecord.PostalCode = businessPostalCode;
            leadRecord.Country = businessCountry;
            leadRecord.State_of_Incorporation_Organization__c = stateOfFormation;
            if(OriginationHelper.canIndustryProfile.ContainsKey(industry)) {
                leadRecord.loan__SICCode__c = OriginationHelper.canIndustryProfile.get(industry).Digit_Code__c;
                leadRecord.SIC_Description__c = OriginationHelper.canIndustryProfile.get(industry).Description__c;
            }
            if(argumentsFromPortal.containsKey(PartnerAPIConstants.PARTNER_INFO)) {
                leadRecord.LeadSource = PortalConstants.PARTNER_API;
            } else {
                leadRecord.LeadSource = PortalConstants.BROKER_PORTAL;
            }
            leadDBInstance.addInsert(leadRecord);
            leadDBInstance.executeInserts();
            leadId = leadRecord.Id;

            errorLogOriginText = PortalConstants.KNOCKOUT_RULES_ORIGIN_CREATE_APPLICATION_CLASS_BP;
            if(OriginationHelper.canIndustryProfile.ContainsKey(industry) &&
                OriginationHelper.canIndustryProfile.get(industry).Industry_Rating__c.equals(PortalConstants.PROHIBITED)) {
                leadRecord.Status = PortalConstants.CLOSED_NOT_CONVERTED;
                fields.put(PortalConstants.REJECT_REASON, PortalConstants.INDUSTRY_RESTRICTION);
                leadDBInstance.addUpdate(leadRecord);
                leadDBInstance.executeUpdates();
                return getErrorResponse(PortalConstants.INDUSTRY_RESTRICTION);
            }else if(age < PortalConstants.OWNER_MIN_AGE){
                leadRecord.Status = PortalConstants.CLOSED_NOT_CONVERTED;
                fields.put(PortalConstants.REJECT_REASON, PortalConstants.AGE_RESTRICTION);
                leadDBInstance.addUpdate(leadRecord);
                leadDBInstance.executeUpdates();
                return getErrorResponse(PortalConstants.AGE_RESTRICTION);
            }else if(title.equals(PortalConstants.OTHER_TITLE)) {
                leadRecord.Status = PortalConstants.CLOSED_NOT_CONVERTED;
                fields.put(PortalConstants.REJECT_REASON, PortalConstants.TITLE_RESTRICTION);
                leadDBInstance.addUpdate(leadRecord);
                leadDBInstance.executeUpdates();
                return getErrorResponse(PortalConstants.TITLE_RESTRICTION);
            }else if((!businessCountry.equalsIgnoreCase(PortalConstants.UNITED_STATES)
                                                        && (!businessCountry.equalsIgnoreCase(PortalConstants.US))
                                                        && (!businessCountry.equalsIgnoreCase(PortalConstants.USA)))){
                leadRecord.Status = PortalConstants.CLOSED_NOT_CONVERTED;
                fields.put(PortalConstants.REJECT_REASON, PortalConstants.COUNTRY_RESTRICTION);
                leadDBInstance.addUpdate(leadRecord);
                leadDBInstance.executeUpdates();
                return getErrorResponse(PortalConstants.COUNTRY_RESTRICTION);
            }else{
                leadRecord.Status = PortalConstants.OPEN_NEW_LEAD;
            }
            leadDBInstance.addUpdate(leadRecord);
            leadDBInstance.executeUpdates();
            dbSavePoint =  Database.setSavePoint();
            errorLogOriginText = PortalConstants.LEAD_CONVERSION_ORIGIN_CREATE_APPLICATION_CLASS_BP;
            if(!leadRecord.Status.equals(PortalConstants.CLOSED_NOT_CONVERTED)){
                if(!existingBorrowerAccountsList.isEmpty()){
                    borrowerAccount = existingBorrowerAccountsList[0];
                }
                else{
                    errorLogOriginText = PortalConstants.BUSINESS_ACC_CREATION_ORIGIN_CREATE_APPLICATION_CLASS_BP;
                    borrowerAccount = Accounts.createBorrowerAccount(leadRecord, businessLegalStructureId);
                    borrowerAccount.Name = leadRecord.Company;
                    borrowerAccount.Broker_Account__c = loggedInBrokerUsersList[0].AccountId;
                    borrowerAccount.Broker_Contact__c = loggedInBrokerUsersList[0].ContactId;
                    borrowerAccount.OwnerId = partnerAccountManagerID;
                    accountDBInstance.addInsert(borrowerAccount);
                    accountDBInstance.executeInserts();
                }
                if(!existingContactsList.isEmpty()){
                    guarantorContact = existingContactsList[0];
                    guarantorAccount.Id = existingContactsList[0].AccountId;
                    leadRecord.Status = PortalConstants.CLOSED_CONVERTED;
                    leadDBInstance.addUpdate(leadRecord);
                    leadDBInstance.executeUpdates();

                    errorLogOriginText = PortalConstants.OPP_CREATE_EXISTING_CUSTOMER_ORIGIN_CREATE_APPLICATION_CLASS_BP;
                    opportunityRecord = Opportunities.getOpportunityRecordForPortal(borrowerAccount.Id, guarantorContact.Id);
                    opportunityRecord.Name = borrowerAccount.Name;
                    opportunityRecord.Requested_Loan_Amount__c = leadRecord.How_much_do_you_Need__c;
                    opportunityRecord.Type = PortalConstants.LOAN_TYPE_NEW;
                    opportunityRecord.LeadSource = leadRecord.LeadSource;
                    opportunityRecord.Broker_Account__c = loggedInBrokerUsersList[0].AccountId;
                    opportunityRecord.Broker_Contact__c = loggedInBrokerUsersList[0].ContactId;
                    opportunityRecord.OwnerId = partnerAccountManagerID;
                    opportunityDBInstance.addInsert(opportunityRecord);
                    opportunityDBInstance.executeInserts();
                }
                else{
                    Database.LeadConvert leadConvert = new Database.LeadConvert();
                    leadConvert.setLeadId(leadRecord.Id);
                    leadConvert.setConvertedStatus(PortalConstants.CLOSED_CONVERTED);
                    Database.LeadConvertResult leadConvertResult = Database.convertLead(leadConvert);
                    leadRecord.Status = PortalConstants.CLOSED_CONVERTED;

                    errorLogOriginText = PortalConstants.GUARANTOR_ACC_CREATION_ORIGIN_CREATE_APPLICATION_CLASS_BP;
                    guarantorAccount = Accounts.createGuarantorAccount(leadRecord,individualLegalStructureId);
                    guarantorAccount.Id = leadConvertResult.getAccountId();
                    guarantorAccount.OwnerId = partnerAccountManagerID;
                    guarantorAccount.Broker_Account__c = loggedInBrokerUsersList[0].AccountId;
                    guarantorAccount.Broker_Contact__c = loggedInBrokerUsersList[0].ContactId;
                    accountDBInstance.addUpdate(guarantorAccount);
                    accountDBInstance.executeUpdates();

                    errorLogOriginText = PortalConstants.GUARANTOR_CON_CREATION_ORIGIN_CREATE_APPLICATION_CLASS_BP;
                    guarantorContact = Contacts.createGuarantorContact(leadRecord, individualLegalStructureId, guarantorAccount);
                    guarantorContact.Id = leadConvertResult.getContactId();
                    guarantorContact.OwnerId = partnerAccountManagerID;
                    guarantorContact.Broker_Account__c = loggedInBrokerUsersList[0].AccountId;
                    guarantorContact.Broker_Contact__c = loggedInBrokerUsersList[0].ContactId;
                    contactDBInstance.addUpdate(guarantorContact);
                    contactDBInstance.executeUpdates();

                    errorLogOriginText = PortalConstants.OPP_CREATE_NEW_CUSTOMER_ORIGIN_CREATE_APPLICATION_CLASS_BP;
                    opportunityRecord = Opportunities.getOpportunityRecordForPortal(borrowerAccount.Id, guarantorContact.Id);
                    opportunityRecord.Id = leadConvertResult.getOpportunityId();
                    opportunityRecord.Requested_Loan_Amount__c = leadRecord.How_much_do_you_Need__c;
                    opportunityRecord.Type = PortalConstants.LOAN_TYPE_NEW;
                    opportunityRecord.LeadSource = leadRecord.LeadSource;
                    opportunityRecord.Broker_Account__c = loggedInBrokerUsersList[0].AccountId;
                    opportunityRecord.Broker_Contact__c = loggedInBrokerUsersList[0].ContactId;
                    opportunityRecord.OwnerId = partnerAccountManagerID;
                    opportunityDBInstance.addUpdate(opportunityRecord);
                    opportunityDBInstance.executeUpdates();

                    // With this code we are inserting missing relation between Account and Contact
                    if(borrowerAccount.Id !=null && guarantorContact.Id != null)
                    {
                        errorLogOriginText = PortalConstants.ACCOUNT_CONTACT_RELATIONSHIP_CLASS_BP;
                        AccountContactRelation accountContactRelationRecord = new AccountContactRelation();
                        accountContactRelationRecord.AccountId = borrowerAccount.Id;
                        accountContactRelationRecord.ContactId = guarantorContact.Id;
                        accountContactRelationRecord.IsActive = true;
                        accountContactRelationDBInstance.addInsert(accountContactRelationRecord);
                        accountContactRelationDBInstance.executeInserts();
                    }
                }

                List<clcommon__Relationship__c> relationshipList = new List<clcommon__Relationship__c>();
                List<clcommon__Reciprocal_Role__c> relationshipRoleList = clCommonReciprocalRoleDBInstance.getCLCommonRelationship
                                                                                        (new Set<String> {Leads.GUARANTOR});
                Id relationshipRoleId = relationshipRoleList.isEmpty() ? null : relationshipRoleList[0].Id;
                clcommon__Relationship__c relationship = CLCommonRelationships.createCLCommonRelationships
                                                                         (borrowerAccount.Id, guarantorAccount.Id, relationshipRoleId);
                relationshipList.add(relationship);
                if(!loggedInBrokerUsersList.isEmpty()) {
                    relationshipRoleList = clCommonReciprocalRoleDBInstance.getCLCommonRelationship(new Set<String> {Leads.BROKER});
                    relationshipRoleId = relationshipRoleList.isEmpty() ? null : relationshipRoleList[0].Id;
                    clcommon__Relationship__c relationshipBroker = CLCommonRelationships.createCLCommonRelationships
                                                                    (borrowerAccount.Id, loggedInBrokerUsersList[0].AccountId,
                                                                    relationshipRoleId);
                    relationshipList.add(relationshipBroker);
                }
                clCommonRelationshipDBInstance.addInserts(relationshipList);
                clCommonRelationshipDBInstance.executeInserts();
            }
            errorLogOriginText = PortalConstants.APPLICATION_CREATION_ORIGIN_CREATE_APPLICATION_CLASS_BP;
            genesis.BorrowerAPI4 borrowerApi = genesis.APIFactory.getBorrowerAPI4();
            if(application.Id != null)
            {
                application = borrowerApi.updateApplication(application, null, null);
            }else if(leadRecord.Status.equals(PortalConstants.CLOSED_CONVERTED))
            {
                application = ApplicationManager.createApplicationAndParties(
                    opportunityRecord.Id, opportunityRecord.Requested_Loan_Amount__c, borrowerAccount.Id, guarantorAccount.Id, guarantorContact.Id, loggedInBrokerUsersList.get(0),
                    GeneralConstants.LOAN_TYPE_NEW
                );
                genesis__Applications__c applicationShell = new genesis__Applications__c(Id = application.Id);
                applicationShell.What_is_used_for__c = leadRecord.Use_of_Funds__c;
                applicationShell.Sales_Rep__c = partnerAccountManagerID;
                applicationDBInstance.addUpdate(applicationShell);
                applicationDBInstance.executeUpdates();
            }
            else{
                Database.rollback(dbSavePoint);
                leadRecord.Portal_Lead_Converted__c = false;
                leadDBInstance.addUpdate(leadRecord);
                leadDBInstance.executeUpdates();
                Error_Log__c errorLog = ErrorLogs.createErrorLog (
                    errorLogOriginText, PortalConstants.ERROR_APP_CREATION_LEAD_CLOSED_NOT_CONVERTED_BP, null, null, 'Error', null, true);
                errorLogDBInstance.addInsert(errorLog);
                errorLogDBInstance.executeInserts();
                return getErrorResponse(PortalConstants.LEAD_CLOSED_SOMETHING_WENT_WRONG);
            }
            fields.put(PortalConstants.ACCOUNT_ID, borrowerAccount.Id);
            fields.put(PortalConstants.BORROWER_ACCOUNT_ID, guarantorAccount.Id);
            fields.put(PortalConstants.CONTACT_ID, guarantorContact.Id);
            fields.put(PortalConstants.APPLICATION_ID, application.Id);
            fields.put(PortalConstants.STATUS, leadRecord.Status);
            fields.put(PortalConstants.CLIENT_TYPE, PortalConstants.BUSINESS);
            response.status = clcommon.Constants.SUCCESS;
            List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
            respList.add(new clcommon.PortalCustomRemoteActionRecord('KEY_RESPONSE', fields));
            response = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
            return response;
        } catch (Exception e) {
            Database.rollback(dbSavePoint);
            Error_Log__c errorLog = new Error_Log__c();
            try{
                if(leadRecord.Id != null)
                {
                    leadRecord.Portal_Lead_Converted__c = false;
                    leadDBInstance.addUpdate(leadRecord);
                    leadDBInstance.executeUpdates();
                }
            }
            catch(Exception ex){
                errorLog = ErrorLogs.createErrorLog (
                errorLogOriginText, ex.getMessage(), ex.getStackTraceString(), null, ErrorLogs.ERROR, null, true);
                errorLogDBInstance.addInsert(errorLog);
                errorLogDBInstance.executeInserts();
                return getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
            }
            if(application.Id != null){
                errorLog = ErrorLogs.createErrorLog (
                errorLogOriginText, e.getMessage(), e.getStackTraceString(), null, ErrorLogs.ERROR, application.Id, true);
            } else {
                errorLog = ErrorLogs.createErrorLog (
                errorLogOriginText, e.getMessage(), e.getStackTraceString(), null, ErrorLogs.ERROR, null, true);
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
    private String getNamespaceForObjectName(){
        String namespace = 'genesis';
        if(String.isEmpty(namespace)){
            return '';
        }else{
            return namespace+'__';
        }
    }
}