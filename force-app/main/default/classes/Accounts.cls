public class Accounts
{
    public static final String BORROWER = 'Borrower';
    public static final String GUARANTOR = 'Guarantor';
    public static final String BROKER = 'Broker';
    public static final String COMPETITOR = 'Competitor';

    public static final  Set<String> INELIGIBLE_COLLECTION_STATUS = new Set<String> {
        'Legally Uncollectable', 'Efforts Exhausted'
    };

    public static Account createGuarantorAccount(Lead leadRecord, Id legalEntityType)
    {
        Account guarantorAccount = new Account();
        String firstName = leadRecord.FirstName != null ? leadRecord.FirstName : '';
        guarantorAccount.Name = firstName  + ' ' + leadRecord.LastName;
        guarantorAccount.BillingStreet = '';
        guarantorAccount.BillingCity = '';
        guarantorAccount.BillingState = '';
        guarantorAccount.BillingCountry = '';
        guarantorAccount.BillingPostalCode = '';
        guarantorAccount.clcommon__Legal_Entity_type__c = legalEntityType;
        guarantorAccount.Type = GUARANTOR;
        guarantorAccount.AccountSource = leadRecord.LeadSource;
        guarantorAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(guarantorAccount.Type.toUpperCase()).getRecordTypeId();
        return guarantorAccount;
    }

    public static Account createBorrowerAccount(Lead leadRecord, Id businessLegalEntityType)
    {
        Account borrowerAccount = new Account();
        borrowerAccount.clcommon__Legal_Entity_type__c = businessLegalEntityType;
        borrowerAccount.Industry = leadRecord.Industry;
        borrowerAccount.AnnualRevenue = leadRecord.AnnualRevenue;
        borrowerAccount.Business_Tax_ID__c = leadRecord.Tax_ID__c;
        borrowerAccount.State_of_Incorporation_Organization__c = leadRecord.State_of_Incorporation_Organization__c;
        borrowerAccount.Business_Name__c = leadRecord.Company;
        borrowerAccount.Legal_Name__c = leadRecord.Company;
        borrowerAccount.loan__Borrower__c = true;
        borrowerAccount.Biz_Start_Date__c = leadRecord.Biz_Start_Date__c;
        borrowerAccount.Doing_Business_As_Name__c = leadRecord.DBA__c;
        borrowerAccount.Phone = leadRecord.Biz_Phone__c;
        borrowerAccount.BillingBuildingNumber__c = leadRecord.BusinessBuildingNumber__c;
        borrowerAccount.BillingStreet = leadRecord.Street;
        borrowerAccount.BillingCity = leadRecord.City;
        borrowerAccount.BillingState = leadRecord.State;
        borrowerAccount.BillingCountry = leadRecord.Country;
        borrowerAccount.BillingPostalCode = leadRecord.PostalCode;
        if(leadRecord.loan__SICCode__c != null && leadRecord.loan__SICCode__c.length() > 2) {
            borrowerAccount.Sic = leadRecord.loan__SICCode__c;
            borrowerAccount.SicDesc = leadRecord.SIC_Description__c;
            borrowerAccount.SIC_Code_2__c = leadRecord.loan__SICCode__c.left(2);
            borrowerAccount.SIC_Description_2__c = leadRecord.SIC_Description__c;
        } else {
            borrowerAccount.SIC_Code_2__c = leadRecord.loan__SICCode__c;
            borrowerAccount.SIC_Description_2__c = leadRecord.SIC_Description__c;
        }
        borrowerAccount.Type = BORROWER;
        borrowerAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(borrowerAccount.Type.toUpperCase()).getRecordTypeId();
        if(leadRecord.LeadSource == PortalConstants.BROKER_PORTAL ||
            leadRecord.LeadSource == PortalConstants.MERCHANT_PORTAL ||
            leadRecord.LeadSource == PortalConstants.PARTNER_API)
        {
            borrowerAccount.AccountSource = leadRecord.LeadSource;
        }
        return borrowerAccount;
    }

    public static Account createBrokerAccount(Lead leadRecord)
    {
        Account brokerAccount = new Account();
        brokerAccount.Industry = leadRecord.Industry;
        brokerAccount.Business_Tax_ID__c = leadRecord.Tax_ID__c;
        brokerAccount.State_of_Incorporation_Organization__c = leadRecord.State_of_Incorporation_Organization__c;
        brokerAccount.Business_Name__c = leadRecord.Company;
        brokerAccount.Legal_Name__c = leadRecord.Company;
        brokerAccount.loan__Broker__c = true;
        brokerAccount.Biz_Start_Date__c = leadRecord.Biz_Start_Date__c;
        brokerAccount.Doing_Business_As_Name__c = leadRecord.DBA__c;
        brokerAccount.Phone = leadRecord.Biz_Phone__c;
        brokerAccount.BillingBuildingNumber__c = leadRecord.BusinessBuildingNumber__c;
        brokerAccount.BillingStreet = leadRecord.Street;
        brokerAccount.BillingCity = leadRecord.City;
        brokerAccount.BillingState = leadRecord.State;
        brokerAccount.BillingCountry = leadRecord.Country;
        brokerAccount.BillingPostalCode = leadRecord.PostalCode;
        if(leadRecord.loan__SICCode__c != null && leadRecord.loan__SICCode__c.length() > 2) {
            brokerAccount.Sic = leadRecord.loan__SICCode__c;
            brokerAccount.SicDesc = leadRecord.SIC_Description__c;
            brokerAccount.SIC_Code_2__c = leadRecord.loan__SICCode__c.left(2);
            brokerAccount.SIC_Description_2__c = leadRecord.SIC_Description__c;
        } else {
            brokerAccount.SIC_Code_2__c = leadRecord.loan__SICCode__c;
            brokerAccount.SIC_Description_2__c = leadRecord.SIC_Description__c;
        }
        brokerAccount.Type = BROKER;
        brokerAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(brokerAccount.Type.toUpperCase()).getRecordTypeId();
        brokerAccount.renewal_funding_notice__c = true;
        return brokerAccount;
    }

    public static void setContractApprovedRelatedFields(Account accountRecord, Id brokerAccountId, Id brokerContactId) {
        if(accountRecord.Customer_Since__c == null) {
            accountRecord.Customer_Since__c = GeneralHelper.currentSystemDate;
        }
        if(accountRecord.Legacy_Number_of_Contracts__c == null) {
            accountRecord.Legacy_Number_of_Contracts__c = 0;
        }
        accountRecord.Legacy_Number_of_Contracts__c++;

        accountRecord.Broker_Account__c = brokerAccountId;
        accountRecord.Broker_Contact__c = brokerContactId;
        accountRecord.Legacy_Active_Contract__c = false;
        accountRecord.CLS_Active_Contract__c = true;
        accountRecord.Is_Exclude_From_Auto_Renewal_Process__c = false;
    }

    public static Account setContractApprovedRelatedFields(loan__Loan_Account__c clContract) {
        Account borrowerAccount = new Account(Id = clContract.loan__Account__c);
        borrowerAccount.Original_Loan_Funded_Date__c = clContract.loan__Disbursal_Date__c;
        borrowerAccount.Original_Max_Funding_Amount__c = clContract.loan__Loan_Amount__c;
        borrowerAccount.Original_Max_Daily_Payment_Amount__c = clContract.loan__Payment_Amount__c;
        borrowerAccount.Original_Loan_Amount__c = clContract.loan__Last_Disbursal_Amount__c;
        borrowerAccount.Original_Loan_s_price__c = clContract.Pricing_Factor__c;
        borrowerAccount.Original_Loan_s_O_Fee__c = clContract.Origination_Fee__c;
        borrowerAccount.Legacy_Payment_Frequency__c = clContract.loan__Frequency_of_Loan_Payment__c;
        borrowerAccount.Product_Type__c = clContract.loan__Product_Type__c;
        borrowerAccount.Zero_Balance_Date__c = null;

        return borrowerAccount;
    }

    public static Account setSICCodeFromApplication(genesis__Applications__c application) {
        Account accountRecord = new Account(Id = application.genesis__Account__c);
        if(application.SIC_Code__c != null) {
            accountRecord.Sic = application.SIC_Code__c;
            accountRecord.SIC_Code_2__c = application.SIC_Code__c.left(2);
        }
        return accountRecord;
    }

    public static Account setClosedContractRelatedFields(loan__Loan_Account__c clContract) {
        Account borrowerAccount = new Account(Id = clContract.loan__Account__c);
        if(clContract.loan__Loan_Status__c == CLContracts.LOAN_STATUS_CLOSED_OBLIGATION_MET) {
            borrowerAccount.Zero_Balance_Date__c = GeneralHelper.currentSystemDate;
        }
        borrowerAccount.Legacy_Number_of_Current_Missed_Payments__c = 0;
        borrowerAccount.Legacy_Amount_Past_Due__c = 0;
        borrowerAccount.Legacy_Percent_Paid__c = clContract.Percentage_Paid__c;
        borrowerAccount.Legacy_Current_Balance__c = 0;
        borrowerAccount.Legacy_Payoff_Balance__c = 0;
        borrowerAccount.Concurrent_Eligible_Amount__c = 0;
        borrowerAccount.Concurrent_Remaining_Amount__c = 0;
        borrowerAccount.CLS_Active_Contract__c = false;

        return borrowerAccount;
    }

    public static Account setCanceledContractRelatedFields(Account accountRecord) {
        accountRecord.Legacy_Number_of_Contracts__c--;
        return accountRecord;
    }

    public static Boolean isCANNegativeHistory(Account newAccount, Account oldAccount) {
        return (newAccount.Legacy_Negative_CAN_History__c != oldAccount.Legacy_Negative_CAN_History__c &&
            newAccount.Legacy_Negative_CAN_History__c);
    }

    public static Account setNegativeHistoryAccountFields(Account newAccount, Account oldAccount) {
        Account negativeHistoryAccount;
        if(newAccount.ParentId != null) {
            if(newAccount.Negative_CAN_History_Reason__c == 'Written Off Contract') {
                negativeHistoryAccount = new Account(Id = newAccount.ParentId);
                negativeHistoryAccount.Legacy_Negative_CAN_History__c = true;
                negativeHistoryAccount.Negative_CAN_History_Reason__c = 'Child Account Written Off';
            }
            else if(newAccount.Negative_CAN_History_Reason__c == 'Missed Payments') {
                negativeHistoryAccount = new Account(Id = newAccount.ParentId);
                negativeHistoryAccount.Legacy_Negative_CAN_History__c = true;
                negativeHistoryAccount.Negative_CAN_History_Reason__c = 'Child Account Missed Payments';
            }
        }
        return negativeHistoryAccount;
    }

    public static void setAccountFieldsOnBeforeInsert(Account account)
    {
        if(account.Legacy_Percent_Paid__c != null) {
            account.Legacy_Percent_Paid_High_Indicator__c = account.Legacy_Percent_Paid__c > 75 ? true : false;
        }
        if(account.BillingState != null) {
            account.BillingState = GeneralHelper.convertStateNameToShortCode(account.BillingState);
        }
        if(account.Type == Accounts.GUARANTOR || account.Type == Accounts.COMPETITOR) {
            account.Do_Not_Sync_With_SFMC__c = true;
        }
        if(account.Type == Accounts.BROKER) {
            account.renewal_funding_notice__c = true;
        }
    }

    public static void setAccountFieldsOnBeforeUpdate(Account newAccount, Account oldAccount)
    {
        if(newAccount.Industry != oldAccount.Industry && OriginationHelper.canIndustryProfile.ContainsKey(newAccount.Industry)) {
            if(OriginationHelper.canIndustryProfile.get(newAccount.Industry).Industry_Rating__c == 'Prohibited'){
                throw new AccountsException('Selected Industry type is Prohibited');
            }

            if(OriginationHelper.canIndustryProfile.get(newAccount.Industry).Digit_Code__c != null &&
                OriginationHelper.canIndustryProfile.get(newAccount.Industry).Digit_Code__c.length() > 2) {
                newAccount.Sic = OriginationHelper.canIndustryProfile.get(newAccount.Industry).Digit_Code__c;
                newAccount.SicDesc = OriginationHelper.canIndustryProfile.get(newAccount.Industry).Description__c;
            } else {
                newAccount.SIC_Code_2__c = OriginationHelper.canIndustryProfile.get(newAccount.Industry).Digit_Code__c;
                newAccount.SIC_Description_2__c = OriginationHelper.canIndustryProfile.get(newAccount.Industry).Description__c;
            }
        }

        if(newAccount.Sic != oldAccount.Sic || newAccount.SIC_Code_2__c != oldAccount.SIC_Code_2__c){
            newAccount.SicDesc = IndustryRatingProfileManager.getIndustryRatingDescriptionBySICCode(newAccount.Sic);
            newAccount.SIC_Description_2__c = newAccount.SicDesc;
        }
        if(newAccount.Legacy_Percent_Paid__c != null) {
            newAccount.Legacy_Percent_Paid_High_Indicator__c = newAccount.Legacy_Percent_Paid__c > 75 ? true : false;
        }

        newAccount.Is_Not_Same_Broker__c = newAccount.Broker_Contact__c != oldAccount.Broker_Contact__c;
        if(newAccount.Type == Accounts.BROKER && newAccount.loan__Broker__c && newAccount.Partner_API_Key__c == null) {
            newAccount.Partner_API_Key__c = GeneralHelper.generateUniqueReferenceId(newAccount.Id);
        }
        if(newAccount.BillingState != null && newAccount.BillingState != oldAccount.BillingState) {
            newAccount.BillingState = GeneralHelper.convertStateNameToShortCode(newAccount.BillingState);
        }
        if(newAccount.Legacy_Negative_CAN_History__c && newAccount.Legacy_Negative_CAN_History__c != oldAccount.Legacy_Negative_CAN_History__c) {
            newAccount.Do_Not_Sync_With_SFMC__c = true;
        } else if(newAccount.Do_Not_Contact__c && newAccount.Do_Not_Contact__c != oldAccount.Do_Not_Contact__c) {
            newAccount.Do_Not_Sync_With_SFMC__c = true;
        } else if(newAccount.Do_Not_Contact_Email__c && newAccount.Do_Not_Contact_Email__c != oldAccount.Do_Not_Contact_Email__c) {
            newAccount.Do_Not_Sync_With_SFMC__c = true;
        } else if((newAccount.Type == Accounts.GUARANTOR || newAccount.Type == Accounts.COMPETITOR) && newAccount.Type != oldAccount.Type) {
            newAccount.Do_Not_Sync_With_SFMC__c = true;
        }
    }

    public static Account setAccountFieldsFromCollectionsAfterInsert(Collection_Case__c collectionCase)
    {
        Account borrowerAccount = new Account(Id = collectionCase.Account__c);
        borrowerAccount.Collections_status__c = collectionCase.Collections_status__c;
        borrowerAccount.SCRA__c = collectionCase.SCRA__c;
        borrowerAccount.Confirmed_Fraud_Flag__c = collectionCase.Confirmed_fraud__c;
        borrowerAccount.Deceased__c = collectionCase.Deceased_owner__c;
        borrowerAccount.Cease_and_Desist__c = collectionCase.Cease_and_Desist__c;

        return borrowerAccount;
    }

    public static Account setAccountFieldsFromCollectionsAfterUpdate(
        Collection_Case__c collectionCase, Collection_Case__c oldCollectionCase
    ) {
        Account borrowerAccount = new Account(Id = collectionCase.Account__c);

        if(collectionCase.Collections_status__c != oldCollectionCase.Collections_status__c) {
            borrowerAccount.Collections_status__c = collectionCase.Collections_status__c;
        }
        if(collectionCase.SCRA__c != oldCollectionCase.SCRA__c) {
            borrowerAccount.SCRA__c = collectionCase.SCRA__c;
        }
        if(collectionCase.Confirmed_fraud__c != oldCollectionCase.Confirmed_fraud__c) {
            borrowerAccount.Confirmed_Fraud_Flag__c = collectionCase.Confirmed_fraud__c;
        }
        if(collectionCase.Deceased_owner__c != oldCollectionCase.Deceased_owner__c) {
            borrowerAccount.Deceased__c = collectionCase.Deceased_owner__c;
        }
        if(collectionCase.Cease_and_Desist__c != oldCollectionCase.Cease_and_Desist__c) {
            borrowerAccount.Cease_and_Desist__c = collectionCase.Cease_and_Desist__c;
        }

        return borrowerAccount;
    }

    public static Account setAccountFieldsFromApplication(genesis__Applications__c application) {
        Account accountRecord = new Account(Id = application.genesis__Account__c);
        if(application.Is_EIS_Renewal__c && application.Auto_Renewed__c) {
            accountRecord.EIS_To_CLS_Converted__c = true;
        }
        accountRecord.Legacy_Renewal_Application_Created_Date__c = GeneralHelper.currentSystemDate;
        if(application.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL) {
            accountRecord.Is_Exclude_From_Auto_Renewal_Process__c = true;
        }
        return accountRecord;
    }

    private class AccountsException extends Exception {}
}