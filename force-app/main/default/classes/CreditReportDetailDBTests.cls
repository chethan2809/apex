@isTest(isParallel=true)
private class CreditReportDetailDBTests{

    private static CreditReportDetailDB creditReportDetailDBInstance = new CreditReportDetailDB();

    @isTest
    private static void  getBusinessCreditReportByAccountIds(){
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(accountId);

        Test.startTest();
            List<Credit_Report_Detail__c> creditReportDetailList = creditReportDetailDBInstance.getBusinessCreditReportByAccountIds(accountIds);
        Test.stopTest();

        System.assert(creditReportDetailList != null);
        System.assert(creditReportDetailList.isEmpty());
    }

    @isTest
    private static void  getBusinessAndLexisNexisReportsByAccountIdsAndApplicationIds(){
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(accountId);

        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(applicationId);

        Test.startTest();
            List<Credit_Report_Detail__c> creditReportDetailList = creditReportDetailDBInstance.getBusinessAndLexisNexisReportsByAccountIdsAndApplicationIds(accountIds, applicationIds);
        Test.stopTest();

        System.assert(creditReportDetailList != null);
        System.assert(creditReportDetailList.isEmpty());
    }

    @isTest
    private static void  getConsumerCreditReportByContactIds(){
        Id contactId = TestUtility.getFakeId(Contact.getSObjectType());
        Set<Id> contactIds = new Set<Id>();
        contactIds.add(contactId);

        Test.startTest();
            List<Credit_Report_Detail__c> creditReportDetailList = creditReportDetailDBInstance.getConsumerCreditReportByContactIds(contactIds);
        Test.stopTest();

        System.assert(creditReportDetailList != null);
        System.assert(creditReportDetailList.isEmpty());
    }

    @isTest
    private static void  getAllReportByApplicationIdOrAccountIdOrContactId(){
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id contactId = TestUtility.getFakeId(Contact.getSObjectType());
        Set<Id> accountIdOrContactIds = new Set<Id>();
        accountIdOrContactIds.add(accountId);
        accountIdOrContactIds.add(contactId);

        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(applicationId);

        Test.startTest();
            List<Credit_Report_Detail__c> creditReportDetailList = creditReportDetailDBInstance.getAllReportByApplicationIdOrAccountIdOrContactId(accountIdOrContactIds, applicationIds);
        Test.stopTest();

        System.assert(creditReportDetailList != null);
        System.assert(creditReportDetailList.isEmpty());
    }

    @isTest
    private static void  getLexisNexisCreditReportByApplicationIds(){
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(applicationId);

        Test.startTest();
            List<Credit_Report_Detail__c> creditReportDetailList = creditReportDetailDBInstance.getLexisNexisCreditReportByApplicationIds(applicationIds);
        Test.stopTest();

        System.assert(creditReportDetailList != null);
        System.assert(creditReportDetailList.isEmpty());
    }

    @isTest
    private static void  getCanScoringReportByApplicationIds(){
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(applicationId);

        Test.startTest();
            List<Credit_Report_Detail__c> creditReportDetailList = creditReportDetailDBInstance.getCanScoringReportByApplicationIds(applicationIds);
        Test.stopTest();

        System.assert(creditReportDetailList != null);
        System.assert(creditReportDetailList.isEmpty());
    }
}