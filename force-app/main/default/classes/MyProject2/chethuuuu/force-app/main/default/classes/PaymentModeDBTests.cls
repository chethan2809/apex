@isTest(isParallel=true)
private class PaymentModeDBTests {

    private static PaymentModeDB paymentModeDBInstance = new PaymentModeDB();

    @isTest
    private static void getAllPaymentModes() {

        Test.startTest();
            List<loan__Payment_Mode__c> paymentModeList = paymentModeDBInstance.getAllPaymentModes();
        Test.stopTest();

        System.assert(paymentModeList != null);
        System.assert(paymentModeList.isEmpty());
    }
}