@isTest
private class CongaSignTransactionsDBTests {

    private static CongaSignTransactionsDB congaSignTransactionsDBInstance = new CongaSignTransactionsDB();

    @IsTest
    private static void getCongaSignTransactionsByIds(){
        Id congaSignTransactionId = TestUtility.getFakeId(APXT_CongaSign__Transaction__c.getSObjectType());
        Set<Id> congaSignTransactionIds = new Set<Id>();
        congaSignTransactionIds.add(congaSignTransactionId);

        Test.startTest();
        List<APXT_CongaSign__Transaction__c> congaSignTransactionList = CongaSignTransactionsDBInstance.getCongaSignTransactionsByIds(congaSignTransactionIds);
        Test.stopTest();

        system.assert(congaSignTransactionList != null);
    }
}