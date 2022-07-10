@IsTest
private class CaseTriggerHandlerTests
{
    private static CaseTriggerHandler CaseTrigger = new CaseTriggerHandler();

    @TestSetup
    static void makeData() {
        TestUtility.createReciprocalRole();
    }

    @IsTest
    private static void afterUpdateTests()
    {
        Account account = new Account();
        account.Name = 'Test Case Account';
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        list<clcommon__Address__c> addressList = new list<clcommon__Address__c>();
        clcommon__Address__c address = new clcommon__Address__c();

        address.genesis__Active__c = false;
        address.Id = TestUtility.getFakeId(clcommon__Address__c.getSObjectType());
        addressList.add(address);

         Map<Id, Id> addressIdByAccountId = new Map<Id, Id>();
         addressIdByAccountId.put(address.Id, account.Id);

        Set<Id> accountIds = new Set<Id>();
        accountIds.add(account.Id);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        CaseTriggerHandler.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub clcommonAddressDBStubInstance = new DBManagerTestsStub();
        clcommonAddressDBStubInstance.genericReturnObject = new List<clcommon__Address__c> {address};
        CaseTriggerHandler.clcommonAddressDBInstance = (clcommonAddressDB) Test.createStub(clcommonAddressDB.class, clcommonAddressDBStubInstance);

        loan__Bank_Account__c bankAccount = new loan__Bank_Account__c();
        bankAccount.Id = TestUtility.getFakeId(loan__Bank_Account__c.getSObjectType());

        Case oldCase = new Case();
        oldCase.Status = 'Closed';
        oldCase.Id = TestUtility.getFakeId(case.getSObjectType());

        list<Case> caseList = new list<Case>();

        Case newCase = new Case();
        newCase.Id = oldCase.Id;
        newCase.Type = 'Business Address Change';
        newCase.Status = 'Approved';
        newCase.New_Address__c = address.Id;
        newCase.Bank_Account__c = bankAccount.Id;
        newCase.AccountId = account.Id;
        caseList.add(newCase);

        Map<Id,Id> bankAccountIdByAccountId = new Map<Id,Id>();
        bankAccountIdByAccountId.put(newCase.Bank_Account__c, account.Id);

        DBManagerTestsStub bankAccountDBStubInstance = new DBManagerTestsStub();
        bankAccountDBStubInstance.genericReturnObject = new List<loan__Bank_Account__c> {bankAccount};
        CaseTriggerHandler.bankAccountDBInstance = (bankAccountDB) Test.createStub(bankAccountDB.class, bankAccountDBStubInstance);
        Map<Id,Case> oldCaseMap = new Map<Id,Case>();
        oldCaseMap.put(oldCase.Id, oldCase);

        List<String> caseData = new List<String> {newCase.Type, newCase.Status};
        Map<Id, List<String>> caseDataMap = new Map<Id, List<String>>();
        caseDataMap.put(account.Id, caseData);
        Test.startTest();
            CaseTrigger.afterUpdate(caseList, oldCaseMap);
        Test.stopTest();
    }

    @IsTest
    private static void afterUpdateBankTypeTests()
    {
        Account account = new Account();
        account.Name = 'Test Case Account';
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        list<clcommon__Address__c> addressList = new list<clcommon__Address__c>();
        clcommon__Address__c address = new clcommon__Address__c();

        address.genesis__Active__c = false;
        address.Id = TestUtility.getFakeId(clcommon__Address__c.getSObjectType());
        addressList.add(address);

         Map<Id, Id> addressIdByAccountId = new Map<Id, Id>();
         addressIdByAccountId.put(address.Id, account.Id);

        Set<Id> accountIds = new Set<Id>();
        accountIds.add(account.Id);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        CaseTriggerHandler.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub clcommonAddressDBStubInstance = new DBManagerTestsStub();
        clcommonAddressDBStubInstance.genericReturnObject = new List<clcommon__Address__c> {address};
        CaseTriggerHandler.clcommonAddressDBInstance = (clcommonAddressDB) Test.createStub(clcommonAddressDB.class, clcommonAddressDBStubInstance);

        loan__Bank_Account__c bankAccount = new loan__Bank_Account__c();
        bankAccount.Id = TestUtility.getFakeId(loan__Bank_Account__c.getSObjectType());

        Case oldCase = new Case();
        oldCase.Status = 'Closed';
        oldCase.Id = TestUtility.getFakeId(case.getSObjectType());

        list<Case> caseList = new list<Case>();

        Case newCase = new Case();
        newCase.Id = oldCase.Id;
        newCase.Type = 'Bank Account Change';
        newCase.Status = 'Approved';
        newCase.New_Address__c = address.Id;
        newCase.Bank_Account__c = bankAccount.Id;
        newCase.AccountId = account.Id;
        caseList.add(newCase);

        Map<Id,Id> bankAccountIdByAccountId = new Map<Id,Id>();
        bankAccountIdByAccountId.put(newCase.Bank_Account__c, account.Id);

        DBManagerTestsStub bankAccountDBStubInstance = new DBManagerTestsStub();
        bankAccountDBStubInstance.genericReturnObject = new List<loan__Bank_Account__c> {bankAccount};
        CaseTriggerHandler.bankAccountDBInstance = (bankAccountDB) Test.createStub(bankAccountDB.class, bankAccountDBStubInstance);
        Map<Id,Case> oldCaseMap = new Map<Id,Case>();
        oldCaseMap.put(oldCase.Id, oldCase);

        List<String> caseData = new List<String> {newCase.Type, newCase.Status};
        Map<Id, List<String>> caseDataMap = new Map<Id, List<String>>();
        caseDataMap.put(account.Id, caseData);
        Test.startTest();
            CaseTrigger.afterUpdate(caseList, oldCaseMap);
        Test.stopTest();
    }
}