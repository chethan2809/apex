@isTest(isParallel=true)
private class CongaSignDocumentDBTests {

    private static CongaSignDocumentDB congaSignDocumentDBInstance = new CongaSignDocumentDB();

    @isTest
    private static void getFinalSignDocumentsIds() {
        Id congaSignDocId = TestUtility.getFakeId(APXT_CongaSign__Document__c.getSObjectType());
        Set<Id> congaSignDocIds = new Set<Id>();
        congaSignDocIds.add(congaSignDocId);

        Test.startTest();
            List<APXT_CongaSign__Document__c> congaSignDocList = congaSignDocumentDBInstance.getFinalSignDocumentsIds(congaSignDocIds);
        Test.stopTest();

        System.assert(congaSignDocList != null);
        System.assert(congaSignDocList.isEmpty());
    }
}