@isTest
private class CongaQueryDBTests {
    private static CongaQueryDB congaQueryDBInstance = new CongaQueryDB();

    @isTest
    private static void getCongaQueriesByMatchingName() {
        String congaName = '';

        Test.startTest();
            List<APXTConga4__Conga_Merge_Query__c> congaQueryList = congaQueryDBInstance.getCongaQueriesByMatchingName(congaName);
        Test.stopTest();

        System.assert(congaQueryList != null);
        System.assert(congaQueryList.isEmpty());
    }
}