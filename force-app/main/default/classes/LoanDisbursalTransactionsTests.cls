@isTest
private class LoanDisbursalTransactionsTests {

    @isTest
    private static void loanDisbursalTransaction() {
        Decimal amount = 1250;
        Id bankAccountId = TestUtility.getFakeId(loan__Bank_Account__c.getSObjectType());
        Id paymentModeId = TestUtility.getFakeId(loan__Payment_Mode__c.getSObjectType());
        Id loanAccountId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Date disbursalDate = GeneralHelper.currentSystemDate;

        System.Test.startTest();
            loan__Loan_Disbursal_Transaction__c actualLoanDisbursalTransaction =
                LoanDisbursalTransactions.createLoanDisbursalTransaction(
                    amount, loanAccountId, paymentModeId, bankAccountId, disbursalDate
                );
        System.Test.stopTest();

        System.assert(actualLoanDisbursalTransaction != null);
        System.assertEquals(loanAccountId, actualLoanDisbursalTransaction.loan__Loan_Account__c);
        System.assertEquals(paymentModeId, actualLoanDisbursalTransaction.loan__Mode_of_Payment__c);
        System.assertEquals(bankAccountId, actualLoanDisbursalTransaction.loan__Bank_Account__c);
        System.assertEquals(disbursalDate, actualLoanDisbursalTransaction.loan__Disbursal_Date__c);
    }
}