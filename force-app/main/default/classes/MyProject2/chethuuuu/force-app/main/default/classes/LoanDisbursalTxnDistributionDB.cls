public class LoanDisbursalTxnDistributionDB extends DBManager {

    public List<loan__Disbursal_Txn_Distribution__c> getLoanDisbursalTxnDistributionsByLoanNames(Set<String> loanNames) {
        return [
            SELECT Id
            FROM loan__Disbursal_Txn_Distribution__c
            WHERE loan__Name_of_Entity__c IN :loanNames
            ORDER BY Name ASC
        ];
    }

    public List<loan__Disbursal_Txn_Distribution__c> getLoanDisbursalTxnDistributionsByDisbursalIds(
        Set<Id> disbursalTransactionIds, Set<String> fundedSources
    ) {
        return [
            SELECT Id, loan__Loan_Disbursal_Transaction__c, loan__Distribution_Amount__c, Funded_Source__c,
                loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__c
            FROM loan__Disbursal_Txn_Distribution__c
            WHERE loan__Loan_Disbursal_Transaction__c IN :disbursalTransactionIds
                AND Funded_Source__c IN : fundedSources
        ];
    }
}