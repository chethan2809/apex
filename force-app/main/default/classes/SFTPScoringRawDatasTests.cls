@isTest
public class SFTPScoringRawDatasTests {

    @isTest
    private static void buildResponseAttachmentTests() {

        TestUtility.runSetupData();
       	Id contactId = TestUtility.getFakeId(Contact.getSObjectType());

    	DateTime currentSystemDateTime = GeneralHelper.currentSystemDateTime;

        Credit_Report_Detail__c creditReport = new Credit_Report_Detail__c();
        creditReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        creditReport.Account__c = TestUtility.getFakeId(Account.getSObjectType());
        creditReport.Contact__c = contactId;

        List<Credit_Report_Detail__c> creditReports = new List<Credit_Report_Detail__c>();
        creditReports.add(creditReport);

        Map<Id, Map<String, String>> responseMapByCreditReportDetails = new Map<Id, Map<String, String>>();
        Map<String, String> responseMap = new Map<String, String>();

        responseMap.put('consumerReport', 'consumerReportResponse');
        responseMapByCreditReportDetails.put(creditReport.Contact__c , responseMap);

        genesis__Applications__c application =  new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        SFTPScoringRawDataManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        Map<Id, Id> contactIdAccountIdToApplicationIds = new Map<Id, Id>();
        contactIdAccountIdToApplicationIds.put(contactId, application.Id);

        List<Attachment> attachmentList = new List<Attachment>();
        Attachment attachmentRecord = new Attachment();
        Id applicationId;
        String currentDate = String.ValueOf(GeneralHelper.currentSystemDateTime);
        Blob fileBlob = Blob.valueOf('consumerReport');
        attachmentRecord.Name = 'ExperianConsumerCreditReport_' + currentDate;
        applicationId = contactIdAccountIdToApplicationIds.get(creditReport.Contact__c);
        attachmentRecord.Body = fileBlob;
        attachmentRecord.parentId = creditReport.Id;
        attachmentRecord.ContentType = 'text/plain';
        attachmentList.add(attachmentRecord);

        Test.startTest();
        Id actualApplicationId = SFTPScoringRawDatas.buildResponseAttachment(creditReport, responseMapByCreditReportDetails, attachmentList, contactIdAccountIdToApplicationIds);
        Test.stopTest();

        system.assert(actualApplicationId != null);
        system.assertEquals(applicationId , actualApplicationId);
    }

    @isTest
    private static void buildResponseAccount() {

        TestUtility.runSetupData();
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());

    	DateTime currentSystemDateTime = GeneralHelper.currentSystemDateTime;

        Credit_Report_Detail__c creditReport = new Credit_Report_Detail__c();
        creditReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        creditReport.Account__c = accountId;

        List<Credit_Report_Detail__c> creditReports = new List<Credit_Report_Detail__c>();
        creditReports.add(creditReport);

        Map<Id, Map<String, String>> responseMapByCreditReportDetails = new Map<Id, Map<String, String>>();
        Map<String, String> responseMap = new Map<String, String>();

        responseMap.put('consumerReport', 'consumerReportResponse');
        responseMapByCreditReportDetails.put(creditReport.Account__c , responseMap);

        genesis__Applications__c application =  new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        SFTPScoringRawDataManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        Map<Id, Id> contactIdAccountIdToApplicationIds = new Map<Id, Id>();
        contactIdAccountIdToApplicationIds.put(accountId, application.Id);

        List<Attachment> attachmentList = new List<Attachment>();
        Attachment attachmentRecord = new Attachment();
        Id applicationId;
        Set<String> reportType = responseMap.KeySet();
        String currentDate = String.ValueOf(GeneralHelper.currentSystemDateTime);
        Blob fileBlob = Blob.valueOf('consumerReport');
        attachmentRecord.Name = reportType + '_' + currentDate;
        applicationId = contactIdAccountIdToApplicationIds.get(creditReport.Account__c);
        attachmentRecord.Body = fileBlob;
        attachmentRecord.parentId = creditReport.Id;
        attachmentRecord.ContentType = 'text/plain';
        attachmentList.add(attachmentRecord);

        Test.startTest();
        Id actualApplicationId = SFTPScoringRawDatas.buildResponseAttachment(creditReport, responseMapByCreditReportDetails, attachmentList, contactIdAccountIdToApplicationIds);
        Test.stopTest();

        system.assert(actualApplicationId != null);
        system.assertEquals(applicationId , actualApplicationId);
    }

    @isTest
    private static void buildResponseApplication() {

        TestUtility.runSetupData();

    	DateTime currentSystemDateTime = GeneralHelper.currentSystemDateTime;

		genesis__Applications__c application =  new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        Id applicationsId = application.Id;

        Credit_Report_Detail__c creditReport = new Credit_Report_Detail__c();
        creditReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        creditReport.Application__c = applicationsId;

        List<Credit_Report_Detail__c> creditReports = new List<Credit_Report_Detail__c>();
        creditReports.add(creditReport);

        Map<Id, Map<String, String>> responseMapByCreditReportDetails = new Map<Id, Map<String, String>>();
        Map<String, String> responseMap = new Map<String, String>();

        responseMap.put('lexisNexisReport', 'consumerReportResponse');
        responseMapByCreditReportDetails.put(creditReport.Application__c , responseMap);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        SFTPScoringRawDataManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        Map<Id, Id> contactIdAccountIdToApplicationIds = new Map<Id, Id>();
        contactIdAccountIdToApplicationIds.put(applicationsId, application.Id);

        List<Attachment> attachmentList = new List<Attachment>();
        Attachment attachmentRecord = new Attachment();
        Id applicationId;

        String currentDate = String.ValueOf(GeneralHelper.currentSystemDateTime);
        Blob fileBlob = Blob.valueOf('lexisNexisReport');
        attachmentRecord.Name = 'LexisNexis_' + currentDate;
        applicationId = contactIdAccountIdToApplicationIds.get(creditReport.Application__c);
        attachmentRecord.Body = fileBlob;
        attachmentRecord.parentId = creditReport.Id;
        attachmentRecord.ContentType = 'text/plain';
        attachmentList.add(attachmentRecord);

        Test.startTest();
        Id actualApplicationId =  SFTPScoringRawDatas.buildResponseAttachment(creditReport, responseMapByCreditReportDetails, attachmentList, contactIdAccountIdToApplicationIds);
        Test.stopTest();

        system.assert(actualApplicationId != null);
        system.assertEquals(applicationId , actualApplicationId);
    }
}