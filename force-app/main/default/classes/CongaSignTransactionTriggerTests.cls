@isTest
private class CongaSignTransactionTriggerTests {

    @isTest
    private static void congaSignTransaction(){

        String contentDocumentId = TestUtility.getFakeId(ContentDocument.getSObjectType());
        String originalDocumentId = TestUtility.getFakeId(ContentDocument.getSObjectType());

        APXT_CongaSign__Transaction__c congaSignTransaction = new APXT_CongaSign__Transaction__c();
        congaSignTransaction.APXT_CongaSign__BusinessUnit__c = 'Test DBS';
        congaSignTransaction.APXT_CongaSign__ContentDocumentId__c = contentDocumentId;
        congaSignTransaction.APXT_CongaSign__OriginalDocumentId__c = originalDocumentId;
        congaSignTransaction.APXT_CongaSign__SenderEmail__c = 'TestConga@gmail.com';
        congaSignTransaction.APXT_CongaSign__SenderName__c = 'Fake Name';
        congaSignTransaction.APXT_CongaSign__Status__c = 'new';
        insert congaSignTransaction;

        Test.startTest();
            CongaSignTransaction.APXT_CongaSign__BusinessUnit__c = 'Test DBS Updated';
            update CongaSignTransaction;
        Test.stopTest();

        list<APXT_CongaSign__Transaction__c> congaSignTransactionList = [
            SELECT Id, APXT_CongaSign__BusinessUnit__c
            FROM APXT_CongaSign__Transaction__c
        ];

        System.assert(CongaSignTransaction.Id != null);
        System.assertEquals(1, congaSignTransactionList.size());
        System.assertEquals('Test DBS Updated', congaSignTransactionList[0].APXT_CongaSign__BusinessUnit__c);
    }
}