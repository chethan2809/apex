@isTest
private class AccountContactRelationManagerTests{
    @isTest
    private static void createAccountContactRelationTest(){

        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id contactId = TestUtility.getFakeId(Contact.getSObjectType());

        DBManagerTestsStub accountContactRelationDBStubInstance = new DBManagerTestsStub();
        AccountContactRelationManager.accountContactRelationDBInstance = (accountContactRelationDB) Test.createStub(accountContactRelationDB.class, accountContactRelationDBStubInstance);

        Test.startTest();
        AccountContactRelationManager.createAccountContactRelation(accountId, contactId);
        Test.stopTest();

        System.assertEquals(1, accountContactRelationDBStubInstance.forInsertSObjects.size());
    }
}