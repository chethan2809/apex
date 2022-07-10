@isTest
private class ApplicationDBTests {

    private static ApplicationDB applicationDBInstance = new ApplicationDB();

    @isTest
    private static void executeInserts() {

        TestUtility.runSetupData();
        clcommon__CL_Product__c clProduct = TestUtility.createCLProduct();
        Opportunity opportunity = TestUtility.createOpportunity();
        Account account = TestUtility.createAccount();
        Contact contact = TestUtility.createContact();

        genesis__Applications__c application = TestUtility.generateApplication(clProduct.Id, contact.Id, account.Id, opportunity.Id);

        Test.startTest();
            ApplicationDB applicationDBInstance = applicationDBInstance.executeInserts(application);
        Test.stopTest();

        System.assert(applicationDBInstance != null);
        System.assert(application.Id != null);
    }

    @isTest
    private static void getApplicationPartiesConsentById() {
        TestUtility.runSetupData();
        genesis__Applications__c application = TestUtility.createApplication();
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(application.Id);

        Test.startTest();
            List<genesis__Applications__c> applicationList = applicationDBInstance.getApplicationPartiesConsentById(applicationIds);
        Test.stopTest();

        System.assert(applicationList != null);
    }

    @isTest
    private static void getApplicationsByIds() {
        TestUtility.runSetupData();
        genesis__Applications__c application = TestUtility.createApplication();
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(application.Id);

        Test.startTest();
            List<genesis__Applications__c> applicationList = applicationDBInstance.getApplicationsByIds(applicationIds);
        Test.stopTest();

        System.assert(applicationList != null);
    }

    @isTest
    private static void getActiveApplicationsByOpportunityIds() {
        Id opportunityId = TestUtility.getFakeId(Opportunity.getSObjectType());
        Set<Id> opportunityIds = new Set<Id>();
        opportunityIds.add(opportunityId);

        Test.startTest();
            List<genesis__Applications__c> applicationList = applicationDBInstance.getActiveApplicationsByOpportunityIds(opportunityIds);
        Test.stopTest();

        System.assert(applicationList != null);
        System.assert(applicationList.isEmpty());
    }

    @isTest
    private static void getApplicationListByBorrowerAccId() {
        Account brokerAccount = TestUtility.createAccount();
        Set<Id> brokerAccountIds = new Set<Id>();
        brokerAccountIds.add(brokerAccount.Id);

        Test.startTest();
            List<genesis__Applications__c> applicationList = applicationDBInstance.getApplicationListByBorrowerAccId(brokerAccountIds);
        Test.stopTest();

        System.assert(applicationList != null);
        System.assert(applicationList.isEmpty());
    }

    @isTest
    private static void getInProgressApplicationsByAccountIds() {
        Account account = TestUtility.createAccount();
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(account.Id);

        Test.startTest();
            List<genesis__Applications__c> applicationList = applicationDBInstance.getInProgressApplicationsByAccountIds(accountIds);
        Test.stopTest();

        System.assert(applicationList != null);
        System.assert(applicationList.isEmpty());
    }

    @isTest
    private static void getApplicationsWithPricingAndSTIPListByIds() {
        TestUtility.runSetupData();
        genesis__Applications__c application = TestUtility.createApplication();
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(application.Id);

        Test.startTest();
            List<genesis__Applications__c> applicationList = applicationDBInstance.getApplicationsWithPricingAndSTIPListByIds(applicationIds);
        Test.stopTest();

        System.assert(applicationList != null);
    }

    @isTest
    private static void getApplicationsByOpportunityIds() {
        Id opportunityId = TestUtility.getFakeId(Opportunity.getSObjectType());
        Set<Id> opportunityIds = new Set<Id>();
        opportunityIds.add(opportunityId);

        Test.startTest();
            List<genesis__Applications__c> applicationList = applicationDBInstance.getApplicationsByOpportunityIds(opportunityIds);
        Test.stopTest();

        System.assert(applicationList != null);
        System.assert(applicationList.isEmpty());
    }

    @isTest
    private static void getClosedAndApprovedApplicationsByAccountIds() {
        Account account = TestUtility.createAccount();
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(account.Id);

        Test.startTest();
            List<genesis__Applications__c> applicationList = applicationDBInstance.getClosedAndApprovedApplicationsByAccountIds(accountIds);
        Test.stopTest();

        System.assert(applicationList != null);
        System.assert(applicationList.isEmpty());
    }

    @isTest
    private static void getPartnerApplicationByNameTest() {
        Account account = TestUtility.createAccount();
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(account.Id);

        Test.startTest();
        List<genesis__Applications__c> applicationNamesList = applicationDBInstance.getPartnerApplicationByName(new Set<String> {'APP-000000XXXX'});
        Test.stopTest();

        System.assert(applicationNamesList != null);
        System.assert(applicationNamesList.isEmpty());
    }

    @isTest
    private static void getApplicationsByIdsAndBrokerIdsTest() {

        TestUtility.runSetupData();
        Account account = TestUtility.createAccount();
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(account.Id);

        genesis__Applications__c application = TestUtility.createApplication();
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(application.Id);

        Test.startTest();
        List<genesis__Applications__c> applicationList = applicationDBInstance.getApplicationsByIdsAndBrokerIds(applicationIds, accountIds);
        Test.stopTest();

        System.assert(applicationList != null);
        System.assert(applicationList.isEmpty());
    }

    @isTest
    private static void getApplicationsByBorrowerAccountIdsTest() {
        Account account = TestUtility.createAccount();
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(account.Id);

        Test.startTest();
        List<genesis__Applications__c> applicationList = applicationDBInstance.getApplicationsByBorrowerAccountIds(accountIds);
        Test.stopTest();

        System.assert(applicationList != null);
        System.assert(applicationList.isEmpty());
    }

    @isTest
    private static void getDeclineApplicationByDeclineUntilAndBorrowerIdsTest() {
        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);
        Account account = TestUtility.createAccount();
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(account.Id);

        Test.startTest();
        List<genesis__Applications__c> applicationList = applicationDBInstance.getDeclineApplicationByDeclineUntilAndBorrowerIds(accountIds);
        Test.stopTest();

        System.assert(applicationList != null);
        System.assert(applicationList.isEmpty());
    }
}