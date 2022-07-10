global class CCBPCreateConcurrentApplicationAPI implements clcommon.PortalCustomRemoteAPI1 {
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
        Map<String, Object> applicationDetailsMap = new Map<String, Object>();
        Id concurrentAccountId;
        try{
            if((argumentsFromPortal.containsKey(PortalConstants.CONCURRENT_ACCOUNT_DETAILS) && argumentsFromPortal.get(PortalConstants.CONCURRENT_ACCOUNT_DETAILS) != null) &&
            (argumentsFromPortal.containsKey(PortalConstants.APPLICATION_DETAILS) && argumentsFromPortal.get(PortalConstants.APPLICATION_DETAILS) != null)){
                concurrentAccountDetailsMap = (Map<String, Object>)JSON.deserializeUntyped((String)argumentsFromPortal.get(PortalConstants.CONCURRENT_ACCOUNT_DETAILS));
                applicationDetailsMap = (Map<String, Object>)JSON.deserializeUntyped((String)argumentsFromPortal.get(PortalConstants.APPLICATION_DETAILS));
                concurrentAccountId = (Id)concurrentAccountDetailsMap.get('Id');
                Boolean isValidUser;
                isValidUser = CLSPBPortalSecurity.validateUserByBorrowerAccountId(concurrentAccountId);
                if(isValidUser){
                    Opportunity opportunityRecord = new Opportunity();
                    Account borrowerAccount = new Account();
                    Account guarantorAccount = new Account();
                    Contact guarantorContact = new Contact();
                    Map<String,Object> fields = new Map<String,Object>();
                    List<Contact> relatedPrimaryGuarantorContactList = new List<Contact>();
                    genesis__Applications__c application = new genesis__Applications__c();
                    boolean newGuarantorForMigratedConcurrentApp = CustomMetaDataHelper.defaultGeneralSetting.Link_Guarantor_For_Migrated_Concrt_App__c;
                    String brokerPortalDefaultOwnerEmail;
                    Default_Portal_Owner_Mapping__mdt defaultBrokerPortalOwnerMapping = CustomMetaDataHelper.defaultPortalOwnerMap.get(PortalConstants.DEFAULT_BROKER_PORTAL_OWNER);
                    if(defaultBrokerPortalOwnerMapping != null){
                        brokerPortalDefaultOwnerEmail = defaultBrokerPortalOwnerMapping.Owner_Email__c;
                    }
                    List<User> defaultBrokerPortalOwnerList = userDBInstance.getDefaultPortalOwnerByEmail(new Set<String>{brokerPortalDefaultOwnerEmail});
                    Double loanAmount = Double.valueOf(concurrentAccountDetailsMap.get('Max_Funding_Amount__c'));
                    String loanPurpose = String.valueOf(concurrentAccountDetailsMap.get('What_is_used_for__c')) != null ? String.valueOf(concurrentAccountDetailsMap.get('What_is_used_for__c')) : '';
                    Double concurrentEligibleAmount = Double.valueOf(concurrentAccountDetailsMap.get('Concurrent_Eligible_Amount__c'));
                    String contractId = String.valueOf(concurrentAccountDetailsMap.get('contractId'));
                    String paymentFrequency =  String.valueOf(applicationDetailsMap.get('Application__r.genesis__Payment_Frequency__c'));
                    Integer paymentTerm = Integer.valueOf(applicationDetailsMap.get('Application__r.genesis__Term__c'));

                    List<User> loggedInBrokerUsersList = userDBInstance.getBrokerUserDetailsByLoggedInId();
                    Id individualLegalStructureId = OriginationHelper.legalNameToId.get(GeneralConstants.LEGAL_TYPE_INDIVIDUAL);

                    List<clcommon__Relationship__c> relationshipList = new List<clcommon__Relationship__c>();

                    List<clcommon__Reciprocal_Role__c> guarantorRoleList = clCommonReciprocalRoleDBInstance.getCLCommonRelationship
                        (new Set<String> {Leads.GUARANTOR});
                    List<clcommon__Reciprocal_Role__c> brokerRoleList = clCommonReciprocalRoleDBInstance.getCLCommonRelationship
                        (new Set<String> {Leads.BROKER});

                    Id guarantorRelationshipId = guarantorRoleList.isEmpty() ? null : guarantorRoleList[0].Id;
                    Id brokerRelationshipId = brokerRoleList.isEmpty() ? null : brokerRoleList[0].Id;

                    List<clcommon__Relationship__c> relatedPrimaryGuarantorsList = clCommonRelationshipDBInstance.getPrimaryGuarantorDetailsByBorrowerId
                        (new Set<Id> {concurrentAccountId},
                         new Set<Id> {guarantorRelationshipId});
                    List<clcommon__Relationship__c> relatedBrokerList = clCommonRelationshipDBInstance.getBrokerDetailsByBorrowerId
                        (new Set<Id> {concurrentAccountId},
                         new Set<Id> {brokerRelationshipId});

                    List<Account> concurrentEligibleBorrowerAccountsList = accountDBInstance.getConcurrentEligibleBorrowerAccounts
                        (new Set<Id> {concurrentAccountId});

                    if(!concurrentEligibleBorrowerAccountsList.isEmpty() && (concurrentEligibleBorrowerAccountsList[0].Migrated_Date__c != null || concurrentEligibleBorrowerAccountsList[0].Migrated_From__c != null) && newGuarantorForMigratedConcurrentApp){
                        borrowerAccount = concurrentEligibleBorrowerAccountsList[0];
                        List<Contact> borrowerContactsList = contactDBInstance.getRelatedGuarantorContactsByAccId
                            (new Set<Id> {concurrentAccountId});
                        if(!borrowerContactsList.isEmpty()){
                            guarantorAccount.Name = borrowerContactsList[0].Name;
                            guarantorAccount.clcommon__Legal_Entity_type__c = individualLegalStructureId;
                            guarantorAccount.Type = Leads.GUARANTOR;
                            guarantorAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(guarantorAccount.Type.toUpperCase()).getRecordTypeId();
                            guarantorAccount.OwnerId = defaultBrokerPortalOwnerList[0].Id;
                            accountDBInstance.addInsert(guarantorAccount);
                            accountDBInstance.executeInserts();
                            guarantorContact = borrowerContactsList[0];
                            guarantorContact.AccountId = guarantorAccount.Id;
                            guarantorContact.OwnerId = defaultBrokerPortalOwnerList[0].Id;
                            contactDBInstance.addUpdate(guarantorContact);
                            contactDBInstance.executeUpdates();
                            List<AccountContactRelation> accountContactRelationList = accountContactRelationDBInstance.getAccountContactRelationByAccountIds
                                (new Set<Id> {borrowerAccount.Id});
                            accountContactRelationDBInstance.addDeletes(accountContactRelationList);
                            accountContactRelationDBInstance.executeDeletes();
                            if(relatedPrimaryGuarantorsList.isEmpty()){
                                List<clcommon__Relationship__c> relationshipGuarantorList = clCommonRelationshipDBInstance.getCLCommonRelationships(
                                    new Set<Id> {borrowerAccount.Id}, new Set<Id> {guarantorAccount.Id}, new Set<Id> {guarantorRelationshipId});
                                if(relationshipGuarantorList.isEmpty()) {
                                    clcommon__Relationship__c guarantorRelationship = CLCommonRelationships.createCLCommonRelationships
                                    (borrowerAccount.Id, guarantorAccount.Id, guarantorRelationshipId);
                                    relationshipList.add(guarantorRelationship);
                                }
                            }
                            if(relatedBrokerList.isEmpty() && !loggedInBrokerUsersList.isEmpty()){
                                List<clcommon__Relationship__c> relationshipBrokerList = clCommonRelationshipDBInstance.getCLCommonRelationships(
                                    new Set<Id> {borrowerAccount.Id}, new Set<Id> {loggedInBrokerUsersList[0].AccountId}, new Set<Id> {brokerRelationshipId});
                                if(relationshipBrokerList.isEmpty()) {
                                    clcommon__Relationship__c brokerRelationship = CLCommonRelationships.createCLCommonRelationships
                                    (borrowerAccount.Id, loggedInBrokerUsersList[0].AccountId, brokerRelationshipId);
                                    relationshipList.add(brokerRelationship);
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
                        return getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
                    }
                    opportunityRecord = Opportunities.getOpportunityRecordForPortal(borrowerAccount.Id, guarantorContact.Id);
                    opportunityRecord.Name = borrowerAccount.Name;
                    opportunityRecord.Type = PortalConstants.LOAN_TYPE_CONCURRENT;
                    opportunityRecord.Requested_Loan_Amount__c = loanAmount;
                    opportunityRecord.LeadSource = PortalConstants.BROKER_PORTAL;
                    opportunityRecord.Broker_Account__c = loggedInBrokerUsersList[0].AccountId;
                    opportunityRecord.Broker_Contact__c = loggedInBrokerUsersList[0].ContactId;
                    opportunityRecord.OwnerId = defaultBrokerPortalOwnerList[0].Id;
                    opportunityRecord.Concurrent_Eligible_Amount__c = concurrentEligibleAmount;
                    opportunityDBInstance.addInsert(opportunityRecord);
                    opportunityDBInstance.executeInserts();

                    application = ApplicationManager.createApplicationAndParties(
                        opportunityRecord.Id, opportunityRecord.Requested_Loan_Amount__c, borrowerAccount.Id, guarantorAccount.Id, guarantorContact.Id, loggedInBrokerUsersList.get(0),
                        PortalConstants.LOAN_TYPE_CONCURRENT
                    );
                    genesis__Applications__c applicationShell = new genesis__Applications__c(Id = application.Id);
                    applicationShell.What_is_used_for__c = loanPurpose;
                    applicationShell.Sales_Rep__c = defaultBrokerPortalOwnerList[0].Id;
                    applicationShell.Renewal_Concurrent_LoanAccount__c = contractId;
                    applicationShell.genesis__Payment_Frequency__c = paymentFrequency;
                    applicationShell.genesis__Term__c = paymentTerm;
                    applicationDBInstance.addUpdate(applicationShell);
                    applicationDBInstance.executeUpdates();

                    fields.put(PortalConstants.ACCOUNT_ID, borrowerAccount.Id);
                    fields.put(PortalConstants.BORROWER_ACCOUNT_ID, guarantorAccount.Id);
                    fields.put(PortalConstants.CONTACT_ID, guarantorContact.Id);
                    fields.put(PortalConstants.APPLICATION_ID, application.Id);
                    fields.put(PortalConstants.CLIENT_TYPE, PortalConstants.BUSINESS);
                    response.status = clcommon.Constants.SUCCESS;
                    List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
                    respList.add(new clcommon.PortalCustomRemoteActionRecord('KEY_RESPONSE', fields));
                    response = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
                }
                else{
                    Database.rollback(dbSavePoint);
                    Error_Log__c errorLog = ErrorLogs.createErrorLog (
                        PortalConstants.ERROR_CONCURRENT_APP_CREATION_CATCH_BP, PortalConstants.ACCESS_DENIED_CREATE_CONCURRENT_APPLICATION, null,
                        null, ErrorLogs.ERROR, concurrentAccountId, true);
                    errorLogDBInstance.addInsert(errorLog);
                    errorLogDBInstance.executeInserts();
                    return getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
                }
                return response;
            }else{
                Database.rollback(dbSavePoint);
                Error_Log__c errorLog = ErrorLogs.createErrorLog (
                    PortalConstants.ERROR_CONCURRENT_APP_CREATION_CATCH_BP, PortalConstants.CONCURRENT_ACCOUNT_DETAILS_NOT_FOUND, null,
                    null, ErrorLogs.ERROR, concurrentAccountId, true);
                errorLogDBInstance.addInsert(errorLog);
                errorLogDBInstance.executeInserts();
                return getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
            }
        }catch(Exception e){
            Database.rollback(dbSavePoint);
            Error_Log__c errorLog = ErrorLogs.createErrorLog (
                PortalConstants.ERROR_CONCURRENT_APP_CREATION_CATCH_BP, e.getMessage(), e.getStackTraceString(),
                null, ErrorLogs.ERROR, concurrentAccountId, true);
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