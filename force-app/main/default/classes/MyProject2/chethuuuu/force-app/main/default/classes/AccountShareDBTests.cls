@isTest(isParallel=true)
private class AccountShareDBTests {

    private static AccountShareDB accountShareDBInstance = new AccountShareDB();

    @isTest
    private static void getAccountShareRecordsByLoggedInUserId() {
        Id userId = TestUtility.getFakeId(User.getSObjectType());

        Test.startTest();
            List<AccountShare> accountShare = accountShareDBInstance.getAccountShareRecordsByLoggedInUserId(new Set<Id>{userId});
        Test.stopTest();

        System.assert(accountShare != null);
        System.assert(accountShare.isEmpty());
    }
}