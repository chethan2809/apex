@isTest
private class PaymentArrangementsTests {

    @isTest
    private static void paymentArrangementsTest() {
        APXT_CongaSign__Transaction__c congaSignTransaction = new APXT_CongaSign__Transaction__c();
        congaSignTransaction.APXT_CongaSign__SenderName__c ='test';
        insert congaSignTransaction;

        APXT_CongaSign__Document__c congaSignDocument = new APXT_CongaSign__Document__c();
        congaSignDocument.APXT_CongaSign__ContentDocumentId__c = '13';
        congaSignDocument.APXT_CongaSign__ContentVersionId__c ='12';
        congaSignDocument.APXT_CongaSign__Transaction__c = congaSignTransaction.Id;
        congaSignDocument.APXT_CongaSign__Type__c = 'Final';
        congaSignDocument.APXT_CongaSign__DocumentOrder__c = 1200;
        congaSignDocument.Name ='test';
        insert congaSignDocument;

        Test.StartTest();
        	PaymentArrangements.setPAFieldsfromCongaSignTransaction(congaSignTransaction);
        Test.StopTest();

        System.assert(congaSignDocument.Id != null);
    }
}