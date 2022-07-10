public class ccFundingDetailsController {

    @TestVisible
    private static FundingDetailsDB fundingDetailsDBInstance = new FundingDetailsDB();

    @AuraEnabled(cacheable=true)
    public static List<loan__Disbursal_Txn_Distribution__c> getFundingDetails(Id disbursalTransactionId) {
        return fundingDetailsDBInstance.getFundingDetailsByIds(disbursalTransactionId);
    }

    @AuraEnabled(cacheable=true)
    public static AggregateResult getDisbursalTransactionTotalSummary(Id disbursalTransactionId) {
        return fundingDetailsDBInstance.getDisbursalTransactionSummaryIds(disbursalTransactionId);
    }

    @AuraEnabled(cacheable=true)
    public static List<loan__Loan_Disbursal_Transaction__c> getLoanDisbursalTransactionDetails(String contractName) {
        return fundingDetailsDBInstance.getLoanDisbursalTransactionDetailsByIds(contractName);
    }
}