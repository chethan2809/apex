@isTest
public class SFTPScoringRawDataSchedulableTests {

    @isTest
    private static void sftpScoringRawDataSchedulable() {
        String cronExp = '0 0 12 1 1 ? *';
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Id contactId = TestUtility.getFakeId(Contact.getSObjectType());
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
        contactIdAccountIdToApplicationIds.put(contactId, application.Id);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        SFTPScoringRawDataManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        SFTPScoringRawDataManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Test.startTest();
            String jobId = System.schedule('SFTPScoringRawDataSchedulableTests',  cronExp, new SFTPScoringRawDataSchedulable(creditReport,responseMapByCreditReportDetails,contactIdAccountIdToApplicationIds));
            CronTrigger triggerCron = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                                        FROM CronTrigger
                                        WHERE id = :jobId];
            System.assertEquals(cronExp, triggerCron.CronExpression);
            System.assertEquals(0, triggerCron.TimesTriggered);
        Test.stopTest();

        System.assertEquals(0, applicationDBStubInstance.forUpdateSObjects.size());
        System.assertEquals(0, errorLogDBStubInstance.forInsertSObjects.size());
    }
}