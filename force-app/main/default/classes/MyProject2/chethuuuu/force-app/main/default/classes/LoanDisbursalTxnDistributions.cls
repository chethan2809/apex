public class LoanDisbursalTxnDistributions {
    public static final String DISTRIBUTION_TYPE = 'Disbursement';
    public static final String FUNDED_SOURCE_COMPETITOR = 'Competitor';
    public static final String FUNDED_SOURCE_MERCHANT = 'Merchant';
    public static final String FUNDED_SOURCE_CROSSOVER = 'Crossover';
    public static final String FUNDED_SOURCE_REPURCHASE = 'Repurchase';

    public static loan__Disbursal_Txn_Distribution__c createLoanDisbursalTxnDistribution(
        Decimal distributionAmount, Id bankAccountId, Id paymentModeId, String distributionType, String fundedSource
    ) {
        loan__Disbursal_Txn_Distribution__c distribution = new loan__Disbursal_Txn_Distribution__c();
        distribution.loan__Distribution_Amount__c = distributionAmount;
        distribution.loan__Payment_Mode__c = paymentModeId;
        distribution.loan__Bank_Account__c = bankAccountId;
        distribution.loan__Distribution_Type__c = distributionType;
        distribution.Funded_Source__c = fundedSource;
        return distribution;
    }
}