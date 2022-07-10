public class AccountDB extends DBManager {

    public List<Account> getAccountByIds(Set<Id> accountIds) {
        return [
            SELECT Id, Name, Phone, Business_Tax_ID__c, BillingStreet, BillingCity, BillingState, BillingPostalCode,
                Last_Business_Credit_Pull__c, Sic, Customer_Since__c, Legacy_Percent_Paid__c, Biz_Start_Date__c,
                clcommon__Legal_Entity_Type__c, Industry, clcommon__Email__c, BillingAddress, BillingCountry,
                Doing_Business_As_Name__c, AnnualRevenue, BillingBuildingNumber__c, clcommon__Legal_Entity_Type__r.Name,
                Fax, Legacy_Current_Balance__c, Legacy_Average_Bounced_Number_12M__c, Legacy_Average_Bounced_Number_1M__c,
                Paid_Pct_High_Ind__c, Legacy_Ever_Paid_Days__c, Legal_Name__c, SIC_Code_2__c, Partner_API_Key__c,
                Legacy_Negative_CAN_History__c, Commision_Based_On__c, Default_Broker_Commission__c, Is_Broker_Active__c,
                Flat_Referral_Fee__c,New_Max_Broker_Commission__c,Is_Flat_Renewal__c,Commission_Eligible__c, Is_Exclusivity__c,
                Flat_Renewal_Commission__c,Renewal_Amount_Commission__c,Renewal_Max_Broker_Commission__c, Total_Clawback_Amount__c,
                Legacy_Turn_Ratio__c, Legacy_Number_of_Contracts__c, Number_Of_Bounces_in_Last_60_Days__c,
                Last_Date_of_Activity__c, Legacy_Renewal_Eligible__c, Legacy_Renewal_Application_Created_Date__c,
                Migrated_Date__c, loan__Borrower__c, Type, AccountSource, Business_Name__c, Legacy_Payment_Frequency__c,
                Legacy_Number_of_Current_Missed_Payments__c, Legacy_Latest_Missed_Payment_Date__c, OwnerId, Broker_Account__c,
                Broker_Contact__c, Legacy_GAV__c, Current_Active_Contract_Number__c, Email_cc__c, Legacy_Active_Contract__c,
                Current_Remaining_Payment_Days__c, Current_Payment_Amount__c, Current_Contract_Type__c, Legacy_Max_Missed_Payments__c,
                UCC_Status__c, UCC_Opt_Out__c, Merchant_ID__c, UCC_Order_Number__c, UCC_Order_Status__c, CLS_Active_Contract__c
            FROM Account
            WHERE Id IN :accountIds
        ];
    }

    public List<Account> getAccountByIdsForUpdate(Set<Id> accountIds) {
        return [
            SELECT Id, Name, Legacy_Ever_Paid_Days__c
            FROM Account
            WHERE Id IN :accountIds  FOR UPDATE
        ];
    }

     public Account getAccountNameAndPhoneNumberById(String accountId){
        return [
            SELECT Name, Phone
            FROM Account
            WHERE Id = :accountId
        ];
    }

    public List<Account> getDuplicateGuarantorAccounts(String guarantorAccountName) {
        return [
            SELECT Id, Name, Type
            FROM Account
            WHERE Name = :guarantorAccountName
                AND Type = :Accounts.GUARANTOR
        ];
    }

    public List<Account> getExistingBorrowerAccts(Set<String> taxIds, Set<String> businessStreet, Set<String> businessCity) {
        return [
            SELECT Id, Name, Business_Tax_ID__c, BillingStreet, BillingCity, BillingPostalCode
            FROM Account
            WHERE  Business_Tax_ID__c IN :taxIds
                AND BillingStreet IN :businessStreet
                AND BillingCity IN :businessCity
                AND Type = :Accounts.BORROWER
        ];
    }

    public List<Account> getBorrowerAccountsToShowInBrokerPortal(Set<Id> accountIds) {
        return [
            SELECT Id, Name, Phone, clcommon__Legal_Entity_Type__r.Name, Type
            FROM Account
            WHERE Id IN :accountIds
                AND Type = :Accounts.BORROWER
                AND Is_Exclusivity__c = true
            ORDER BY CreatedDate DESC
        ];
    }

    public List<Account> getConcurrentEligibleBorrowerAccounts(Set<Id> accountIds){
        return [
            SELECT Id, Name, Phone, Type,
                clcommon__Legal_Entity_Type__c, Migrated_Date__c, Migrated_From__c
            FROM Account
            WHERE Id IN :accountIds
                AND Type = :Accounts.BORROWER
        ];
    }

    public List<Account> getBorrowerAccountsByBrokerAccounts(Set<Id> brokerAccountIds){
        return [
            SELECT Id, Name, Phone, clcommon__Legal_Entity_Type__r.Name, Type, Broker_Account__c
            FROM Account
            WHERE Broker_Account__c IN :brokerAccountIds
                AND Type = :Accounts.BORROWER
            ORDER BY CreatedDate DESC
        ];
    }

    public List<Account> getAllCompetitorAccounts(){
        return [
            SELECT Id, Name, Type, Additional_Names__c
            FROM Account
            WHERE Type = :Accounts.COMPETITOR
        ];
    }

    public List<Account> getGuarantorAccountsByIds(Set<Id> guarantorAccounts) {
        return [
            SELECT Id, Name, Type
            FROM Account
            WHERE Id = :guarantorAccounts
                AND Type = :Accounts.GUARANTOR
        ];
    }

    public List<Account> getBorrowerAccountsByBrokerAccountsAndIds(Set<Id> brokerAccountIds, Set<Id> borrowerIds){
        return [
            SELECT Id, Name, Phone, clcommon__Legal_Entity_Type__r.Name, Type, Broker_Account__c
            FROM Account
            WHERE Broker_Account__c IN :brokerAccountIds
                AND Id IN :borrowerIds
                AND Type = :Accounts.BORROWER
        ];
    }

    public List<Account> getBrokerDetailsByBorrowerAccountIds(Set<Id> borrowerIds){
        return [
            SELECT Id, Name, Is_Exclusivity__c, Broker_Account__c, Broker_Contact__c, Broker_Account__r.Exclusivity_Period__c,
                Days_Since_Zero_Balance_Date__c
            FROM Account
            WHERE Id IN : borrowerIds
        ];
    }

    public List<Account> getInActiveBrokerDetailsByIds(Set<Id> brokerIds) {
        return [
            SELECT Id, Name, Is_Broker_Active__c
            FROM Account
            WHERE Id IN : brokerIds
                AND Is_Broker_Active__c = false
        ];
    }
}