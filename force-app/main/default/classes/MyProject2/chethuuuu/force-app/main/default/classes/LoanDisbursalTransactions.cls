public class LoanDisbursalTransactions {

    public static loan__Loan_Disbursal_Transaction__c createLoanDisbursalTransaction(
        Decimal amount, Id loanAccountId, Id paymentModeId, Id bankAccountId, Date disbursalDate
    ){
        loan__Loan_Disbursal_Transaction__c disbursal =  new loan__Loan_Disbursal_Transaction__c();
        disbursal.loan__Disbursal_Date__c = disbursalDate;
        disbursal.loan__Disbursed_Amt__c = amount;
        disbursal.loan__Loan_Account__c = loanAccountId;
        disbursal.loan__Mode_of_Payment__c = paymentModeId;
        disbursal.loan__Bank_Account__c = bankAccountId;
        return disbursal;
    }
}