public class LoanPaymentTransactionDB extends DBManager {

    public List<AggregateResult> getAggregatedInterestByContractId(Id contractId, Date startDate, Date endDate){
        return [
            SELECT SUM(loan__Interest__c)
            FROM loan__Loan_Payment_Transaction__c
            WHERE loan__Loan_Account__c = :contractId
                AND loan__Transaction_Date__c >= :startDate
                AND loan__Transaction_Date__c <= :endDate
        ];
    }

    public List<loan__Loan_Payment_Transaction__c> getLoanPaymentTransactionByName(Set<String> loanPaymentTxnName){
        return [
            SELECT Id, Name, loan__Loan_Account__r.Name
            FROM loan__Loan_Payment_Transaction__c
            WHERE Name IN : loanPaymentTxnName
        ];
    }
}