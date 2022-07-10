@isTest
private class LoanDisbursalTxnDistributionsTests {

    @isTest
    private static void createLoanDisbursalTxnDistribution() {

        Id bankAccountId = TestUtility.getFakeId(loan__Bank_Account__c.getSObjectType());
        Id paymentModeId = TestUtility.getFakeId(loan__Payment_Mode__c.getSObjectType());

        Test.startTest();
            loan__Disbursal_Txn_Distribution__c loanDisbursal = LoanDisbursalTxnDistributions.createLoanDisbursalTxnDistribution(
                1000, bankAccountId, paymentModeId, 'Disbursement', 'ACH');
        Test.stopTest();

        System.assert(loanDisbursal != null);
        System.assertEquals(1000, loanDisbursal.loan__Distribution_Amount__c);
        System.assertEquals(paymentModeId, loanDisbursal.loan__Payment_Mode__c);
        System.assertEquals(bankAccountId, loanDisbursal.loan__Bank_Account__c);
        System.assertEquals('Disbursement', loanDisbursal.loan__Distribution_Type__c );
        System.assertEquals('ACH', loanDisbursal.Funded_Source__c );
    }
}