public class FundingDetailsDB extends DBManager {

    public List<loan__Disbursal_Txn_Distribution__c> getFundingDetailsByIds(Id disbursalTransactionId)
    {
        return [
            SELECT Id, Name, loan__Transaction_Date__c, Funded_Source__c, Account_Name__c, loan__Distribution_Amount__c, loan__Payment_Mode__r.Name
            FROM loan__Disbursal_Txn_Distribution__c
            WHERE loan__Loan_Disbursal_Transaction__c = :disbursalTransactionId
        ];
    }

    public AggregateResult getDisbursalTransactionSummaryIds(Id disbursalTransactionId)
    {
        return [
            SELECT SUM(loan__Distribution_Amount__c) distributionGrandTotal
            FROM loan__Disbursal_Txn_Distribution__c
            WHERE loan__Loan_Disbursal_Transaction__c = :disbursalTransactionId
       ];
    }

    public List<loan__Loan_Disbursal_Transaction__c> getLoanDisbursalTransactionDetailsByIds(String contractName) {
        return [
            SELECT Id, CL_Contract__c
            FROM loan__Loan_Disbursal_Transaction__c
            WHERE CL_Contract__c = :contractName
        ];
    }
}