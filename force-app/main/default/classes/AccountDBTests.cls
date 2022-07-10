@IsTest(isParallel=true)
private class AccountDBTests {
    private static AccountDB accountDBInstance = new AccountDB();
    @isTest
    private static void getAccountByIds() {
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(accountId);

        Test.startTest();
            List<Account> accountList = accountDBInstance.getAccountByIds(accountIds);
        Test.stopTest();

        System.assert(accountList != null);
        System.assert(accountList.isEmpty());
    }

    @isTest
    private static void getAccountNameAndPhoneNumberById() {
        TestUtility.runSetupData();
        Account account = TestUtility.createAccount();

        Test.startTest();
            Account accountObject = accountDBInstance.getAccountNameAndPhoneNumberById(account.Id);
        Test.stopTest();

        System.assert(accountObject != null);
    }

    @isTest
    private static void getDuplicateGuarantorAccounts() {
        String accountIdStr = TestUtility.getFakeId(Account.getSObjectType());

        Test.startTest();
            List<Account> accountList = accountDBInstance.getDuplicateGuarantorAccounts(accountIdStr);
        Test.stopTest();

        System.assert(accountList != null);
        System.assert(accountList.isEmpty());
    }

    @isTest
    private static void getExistingBorrowerAccts() {
        Test.startTest();
            List<Account> accountList = accountDBInstance.getExistingBorrowerAccts(new Set<String>{'870227400'}, new Set<String>{'Randolph'}, new Set<String>{'Chicago'});
        Test.stopTest();

        System.assert(accountList != null);
        System.assert(accountList.isEmpty());
    }

    @isTest
    private static void getBorrowerAccountsToShowInBrokerPortal() {
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(accountId);

        Test.startTest();
            List<Account> accountList = accountDBInstance.getBorrowerAccountsToShowInBrokerPortal(accountIds);
        Test.stopTest();

        System.assert(accountList != null);
        System.assert(accountList.isEmpty());
    }

    @isTest
    private static void getConcurrentEligibleBorrowerAccounts() {
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(accountId);

        Test.startTest();
            List<Account> accountList = accountDBInstance.getConcurrentEligibleBorrowerAccounts(accountIds);
        Test.stopTest();

        System.assert(accountList != null);
        System.assert(accountList.isEmpty());
    }

    @IsTest
    private static void getConcurrentEligibleBorrowerAccountsTests() {
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(accountId);

        Test.startTest();
            List<Account> accountCompList = accountDBInstance.getAllCompetitorAccounts();
            List<Account> accountGAByIDsList = accountDBInstance.getGuarantorAccountsByIds(accountIds);
            List<Account> accountBAByBrokerList = accountDBInstance.getBorrowerAccountsByBrokerAccounts(accountIds);
            Test.stopTest();

        System.assert(accountBAByBrokerList != null);
        System.assert(accountBAByBrokerList.isEmpty());
    }

    @IsTest
    private static void getBorrowerAccountsByBrokerAccountsAndIdsTets() {
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(accountId);

        Test.startTest();
            List<Account> accountList = accountDBInstance.getBorrowerAccountsByBrokerAccountsAndIds(accountIds, accountIds);
            Test.stopTest();

        System.assert(accountList != null);
        System.assert(accountList.isEmpty());
    }

    @IsTest
    private static void getBrokerDetailsByBorrowerAccountIds() {
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(accountId);

        Test.startTest();
            List<Account> accountList = accountDBInstance.getBrokerDetailsByBorrowerAccountIds(accountIds);
            Test.stopTest();

        System.assert(accountList != null);
        System.assert(accountList.isEmpty());
    }
}