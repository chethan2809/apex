@isTest
private class CongasTests {
    @isTest
    private static void buildApplicationTemplateForConcurrent() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Total_Competitors_Amount__c = 1000;
        application.Type__c = GeneralConstants.LOAN_TYPE_CONCURRENT;

        Test.startTest();
            Set<String> eligibleTemplateGroups = Congas.buildApplicationTemplateGroupNames(application);
        Test.stopTest();

        String expectedValue = Congas.CONGA_LOAN_AGREEMENT_CONCURRENT_WEEKLY;
        System.assert(eligibleTemplateGroups.contains(expectedValue));
    }

    @isTest
    private static void buildApplicationTemplateForRenewal() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Total_Competitors_Amount__c = 1000;
        application.Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;

        Test.startTest();
            Set<String> eligibleTemplateGroups = Congas.buildApplicationTemplateGroupNames(application);
        Test.stopTest();

        String expectedValue = Congas.CONGA_LOAN_AGREEMENT_RENEWAL;
        System.assert(eligibleTemplateGroups.contains(expectedValue));
    }
}