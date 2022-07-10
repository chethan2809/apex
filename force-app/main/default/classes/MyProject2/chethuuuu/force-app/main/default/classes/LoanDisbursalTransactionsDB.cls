public class LoanDisbursalTransactionsDB extends DBManager {

    public LoanDisbursalTransactionsDB executeInserts(loan__Loan_Disbursal_Transaction__c disbursal,List<loan__Disbursal_Txn_Distribution__c> disbursalDistributionList){
        loan.LoanDisbursalActionAPI action = new loan.LoanDisbursalActionAPI(disbursal, disbursalDistributionList);
        action.disburseLoanAccount();
        return this;
    }

    public List<loan__Loan_Disbursal_Transaction__c> getLoanDisbursalTransactionsByIds (Set<Id> loanDisbursalTransactionIds) {
        return [
            SELECT Id, Name, loan__Loan_Account__c, loan__Loan_Account__r.Broker_Contact__c, Investor_Account__c,
                loan__Loan_Account__r.Broker_Contact__r.AccountId, loan__Loan_Account__r.Broker_Contact__r.Account.Commision_Based_On__c,
                loan__Disbursed_Amt__c, loan__Disbursal_Date__c, loan__Loan_Account__r.loan__Interest_Rate__c,
                Investor_Account__r.loan__Service_Rate_On_Investment__c, Investor_Account__r.loan__Collect_Service_Fees_on__c
            FROM loan__Loan_Disbursal_Transaction__c
            WHERE Id IN :loanDisbursalTransactionIds
        ];
    }

    public List<loan__Loan_Disbursal_Transaction__c> getDisbursalTransactionsListByLoanAccountIds (Set<Id> loanAccountIds) {
        return [
            SELECT loan__Loan_Account__c, Id
            FROM loan__Loan_Disbursal_Transaction__c
            WHERE loan__Loan_Account__c IN: loanAccountIds
        ];
    }
}