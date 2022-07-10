@isTest
private class DataMerchQueueableJobTests {
    @isTest
    private static void requestDataMerch() {
        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        account.Business_Tax_ID__c = '852802924';
    }
}