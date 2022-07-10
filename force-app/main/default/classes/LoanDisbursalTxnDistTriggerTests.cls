@isTest
private class LoanDisbursalTxnDistTriggerTests {

    @TestSetup
    static void makeData(){
        TestUtility.runSetupData();
        loan__Loan_Disbursal_Transaction__c disbursalTransaction = TestUtility.createLoanDisbursalTransaction();
        disbursalTransaction.loan__Cleared__c = true;
        update disbursalTransaction;
    }

    @isTest
    static void onInsert() {
        loan__Loan_Disbursal_Transaction__c disbursalTransaction = [SELECT Id, loan__Disbursed_Amt__c FROM loan__Loan_Disbursal_Transaction__c LIMIT 1];

        loan__Disbursal_Txn_Distribution__c newDisbursalTxnDistribution = new loan__Disbursal_Txn_Distribution__c();
        newDisbursalTxnDistribution.loan__Distribution_Amount__c = disbursalTransaction.loan__Disbursed_Amt__c;
        newDisbursalTxnDistribution.loan__Loan_Disbursal_Transaction__c = disbursalTransaction.Id;

        Exception ex;
        Test.startTest();
        try {
            insert newDisbursalTxnDistribution;
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        TestUtility.assertException(ex);
    }

}