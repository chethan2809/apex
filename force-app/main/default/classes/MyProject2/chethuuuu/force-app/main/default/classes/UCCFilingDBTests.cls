@isTest(isParallel=true)

private class UCCFilingDBTests {

    private static UCCFilingDB uccFillingDBInstance = new UCCFilingDB();

    @isTest

    Private static void getUCCFilingListByIds() {

        Id uccFilingId = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        Set<Id> uccFilingIds = new Set<Id>();
        uccFilingIds.add(uccFilingId);

        Test.startTest();
            List<UCC_Filing_Detail__c> uccFilingDetailList = uccFillingDBInstance.getUCCFilingListByIds(uccFilingIds);
        Test.stopTest();

        System.assert(uccFilingDetailList != null);
        System.assert(uccFilingDetailList.isEmpty());
    }

    @isTest
    private static void getUCCRecordsByAccountIds(){
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(accountId);

        Test.startTest();
            List<UCC_Filing_Detail__c> getUccFilingDetailList = uccFillingDBInstance.getUCCRecordsByAccountIds(accountIds);
        Test.stopTest();

        System.assert(getUccFilingDetailList != null);
        System.assert(getUccFilingDetailList.isEmpty());
    }
}