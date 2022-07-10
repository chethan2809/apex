@isTest(isParallel=true)
private class OcrolusReportDBTests {

    private static OcrolusReportDB ocrolusReportDBInstance = new OcrolusReportDB();

    @isTest
    private static void getCANOcrolusReportByPK() {

        Test.startTest();
            List<CAN_Ocrolus_Report__c> loanDisbursalTransactionList = ocrolusReportDBInstance.getCANOcrolusReportByPK('1260238');
        Test.stopTest();

        System.assert(loanDisbursalTransactionList != null);
        System.assert(loanDisbursalTransactionList.isEmpty());
    }

    @isTest
    private static void getCANOcrolusReportByApplicationIDs() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(applicationId);

        Test.startTest();
            List<CAN_Ocrolus_Report__c> loanDisbursalTransactionList = ocrolusReportDBInstance.getCANOcrolusReportByApplicationIDs(applicationIds);
        Test.stopTest();

        System.assert(loanDisbursalTransactionList != null);
        System.assert(loanDisbursalTransactionList.isEmpty());
    }

    @isTest
    private static void getCANOcrolusReportByIds() {
        Id reportId = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        Set<Id> reportIds = new Set<Id>();
        reportIds.add(reportId);

        Test.startTest();
            List<CAN_Ocrolus_Report__c> loanDisbursalTransactionList = ocrolusReportDBInstance.getCANOcrolusReportByIds(reportIds);
        Test.stopTest();

        System.assert(loanDisbursalTransactionList != null);
        System.assert(loanDisbursalTransactionList.isEmpty());
    }
}