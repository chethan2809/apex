@isTest
private class CongaSignTransactionsTests {

    @isTest
    private static void isStatusChanged() {
        APXT_CongaSign__Transaction__c oldCongaTransaction = new APXT_CongaSign__Transaction__c();
        oldCongaTransaction.Id = TestUtility.getFakeId(APXT_CongaSign__Transaction__c.getSObjectType());
        oldCongaTransaction.APXT_CongaSign__Status__c  = 'DRAFT';

        APXT_CongaSign__Transaction__c newCongaTransaction = new APXT_CongaSign__Transaction__c();
        newCongaTransaction.Id = oldCongaTransaction.Id;
        newCongaTransaction.APXT_CongaSign__Status__c = 'SENT';

        Test.startTest();
            Boolean statusChanged = CongaSignTransactions.isStatusChanged(newCongaTransaction, oldCongaTransaction);
        Test.stopTest();

        system.assertEquals(true,statusChanged);
    }
    @isTest
    private static void sendChatterNotificationstests() {

        User userRecord = new User();
        userRecord.Id = TestUtility.getFakeId(User.getSObjectType());

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Sales_Rep__c = userRecord.Id;

        APXT_CongaSign__Transaction__c congaTransaction = new APXT_CongaSign__Transaction__c();
        congaTransaction.Id = TestUtility.getFakeId(APXT_CongaSign__Transaction__c.getSObjectType());
        congaTransaction.Parent_a6t__c = application.Id;

        Test.startTest();
        CongaSignTransactions.sendChatterNotifications(congaTransaction);
        Test.stopTest();

        System.assertEquals(application.Id, congaTransaction.Parent_a6t__c);
    }
}