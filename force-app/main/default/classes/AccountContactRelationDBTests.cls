@isTest(isParallel=true)
private class AccountContactRelationDBTests{

    private static AccountContactRelationDB accountContactRelationDBInstance = new AccountContactRelationDB();

    @isTest
    private static void getAccountContactRelationByAccountIdsTest(){

        Id accountId = TestUtility.getFakeId(Account.getSObjectType());

        System.Test.startTest();
            List<AccountContactRelation> accountContactList = accountContactRelationDBInstance.getAccountContactRelationByAccountIds(new Set<Id> {accountId});
        System.Test.stopTest();

        System.assert(accountContactList != null);
        System.assert(accountContactList.isEmpty());
    }
}