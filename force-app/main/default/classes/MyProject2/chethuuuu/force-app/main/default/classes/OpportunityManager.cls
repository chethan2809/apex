public class OpportunityManager {
    public static ApplicationDB applicationDBInstance = new ApplicationDB();
    public static AccountDB accountDBInstance = new AccountDB();
    public static ContactDB contactDBInstance = new ContactDB();
    public static UserDB userDBInstance = new UserDB();
    private static CLContractDB clContractDBInstance = new CLContractDB();
    public static Boolean mandatoryCheck;

    public static void createApplication(Map<Id, Opportunity> opportunityMap)
    {
        for(Opportunity opportunityRecord : opportunityMap.values()) {
            if(opportunityRecord.Create_Application__c && !applicationExists(new Set<Id> {opportunityRecord.Id})) {
                mandatoryInformationCheck(opportunityRecord);
                ID opportunityId = opportunityRecord.Id;
                Decimal amount = opportunityRecord.Requested_Loan_Amount__c;
                ID borrowerAccountID = opportunityRecord.AccountId;
                List<Contact> contactList = contactDBInstance.getContactsByIds(new Set<Id> {opportunityRecord.Primary_Contact__c});
                ID guarantorAccountID = contactList.isEmpty() ? null : contactList[0].AccountId;
                ID guarantorContactId = opportunityRecord.Primary_Contact__c;
                User brokerUserRecord;
                if(opportunityRecord.Broker_Contact__c != null) {
                    List<User> users = userDBInstance.getUsersByContactIds(new Set<Id> {opportunityRecord.Broker_Contact__c});
                    brokerUserRecord = users.isEmpty() ? null : users[0];
                    if(users.isEmpty()) {
                        opportunityRecord.addError('Broker User Not Found For The Selected Broker Contact');
                    }
                }
                if(amount != null) {
                    genesis__Applications__c application = ApplicationManager.createApplicationAndParties(
                        opportunityId, amount, borrowerAccountID, guarantorAccountID, guarantorContactId, brokerUserRecord, opportunityRecord.Type
                    );
                    if(application != null)
                    {
                        List<loan__Loan_Account__c> loanContractList = clContractDBInstance.getRecentLoanAccountsByOppAccountIds(new Set<Id> {opportunityRecord.AccountId});
                        genesis__Applications__c applicationShell = new genesis__Applications__c(Id = application.Id);
                        if(loanContractList.isEmpty()) {
                            List<Account> borrowerAccountList = accountDBInstance.getAccountByIds(new Set<Id> {borrowerAccountID});
                            Account borrowerAccount = borrowerAccountList.isEmpty() ? new Account() : borrowerAccountList[0];
                            if((opportunityRecord.Type == GeneralConstants.LOAN_TYPE_RENEWAL || opportunityRecord.Type == GeneralConstants.LOAN_TYPE_CONCURRENT) &&
                                borrowerAccount.AccountSource == 'EIS')
                            {
                                if(borrowerAccount.Current_Active_Contract_Number__c == null) {
                                    opportunityRecord.addError('Please update Current Active Contract Number in Borrower Account');
                                } else {
                                    applicationShell.Sales_Rep__c = opportunityRecord.OwnerId != null ? opportunityRecord.OwnerId : UserInfo.getUserId();
                                    applicationShell.Annual_Volume__c = borrowerAccount.AnnualRevenue;
                                    applicationShell.OwnerId = brokerUserRecord != null ? brokerUserRecord.Id : applicationShell.Sales_Rep__c;
                                    applicationShell.CAN_Pay_Off_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
                                    applicationShell.Renewal_Contract_Number__c = borrowerAccount.Current_Active_Contract_Number__c;
                                    applicationShell.Is_EIS_Renewal__c = true;
                                }
                            } else if(opportunityRecord.Type == GeneralConstants.LOAN_TYPE_RENEWAL || opportunityRecord.Type == GeneralConstants.LOAN_TYPE_CONCURRENT) {
                                opportunityRecord.addError('No CL Contract found for Borrower Account');
                            } else {
                                applicationShell.Sales_Rep__c = opportunityRecord.OwnerId != null ? opportunityRecord.OwnerId : UserInfo.getUserId();
                                applicationShell.OwnerId = brokerUserRecord != null ? brokerUserRecord.Id : applicationShell.Sales_Rep__c;
                            }
                            borrowerAccount.Legacy_Renewal_Application_Created_Date__c = GeneralHelper.currentSystemDate;
                            accountDBInstance.addUpdate(borrowerAccount);
                            accountDBInstance.executeUpdates();
                        } else {
                            if(!loanContractList.isEmpty() && (opportunityRecord.Type == GeneralConstants.LOAN_TYPE_RENEWAL ||
                                opportunityRecord.Type == GeneralConstants.LOAN_TYPE_CONCURRENT))
                            {
                                Applications.setRenewalApplicationFieldsFromLoanAccount(applicationShell, loanContractList[0]);
                            }
                            applicationShell.Sales_Rep__c = opportunityRecord.OwnerId != null ? opportunityRecord.OwnerId : UserInfo.getUserId();
                            applicationShell.OwnerId = brokerUserRecord != null ? brokerUserRecord.Id : applicationShell.Sales_Rep__c;
                        }
                        if(!loanContractList.isEmpty() && opportunityRecord.Type == GeneralConstants.LOAN_TYPE_CONCURRENT) {
                            applicationShell.genesis__Payment_Frequency__c = loanContractList.get(0).Application__r.genesis__Payment_Frequency__c;
                            applicationShell.genesis__Term__c = loanContractList.get(0).Application__r.genesis__Term__c;
                        }
                        applicationDBInstance.addUpdate(applicationShell);
                        applicationDBInstance.executeUpdates();
                        Map<Id, String> attachmentIdToFileName = ContentDocumentLinkManager.getContentDocumentLinkByParentIds(new Set<Id> {opportunityRecord.Id});
                        CategoryAttachAssnManager.createBulkDocumentCategoryAssociationForApplication(
                                attachmentIdToFileName, application.Id, GeneralConstants.DOCUMENT_TYPE_OTHERS);
                    }
                }
            }
        }
    }

    public static Boolean applicationExists(Set<Id> opportunityIds) {
        List<genesis__Applications__c> applicationList = applicationDBInstance.getApplicationsByOpportunityIds(opportunityIds);
        return applicationList.isEmpty() ? false : true;
    }

    public static void mandatoryInformationCheck(Opportunity opportunityRecord)
    {
        List<Account> accountList = accountDBInstance.getAccountByIds(new Set<Id> {opportunityRecord.AccountId});
        List<Contact> contactList = contactDBInstance.getContactsByIds(new Set<Id> {opportunityRecord.Primary_Contact__c});
        mandatoryCheck = true;
        String errorString = '';
        for(Account accountRecord : accountList)
        {
            if(accountRecord.Business_Tax_ID__c == null) {
                mandatoryCheck = false;
                errorString += 'Business Tax Id';
            }
            if(accountRecord.Biz_Start_Date__c == null) {
                mandatoryCheck = false;
                errorString += errorString != '' ? ', ' + 'Biz start date' : 'Biz start date';
            }
            if(accountRecord.clcommon__Legal_Entity_type__c == null) {
                mandatoryCheck = false;
                errorString += errorString != '' ? ', ' + 'Legal Entity' : 'Legal Entity';
            }
            if(accountRecord.BillingCountry == null) {
                mandatoryCheck = false;
                errorString += errorString != '' ? ', ' + 'Billing Address Country' : 'Billing Address Country';
            }
        }
        for(Contact contactRecord : contactList)
        {
            if(contactRecord.Email == null) {
                mandatoryCheck = false;
                errorString += 'Contact Email';
            }
            if(contactRecord.Title__c == null) {
                mandatoryCheck = false;
                errorString += errorString != '' ? ', ' + 'Contact Title' : 'Contact Title';
            }
            if(contactRecord.BirthDate == null) {
                mandatoryCheck = false;
                errorString += errorString != '' ? ', ' + 'Contact BirthDate' : 'Contact BirthDate';
            }
        }

        if(!mandatoryCheck)
        {
            opportunityRecord.addError('Please Enter ' + errorString);
        }
    }

    private class OpportunityManagerException extends Exception {}
}