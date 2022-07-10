@isTest
private class PaymentArrangementsBatchJobTests {

    @isTest
    private static void paymentArrangementsBatchJobTest()
    {
        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.Payment_Arrangements_Batch_Size__c = 50.0;
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;
        Payment_Arrangements__c payMentArrangement = new Payment_Arrangements__c();
        insert payMentArrangement;

        Exception ex;

        System.Test.startTest();
            try {
                PaymentArrangementsBatchJob.execute();
            }
            catch(Exception e) {
                ex = e;
            }
        System.Test.stopTest();
        System.assertEquals(ex, null);
    }

    @isTest
    private static void paymentArrangementsJobCheckBatchSizeException() {

        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.Payment_Arrangements_Batch_Size__c = null;
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;
        Exception ex;

        System.Test.startTest();
            try {
                PaymentArrangementsBatchJob.execute();
            }
            catch(Exception e) {
                ex = e;
            }
        System.Test.stopTest();

        TestUtility.assertException(ex);
        System.assertEquals(ex.getMessage(), 'Payment_Arrangements_Batch_Size__c is null');
    }
}