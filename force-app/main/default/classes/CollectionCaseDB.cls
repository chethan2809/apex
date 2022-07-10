public class CollectionCaseDB extends DBManager {

    public List<Collection_Case__c> getCollectionCasesByIds(Set<Id> collectionCaseIds) {
        return [
            SELECT Id, Name, CL_Contract_Id__c, OwnerId, Is_Active__c, Contract_Application_Id__c, Active_PA__c, Active_PA_Type__c, Active_PA_Total__c,
                Manual_Collector_Assigned__c, Case_Queue__c, Is_Same_Queue__c, Legal_User__c, Last_Consumer_Credit_Report_Pull_Date__c, Last_Business_Credit_Report_Pull_Date__c,
                Account__c, Contact__c, Supervisor__c, Case_Number__c, Collections_status__c, Collections_sub_status__c
            FROM Collection_Case__c
            WHERE Id IN :collectionCaseIds
        ];
    }

    public List<Collection_Case__c> getCollectionCases() {
        return [
            SELECT Id, Name, CL_Contract_Id__c, OwnerId, Is_Active__c, Contract_Application_Id__c, Manual_Collector_Assigned__c,
                Case_Queue__c, Is_Same_Queue__c, Account__c, Contact__c, Supervisor__c, Case_Number__c, Legal_User__c,
                Collections_status__c, Collections_sub_status__c
            FROM Collection_Case__c
        ];
    }

    public List<Collection_Case__c> getActiveCollectionCases() {
        return [
            SELECT Id, Name, CL_Contract_Id__c, OwnerId, Is_Active__c, Contract_Application_Id__c,
                Manual_Collector_Assigned__c, Case_Queue__c, Is_Same_Queue__c, Legal_User__c,
                Account__c, Contact__c, Supervisor__c, Case_Number__c, Collections_status__c, SCRA__c,
                Confirmed_fraud__c, Deceased_owner__c, Cease_and_Desist__c, Collections_sub_status__c
            FROM Collection_Case__c
            WHERE Is_Active__c = true
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<loan__Loan_account_Due_Details__c> getCLLoanBills(Id loanAccountId, Integer limitSize, Integer offset, String filters, boolean isChanged) {
        String queryString = 'SELECT Id, Name, loan__Balance_Amount__c, loan__Principal_Billed__c, loan__Interest_Billed__c,';
        queryString = queryString + 'loan__Due_Amt__c, loan__Due_Date__c, Due_Date_For_Portal__c, loan__Fees_Due__c, loan__Invoice__c,';
        queryString = queryString + 'loan__Loan_Account__c, loan__Opening_Balance__c, loan__Fees_Paid__c, loan__Payment_Amt__c,';
        queryString = queryString + 'loan__Payment_Date__c, loan__Payoff_Balance__c, loan__Previous_Bill_Amount__c,';
        queryString = queryString + 'loan__Remarks__c, loan__Transaction_Date__c, loan__Total_Amount_Disbursed__c, loan__Payment_Satisfied__c';
        queryString = queryString + ' FROM loan__Loan_account_Due_Details__c WHERE loan__Loan_Account__c =\'' + loanAccountId + '\'';
        queryString = queryString + filters +' ORDER BY CreatedDate Desc LIMIT ' + limitSize +' OFFSET ' + offset;
        return Database.query(queryString);
    }

    @AuraEnabled(cacheable=true)
    public static List<loan__Loan_Payment_Transaction__c> getCLLoanPayments(Id loanAccountId, Integer limitSize, Integer offset, String filters) {
        String queryString = 'SELECT Id, Name, loan__Balance__c, loan__Check__c, loan__Cleared__c, loan__Principal__c, loan__Interest__c,';
        queryString = queryString + 'loan__Bank_Name__c, loan__Loan_Account__c, loan__Payment_Mode__c, loan__Payment_Type__c, loan__Fees__c,';
        queryString = queryString + 'loan__Receipt_Date__c, Reversed_Date__c, loan__Transaction_Amount__c, loan__Transaction_Date__c, loan__waived__c,';
        queryString = queryString + 'loan__Reversal_Reason__c, loan__Reversed__c, Wire_Payment_Transaction__c, Reversed_LPT_Reference__c';
        queryString = queryString + ' FROM loan__Loan_Payment_Transaction__c WHERE loan__Loan_Account__c =\'' + loanAccountId + '\'';
        queryString = queryString + filters +' ORDER BY CreatedDate Desc LIMIT '+ limitSize + ' OFFSET ' + offset;
        return Database.query(queryString);
    }

    @AuraEnabled(cacheable=true)
    public static List<loan__Charge__c> getCLLoanCharges(Id loanAccountId, Integer limitSize, Integer offset, String filters, boolean isChanged) {
        String queryString = 'SELECT Id, Name, loan__Balance__c, CL_Contract__c, loan__Date__c, loan__Fee__c, loan__Fee__r.Name,';
        queryString = queryString + 'loan__Loan_Account__c, loan__Original_Amount__c, loan__Paid_Amount__c, loan__Total_Amount_Due__c,';
        queryString = queryString + 'loan__Payoff_Balance__c, loan__Principal_Due__c, loan__Paid__c, loan__Waive__c';
        queryString = queryString + ' FROM loan__Charge__c WHERE loan__Loan_Account__c =\'' + loanAccountId + '\'';
        queryString = queryString + filters +' ORDER BY CreatedDate Desc LIMIT '+ limitSize + ' OFFSET ' + offset;
        return Database.query(queryString);
    }

    @AuraEnabled(cacheable=true)
    public static List<loan__Automated_Payment_Setup__c> getAPSRecords(Id loanAccountId, Integer limitSize, Integer offset, boolean isSame) {
        return [
            SELECT Id, Name, loan__Type__c, loan__Transaction_Amount__c, loan__Debit_Date__c,loan__Frequency__c, loan__Payment_Mode__r.Name, loan__Active__c
            FROM loan__Automated_Payment_Setup__c
            WHERE loan__CL_Contract__c = :loanAccountId
            ORDER BY CreatedDate Desc
            LIMIT :limitSize
            OFFSET :offset
        ];
    }

    @AuraEnabled(cacheable=true)
    public static Integer getTotalCount(Id genericId, String tblName, String whereClauseFieldName){
        String queryStr = 'SELECT count(Id) recCount FROM ' + tblName + ' WHERE '+ whereClauseFieldName + ' = \'' + genericId + '\'';
        AggregateResult results = Database.query(queryStr);
        Integer recCount = (Integer)results.get('recCount');
        return recCount;
    }

    @AuraEnabled(cacheable=true)
    public static List<Collection_Case__c> getCollectionCaseDetails(Id collectionCaseId) {
        return [
            SELECT Id, CL_Contract_Id__c, Contract_Number__c, Contract_Application_Id__c, Bank_Account__c,
            Automated_Payment_Setup__c, Frequency__c, Payment_Amount__c, Total_Unpaid_Due_Amount_To_Current__c,
            Account__c, Contact__c, Supervisor__c, Case_Number__c, Contract_Application_Name__c, Legal_User__c
            FROM Collection_Case__c
            WHERE Id = :collectionCaseId
            LIMIT 1
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getChargesSummaryByFeeType(Id loanAccountId){
       return [
            SELECT loan__Fee__r.Name, SUM(loan__Total_Amount_Due__c) totalDue, SUM(loan__Paid_Amount__c) totalPaid
            FROM loan__charge__c
            WHERE loan__Loan_Account__c = :loanAccountId
            GROUP BY loan__Fee__r.Name
       ];
    }

    @AuraEnabled(cacheable=true)
    public static AggregateResult getChargesSummary(Id loanAccountId){
       return [
            SELECT SUM(loan__Total_Amount_Due__c) grandTotalDue, SUM(loan__Paid_Amount__c) grandTotalPaid
            FROM loan__charge__c
            WHERE loan__Loan_Account__c = :loanAccountId
       ];
    }

    @AuraEnabled(cacheable=true)
    public static List<clcommon__party__c> getRelatedPartiesByApplicationIds(List<Id> applicationIds){
        return[
            SELECT clcommon__Contact__c, clcommon__Type__r.Name, clcommon__Contact__r.loan__Contact_Type__c, clcommon__Contact__r.Name,
            clcommon__Contact__r.Title__c, clcommon__Contact__r.MobilePhone, clcommon__Contact__r.Email, clcommon__Contact__r.Birthdate,
            clcommon__Contact__r.ints__Social_Security_Number__c, clcommon__Contact__r.MailingAddress, clcommon__Contact__r.MailingStreet, clcommon__Contact__r.MailingState, clcommon__Contact__r.MailingCity, clcommon__Contact__r.MailingCountry,
            clcommon__Contact__r.MailingPostalCode, clcommon__Contact__r.Phone, clcommon__Contact__r.Alternate_Phone__c,
            clcommon__Contact__r.Alternate_Email__c, clcommon__Contact__r.Do_Not_Contact__c
            FROM clcommon__party__c
            WHERE genesis__Application__c IN :applicationIds
            AND (clcommon__Type__r.Name = 'BROKER'
                OR clcommon__Type__r.Name = 'CONTACT'
                OR clcommon__Type__r.Name = 'GUARANTOR'
                )
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<AccountContactRelation> getRelatedContactsFromBorrowerAccountIds(List<Id> borrowerAccountIds) {
        return[
            SELECT AccountId, ContactId, Contact.Name, Contact.loan__Contact_Type__c, Contact.Email, Contact.Phone, Contact.MobilePhone,
                Contact.Title__c, Contact.Alternate_Phone__c, Contact.Birthdate, Contact.ints__Social_Security_Number__c,
                Contact.MailingStreet, Contact.MailingState, Contact.MailingCity, Contact.MailingCountry, Contact.MailingPostalCode,
                Contact.Alternate_Email__c, Contact.Do_Not_Contact__c
            FROM AccountContactRelation
            WHERE AccountId IN :borrowerAccountIds
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<clcommon__Category_Attachment_Association__c> getAllWasabiFileFromCollectionCase(
        List<String> collectionCase, List<String> applicationNames, Boolean isChanged
    ){
        return[
            SELECT Id, Name, Collection_Case__c, Wasabi_Link__c, clcommon__Document_Category__c,
                clcommon__Attachment_Id__c, Document_Category_Name__c, CreatedDate
            FROM clcommon__Category_Attachment_Association__c
            WHERE Collection_Case__c IN :collectionCase
                OR Application__c IN : applicationNames
            ORDER BY CreatedDate Desc
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<clcommon__Document_Definition__c> getDocumentDefinitions () {
        return[
            SELECT Id, Name, Document_Category__c
            FROM clcommon__Document_Definition__c
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<loan__Fee__c> getAllFeeTypes(){
        return[
            SELECT Id, Name
            FROM loan__Fee__c
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getAllPaymentTypes(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = loan__Loan_Payment_Transaction__c.loan__Payment_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }
        return pickListValuesList;
    }

    @AuraEnabled(cacheable=true)
    public static List<User> getCollectionsQueueUsers(String queue) {
        return [
            SELECT Id, Name, Email
            FROM User
            WHERE Id
            IN (
                SELECT UserOrGroupId
                FROM GroupMember
                WHERE Group.Name = :queue
                AND Group.Type = 'Queue'
            )
        ];
    }

    @AuraEnabled(cacheable=true)
    public static loan__Bank_Account__c getBankAccountDetails(Id bankAccountId){
        return[
            SELECT Id, Name
            FROM loan__Bank_Account__c
            WHERE Id = :bankAccountId
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<loan__Payment_Mode__c> getPaymentTypes(){
        return [
            SELECT Id, Name
            FROM loan__Payment_Mode__c
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<clcommon__Category_Attachment_Association__c> getWasabiFileFromCollectionCase(
        String documentCategory, List<String> collectionCase, List<String> applicationNames, Boolean isChanged
    ){
        return[
            SELECT Id, Name, Collection_Case__c, Wasabi_Link__c, clcommon__Document_Category__c,
                clcommon__Attachment_Id__c, Document_Category_Name__c, CreatedDate
            FROM clcommon__Category_Attachment_Association__c
            WHERE Document_Category_Name__c = :documentCategory
                AND (Collection_Case__c IN :collectionCase
                OR Application__c IN : applicationNames)
            ORDER BY CreatedDate Desc
        ];
    }

    @AuraEnabled(cacheable=true)
    public static CollectionCaseConstants getAllConstants() {
        return new CollectionCaseConstants();
    }

    @AuraEnabled(cacheable=true)
    public static Payment_Arrangements__c getPaymentArrangementById(Id paymentArrangementId){
        return [
            SELECT Id, Name, Collection_Case__c, Contact__c, Total_Outstanding_Repayment_Amount__c, Total_Unpaid_Due_Amount_To_Current__c,
            Payment_Arrangement_Type__c, Payment_Mode__c, Promise__c, Bank_Account__c, Amount__c, Debit_Date__c,
            Automatically_Enable_Default_APS__c, Automated_Payment_Setup__c, Type__c, Setup_Date__c, Transaction_Amount__c, Frequency__c,
            Amount_Type__c, Recurring_ACH_Start_Date__c, Recurring_ACH_End_Date__c, Debit_Day__c
            FROM Payment_Arrangements__c
            WHERE Id = :paymentArrangementId
        ];
    }

    public List<Payment_Arrangements__c> getPaymentArrangementByApsIds(Set<Id> apsId){
        return [
            SELECT Id, Name, Collection_Case__c, Contact__c, Total_Outstanding_Repayment_Amount__c, Total_Unpaid_Due_Amount_To_Current__c,
            Payment_Arrangement_Type__c, Payment_Mode__c, Promise__c, Bank_Account__c, Amount__c, Debit_Date__c,
            Automatically_Enable_Default_APS__c, Automated_Payment_Setup__c, Type__c, Setup_Date__c, Transaction_Amount__c, Frequency__c,
            Amount_Type__c, Recurring_ACH_Start_Date__c, Recurring_ACH_End_Date__c, Debit_Day__c
            FROM Payment_Arrangements__c
            WHERE Automated_Payment_Setup__c IN :apsId
            AND Automatically_Enable_Default_APS__c = true
            AND Payment_Arrangement_Type__c = :CollectionCaseConstants.ACCOMMODATION
        ];
    }

    @AuraEnabled(cacheable=true)
    public static loan__Automated_Payment_Setup__c getDefaultAPSRecordByContractId(Id loanAccountId) {
        return [
            SELECT Id, Name, loan__Type__c, loan__Transaction_Amount__c, loan__Debit_Date__c, loan__Frequency__c, loan__Payment_Mode__r.Name, loan__Active__c, Is_Default__c
            FROM loan__Automated_Payment_Setup__c
            WHERE loan__CL_Contract__c = :loanAccountId
            AND Is_Default__c = true
            ORDER BY CreatedDate Desc
            LIMIT 1
        ];
    }

    public List<Account> getAccountByIds(Set<Id> accountIds){
        return [
            SELECT Id, Name, Active_Payment_Arrangement_Type__c, Active_Payment_Arrangement__c
            FROM Account
            WHERE Id IN :accountIds
        ];
    }

    public List<Collection_Case__c> getCollectionCasesByLoanNames(Set<String> loanAccountNames) {
        return [
            SELECT Id, Name, Contract_Number__c, OwnerId, Owner.Email, Owner.Name, Owner.Title, Owner.Phone
            FROM Collection_Case__c
            WHERE Contract_Number__c IN :loanAccountNames
        ];
    }
}