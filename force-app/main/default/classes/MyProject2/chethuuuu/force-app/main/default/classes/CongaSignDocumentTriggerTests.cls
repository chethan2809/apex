@isTest
private class CongaSignDocumentTriggerTests {

    @isTest
    private static Void congaSignDocumentInsert(){
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

        Exception ex;
        Test.startTest();
        try {
            congaSignDocument.Name ='testNew';
            update congaSignDocument;
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        list<APXT_CongaSign__Document__c> congaSignDocumentList =[
            SELECT Id, APXT_CongaSign__Type__c
            FROM APXT_CongaSign__Document__c
        ];

        System.assert(congaSignDocument.Id != null);
        System.assertEquals(1, congaSignDocumentList.size());
        System.assertEquals('Final', congaSignDocumentList[0].APXT_CongaSign__Type__c);
    }
}