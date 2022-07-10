@isTest
private class PaymentArrangementsDBTests {

    private static PaymentArrangementsDB paymentArrangementsDBInstance = new PaymentArrangementsDB();

    @isTest
    private static void getPaymentArrangementsByAPS() {

        Payment_Arrangements__c paymentArrangement = new Payment_Arrangements__c();
        paymentArrangement.Id = TestUtility.getFakeId(Payment_Arrangements__c.getSObjectType());

        Set<Id> paymentArrangementIds = new Set<Id>();
        paymentArrangementIds.add(paymentArrangement.Id);

        Test.startTest();
        	List<Payment_Arrangements__c> paymentArrangementList = paymentArrangementsDBInstance.getPaymentArrangementsByAPS(paymentArrangementIds);
        Test.stopTest();

        System.assert(paymentArrangementList != null);
        System.assert(paymentArrangementList.isEmpty());
    }
}