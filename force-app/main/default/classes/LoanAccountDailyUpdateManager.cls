public class LoanAccountDailyUpdateManager {

    @TestVisible
    private static CLContractDB clContractDBInstance = new CLContractDB();

    public static void setLoanAccountFields(List<loan__Loan_Account__c> loanAccountList){
        for(loan__Loan_Account__c loanAccount : loanAccountList) {
            loanAccountDailyUpdates.setConcurrentInterestRate(loanAccount);
            clContractDBInstance.addUpdate(loanAccount);
        }
        clContractDBInstance.executeUpdates();
    }
}