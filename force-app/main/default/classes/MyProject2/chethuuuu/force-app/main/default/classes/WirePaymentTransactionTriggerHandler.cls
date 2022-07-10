public class WirePaymentTransactionTriggerHandler {

    @TestVisible
    public static PayOffQuoteDB payOffQuoteDBInstance = new PayOffQuoteDB();
    @TestVisible
    public static promiseToPayDB promiseToPayDBInstance = new promiseToPayDB();
    @TestVisible
    public static wirePaymentTransactionDB wirePaymentTransactionDBInstance = new wirePaymentTransactionDB();

    public void afterInsert(Map<Id, Wire_Payment_Transaction__c> newWirePaymentTransactionMap) {
        List<Wire_Payment_Transaction__c> wirePaymentTransactionList = newWirePaymentTransactionMap.values();
        List<Decimal> wirePaymentTransactionAmountList = new List<Decimal>();
        List<loan__Payoff_Quote__c> payOffQuoteList;
        List<collect__Promise_To_Pay__c> promiseToPayList;
        for(Wire_Payment_Transaction__c wirePaymentTransaction : wirePaymentTransactionList) {
            if(wirePaymentTransaction.Loan_Account_Name__c == null) {
                payOffQuoteList = payOffQuoteDBInstance.getPayOffQuotesByWPTTransactionAmount(wirePaymentTransactionAmountList);
                promiseToPayList = promiseToPayDBInstance.getPromiseToPayByWPTTransactionAmount(wirePaymentTransactionAmountList);
            }
            wirePaymentTransactionAmountList.add(wirePaymentTransaction.Transaction_Amount__c);
        }
        if(!payOffQuoteList.isEmpty() && payOffQuoteList.size() <= 1 && payOffQuoteList.get(0).loan__Loan_Account__c != null) {
            for(Wire_Payment_Transaction__c wirePaymentTransaction : newWirePaymentTransactionMap.values()) {
                wirePaymentTransaction.Loan_Account__c = payOffQuoteList.get(0).loan__Loan_Account__c;
                wirePaymentTransaction.Loan_Account_Name__c = payOffQuoteList.get(0).loan__Loan_Account__r.Name;
                wirePaymentTransactionDBInstance.addUpdate(wirePaymentTransaction);
            }
        }
        else if(!promiseToPayList.isEmpty() && promiseToPayList.size() <= 1 && promiseToPayList.get(0).collect__Dev_Contract__c != null) {
            for(Wire_Payment_Transaction__c wirePaymentTransaction : newWirePaymentTransactionMap.values()) {
                wirePaymentTransaction.Loan_Account__c = promiseToPayList.get(0).collect__Dev_Contract__r.collect__External_ID__c;
                wirePaymentTransaction.Loan_Account_Name__c = promiseToPayList.get(0).collect__Dev_Contract__r.Name;
                wirePaymentTransactionDBInstance.addUpdate(wirePaymentTransaction);
            }
        }
        wirePaymentTransactionDBInstance.executeUpdates();
    }
}