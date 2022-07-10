public class PaymentArrangementsTriggerHandler
{
   public void afterUpdate(Map<Id, Payment_Arrangements__c> newPaymentArrangementMap, Map<Id, Payment_Arrangements__c> oldPaymentArrangementMap) {
        //PaymentArrangementsManager.updatePaymentArrangement(newPaymentArrangementMap.values());
    }

    public void afterInsert(Map<Id, Payment_Arrangements__c> newPaymentArrangementMap) {
        //PaymentArrangementsManager.updatePaymentArrangement(newPaymentArrangementMap.values());
    }
}