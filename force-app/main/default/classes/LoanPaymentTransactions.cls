public class LoanPaymentTransactions {

    public static loan__Loan_Payment_Transaction__c createLoanPaymentTransaction(
        Id loanAccountId, Id paymentModeId, Decimal transactionAmount, Date transactionDate
    ) {
        loan__Loan_Payment_Transaction__c loanPaymentTransaction = new loan__Loan_Payment_Transaction__c();
        loanPaymentTransaction.loan__Transaction_Amount__c = transactionAmount;
        loanPaymentTransaction.loan__Payment_Mode__c = paymentModeId;
        loanPaymentTransaction.loan__Transaction_Date__c = transactionDate;
        LoanPaymentTransaction.loan__Receipt_Date__c = GeneralHelper.currentSystemDate;
        loanPaymentTransaction.loan__Loan_Account__c = loanAccountId;
        return loanPaymentTransaction;
    }
}