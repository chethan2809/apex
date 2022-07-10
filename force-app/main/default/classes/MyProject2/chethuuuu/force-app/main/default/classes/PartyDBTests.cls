@isTest(isParallel=true)
private class PartyDBTests {

    private static PartyDB partyDBInstance = new PartyDB();

    @isTest
    private static void getPartiesByApplicationIdsAndPartyTypeId() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(applicationId);

        Id partyTypeId = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());

        Test.startTest();
            List<clcommon__Party__c> partyList = partyDBInstance.getPartiesByApplicationIdsAndPartyTypeId(applicationIds, partyTypeId);
        Test.stopTest();

        System.assert(partyList != null);
        System.assert(partyList.isEmpty());
    }

    @isTest
    private static void getPartiesByApplicationIdsAndPartyTypeIds() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(applicationId);

        Id partyTypeId = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());
        Set<Id> partyTypeIds = new Set<Id>();
        partyTypeIds.add(partyTypeId);

        Test.startTest();
            List<clcommon__Party__c> partyList = partyDBInstance.getPartiesByApplicationIdsAndPartyTypeIds(applicationIds, partyTypeIds);
        Test.stopTest();

        System.assert(partyList != null);
        System.assert(partyList.isEmpty());
    }

    @isTest
    private static void getAllPartiesByApplicationIds() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(applicationId);

        Test.startTest();
            List<clcommon__Party__c> partyList = partyDBInstance.getAllPartiesByApplicationIds(applicationIds);
        Test.stopTest();

        System.assert(partyList != null);
        System.assert(partyList.isEmpty());
    }

    @isTest
    private static void getBorrowerAndPrimanyGuarantorByApplicationIds() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(applicationId);

        Test.startTest();
            List<clcommon__Party__c> partyList = partyDBInstance.getBorrowerAndPrimanyGuarantorByApplicationIds(applicationIds);
        Test.stopTest();

        System.assert(partyList != null);
        System.assert(partyList.isEmpty());
    }

    @isTest
    private static void getRecentApplicationsListForBrokerPortalDashboard() {

        Id brokerUserId = TestUtility.getFakeId(User.getSObjectType());
        Set<Id> userIds = new Set<Id>();
        userIds.add(brokerUserId);

        Test.startTest();
            List<clcommon__Party__c> partyList = partyDBInstance.getRecentApplicationsListForBrokerPortalDashboard(userIds);
        Test.stopTest();

        System.assert(partyList != null);
        System.assert(partyList.isEmpty());
    }

    @isTest
    private static void getApplicationsListForBrokerPortalOnCategories() {
        Set<String> buckets = new Set<String>{'Outstanding', 'Submitted', 'Completed'};
        Id brokerUserId = TestUtility.getFakeId(User.getSObjectType());
        Set<Id> userIds = new Set<Id>();
        userIds.add(brokerUserId);

        Test.startTest();
            List<clcommon__Party__c> partyList = partyDBInstance.getApplicationsListForBrokerPortalOnCategories(buckets, userIds);
        Test.stopTest();

        System.assert(partyList != null);
        System.assert(partyList.isEmpty());
    }

    @isTest
    private static void getApplicationsListForBrokerPortalOnCategoriesFunded() {
        Set<String> buckets = new Set<String>{'Funded'};
        Id brokerUserId = TestUtility.getFakeId(User.getSObjectType());
        Set<Id> userIds = new Set<Id>();
        userIds.add(brokerUserId);
        Date currentSystemDate = Date.newInstance(2020, 1, 1);
        Date lastNinetyDays = currentSystemDate.addDays(-90);

        Test.startTest();
            List<clcommon__Party__c> partyList = partyDBInstance.getApplicationsListForBrokerPortalOnCategoryFunded(buckets, userIds,lastNinetyDays);
        Test.stopTest();

        System.assert(partyList != null);
        System.assert(partyList.isEmpty());
    }

    @isTest
    private static void getApplicationsListForBrokerPortalOnCategoryClosedDeclined() {
        Set<String> buckets = new Set<String>{'Closed Declined'};
        Id brokerUserId = TestUtility.getFakeId(User.getSObjectType());
        Set<Id> userIds = new Set<Id>();
        userIds.add(brokerUserId);
        Date currentSystemDate = Date.newInstance(2020, 1, 1);
        Date lastNinetyDays = currentSystemDate.addDays(-90);

        Test.startTest();
            List<clcommon__Party__c> partyList = partyDBInstance.getApplicationsListForBrokerPortalOnCategoryClosedDeclined(buckets, userIds,lastNinetyDays);
        Test.stopTest();

        System.assert(partyList != null);
        System.assert(partyList.isEmpty());
    }

    @isTest
    private static void getALLApplicationsListForBrokerPortal() {

        Id brokerUserId = TestUtility.getFakeId(User.getSObjectType());
        Set<Id> userIds = new Set<Id>();
        userIds.add(brokerUserId);

        Test.startTest();
            List<clcommon__Party__c> partyList = partyDBInstance.getALLApplicationsListForBrokerPortal(userIds);
        Test.stopTest();

        System.assert(partyList != null);
        System.assert(partyList.isEmpty());
    }

    @isTest
    private static void getALLApplicationsListForBrokerPortalAdvancedFilter() {
        GeneralHelper.currentSystemDate = System.today();
        Set<Date> fromDate = new Set<Date>{GeneralHelper.currentSystemDate.addDays(1)};
        Set<Date> toDate = new Set<Date>{GeneralHelper.currentSystemDate.addDays(5)};
        Set<Integer> minLoanAmount = new Set<Integer>{100};
        Set<Integer> maxLoanAmount = new Set<Integer>{1000};

        Id brokerUserId = TestUtility.getFakeId(User.getSObjectType());
        Set<Id> userIds = new Set<Id>();
        userIds.add(brokerUserId);

        TestUtility.runSetupData();
        genesis__Applications__c application = TestUtility.createApplication();
        Account account = TestUtility.createAccount();

        Set<String> applicationIds = new Set<String>();
        applicationIds.add(application.Name);
        Set<String> accounts = new Set<String>();
        accounts.add(account.Name);

        Test.startTest();
            List<clcommon__Party__c> partyList = partyDBInstance.getALLApplicationsListForBrokerPortalAdvancedFilter(fromDate, toDate, minLoanAmount, maxLoanAmount, applicationIds, accounts, userIds);
        Test.stopTest();

        System.assert(partyList != null);
        System.assert(partyList.isEmpty());
    }

    @isTest
    private static void getBorrowerAndGuarantorsByApplicationIds() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(applicationId);

        Test.startTest();
            List<clcommon__Party__c> partyList = partyDBInstance.getBorrowerAndGuarantorsByApplicationIds(applicationIds);
        Test.stopTest();

        System.assert(partyList != null);
        System.assert(partyList.isEmpty());
    }

    @isTest
    private static void getBorrowerGuarantorsAndContactBeneficialOwnersByApplicationIds() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(applicationId);

        Test.startTest();
            List<clcommon__Party__c> partyList = partyDBInstance.getBorrowerGuarantorsAndContactBeneficialOwnersByApplicationIds(applicationIds);
        Test.stopTest();

        System.assert(partyList != null);
        System.assert(partyList.isEmpty());
    }

    @isTest
    private static void getGuarantorsAndContactBeneficialOwnersByApplicationIds() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(applicationId);

        Test.startTest();
            List<clcommon__Party__c> partyList = partyDBInstance.getGuarantorsAndContactBeneficialOwnersByApplicationIds(applicationIds);
        Test.stopTest();

        System.assert(partyList != null);
        System.assert(partyList.isEmpty());
    }

    @isTest
    private static void getAdditionalGuarantorsAndContactBeneficialOwnersByApplicationIds() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(applicationId);

        Test.startTest();
            List<clcommon__Party__c> partyList = partyDBInstance.getAdditionalGuarantorsAndContactBeneficialOwnersByApplicationIds(applicationIds);
        Test.stopTest();

        System.assert(partyList != null);
        System.assert(partyList.isEmpty());
    }

    @isTest
    private static void getCompetitorPartiesByApplicationIds() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(applicationId);

        Test.startTest();
            List<clcommon__Party__c> partyList = partyDBInstance.getCompetitorPartiesByApplicationIds(applicationIds);
        Test.stopTest();

        System.assert(partyList != null);
        System.assert(partyList.isEmpty());
    }

    @isTest
    private static void getPartiesByApplicationAndAccountIds() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(applicationId);

        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Set<Id> accountIds = new Set<Id>();

        Test.startTest();
            List<clcommon__Party__c> partyList = partyDBInstance.getPartiesByApplicationAndAccountIds(applicationIds, accountIds);
        Test.stopTest();

        System.assert(partyList != null);
        System.assert(partyList.isEmpty());
    }

    @isTest
    private static void getGuarantorPartiesByApplicationIds() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(applicationId);

        Test.startTest();
            List<clcommon__Party__c> partyList = partyDBInstance.getGuarantorPartiesByApplicationIds(applicationIds);
        Test.stopTest();

        System.assert(partyList != null);
        System.assert(partyList.isEmpty());
    }

    @isTest
    private static void getFraudBorrowerANDGuarantorPartiesByAccountContactIds() {
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id contactId = TestUtility.getFakeId(Contact.getSObjectType());
        Set<Id> accountsAndContactIds = new Set<Id>();
        accountsAndContactIds.add(accountId);
        accountsAndContactIds.add(contactId);

        Test.startTest();
            List<clcommon__Party__c> partyList = partyDBInstance.getFraudBorrowerANDGuarantorPartiesByAccountContactIds(accountsAndContactIds);
        Test.stopTest();

        System.assert(partyList != null);
        System.assert(partyList.isEmpty());
    }

    @isTest
    private static void getGuarantorANDBrokerPartiesByApplicationIds() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(applicationId);

        Test.startTest();
            List<clcommon__Party__c> partyList = partyDBInstance.getGuarantorANDBrokerPartiesByApplicationIds(applicationIds);
        Test.stopTest();

        System.assert(partyList != null);
        System.assert(partyList.isEmpty());
    }

    @isTest
    private static void getPartiesByIds() {
        Id partyId = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());

        Test.startTest();
            List<clcommon__Party__c> partyList = partyDBInstance.getPartiesByIds(new Set<Id> {partyId});
        Test.stopTest();

        System.assert(partyList != null);
        System.assert(partyList.isEmpty());
    }
}