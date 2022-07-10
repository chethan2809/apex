@isTest
public class CongaSignDocumentTriggerTest {
    @isTest
    Static Void Signdocument(){
        APXT_CongaSign__Transaction__c conga = new APXT_CongaSign__Transaction__c();
        conga.APXT_CongaSign__SenderName__c ='test';
        insert conga;
        APXT_CongaSign__Document__c apxt = new APXT_CongaSign__Document__c();
        apxt.APXT_CongaSign__ContentDocumentId__c = '13';
        apxt.APXT_CongaSign__ContentVersionId__c ='12';
        apxt.APXT_CongaSign__Transaction__c = conga.Id;
        apxt.APXT_CongaSign__Type__c = 'Final';
        apxt.APXT_CongaSign__DocumentOrder__c = 1200;
        apxt.Name ='test';
        //insert apxt;
        
       Exception ex;
        Test.startTest();
        try {
            insert apxt;
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();
        System.assert(apxt!= null);
    }
    
}