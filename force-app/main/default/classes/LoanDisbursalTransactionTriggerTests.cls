@isTest
private class LoanDisbursalTransactionTriggerTests {
    @isTest
    private static void loanDisbursalTransactionTriggerTest(){
        TestUtility.runSetupData();
        Account investorAccount = new Account();
        investorAccount.Name = TestUtility.generateFakeName();
        insert investorAccount;

        loan__Loan_Disbursal_Transaction__c disbursalTransaction = TestUtility.createLoanDisbursalTransaction();
        disbursalTransaction.loan__Disbursal_Date__c = TestUtility.currentSystemDate;
        disbursalTransaction.Investor_Account__c = investorAccount.Id;
        update disbursalTransaction;

        list<loan__Loan_Disbursal_Transaction__c> disbursalTransactionList = [
            SELECT Id, Investor_Account__c
            FROM loan__Loan_Disbursal_Transaction__c
        ];

        System.assert(disbursalTransaction.Id != null);
        System.assertEquals(1, disbursalTransactionList.size());
        System.assertEquals(disbursalTransaction.Investor_Account__c, disbursalTransactionList[0].Investor_Account__c);
    }
}