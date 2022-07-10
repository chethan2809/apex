public class OtherLoanTransactionTriggerHandler {
    @TestVisible
    private static OtherLoanTransactionDB OtherLoanTransactionDBInstance = new OtherLoanTransactionDB();
    public static Decimal loanInterestAccured = 0;
    public static Decimal loanRemaining = 0;
    public static Decimal waivedInterest = 0;

    public void beforeInsert(List<loan__Other_Transaction__c> newList){
        for(loan__Other_Transaction__c otherTransaction : newList){
            if(otherTransaction.loan__Loan_Account__r.loan__Deposit_Interest_Accrued__c != null){
                loanInterestAccured = loanInterestAccured + otherTransaction.loan__Loan_Account__r.loan__Deposit_Interest_Accrued__c;
            }
            if(otherTransaction.loan__Loan_Account__r.loan__Interest_Remaining__c != null){
                loanRemaining = loanRemaining + otherTransaction.loan__Loan_Account__r.loan__Interest_Remaining__c;
            }
            waivedInterest = loanInterestAccured + loanRemaining;
            if(waivedInterest > 0 && otherTransaction.loan__Transaction_Type__c == 'Interest Waive'){
                otherTransaction.loan__Waived_Interest__c = waivedInterest;
                OtherLoanTransactionDBInstance.addInsert(otherTransaction);
            }
        }
        OtherLoanTransactionDBInstance.executeInserts();
    }
}