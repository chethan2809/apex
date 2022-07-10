public class LoanDisbursalTransactionTriggerHandler {

    @TestVisible
    private static LoanDisbursalTransactionsDB loanDisbursalTransactionsDBInstance = new LoanDisbursalTransactionsDB();

    public void beforeInsert(List<loan__Loan_Disbursal_Transaction__c> newLoanDisbursalTransactionList) {

        Id investorId = CustomSettingsHelper.generalSettings.Default_Investor_Account_Id__c;

        for(loan__Loan_Disbursal_Transaction__c newDisbursalTransaction : newLoanDisbursalTransactionList) {
            newDisbursalTransaction.Investor_Account__c = investorId;
        }

    }

    public void afterInsert(Map<Id, loan__Loan_Disbursal_Transaction__c> newLoanDisbursalTransactionMap) {
        Set<Id> disbursalIdsForInvestorLoanCreation = new Set<Id>();

        for(loan__Loan_Disbursal_Transaction__c newDisbursalTransaction :
            loanDisbursalTransactionsDBInstance.getLoanDisbursalTransactionsByIds(newLoanDisbursalTransactionMap.keySet())
        ) {
            if(newDisbursalTransaction.Investor_Account__c != null) {
                disbursalIdsForInvestorLoanCreation.add(newDisbursalTransaction.Id);
            }
        }

        if(!disbursalIdsForInvestorLoanCreation.isEmpty()) {
            InvestorLoanManager.createInvestorLoans(disbursalIdsForInvestorLoanCreation);
        }
    }

    public void afterUpdate(
        Map<Id, loan__Loan_Disbursal_Transaction__c> newLoanDisbursalTransactionMap,
        Map<Id, loan__Loan_Disbursal_Transaction__c> oldLoanDisbursalTransactionMap
    ) {

        Set<Id> disbursalIdsForInvestorLoanCreation = new Set<Id>();
        for(loan__Loan_Disbursal_Transaction__c newDisbursalTransaction : newLoanDisbursalTransactionMap.values()) {
            loan__Loan_Disbursal_Transaction__c oldDisbursalTransaction = oldLoanDisbursalTransactionMap.get(newDisbursalTransaction.Id);
            if(oldDisbursalTransaction.Investor_Account__c == null && newDisbursalTransaction.Investor_Account__c != null) {
                disbursalIdsForInvestorLoanCreation.add(newDisbursalTransaction.Id);
            }
        }

        if(!disbursalIdsForInvestorLoanCreation.isEmpty()) {
            InvestorLoanManager.createInvestorLoans(disbursalIdsForInvestorLoanCreation);
        }
    }
}