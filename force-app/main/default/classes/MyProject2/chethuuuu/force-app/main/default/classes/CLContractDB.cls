public class CLContractDB extends DBManager {
    public List<loan__Loan_Account__c> getLoanAccountsByIds (Set<Id> loanAccountIds) {
        return [
            SELECT Id, Name, loan__Loan_Amount__c, loan__Frequency_of_Loan_Payment__c,
                Bank_Account__c, loan__Next_Installment_Date__c, Primary_Contact__c, loan__Account__c,
                loan__Product_Type__c, Percentage_Paid__c, Latest_Number_Of_Missed_Payments__c, loan__Loan_Status__c, Type__c,
                Total_Unpaid_Due_Amount_To_Current__c, Broker_Contact__r.AccountId, Broker_Contact__c, loan__Last_Payment_Date__c,
                loan__Expected_Disbursal_Date__c, Broker_Standard_Commission__c, Total_Outstanding_Repayment_Amount__c,
                loan__Total_Interest_Amortization_Based__c, Last_ACH_return_date__c, ACH_Turned_off_Date__c, loan__Disbursed_Amount__c,
                Remaining_Number_of_Payments__c, loan__Interest_Rate__c, loan__Payment_Amount__c, Application__c,
                Application__r.genesis__Loan_Amount__c, Application__r.Disbursement_Id__c, Application__r.Business_Type__c,
                Application__r.Total_Repayment_Amount__c, Application__r.Buy_Rate__c, Application__r.Pricing_Factor__c, Pricing_Factor__c,
                Application__r.Type__c, Application__r.genesis__Maturity_Date__c, Application__r.CAN_Pay_Off_Type__c,
                Return_Blocked_Account_Fee_Applied_Date__c, Return_Blocked_Account_Fee_Count__c, Return_ACH_Fee_Applied_Date__c,
                Return_ACH_Fee_Count__c, Max_Number_Of_Missed_Payments__c, Return_Reason_Code__c,
                Is_Pre_Closure_Fee_Applied__c, Pre_Closure_Penalty_Amount__c, Outstanding_Repayment_Amount__c,
                loan__Last_Installment_Date__c, loan__Disbursal_Date__c, loan__Last_Disbursal_Amount__c, loan__Number_of_Installments__c,
                Primary_Contact__r.FirstName, Primary_Contact__r.LastName, Primary_Contact__r.MiddleName, Primary_Contact__r.Suffix
            FROM loan__Loan_Account__c
            WHERE Id IN :loanAccountIds
        ];
    }

    public List<loan__Loan_Account__c> getLoanAccountsAndItsCompetitorPartiesByIds (Set<Id> loanAccountIds) {
        return [
            SELECT Id, Name, loan__Loan_Amount__c, loan__Frequency_of_Loan_Payment__c,
                Bank_Account__c, loan__Next_Installment_Date__c, Primary_Contact__c, loan__Account__c,
                loan__Product_Type__c, Percentage_Paid__c, Latest_Number_Of_Missed_Payments__c, loan__Loan_Status__c, Type__c,
                Total_Unpaid_Due_Amount_To_Current__c, Broker_Contact__r.AccountId, Broker_Contact__c, loan__Last_Payment_Date__c,
                loan__Expected_Disbursal_Date__c, Broker_Standard_Commission__c, Total_Outstanding_Repayment_Amount__c,
                loan__Total_Interest_Amortization_Based__c, Last_ACH_return_date__c, ACH_Turned_off_Date__c, loan__Disbursed_Amount__c,
                Remaining_Number_of_Payments__c, loan__Interest_Rate__c, loan__Payment_Amount__c, Application__c,
                Application__r.genesis__Loan_Amount__c, Application__r.Disbursement_Id__c,
                Application__r.Total_Repayment_Amount__c, Application__r.Oldest_Unpaid_Due_As_Of_Today__c,
                Application__r.Buy_Rate__c, Application__r.Pricing_Factor__c, Application__r.Type__c,
                Application__r.genesis__Maturity_Date__c, Application__r.CAN_Pay_Off_Type__c,
                Max_Number_Of_Missed_Payments__c, Outstanding_Repayment_Amount__c,
                (SELECT Id, Competitor_Amount__c, Competitor_Bank_Account__c, clcommon__Type__c,
                clcommon__Type__r.Name, clcommon__Account__c, competitor_payment_mode__c
                FROM Parties__r
                WHERE clcommon__Type__c = :OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_COMPETITOR))
            FROM loan__Loan_Account__c
            WHERE Id IN :loanAccountIds
        ];
    }

    public List<loan__Loan_Account__c> getActiveLoanAccountsByBorrowerIds (Set<Id> borrowerIds) {
        return [
            SELECT Id, loan__Account__c
            FROM loan__Loan_Account__c
            WHERE loan__Account__c IN :borrowerIds
                AND loan__Loan_Status__c IN :CLContracts.LOAN_ACTIVE_STATUSES
        ];
    }

    public List<loan__Loan_Account__c> getClosedLoanAccountsByCustomerAccountIds (Set<Id> customerAccountIds) {
        return [
            SELECT Id,Name,loan__Closed_Date__c
            FROM loan__Loan_Account__c
            WHERE loan__Account__c IN : customerAccountIds
                AND loan__Loan_Status__c like 'Closed%'
        ];
    }

    public List<loan__Loan_Account__c> getRecentLoanAccountsByBorrowerIds (Set<Id> borrowerAccountIds) {
        return [
            SELECT Id, Name, loan__Loan_Amount__c, Primary_Contact__c, loan__Account__c,
                Broker_Contact__c, Broker_Contact__r.AccountId, Application__r.OwnerId,
                Application__r.Underwriter__c, Application__r.Sales_Rep__c, Application__r.Annual_Volume__c,
                Application__r.Opportunity__c, Application__r.Opportunity__r.LeadSource,
                Concurrent_Eligible_Amount__c
            FROM loan__Loan_Account__c
            WHERE loan__Account__c IN :borrowerAccountIds
                AND loan__Loan_Status__c IN :CLContracts.LOAN_RENEWAL_ELIGIBLE_STATUSES
                ORDER BY CreatedDate DESC LIMIT 1
        ];
    }

    public List<loan__Loan_Account__c> getRecentLoanAccountsByOppAccountIds (Set<Id> borrowerAccountIds) {
        return [
            SELECT Id, Name, loan__Loan_Amount__c, Primary_Contact__c, loan__Account__c,
                Broker_Contact__c, Broker_Contact__r.AccountId, Application__r.OwnerId,
                Application__r.Underwriter__c, Application__r.Sales_Rep__c, Application__r.Annual_Volume__c,
                Application__r.Opportunity__c, Application__r.Opportunity__r.LeadSource,
                Concurrent_Eligible_Amount__c, Application__r.genesis__Payment_Frequency__c,
                Application__r.genesis__Term__c
            FROM loan__Loan_Account__c
            WHERE loan__Account__c IN :borrowerAccountIds
                AND loan__Loan_Status__c IN :CLContracts.LOAN_RENEWAL_ELIGIBLE_STATUSES
                ORDER BY CreatedDate DESC LIMIT 1
        ];
    }

    public List<loan__Loan_Account__c> getLoanAccountsAndItsLastRepaymentScheduleByIds (Set<Id> loanAccountIds) {
        return [
            SELECT Id, Name, loan__Loan_Amount__c, loan__Disbursed_Amount__c, Pricing_Factor__c,
            loan__Total_Interest_Amortization_Based__c,
                (SELECT Id, loan__Due_Interest__c, loan__Due_Amount__c, loan__Due_Principal__c
                FROM loan__Repayment_Schedule__r
                WHERE loan__Is_Archived__c = false
                ORDER BY loan__Due_Date__c DESC
                LIMIT 1)
            FROM loan__Loan_Account__c
            WHERE Id IN :loanAccountIds
        ];
    }

    public List<loan__Loan_Account__c> getLoanAccountsByApplicationIds (Set<Id> applicationIds) {
        return [
            SELECT Id, Name, Application__c, loan__Loan_Status__c
            FROM loan__Loan_Account__c
            WHERE Application__c IN :applicationIds
            ORDER BY CreatedDate DESC LIMIT 1
        ];
    }

    public List<loan__Loan_Account__c> getLoanAccountsByNames(Set<String> loanNames) {
        return [
            SELECT Id, Name, Disbursement_Count__c, Bank_Account__c,  Primary_Contact__r.FirstName, Primary_Contact__r.LastName,
                Primary_Contact__r.MiddleName, Primary_Contact__r.Suffix, loan__Disbursed_Amount__c
            FROM loan__Loan_Account__c
            WHERE Name IN :loanNames
        ];
    }

    public List<loan__Loan_Account__c> getLoanAccountsAndItsLoanPaymentTxnByName (Set<String> loanAccountNames) {
        return [
            SELECT Id, Name,
                (
                    SELECT Id, Name, loan__Reversed__c
                    FROM loan__Loan_Payment_Transactions__r
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                )
            FROM loan__Loan_Account__c
            WHERE Name IN :loanAccountNames
        ];
    }

    public List<loan__Loan_Account__c> getCLContractsAndItsReversedPaymentTxnsByAccountIds (Set<Id> accountIds) {
        return [
            SELECT Id, Name,
                loan__Account__c, loan__Contact__c, loan__Account_Type__c,
                loan__Loan_Status__c, Latest_Number_Of_Missed_Payments__c,
                loan__Frequency_of_Loan_Payment__c, loan__Amount_Due_Till_Current__c, Total_Unpaid_Due_Amount_To_Current__c,
                Percentage_Paid__c, loan__Loan_Balance__c, Current_Payoff_Amount__c,
                Latest_Missed_Payment_Date__c, Concurrent_Eligible_Amount__c,
                Concurrent_Remaining_Amount__c, Total_Outstanding_Repayment_Amount__c,
                loan__Last_Payment_Date__c, Is_Renewal_Eligible__c, Application__r.Annual_Volume__c, Application__r.GAV__c,
                loan__Pmt_Amt_Cur__c, Type__c, Remaining_Number_of_Payments__c, Max_Number_Of_Missed_Payments__c,
                Original_Payoff_Amount__c,
                (
                    SELECT Id, loan__Reversed__c, Reversed_Date__c, loan__Cleared__c
                    FROM loan__Loan_Payment_Transactions__r
                    WHERE loan__Reversed__c = true
                )
            FROM loan__Loan_Account__c
            WHERE loan__Account__c IN :accountIds
                AND loan__Loan_Status__c IN :CLContracts.LOAN_ACTIVE_AND_CLOSED_OBLIGATION_MET_STATUSES
                AND loan__Invalid_Data__c = false
            ORDER BY LastModifiedDate DESC
        ];
    }

    public List<loan__Loan_Account__c> getLoanUpcomingRepaymentScheduleByLoanId(Set<Id> loanAccountIds) {
        return [
            SELECT Id, Name, loan__Loan_Amount__c, loan__Disbursed_Amount__c, Pricing_Factor__c,
            loan__Total_Interest_Amortization_Based__c, loan__Frequency_of_Loan_Payment__c,
                (SELECT Id, loan__Due_Interest__c, loan__Due_Amount__c, loan__Due_Principal__c, loan__Due_Date__c
                FROM loan__Repayment_Schedule__r
                WHERE loan__Is_Archived__c = false
                    AND loan__Due_Date__c > :GeneralHelper.currentSystemDate
                LIMIT 1)
            FROM loan__Loan_Account__c
            WHERE Id IN :loanAccountIds
        ];
    }
}