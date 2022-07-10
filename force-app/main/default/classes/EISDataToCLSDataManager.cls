public class EISDataToCLSDataManager
{
    public static AccountDB accountDBInstance = new AccountDB();
    public static CLCommonRelationshipDB clCommonRelationshipDBInstance = new CLCommonRelationshipDB();
    public static CLCommonReciprocalRoleDB clCommonReciprocalRoleDBInstance = new CLCommonReciprocalRoleDB();
    public static ContactDB contactDBInstance = new ContactDB();
    public static UserDB userDBInstance = new UserDB();
    public static AccountContactRelationDB accountContactRelationDBInstance = new AccountContactRelationDB();
    public static Id individualLegalStructureId = OriginationHelper.legalNameToId.get(GeneralConstants.LEGAL_TYPE_INDIVIDUAL);
    public static List<clcommon__Relationship__c> relationshipList = new List<clcommon__Relationship__c>();
    public static List<clcommon__Reciprocal_Role__c> guarantorRoleList = clCommonReciprocalRoleDBInstance.getCLCommonRelationship
        (new Set<String> {Leads.GUARANTOR});
    public static List<clcommon__Reciprocal_Role__c> brokerRoleList = clCommonReciprocalRoleDBInstance.getCLCommonRelationship
        (new Set<String> {Leads.BROKER});
    public static Id guarantorRelationshipId = guarantorRoleList.isEmpty() ? null : guarantorRoleList[0].Id;
    public static Id brokerRelationshipId = brokerRoleList.isEmpty() ? null : brokerRoleList[0].Id;

    public static void convertToCLSDataModel(Account borrowerAccount)
    {
        List<Contact> borrowerContactsList = contactDBInstance.getRelatedGuarantorContactsByAccId(new Set<Id> {borrowerAccount.Id});
        Account guarantorAccount = new Account();
        Contact guarantorContact = new Contact();

        Id brokerAccountId;
        if(borrowerAccount.Broker_Account__c != null) {
            brokerAccountId = borrowerAccount.Broker_Account__c;
        }

        if(!borrowerContactsList.isEmpty()) {
            guarantorAccount.Name = borrowerContactsList[0].Name;
            guarantorAccount.clcommon__Legal_Entity_type__c = individualLegalStructureId;
            guarantorAccount.OwnerId = borrowerAccount.OwnerId != null ? borrowerAccount.OwnerId : UserInfo.getUserId();
            guarantorAccount.Type = Leads.GUARANTOR;
            guarantorAccount.AccountSource = borrowerAccount.AccountSource;
            guarantorAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(guarantorAccount.Type.toUpperCase()).getRecordTypeId();
            if(borrowerAccount.Broker_Account__c != null && borrowerAccount.Broker_Contact__c != null) {
                guarantorAccount.Broker_Account__c = borrowerAccount.Broker_Account__c;
                guarantorAccount.Broker_Contact__c = borrowerAccount.Broker_Contact__c;
            }
            accountDBInstance.addInsert(guarantorAccount);
            accountDBInstance.executeInserts();

            guarantorContact = borrowerContactsList[0];
            guarantorContact.AccountId = guarantorAccount.Id;
            guarantorAccount.OwnerId = borrowerAccount.OwnerId != null ? borrowerAccount.OwnerId : UserInfo.getUserId();
            guarantorContact.loan__Contact_Type__c = Leads.GUARANTOR;
            contactDBInstance.addUpdate(guarantorContact);
            contactDBInstance.executeUpdates();

            List<AccountContactRelation> accountContactRelationList = accountContactRelationDBInstance.getAccountContactRelationByAccountIds
                (new Set<Id> {borrowerAccount.Id});
            accountContactRelationDBInstance.addDeletes(accountContactRelationList);
            accountContactRelationDBInstance.executeDeletes();

            List<clcommon__Relationship__c> relationshipGuarantorList = clCommonRelationshipDBInstance.getCLCommonRelationships(
                                    new Set<Id> {borrowerAccount.Id}, new Set<Id> {guarantorAccount.Id}, new Set<Id> {guarantorRelationshipId});
            if(relationshipGuarantorList.isEmpty()) {
                clcommon__Relationship__c guarantorRelationship = CLCommonRelationships.createCLCommonRelationships
                    (borrowerAccount.Id, guarantorAccount.Id, guarantorRelationshipId);
                relationshipList.add(guarantorRelationship);
            }

            if(brokerAccountId != null) {
                List<clcommon__Relationship__c> relationshipBrokerList = clCommonRelationshipDBInstance.getCLCommonRelationships(
                                    new Set<Id> {borrowerAccount.Id}, new Set<Id> {brokerAccountId}, new Set<Id> {brokerRelationshipId});
                if(relationshipBrokerList.isEmpty()) {
                    clcommon__Relationship__c brokerRelationship = CLCommonRelationships.createCLCommonRelationships
                        (borrowerAccount.Id, brokerAccountId, brokerRelationshipId);
                    relationshipList.add(brokerRelationship);
                }
            }
            clCommonRelationshipDBInstance.addUpserts(relationshipList);
            clCommonRelationshipDBInstance.executeUpserts();

            borrowerAccount.EIS_To_CLS_Converted__c = true;
            accountDBInstance.addUpdate(borrowerAccount);
            accountDBInstance.executeUpdates();
        }
    }
}