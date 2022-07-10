public class EISRenewalManager
{
    public static AccountDB accountDBInstance = new AccountDB();
    public static CLCommonRelationshipDB clCommonRelationshipDBInstance = new CLCommonRelationshipDB();
    public static CLCommonReciprocalRoleDB clCommonReciprocalRoleDBInstance = new CLCommonReciprocalRoleDB();
    public static ContactDB contactDBInstance = new ContactDB();
    public static ApplicationDB applicationDBInstance = new ApplicationDB();
    public static OpportunityDB opportunityDBInstance = new OpportunityDB();
    public static UserDB userDBInstance = new UserDB();
    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    public static OcrolusReportDB ocrolusReportDBInstance = new OcrolusReportDB();
    public static Id individualLegalStructureId = OriginationHelper.legalNameToId.get(GeneralConstants.LEGAL_TYPE_INDIVIDUAL);
    public static List<clcommon__Relationship__c> relationshipList = new List<clcommon__Relationship__c>();
    public static List<clcommon__Reciprocal_Role__c> guarantorRoleList = clCommonReciprocalRoleDBInstance.getCLCommonRelationship
                                                                                (new Set<String> {Leads.GUARANTOR});
    public static List<clcommon__Reciprocal_Role__c> brokerRoleList = clCommonReciprocalRoleDBInstance.getCLCommonRelationship
                                                                                (new Set<String> {Leads.BROKER});
    public static Id guarantorRelationshipId = guarantorRoleList.isEmpty() ? null : guarantorRoleList[0].Id;
    public static Id brokerRelationshipId = brokerRoleList.isEmpty() ? null : brokerRoleList[0].Id;

    public static void createRenewalApplication(Account borrowerAccount)
    {
        SavePoint dbSavePoint = Database.setSavePoint();
        try {
            List<Contact> borrowerContactsList = contactDBInstance.getRelatedGuarantorContactsByAccId
                                                        (new Set<Id> {borrowerAccount.Id});
            Account guarantorAccount = new Account();
            Contact guarantorContact = new Contact();

            Id brokerAccountId;
            User brokerUser;
            if(borrowerAccount.Broker_Account__c != null) {
                brokerAccountId = borrowerAccount.Broker_Account__c;
            }
            if(borrowerAccount.Broker_Contact__c != null) {
                List<User> users = userDBInstance.getUsersByBrokerContactIds(new Set<Id> {borrowerAccount.Broker_Contact__c});
                brokerUser = users.isEmpty() ? null : users[0];
                if(users.isEmpty()) {
                    throw new EISRenewalManagerException('Broker User Not Found For The Selected Broker Contact');
                }
            }

            if(!borrowerContactsList.isEmpty()) {
                guarantorAccount.Name = borrowerContactsList[0].Name;
                guarantorAccount.clcommon__Legal_Entity_type__c = individualLegalStructureId;
                guarantorAccount.OwnerId = borrowerAccount.OwnerId != null ? borrowerAccount.OwnerId : UserInfo.getUserId();
                guarantorAccount.Type = Leads.GUARANTOR;
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
            } else {
                List<clcommon__Relationship__c> relatedGuarantorsList = clCommonRelationshipDBInstance.getGuarantorsByBorrowerIds
                                                                        (new Set<Id> {borrowerAccount.Id}, new Set<Id> {guarantorRelationshipId});
                if(relatedGuarantorsList.isEmpty()) { throw new EISRenewalManagerException('Guarantor Contact details not found'); }

                List<Account> guarantorAccountList = accountDBInstance.getGuarantorAccountsByIds(new Set<Id> {relatedGuarantorsList[0].clcommon__Related_Entity__c});
                guarantorAccount = guarantorAccountList[0];
                List<Contact> guarantorContactList = contactDBInstance.getRelatedGuarantorContactsByAccId(new Set<Id> {relatedGuarantorsList[0].clcommon__Related_Entity__c});
                guarantorContact = guarantorContactList[0];
            }
            Opportunity opportunityRecord = new Opportunity();
            opportunityRecord.Name = borrowerAccount.Name;
            opportunityRecord.StageName = Leads.LEAD_STAGE_APP_SUBMITTED;
            opportunityRecord.Sub_Status__c = Leads.LEAD_SUB_STATUS_SCORE_PENDING;
            opportunityRecord.Type = GeneralConstants.LOAN_TYPE_RENEWAL;
            opportunityRecord.CloseDate = GeneralHelper.currentSystemDate.addYears(1);
            opportunityRecord.AccountId = borrowerAccount.Id;
            opportunityRecord.LeadSource = 'EIS';
            opportunityRecord.OwnerId = borrowerAccount.OwnerId != null ? borrowerAccount.OwnerId : UserInfo.getUserId();
            opportunityRecord.Requested_Loan_Amount__c = borrowerAccount.Legacy_Current_Balance__c != null ? borrowerAccount.Legacy_Current_Balance__c : 100;
            opportunityRecord.Primary_Contact__c = guarantorContact.Id;
            if(borrowerAccount.Is_Exclusivity__c) {
                opportunityRecord.Broker_Account__c = borrowerAccount.Broker_Account__c;
                opportunityRecord.Broker_Contact__c = borrowerAccount.Broker_Contact__c;
            }
            opportunityRecord.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
            opportunityDBInstance.addInsert(opportunityRecord);
            opportunityDBInstance.executeInserts();
            dbSavePoint =  Database.setSavePoint();

            ID opportunityId = opportunityRecord.Id;
            Decimal amount = opportunityRecord.Requested_Loan_Amount__c;
            ID borrowerAccountID = borrowerAccount.Id;
            ID guarantorAccountID = guarantorAccount.Id;
            ID guarantorContactId = guarantorContact.Id;

            genesis__Applications__c application = ApplicationManager.createApplicationAndParties(
                opportunityId, amount, borrowerAccountID, guarantorAccountID, guarantorContactId, brokerUser,
                opportunityRecord.Type
            );
            genesis__Applications__c applicationShell = new genesis__Applications__c(Id = application.Id);
            applicationShell.Sales_Rep__c = opportunityRecord.OwnerId != null ? opportunityRecord.OwnerId : UserInfo.getUserId();
            applicationShell.Annual_Volume__c = borrowerAccount.Legacy_GAV__c;
            applicationShell.OwnerId = brokerUser != null && brokerUser.IsActive ? brokerUser.Id : opportunityRecord.OwnerId;
            applicationShell.Renewal_Contract_Number__c = borrowerAccount.Current_Active_Contract_Number__c;
            applicationShell.CAN_Pay_Off_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
            applicationShell.Is_EIS_Renewal__c = true;
            applicationShell.Auto_Renewed__c = true;
            applicationShell.Credit_Check_Consent__c = true;
            applicationDBInstance.addUpdate(applicationShell);
            applicationDBInstance.executeUpdates();

            CAN_Ocrolus_Report__c ocrolusReport = CANOcrolusReports.createEISRenewalApplicationOcrolusReport(application.Id, borrowerAccount.Legacy_GAV__c);
            ocrolusReportDBInstance.addInsert(ocrolusReport).executeInserts();
        } catch (exception e) {
            Database.rollback(dbSavePoint);
            Error_Log__c errorLog = ErrorLogs.createErrorLog (
                'EIS Renewal', e.getMessage(), e.getStackTraceString(),
                null, 'Error', null, true
            );
            errorLogDBInstance.addInsert(errorLog);
            errorLogDBInstance.executeInserts();
        }
    }

    private class EISRenewalManagerException extends Exception {}
}