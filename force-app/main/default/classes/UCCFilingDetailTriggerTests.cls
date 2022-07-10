@isTest
private class UCCFilingDetailTriggerTests {

    @isTest
    private static void afterInsert() {
        Account accountRecord = TestUtility.createAccount();

        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Account__c = accountRecord.Id;
        uccFiling.Order_ID__c = '153467890';

        Exception ex;
        Test.startTest();
            try {
                insert uccFiling;
            } catch (Exception e) {
                ex = e;
            }
        Test.stopTest();

        TestUtility.assertNullException(ex);

        List<UCC_Filing_Detail__c> actualUCCFiling = [
            SELECT Id
            FROM UCC_Filing_Detail__c
        ];

        System.assertEquals(1, actualUCCFiling.size());
    }

    @isTest
    private static void beforeUpdate() {
        Account accountRecord = TestUtility.createAccount();

        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Account__c = accountRecord.Id;
        uccFiling.Order_ID__c = '153467890';
        insert uccFiling;

        uccFiling.Order_Status__c = 'NEW';
        Exception ex;
        Test.startTest();
            try {
                update uccFiling;
            } catch (Exception e) {
                ex = e;
            }
        Test.stopTest();

        TestUtility.assertNullException(ex);

        List<UCC_Filing_Detail__c> actualUCCFiling = [
            SELECT Id
            FROM UCC_Filing_Detail__c
        ];

        System.assertEquals(1, actualUCCFiling.size());
        System.assertEquals('NEW', uccFiling.Order_Status__c);
    }
}