@isTest
private class CollectionCongaGenerateURLTests{

    @isTest
    private static void generateCongaDocURL() {

        Id contactId = TestUtility.getFakeId(Contact.getSObjectType());
        Id congaMergeQueryId = TestUtility.getFakeId(APXTConga4__Conga_Merge_Query__c.getSObjectType());
        String congaMergeQuery = String.valueOf(congaMergeQueryId);

        CAN_Conga_Settings__c congaSettings = new CAN_Conga_Settings__c();
        congaSettings.Collection_Case_Query__c = congaMergeQuery;
        congaSettings.Concurrent_Conga_Expire_Time__c = 17;
        insert congaSettings;

        CAN_Conga_Settings__c canCongaSettings = CAN_Conga_Settings__c.getOrgDefaults();
        Payment_Arrangements__c paymentArrangement = new Payment_Arrangements__c();
        paymentArrangement.Id = TestUtility.getFakeId(Payment_Arrangements__c.getSObjectType());

        Test.startTest();
        String generateCongaDocument = CollectionCongaGenerateURL.generateCongaDocumentURL(paymentArrangement.Id, contactId);
        Test.stopTest();

        System.assert(generateCongaDocument != null);
    }
}