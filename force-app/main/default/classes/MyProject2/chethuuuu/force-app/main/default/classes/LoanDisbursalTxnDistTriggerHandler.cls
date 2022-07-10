public class LoanDisbursalTxnDistTriggerHandler {

    @TestVisible
    private static CLContractDB clContractDBInstance = new CLContractDB();

    public void beforeInsert(List<loan__Disbursal_Txn_Distribution__c> newLoanDisbursalTxnDistributionList) {

        Set<String> loanAccountNames = new Set<String>();
        Map<String, loan__Loan_Account__c> loanAccountByNames = new Map<String, loan__Loan_Account__c>();

        for(loan__Disbursal_Txn_Distribution__c newDisbursalTxnDistribution : newLoanDisbursalTxnDistributionList) {
            loanAccountNames.add(newDisbursalTxnDistribution.loan__Name_of_Entity__c);
        }

        for(loan__Loan_Account__c loanAccount :clContractDBInstance.getLoanAccountsByNames(loanAccountNames)) {
            loanAccountByNames.put(loanAccount.Name, loanAccount);
        }

        for(loan__Disbursal_Txn_Distribution__c newDisbursalTxnDistribution : newLoanDisbursalTxnDistributionList) {
            loan__Loan_Account__c loanAccount = loanAccountByNames.get(newDisbursalTxnDistribution.loan__Name_of_Entity__c);
            if(loanAccount.Disbursement_Count__c != null && loanAccount.Disbursement_Count__c > 1) {
                newDisbursalTxnDistribution.loan__Bank_Account__c = loanAccount.Bank_Account__c;
                newDisbursalTxnDistribution.Funded_Source__c = LoanDisbursalTxnDistributions.FUNDED_SOURCE_MERCHANT;
                newDisbursalTxnDistribution.loan__Payment_Mode__c = ServicingHelper.paymentModeIdByName.get(GeneralConstants.PAYMENT_MODE_ACH);
            }
        }
    }
}