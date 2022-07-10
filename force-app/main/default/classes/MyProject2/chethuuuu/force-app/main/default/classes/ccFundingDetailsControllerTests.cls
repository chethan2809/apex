@isTest(isParallel=true)
private class ccFundingDetailsControllerTests {
    @isTest
    private static void getFundingDetailsTest() {

        Id loanDisbursalDistributionId = TestUtility.getFakeId(loan__Disbursal_Txn_Distribution__c.getSObjectType());

        loan__Disbursal_Txn_Distribution__c loanDisbursalTxnDistribution = new loan__Disbursal_Txn_Distribution__c();

        DBManagerTestsStub fundingDetailsDBInstance = new DBManagerTestsStub();
        fundingDetailsDBInstance.genericReturnObject = new List<loan__Disbursal_Txn_Distribution__c> {loanDisbursalTxnDistribution};
        ccFundingDetailsController.fundingDetailsDBInstance = (FundingDetailsDB) Test.createStub(FundingDetailsDB.class, fundingDetailsDBInstance);

        Test.startTest();
            List<loan__Disbursal_Txn_Distribution__c> loanDisbursalTxnDistributionList = ccFundingDetailsController.getFundingDetails(loanDisbursalDistributionId);
        Test.stopTest();

        System.assertEquals(false, loanDisbursalTxnDistributionList.isEmpty());
    }

    @isTest
    private static void getDisbursalTransactionTotalSummaryTest() {

        Id loanDisbursalDistributionId = TestUtility.getFakeId(loan__Disbursal_Txn_Distribution__c.getSObjectType());

        Test.startTest();
            AggregateResult aggregateResult = ccFundingDetailsController.getDisbursalTransactionTotalSummary(loanDisbursalDistributionId);
        Test.stopTest();

        System.assert(aggregateResult != null);
    }

    @isTest
    private static void getLoanDisbursalTransactionDetailsTest() {

        Id loanLoanDisbursalTransactionId = TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType());

        loan__Loan_Disbursal_Transaction__c loanLoanDisbursalDistribution = new loan__Loan_Disbursal_Transaction__c();

        DBManagerTestsStub fundingDetailsDBInstance = new DBManagerTestsStub();
        fundingDetailsDBInstance.genericReturnObject = new List<loan__Loan_Disbursal_Transaction__c> {loanLoanDisbursalDistribution};
        ccFundingDetailsController.fundingDetailsDBInstance = (FundingDetailsDB) Test.createStub(FundingDetailsDB.class, fundingDetailsDBInstance);

        Test.startTest();
            List<loan__Loan_Disbursal_Transaction__c> loanLoanDisbursalDistributionList = ccFundingDetailsController.getLoanDisbursalTransactionDetails(loanLoanDisbursalTransactionId);
        Test.stopTest();

        System.assertEquals(false, loanLoanDisbursalDistributionList.isEmpty());
    }
}