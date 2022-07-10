@isTest
public class SFTPScoringRawDataQueueableJobTest {

    @isTest
    private static void SFTPScoringRawDataQueueable() {
        String cronExp = '0 0 12 1 1 ? *';
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Id ContactId = TestUtility.getFakeId(Contact.getSObjectType());
        Credit_Report_Detail__c report = new Credit_Report_Detail__c();
        report.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        report.Account__c = TestUtility.getFakeId(Account.getSObjectType());

        List<Credit_Report_Detail__c> creditReport = new List<Credit_Report_Detail__c>();
        creditReport.add(report);
        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();

        Map<Id, Map<String, String>> responseMapByCreditReportDetails = new Map<Id, Map<String, String>>();
        Map<String, String> responseMap = new Map<String, String>();
        responseMap.put('consumerReport', 'consumerReportResponse');
        responseMapByCreditReportDetails.put(report.Account__c , responseMap);

        genesis__Applications__c application =  new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        applicationList.add(application);
        Map<Id, Id> contactIdAccountIdToApplicationIds = new Map<Id, Id>();
        contactIdAccountIdToApplicationIds.put(ContactId, application.Id);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        SFTPScoringRawDataManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        SFTPScoringRawDataManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        SFTPScoringRawDataQueueableJob sftp = new SFTPScoringRawDataQueueableJob(creditReport,responseMapByCreditReportDetails,contactIdAccountIdToApplicationIds);
        Test.startTest();
        System.enqueueJob(sftp);
        Test.stopTest();
    }
}