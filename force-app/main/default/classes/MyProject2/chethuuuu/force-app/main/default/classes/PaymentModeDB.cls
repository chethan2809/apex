public class PaymentModeDB extends DBManager {
    public List<loan__Payment_Mode__c> getAllPaymentModes() {
        return [SELECT Id, Name FROM loan__Payment_Mode__c];
    }
}