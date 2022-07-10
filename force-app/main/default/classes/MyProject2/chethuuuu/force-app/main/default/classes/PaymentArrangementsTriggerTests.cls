@isTest
private class PaymentArrangementsTriggerTests {

    private static PaymentArrangementsDB paymentArrangementsDBInstance = new PaymentArrangementsDB();

    @isTest
    private static void paymentArrangementsTriggerTest() {
    Exception ex;
    Payment_Arrangements__c paymentArrangements = new Payment_Arrangements__c();
    paymentArrangements.Payment_Arrangement_Type__c = 'Settlement';

        try{
            Insert paymentArrangements;
            paymentArrangements.Payment_Arrangement_Type__c = 'Accommodation';
            paymentArrangementsDBInstance.addUpdate(paymentArrangements);
            paymentArrangementsDBInstance.executeUpdates();
        }catch(Exception e){
            e = ex;
        }
        System.assert(paymentArrangements.Id != null);
    }
}