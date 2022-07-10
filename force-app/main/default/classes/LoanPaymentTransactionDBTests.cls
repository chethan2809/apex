@isTest(isParallel=true)
private class LoanPaymentTransactionDBTests {

    private static LoanPaymentTransactionDB loanPaymentTransactionDBInstance = new LoanPaymentTransactionDB();

    @isTest
    private static void getAggregatedInterestByContractId(){
        Id contractId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Date startDate = GeneralHelper.currentSystemDate.addDays(1);
        Date endDate = GeneralHelper.currentSystemDate.addDays(10);

        Test.startTest();
            List<AggregateResult> aggregateList =
                loanPaymentTransactionDBInstance.getAggregatedInterestByContractId(contractId, startDate, endDate);
        Test.stopTest();

        System.assert(aggregateList!= null);
    }

    @isTest
    private static void getLoanPaymentTransactionByName() {
        Set<String> loanPaymentTxnName = new Set<String> {'LPT-000000067'};
        Test.startTest();
            List<loan__Loan_Payment_Transaction__c> loanPaymentTxnList =
                loanPaymentTransactionDBInstance.getLoanPaymentTransactionByName(loanPaymentTxnName);
        Test.stopTest();

        System.assert(loanPaymentTxnList!= null);
    }

    @isTest
    private static void getLoanPaymentTransactionByIdsTest() {
        Id loanPaymentTxnId = TestUtility.getFakeId(loan__Loan_Payment_Transaction__c.getSObjectType());
        Set<Id> loanPaymentTxnIds = new Set<Id>();
        loanPaymentTxnIds.add(loanPaymentTxnId);

        Test.startTest();
            List<loan__Loan_Payment_Transaction__c> loanPaymentTxnList =
                loanPaymentTransactionDBInstance.getLoanPaymentTransactionByIds(loanPaymentTxnIds);
        Test.stopTest();

        System.assert(loanPaymentTxnList!= null);
    }
}