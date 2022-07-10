@isTest(isParallel=true)
private class FundingDetailsDBTests {

    private static FundingDetailsDB fundingDetailsDBInstance = new FundingDetailsDB();

    @isTest
    private static void getFundingDetailsByIdsTest() {

        loan__Disbursal_Txn_Distribution__c loanDisbursalDistribution = new loan__Disbursal_Txn_Distribution__c();
        Id loanDisbursalDistributionId = TestUtility.getFakeId(loan__Disbursal_Txn_Distribution__c.getSObjectType());

        Test.startTest();
        List<loan__Disbursal_Txn_Distribution__c> loanDisbursalDistributionList = fundingDetailsDBInstance.getFundingDetailsByIds(loanDisbursalDistributionId);
        Test.stopTest();

        System.assert(loanDisbursalDistributionList != null);
        System.assert(loanDisbursalDistributionList.isEmpty());
    }

    @isTest
    private static void getDisbursalTransactionSummaryIdsTest() {
        Id loanDisbursalDistributionId = TestUtility.getFakeId(loan__Disbursal_Txn_Distribution__c.getSObjectType());

        Test.startTest();
            AggregateResult aggregateResult = fundingDetailsDBInstance.getDisbursalTransactionSummaryIds(loanDisbursalDistributionId);
        Test.stopTest();

        System.assert(aggregateResult != null);
    }

    @isTest
    private static void getLoanDisbursalTransactionDetailsByIdsTest() {

        loan__Loan_Disbursal_Transaction__c loanLoanDisbursalTransaction = new loan__Loan_Disbursal_Transaction__c();

        loanLoanDisbursalTransaction.Id = TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType());
        loanLoanDisbursalTransaction.loan__ACH_Filename__c = 'APP-00000102';

        Test.startTest();
            List<loan__Loan_Disbursal_Transaction__c> loanLoanDisbursalTransactionList = fundingDetailsDBInstance.getLoanDisbursalTransactionDetailsByIds(loanLoanDisbursalTransaction.loan__ACH_Filename__c);
        Test.stopTest();

        System.assert(loanLoanDisbursalTransactionList != null);
        System.assert(loanLoanDisbursalTransactionList.isEmpty());
    }
}