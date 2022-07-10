@isTest(isParallel=true)
private class LoanDisbursalTxnDistributionDBTests {

    private static LoanDisbursalTxnDistributionDB loanDisbursalTxnDistributionDBInstance = new LoanDisbursalTxnDistributionDB();

    @isTest
    private static void getLoanDisbursalTxnDistributionsByLoanNames() {

        Test.startTest();
            List<loan__Disbursal_Txn_Distribution__c> disbursalList = loanDisbursalTxnDistributionDBInstance.getLoanDisbursalTxnDistributionsByLoanNames(new Set<String>{'Test Name'});
        Test.stopTest();

        System.assert(disbursalList != null);
        System.assert(disbursalList.isEmpty());
    }

    @isTest
    private static void getLoanDisbursalTxnDistributionsByDisbursalIds() {
        Set<Id> disbursalTransactionIds = new Set<Id>();
        Set<String> fundedSources = new Set<String>();
        Test.startTest();
            List<loan__Disbursal_Txn_Distribution__c> disbursalList = loanDisbursalTxnDistributionDBInstance.getLoanDisbursalTxnDistributionsByDisbursalIds(disbursalTransactionIds, fundedSources);
        Test.stopTest();

        System.assert(disbursalList != null);
        System.assert(disbursalList.isEmpty());
    }
}