@isTest(isParallel=true)
private class CLContractDBTests {

    private static CLContractDB clContractDBInstance = new CLContractDB();

    @isTest
    private static void getLoanAccountsByIds() {
        Id loanAccountId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Set<Id> loanAccountIds = new Set<Id>();
        loanAccountIds.add(loanAccountId);

        Test.startTest();
            List<loan__Loan_Account__c> loanAccountList = clContractDBInstance.getLoanAccountsByIds(loanAccountIds);
        Test.stopTest();

        System.assert(loanAccountList != null);
        System.assert(loanAccountList.isEmpty());
    }

    @isTest
    private static void getLoanAccountsAndItsCompetitorPartiesByIds() {
        Id loanAccountId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Set<Id> loanAccountIds = new Set<Id>();
        loanAccountIds.add(loanAccountId);

        clcommon__Party_Type__c partyType = new clcommon__Party_Type__c();
        partyType.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());
        partyType.Name = GeneralConstants.PARTY_TYPE_COMPETITOR;

        Test.startTest();
            List<loan__Loan_Account__c> loanAccountList = clContractDBInstance.getLoanAccountsAndItsCompetitorPartiesByIds(loanAccountIds);
        Test.stopTest();

        System.assert(loanAccountList != null);
        System.assert(loanAccountList.isEmpty());
    }

    @isTest
    private static void getActiveLoanAccountsByBorrowerIds() {
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(accountId);

        Test.startTest();
            List<loan__Loan_Account__c> loanAccountList = clContractDBInstance.getActiveLoanAccountsByBorrowerIds(accountIds);
        Test.stopTest();

        System.assert(loanAccountList != null);
        System.assert(loanAccountList.isEmpty());
    }

    @isTest
    private static void getClosedLoanAccountsByCustomerAccountIds() {
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(accountId);

        Test.startTest();
            List<loan__Loan_Account__c> loanAccountList = clContractDBInstance.getClosedLoanAccountsByCustomerAccountIds(accountIds);
        Test.stopTest();

        System.assert(loanAccountList != null);
        System.assert(loanAccountList.isEmpty());
    }

    @isTest
    private static void getRecentLoanAccountsByBorrowerIds() {
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(accountId);

        Test.startTest();
            List<loan__Loan_Account__c> loanAccountList = clContractDBInstance.getRecentLoanAccountsByBorrowerIds(accountIds);
            List<loan__Loan_Account__c> loanAccountListManual = clContractDBInstance.getRecentLoanAccountsByOppAccountIds(accountIds);
        Test.stopTest();

        System.assert(loanAccountList != null);
        System.assert(loanAccountList.isEmpty());
    }

    @isTest
    private static void getLoanAccountsAndItsLastRepaymentScheduleByIds() {
        Id loanAccountId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Set<Id> loanAccountIds = new Set<Id>();
        loanAccountIds.add(loanAccountId);

        Test.startTest();
            List<loan__Loan_Account__c> loanAccountList = clContractDBInstance.getLoanAccountsAndItsLastRepaymentScheduleByIds(loanAccountIds);
        Test.stopTest();

        System.assert(loanAccountList != null);
        System.assert(loanAccountList.isEmpty());
    }

    @isTest
    private static void getLoanAccountsByApplicationIdsTests() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(applicationId);

        Test.startTest();
            List<loan__Loan_Account__c> loanAccountList = clContractDBInstance.getLoanAccountsByApplicationIds(applicationIds);
        Test.stopTest();

        System.assert(loanAccountList != null);
        System.assert(loanAccountList.isEmpty());
    }

    @isTest
    private static void getLoanAccountsByNames() {
        Test.startTest();
            List<loan__Loan_Account__c> loanAccountList = clContractDBInstance.getLoanAccountsByNames(new Set<String> {'LAI-0000000'});
        Test.stopTest();

        System.assert(loanAccountList != null);
    }

    @isTest
    private static void getLoanAccountsAndItsLoanPaymentTxnByName() {
        Test.startTest();
            List<loan__Loan_Account__c> loanAccountList =
                clContractDBInstance.getLoanAccountsAndItsLoanPaymentTxnByName(new Set<String> {'LAI-0000000'});
        Test.stopTest();

        System.assert(loanAccountList != null);
    }
}