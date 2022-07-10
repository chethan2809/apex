public class PaymentArrangementsDB extends DBManager {
    public List<Payment_Arrangements__c> getPaymentArrangementsByAPS(Set<Id> apsIds) {
        return [
            SELECT Id, Collection_Case__c, Automated_Payment_Setup__c
            FROM Payment_Arrangements__c
            WHERE Automated_Payment_Setup__c IN :apsIds
        ];
    }
}