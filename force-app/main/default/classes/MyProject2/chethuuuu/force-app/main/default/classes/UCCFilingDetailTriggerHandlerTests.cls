@isTest
public class UCCFilingDetailTriggerHandlerTests {
    private static uCCFilingDetailTriggerHandler uccTriggerHandlerInstance = new UCCFilingDetailTriggerHandler();
    @isTest
    public static void afterInsertTests() {
        Map<Id, UCC_Filing_Detail__c> uccFilingMap = new Map<Id, UCC_Filing_Detail__c>();

        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());

        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        UCCFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        uccFiling.Account__c = accountRecord.Id;
        uccFiling.Order_ID__c = '153467890';

        UCCfilingMap.put(UCCFiling.Id, UCCFiling);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{accountRecord};
        UCCFilingManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Test.startTest();
            uccTriggerHandlerInstance.afterInsert(UCCfilingMap);
        Test.stopTest();

        system.assertEquals(1, accountDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    public static void beforeUpdateTests() {
        Map<Id, UCC_Filing_Detail__c> newUCCfilingMap = new Map<Id, UCC_Filing_Detail__c>();
        Map<Id, UCC_Filing_Detail__c> oldUCCfilingMap = new Map<Id, UCC_Filing_Detail__c>();

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        UCC_Filing_Detail__c newUCCFiling = new UCC_Filing_Detail__c();
        newUCCFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        newUCCFiling.Is_Terminated__c = true;
        newUCCFiling.Account__c = account.Id;
        newUCCFiling.Is_UCC_Continued__c = true;

        UCC_Filing_Detail__c oldUCCFiling = new UCC_Filing_Detail__c();
        oldUCCFiling.Id = newUCCFiling.Id;
        oldUCCFiling.Is_Terminated__c = false;

        newUCCfilingMap.put(newUCCFiling.Id, newUCCFiling);
        oldUCCfilingMap.put(oldUCCFiling.Id, oldUCCFiling);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {account};
        UCCFilingDetailTriggerHandler.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Test.startTest();
            uccTriggerHandlerInstance.beforeUpdate(newUCCfilingMap, oldUCCfilingMap);
        Test.stopTest();

        system.assertEquals(1, accountDBStubInstance.forUpdateSObjects.size());
    }
}