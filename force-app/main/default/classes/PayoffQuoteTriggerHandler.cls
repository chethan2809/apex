public class PayoffQuoteTriggerHandler {

    @TestVisible
    private static CLContractDB clContractDBInstance = new CLContractDB();

    public void beforeInsert(List<loan__Payoff_Quote__c> newPayoffQuoteList) {
        Set<Id> loanAccountIds = new Set<Id>();
        String dateString = GeneralHelper.currentSystemDateTime.format('MM-dd-yyyy_hh:mm:ss');

        for(loan__Payoff_Quote__c payoffQuote : newPayoffQuoteList) {
            loanAccountIds.add(payoffQuote.loan__Loan_Account__c);
            payoffQuote.Name = 'PayoffQuote' + '-' + dateString;
        }

        Map<Id, loan__Loan_Account__c> loanAccountMap = new Map<Id, loan__Loan_Account__c>(
            clContractDBInstance.getLoanAccountsByIds(loanAccountIds)
        );

        for(loan__Payoff_Quote__c payoffQuote : newPayoffQuoteList) {
            loan__Loan_Account__c loanAccount = loanAccountMap.get(payoffQuote.loan__Loan_Account__c);
            if(!loanAccount.Is_Pre_Closure_Fee_Applied__c && loanAccount.Pre_Closure_Penalty_Amount__c > 0) {
                payoffQuote.loan__Poq_Unpaid_Charges__c += loanAccount.Pre_Closure_Penalty_Amount__c;
                payoffQuote.loan__Poq_Total_Payoff_Amount__c += loanAccount.Pre_Closure_Penalty_Amount__c;
            }
        }
    }
}