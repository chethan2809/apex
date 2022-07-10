public class LoanPaymentTxnTriggerHandler {
    @TestVisible
    private static AccountDB accountDBInstance = new AccountDB();
    @TestVisible
    private static CLContractDB loanPaymentDBInstance = new CLContractDB();

    public void beforeUpdate(List<loan__Loan_Payment_Transaction__c> triggerNew, Map<Id, loan__Loan_Payment_Transaction__c> oldMap) {
        for(loan__Loan_Payment_Transaction__c loanPaymentTransaction : triggerNew) {
            loan__Loan_Payment_Transaction__c oldLPT = oldMap.get(loanPaymentTransaction.Id);
            if(oldLPT.loan__Reversed__c != loanPaymentTransaction.loan__Reversed__c && loanPaymentTransaction.loan__Reversed__c) {
                loanPaymentTransaction.Reversed_Date__c = GeneralHelper.currentSystemDate;
            }
            if(oldLPT.loan__Retry_On__c != loanPaymentTransaction.loan__Retry_On__c) {
                loanPaymentTransaction.loan__Retry_On__c = GeneralHelper.getBusinessDate(loanPaymentTransaction.loan__Retry_On__c);
            }
        }
    }

    public void afterInsert(Map<Id, loan__Loan_Payment_Transaction__c> lptMap)
    {
        Set<Id> clearedLPTAccountIds = new Set<Id>();
        for (loan__Loan_Payment_Transaction__c lpt : lptMap.values()) {
            if(lpt.loan__Payment_Type__c == 'Regular') {
                clearedLPTAccountIds.add(lpt.Contract_Account_Id__c);
            }
        }

        if(!clearedLPTAccountIds.isEmpty()){
            LoanPaymentTransactionManager.setAccountEverPaidDaysField(clearedLPTAccountIds, true);
        }
    }

    public void afterUpdate(Map<Id, loan__Loan_Payment_Transaction__c> lptNewMap, Map<Id, loan__Loan_Payment_Transaction__c> lptOldMap)
    {
        Set<Id> reversedLPTAccountIds = new Set<Id>();
        for (loan__Loan_Payment_Transaction__c lpt : lptNewMap.values()) {
            loan__Loan_Payment_Transaction__c oldLPT = lptOldMap.get(lpt.Id);

            if(oldLPT.loan__Reversed__c != lpt.loan__Reversed__c && lpt.loan__Reversed__c
                && lpt.loan__Payment_Type__c == 'Regular'
            ) {
                reversedLPTAccountIds.add(lpt.Contract_Account_Id__c);
            }
        }

        if(!reversedLPTAccountIds.isEmpty()){
            LoanPaymentTransactionManager.setAccountEverPaidDaysField(reversedLPTAccountIds, false);
        }
    }

    public void beforeInsert(List<loan__Loan_Payment_Transaction__c> loanPaymentList) {
       Set<Id> contractIds = new Set<Id>();

       for(loan__Loan_Payment_Transaction__c loanPayment : loanPaymentList) {
        contractIds.add(loanPayment.loan__Loan_Account__c);
        System.debug('contractIds++' +contractIds);
       }

       Map<Id, loan__Loan_Account__c> loanAccountMap = new Map<Id, loan__Loan_Account__c>(loanPaymentDBInstance.getLoanAccountsByIds(contractIds));
       System.debug('loanAccountMap++' +loanAccountMap);

       for(loan__Loan_Payment_Transaction__c loanPaymentTransaction : loanPaymentList) {
        if(loanAccountMap.get(loanPaymentTransaction.loan__Loan_Account__c).loan__Loan_Status__c == CLContracts.LOAN_STATUS_CLOSED_WRITTEN_OFF) {
            System.debug('(loanPaymentTransaction.loan__Loan_Account__c).loan__Loan_Status__c++' +(loanAccountMap.get(loanPaymentTransaction.loan__Loan_Account__c).loan__Loan_Status__c));
            loanPaymentTransaction.loan__Write_Off_Recovery_Payment__c = true;
            System.debug(' loanPaymentTransaction.loan__Write_Off_Recovery_Payment__c++' + loanPaymentTransaction.loan__Write_Off_Recovery_Payment__c);
        }
       }
    }
}