@isTest(isParallel=true)
private class BankAccountDBTests {

    private static BankAccountDB bankAccountDBInstance = new BankAccountDB();

    @isTest
    private static void getAllActiveBankAccountsByContactIds() {
        Id contactId = TestUtility.getFakeId(Contact.getSObjectType());
        Set<Id> contactIds = new Set<Id>();
        contactIds.add(contactId);

        Test.startTest();
            List<loan__Bank_Account__c> bankAccountList = bankAccountDBInstance.getAllActiveBankAccountsByContactIds(contactIds);
        Test.stopTest();

        System.assert(bankAccountList != null);
        System.assert(bankAccountList.isEmpty());
    }

    @isTest
    private static void getAllActiveBankAccountsByAccountIds() {
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        List<Id> accountIds = new List<Id>();
        accountIds.add(accountId);

        Test.startTest();
            List<loan__Bank_Account__c> bankAccountList = bankAccountDBInstance.getAllActiveBankAccountsByAccountIds(accountIds);
        Test.stopTest();

        System.assert(bankAccountList != null);
        System.assert(bankAccountList.isEmpty());
    }

    @isTest
    private static void getAllBankAccountsByAccountIds() {
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(accountId);

        Test.startTest();
            List<loan__Bank_Account__c> bankAccountList = bankAccountDBInstance.getAllBankAccountsByAccountIds(accountIds);
        Test.stopTest();

        System.assert(bankAccountList != null);
        System.assert(bankAccountList.isEmpty());
    }

    @isTest
    private static void getBankAccountsById() {
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(accountId);

        Test.startTest();
            List<loan__Bank_Account__c> bankAccountList = bankAccountDBInstance.getBankAccountsById(accountIds);
        Test.stopTest();

        System.assert(bankAccountList != null);
        System.assert(bankAccountList.isEmpty());
    }

    @isTest
    private static void getActiveCANBankAccount() {

        Test.startTest();
            List<loan__Bank_Account__c> bankAccountList = bankAccountDBInstance.getActiveCANBankAccount();
        Test.stopTest();

        System.assert(bankAccountList != null);
    }
}