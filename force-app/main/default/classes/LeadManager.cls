public class LeadManager
{
    public static AccountDB accountDBInstance = new AccountDB();
    public static ApplicationDB applicationDBInstance = new ApplicationDB();
    public static ContactDB contactDBInstance = new ContactDB();
    public static CLCommonRelationshipDB clCommonRelationshipDBInstance = new CLCommonRelationshipDB();
    public static CLCommonReciprocalRoleDB clCommonReciprocalRoleDBInstance = new CLCommonReciprocalRoleDB();
    public static UserDB userDBInstance = new UserDB();
    public static OpportunityDB opportunityDBInstance = new OpportunityDB();
    public static LegalEntityDB legalEntityDBInstance = new LegalEntityDB();
    public static void convertLeadsAsMerchant(Lead lead)
    {
        User brokerUserRecord;
        Account borrowerAccount;
        Contact guarantorContact;
        Id brokerAccountId;
        Id brokerContactId;
        List<Contact> contactsList = new List<Contact>();
        if(lead.Broker_Contact__c != null) {
            brokerContactId = lead.Broker_Contact__c;
            contactsList = contactDBInstance.getContactsByIds(new Set<Id> {brokerContactId});
            brokerAccountId = contactsList.isEmpty() ? null : contactsList[0].AccountId;
            List<User> users = userDBInstance.getUsersByContactIds(new Set<Id> {lead.Broker_Contact__c});
            brokerUserRecord = users.isEmpty() ? null : users[0];
            if(users.isEmpty()) {
                lead.addError('Broker User Not Found For The Selected Broker Contact');
            }
        }
        try {
            Id legalEntityTypeBusiness = OriginationHelper.legalNameToId.get(lead.Biz_Structure__c);
            borrowerAccount = Accounts.createBorrowerAccount(lead, legalEntityTypeBusiness);
            borrowerAccount.Id = lead.ConvertedAccountId;
            if(brokerContactId != null) {
                borrowerAccount.Broker_Account__c = brokerAccountId;
                borrowerAccount.Broker_Contact__c = brokerContactId;
            }
            accountDBInstance.addUpdate(borrowerAccount);
            accountDBInstance.executeUpdates();
        } catch(exception e) {
            if(e.getMessage().contains('DUPLICATES_DETECTED')) {
                lead.addError('Duplicate Account Found : ' + lead.Company);
            } else {
                lead.addError(e.getMessage());
            }
        }

        String firstName = lead.FirstName != null ? lead.FirstName : '';
        String guarantorAccountName = firstName  + ' ' + lead.LastName;
        List<Account> guarantorAccountDuplicates = accountDbInstance.getDuplicateGuarantorAccounts(guarantorAccountName);
        Id legalEntityTypeIndividual = OriginationHelper.legalNameToId.get(Leads.LEGAL_INDIVIDUAL_ENTITY_TYPE);
        Account guarantorAccount = new Account();
        if(!guarantorAccountDuplicates.isEmpty()) {
            guarantorAccount = guarantorAccountDuplicates[0];
        } else {
            guarantorAccount = Accounts.createGuarantorAccount(lead, legalEntityTypeIndividual);
            guarantorAccount.OwnerId = UserInfo.getUserId();
            if(brokerContactId != null) {
                guarantorAccount.Broker_Account__c = brokerAccountId;
                guarantorAccount.Broker_Contact__c = brokerContactId;
            }
            accountDBInstance.addUpsert(guarantorAccount);
            accountDBInstance.executeUpserts();
        }

        try {
            guarantorContact = Contacts.createGuarantorContact(lead, legalEntityTypeIndividual, guarantorAccount);
            guarantorContact.Id = lead.ConvertedContactId;
            guarantorContact.OwnerId = UserInfo.getUserId();
            if(brokerContactId != null) {
                guarantorContact.Broker_Account__c = brokerAccountId;
                guarantorContact.Broker_Contact__c = brokerContactId;
            }
            contactDBInstance.addUpdate(guarantorContact);
            contactDBInstance.executeUpdates();
        } catch(exception e) {
            if(e.getMessage().contains('DUPLICATES_DETECTED')) {
                lead.addError('Duplicate Contact Found : ' + (lead.FirstName != null ? lead.FirstName : '') + ' ' + lead.LastName);
            } else {
                lead.addError(e.getMessage());
            }
        }

        List<clcommon__Relationship__c> relationshipList = new List<clcommon__Relationship__c>();
        List<clcommon__Reciprocal_Role__c> relationshipRoleList = clCommonReciprocalRoleDBInstance.getCLCommonRelationship(new Set<String> {Leads.GUARANTOR});
        Id relationshipRoleId = relationshipRoleList.isEmpty() ? null : relationshipRoleList[0].Id;
        List<clcommon__Relationship__c> relationshipGuarantorList = clCommonRelationshipDBInstance.getCLCommonRelationships(new Set<Id> {borrowerAccount.Id}, new Set<Id> {guarantorAccount.Id}, new Set<Id> {relationshipRoleId});
        if(relationshipGuarantorList.isEmpty()) {
            clcommon__Relationship__c relationship = CLCommonRelationships.createCLCommonRelationships(borrowerAccount.Id, guarantorAccount.Id, relationshipRoleId);
            relationshipList.add(relationship);
        }
        if(brokerAccountId != null) {
            relationshipRoleList = clCommonReciprocalRoleDBInstance.getCLCommonRelationship(new Set<String> {Leads.BROKER});
            relationshipRoleId = relationshipRoleList.isEmpty() ? null : relationshipRoleList[0].Id;
            List<clcommon__Relationship__c> relationshipBrokerList = clCommonRelationshipDBInstance.getCLCommonRelationships(new Set<Id> {borrowerAccount.Id}, new Set<Id> {brokerAccountId}, new Set<Id> {relationshipRoleId});
            if(relationshipBrokerList.isEmpty()) {
                clcommon__Relationship__c relationshipBroker = CLCommonRelationships.createCLCommonRelationships(borrowerAccount.Id, brokerAccountId, relationshipRoleId);
                relationshipList.add(relationshipBroker);
            }
        }
        clCommonRelationshipDBInstance.addInserts(relationshipList);
        clCommonRelationshipDBInstance.executeInserts();

        if(lead.ConvertedOpportunityId != null)
        {
            Opportunity opportunityRecord = Opportunities.createOpportunity(lead, borrowerAccount);
            opportunityRecord.Primary_Contact__c = guarantorContact.Id;
            opportunityRecord.OwnerId = UserInfo.getUserId();
            if(brokerContactId != null) {
                opportunityRecord.Broker_Account__c = brokerAccountId;
                opportunityRecord.Broker_Contact__c = brokerContactId;
            }
            opportunityDBInstance.addUpdate(opportunityRecord);
            opportunityDBInstance.executeUpdates();

            ID opportunityId = opportunityRecord.Id;
            Decimal amount = opportunityRecord.Requested_Loan_Amount__c;
            ID borrowerAccountID = borrowerAccount.Id;
            ID guarantorAccountID = guarantorAccount.Id;
            ID guarantorContactId = guarantorContact.Id;
            if(amount != null) {
                genesis__Applications__c application = ApplicationManager.createApplicationAndParties(
                    opportunityId, amount, borrowerAccountID, guarantorAccountID, guarantorContactId, brokerUserRecord,
                    opportunityRecord.Type
                );

                if(application != null)
                {
                    genesis__Applications__c applicationShell = new genesis__Applications__c(Id = application.Id);
                    applicationShell.What_is_used_for__c = lead.Use_of_Funds__c;
                    applicationShell.Sales_Rep__c = opportunityRecord.OwnerId != null ? opportunityRecord.OwnerId : UserInfo.getUserId();
                    if(brokerUserRecord != null) {
                        applicationShell.OwnerId = brokerUserRecord.Id;
                    }
                    applicationDBInstance.addUpdate(applicationShell);
                    applicationDBInstance.executeUpdates();
                    Map<Id, String> attachmentIdToFileName = ContentDocumentLinkManager.getContentDocumentLinkByParentIds(new Set<Id> {lead.Id});
                    if(attachmentIdToFileName != null) {
                        CategoryAttachAssnManager.createBulkDocumentCategoryAssociationForApplication(
                            attachmentIdToFileName, applicationShell.Id, GeneralConstants.DOCUMENT_TYPE_BANK_STATEMENTS);
                    }
                }
            }
        }
    }

    public static void convertLeadsAsBroker(Lead lead)
    {
        Account brokerAccount;
        Contact brokerContact;
        try {
            brokerAccount = Accounts.createBrokerAccount(lead);
            brokerAccount.Id = lead.ConvertedAccountId;
            accountDBInstance.addUpdate(brokerAccount);
            accountDBInstance.executeUpdates();

            List<clcommon__Reciprocal_Role__c> relationshipRoleList = clCommonReciprocalRoleDBInstance.getCLCommonRelationship(new Set<String> {'Self'});
            Id relationshipRoleId = relationshipRoleList.isEmpty() ? null : relationshipRoleList[0].Id;
            List<clcommon__Relationship__c> relationshipBrokersList = clCommonRelationshipDBInstance.getCLCommonRelationships(new Set<Id> {brokerAccount.Id}, new Set<Id> {brokerAccount.Id}, new Set<Id> {relationshipRoleId});
            if(relationshipBrokersList.isEmpty()) {
                clcommon__Relationship__c relationship = CLCommonRelationships.createCLCommonRelationships(brokerAccount.Id, brokerAccount.Id, relationshipRoleId);
                clCommonRelationshipDBInstance.addInsert(relationship);
                clCommonRelationshipDBInstance.executeInserts();
            }

        } catch(exception e) {
            lead.addError(e.getMessage());
        }

        try {
            brokerContact = Contacts.createBrokerContact(lead, brokerAccount);
            brokerContact.Id = lead.ConvertedContactId;
            contactDBInstance.addUpdate(brokerContact);
            contactDBInstance.executeUpdates();
        } catch(exception e) {
            lead.addError(e.getMessage());
        }

        if(lead.ConvertedOpportunityId != null) {
          Opportunity opportunityRecord = Opportunities.createOpportunity(lead, brokerAccount);
          opportunityRecord.Primary_Contact__c = brokerContact.Id;
          opportunityDBInstance.addUpdate(opportunityRecord);
          opportunityDBInstance.executeUpdates();
        }
    }

    private class LeadManagerException extends Exception {}
}