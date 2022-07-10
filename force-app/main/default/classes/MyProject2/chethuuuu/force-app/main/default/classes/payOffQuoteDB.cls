public class payOffQuoteDB {
    public List<loan__Payoff_Quote__c> getPayOffQuotesByWPTTransactionAmount (List<Decimal> wirePaymentTransactionAmountList) {
        return [
            SELECT Id, loan__Loan_Account__c, loan__Loan_Account__r.Name
            FROM loan__Payoff_Quote__c
            WHERE loan__Poq_Total_Payoff_Amount__c IN :wirePaymentTransactionAmountList
        ];
    }
}