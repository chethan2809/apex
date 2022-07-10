global class CCMPCreateConcurrentApplication implements clcommon.PortalCustomRemoteAPI1 {
    public static AccountDB accountDBInstance = new AccountDB();
    public static CLCommonRelationshipDB clCommonRelationshipDBInstance = new CLCommonRelationshipDB();
    public static CLCommonReciprocalRoleDB clCommonReciprocalRoleDBInstance = new CLCommonReciprocalRoleDB();
    public static ContactDB contactDBInstance = new ContactDB();
    public static ApplicationDB applicationDBInstance = new ApplicationDB();
    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    public static OpportunityDB opportunityDBInstance = new OpportunityDB();
    public static UserDB userDBInstance = new UserDB();
    public static AccountContactRelationDB accountContactRelationDBInstance = new AccountContactRelationDB();
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames,Map<String, Object> argumentsFromPortal) {
        SavePoint dbSavePoint = Database.setSavePoint();
        clcommon.Response response = new clcommon.Response();
        Map<String, Object> concurrentAccountDetailsMap = new Map<String, Object>();
        Id concurrentAccountId;
        try{
            if(argumentsFromPortal.containsKey(PortalConstants.CONCURRENT_ACCOUNT_DETAILS) && argumentsFromPortal.get(PortalConstants.CONCURRENT_ACCOUNT_DETAILS) != null){
                concurrentAccountDetailsMap = (Map<String, Object>)JSON.deserializeUntyped((String)argumentsFromPortal.get(PortalConstants.CONCURRENT_ACCOUNT_DETAILS));
                concurrentAccountId = (Id)concurrentAccountDetailsMap.get('Id');
                Boolean isValidAccount = PortalSecurityUtil.validateUserByBorrowerAccountId(concurrentAccountId);
                if(isValidAccount){
                    Opportunity opportunityRecord = new Opportunity();
                    Account borrowerAccount = new Account();
                    Account guarantorAccount = new Account();
                    Contact guarantorContact = new Contact();
                    Map<String,Object> fields = new Map<String,Object>();
                    List<Contact> relatedPrimaryGuarantorContactList = new List<Contact>();
                    genesis__Applications__c application = new genesis__Applications__c();

                    boolean newGuarantorForMigratedConcurrentApp = CustomMetaDataHelper.defaultGeneralSetting.Link_Guarantor_For_Migrated_Concrt_App__c;

                    String merchantPortalDefaultOwnerEmail;
                    Default_Portal_Owner_Mapping__mdt defaultMerchantPortalOwnerMapping = CustomMetaDataHelper.defaultPortalOwnerMap.get(PortalConstants.DEFAULT_MERCHANT_PORTAL_OWNER);
                    if(defaultMerchantPortalOwnerMapping != null){
                        merchantPortalDefaultOwnerEmail = defaultMerchantPortalOwnerMapping.Owner_Email__c;
                    }

                    List<User> defaultMerchantPortalOwnerList = userDBInstance.getDefaultPortalOwnerByEmail(new Set<String>{merchantPortalDefaultOwnerEmail});

                    Double loanAmount = Double.valueOf(concurrentAccountDetailsMap.get('Max_Funding_Amount__c'));
                    String loanPurpose = String.valueOf(concurrentAccountDetailsMap.get('What_is_used_for__c')) != null ? String.valueOf(concurrentAccountDetailsMap.get('What_is_used_for__c')) : '';
                    Double concurrentEligibleAmount = Double.valueOf(concurrentAccountDetailsMap.get('Concurrent_Eligible_Amount__c'));
                    String contractId = String.valueOf(concurrentAccountDetailsMap.get('contractId'));
                    Integer paymentTerm = Integer.valueOf(concurrentAccountDetailsMap.get('applicationTerm'));
                    String paymentFrequency = String.valueOf(concurrentAccountDetailsMap.get('applicationFrequency'));

                    Id individualLegalStructureId = OriginationHelper.legalNameToId.get(GeneralConstants.LEGAL_TYPE_INDIVIDUAL);

                    List<clcommon__Relationship__c> relationshipList = new List<clcommon__Relationship__c>();

                    List<clcommon__Reciprocal_Role__c> guarantorRoleList = clCommonReciprocalRoleDBInstance.getCLCommonRelationship
                                                                                            (new Set<String> {Leads.GUARANTOR});

                    Id guarantorRelationshipId = guarantorRoleList.isEmpty() ? null : guarantorRoleList[0].Id;

                    List<clcommon__Relationship__c> relatedPrimaryGuarantorsList = clCommonRelationshipDBInstance.getPrimaryGuarantorDetailsByBorrowerId
                                                                                            (new Set<Id> {concurrentAccountId},
                                                                                            new Set<Id> {guarantorRelationshipId});

                    List<Account> concurrentEligibleBorrowerAccountsList = accountDBInstance.getConcurrentEligibleBorrowerAccounts
                                                                                            (new Set<Id> {concurrentAccountId});

                    if(!concurrentEligibleBorrowerAccountsList.isEmpty() && (concurrentEligibleBorrowerAccountsList[0].Migrated_Date__c != null ||
                        concurrentEligibleBorrowerAccountsList[0].Migrated_From__c != null) && newGuarantorForMigratedConcurrentApp){
                        borrowerAccount = concurrentEligibleBorrowerAccountsList[0];
                        List<Contact> borrowerContactsList = contactDBInstance.getRelatedGuarantorContactsByAccId
                                                                    (new Set<Id> {concurrentAccountId});
                        if(!borrowerContactsList.isEmpty()){
                            guarantorAccount.Name = borrowerContactsList[0].Name;
                            guarantorAccount.clcommon__Legal_Entity_type__c = individualLegalStructureId;
                            guarantorAccount.Type = Leads.GUARANTOR;
                            guarantorAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(guarantorAccount.Type.toUpperCase()).getRecordTypeId();
                            accountDBInstance.addInsert(guarantorAccount);
                            accountDBInstance.executeInserts();
                            guarantorContact = borrowerContactsList[0];
                            guarantorContact.AccountId = guarantorAccount.Id;
                            contactDBInstance.addUpdate(guarantorContact);
                            contactDBInstance.executeUpdates();
                            List<AccountContactRelation> accountContactRelationList = accountContactRelationDBInstance.getAccountContactRelationByAccountIds
                                                                                        (new Set<Id> {borrowerAccount.Id});
                            accountContactRelationDBInstance.addDeletes(accountContactRelationList);
                            accountContactRelationDBInstance.executeDeletes();
                            if(relatedPrimaryGuarantorsList.isEmpty()){
                                List<clcommon__Relationship__c> relationshipConcurrentList = clCommonRelationshipDBInstance.getCLCommonRelationships(
                                    new Set<Id> {borrowerAccount.Id}, new Set<Id> {guarantorAccount.Id}, new Set<Id> {guarantorRelationshipId});
                                if(relationshipConcurrentList.isEmpty()) {
                                    clcommon__Relationship__c guarantorRelationship = CLCommonRelationships.createCLCommonRelationships
                                                                                    (borrowerAccount.Id, guarantorAccount.Id, guarantorRelationshipId);
                                    relationshipList.add(guarantorRelationship);
                                }
                            }
                            clCommonRelationshipDBInstance.addInserts(relationshipList);
                            clCommonRelationshipDBInstance.executeInserts();
                        }
                        if(!relatedPrimaryGuarantorsList.isEmpty()){
                            relatedPrimaryGuarantorContactList = contactDBInstance.getRelatedGuarantorContactsByAccId
                                                                        (new Set<Id> {relatedPrimaryGuarantorsList[0].clcommon__Related_Entity__c});
                            guarantorContact = relatedPrimaryGuarantorContactList[0];
                            guarantorAccount.Id = relatedPrimaryGuarantorsList[0].clcommon__Related_Entity__c;
                        }
                        else{
                            Database.rollback(dbSavePoint);
                            return getErrorResponse(PortalConstants.NO_PRIMARY_GUARANTOR_FOUND);
                        }
                    }
                    else if(!concurrentEligibleBorrowerAccountsList.isEmpty() &&
                        concurrentEligibleBorrowerAccountsList[0].Migrated_Date__c == null &&
                        concurrentEligibleBorrowerAccountsList[0].Migrated_From__c == null){
                        borrowerAccount = concurrentEligibleBorrowerAccountsList[0];
                        if(!relatedPrimaryGuarantorsList.isEmpty()){
                            relatedPrimaryGuarantorContactList = contactDBInstance.getRelatedGuarantorContactsByAccId
                                                                        (new Set<Id> {relatedPrimaryGuarantorsList[0].clcommon__Related_Entity__c});
                            guarantorContact = relatedPrimaryGuarantorContactList[0];
                            guarantorAccount.Id = relatedPrimaryGuarantorsList[0].clcommon__Related_Entity__c;
                        }
                        else{
                            Database.rollback(dbSavePoint);
                            return getErrorResponse(PortalConstants.NO_PRIMARY_GUARANTOR_FOUND);
                        }
                    }
                    else{
                        Database.rollback(dbSavePoint);
                        return getErrorResponse(PortalConstants.CONCURRENT_ERROR_MIGRATED_RECORDS);
                    }
                    opportunityRecord = Opportunities.getOpportunityRecordForPortal(borrowerAccount.Id, guarantorContact.Id);
                    opportunityRecord.Name = borrowerAccount.Name;
                    opportunityRecord.Type = PortalConstants.LOAN_TYPE_CONCURRENT;
                    opportunityRecord.Requested_Loan_Amount__c = loanAmount;
                    opportunityRecord.LeadSource = PortalConstants.MERCHANT_PORTAL;
                    opportunityRecord.Concurrent_Eligible_Amount__c = concurrentEligibleAmount;
                    opportunityDBInstance.addInsert(opportunityRecord);
                    opportunityDBInstance.executeInserts();

                    application = ApplicationManager.createApplicationAndParties(
                    opportunityRecord.Id, opportunityRecord.Requested_Loan_Amount__c, borrowerAccount.Id, guarantorAccount.Id, guarantorContact.Id, null, PortalConstants.LOAN_TYPE_CONCURRENT);
                    genesis__Applications__c applicationShell = new genesis__Applications__c(Id = application.Id);
                    applicationShell.What_is_used_for__c = loanPurpose;
                    applicationShell.Sales_Rep__c = defaultMerchantPortalOwnerList[0].Id;
                    applicationShell.Renewal_Concurrent_LoanAccount__c = contractId;
                    applicationShell.genesis__Payment_Frequency__c = paymentFrequency;
                    applicationShell.genesis__Term__c = paymentTerm;
                    applicationDBInstance.addUpdate(applicationShell);
                    applicationDBInstance.executeUpdates();

                    fields.put(PortalConstants.ACCOUNT_ID, borrowerAccount.Id);
                    fields.put(PortalConstants.CONTACT_ID, guarantorContact.Id);
                    fields.put(PortalConstants.APPLICATION_ID, application.Id);
                    response.status = clcommon.Constants.SUCCESS;
                    List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
                    respList.add(new clcommon.PortalCustomRemoteActionRecord('KEY_RESPONSE', fields));
                    response = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
                }
                else{
                    Database.rollback(dbSavePoint);
                    Error_Log__c errorLog = ErrorLogs.createErrorLog (
                    PortalConstants.ERROR_CONCURRENT_APP_CREATION_CATCH_MP, PortalConstants.NO_PERMISSION_ERROR_MSG, null, null, ErrorLogs.ERROR, concurrentAccountId, true);
                    errorLogDBInstance.addInsert(errorLog);
                    errorLogDBInstance.executeInserts();
                    return getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
                }
                return response;
            }
            else{
                Database.rollback(dbSavePoint);
                Error_Log__c errorLog = ErrorLogs.createErrorLog (
                PortalConstants.ERROR_CONCURRENT_APP_CREATION_CATCH_MP, PortalConstants.CONCURRENT_ACCOUNT_DETAILS_NOT_FOUND, null, null, ErrorLogs.ERROR, concurrentAccountId, true);
                errorLogDBInstance.addInsert(errorLog);
                errorLogDBInstance.executeInserts();
                return getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
            }
        }catch(Exception e){
            Database.rollback(dbSavePoint);
            Error_Log__c errorLog = ErrorLogs.createErrorLog (
            PortalConstants.ERROR_CONCURRENT_APP_CREATION_CATCH_MP, e.getMessage(), e.getStackTraceString(), null, ErrorLogs.ERROR, concurrentAccountId, true);
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