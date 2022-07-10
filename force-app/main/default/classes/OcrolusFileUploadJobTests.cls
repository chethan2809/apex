@isTest
private class OcrolusFileUploadJobTests {

    @isTest
    private static void ocrolusFileUploadJobTest(){
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Id documentCategoryId = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());

        clcommon__Document_Definition__c documentDefinition = new clcommon__Document_Definition__c();
        documentDefinition.Name = 'CL Collections';
        documentDefinition.clcommon__Show_In_Portal__c = 'DELIVERED';
        documentDefinition.clcommon__Active__c = true;
        insert documentDefinition;

        clcommon__Document_Category__c documentCategory = new clcommon__Document_Category__c();
        documentCategory.clcommon__Category_Name__c = documentDefinition.Name;
        documentCategory.clcommon__Show_In_Portal__c = documentDefinition.clcommon__Show_In_Portal__c;
        documentCategory.clcommon__Document_Definition__c = documentDefinition.Id;
        insert documentCategory;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c ();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Application__c = applicationId;
        ocrolusReport.Analytics_PK__c = '12872807';
        ocrolusReport.UUID__c = 'c0d78d78-7536-4f95-8241-e8cdc1cde360';
        ocrolusReport.Book_Name__c = '00D17000000L7TQEA0-APP-0000000102';

        clcommon__Category_Attachment_Association__c categoryAttachment = new clcommon__Category_Attachment_Association__c();
        categoryAttachment.Name = 'Bank Statements';
        categoryAttachment.Wasabi_Link__c = 'https://upload.test.com/happiest-minds-test/APP-0000000102/Bank_Statements/428551jul.pdf';
        categoryAttachment.clcommon__Document_Category__c = documentCategory.Id;
        insert categoryAttachment;

        DBManagerTestsStub ocrolusReportDBInstance = new DBManagerTestsStub();
        ocrolusReportDBInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c> { ocrolusReport };
        OcrolusFileUploadJob.ocrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBInstance);

        CANOcrolusCallOut.token = 'idToken';
        Map<Id,Id> categoryAttachmentIdToApplicationId = new Map<Id,Id>();
        categoryAttachmentIdToApplicationId.put(categoryAttachment.Id, applicationId);

        clcommon__Category_Attachment_Association__c categoryAttachmentObj = [
            SELECT Id, Name, Wasabi_Link__c
                FROM clcommon__Category_Attachment_Association__c
        ];

        Test.setMock(HttpCalloutMock.class, new WasabiHTTPCallOutMocks.WasabiGetDocumentSuccessResponse());
        Test.setMock(HttpCalloutMock.class, new CANOcrolusCalloutMock.CANOcrolusCallOutMockUploadFileSuccessResponse());
        Test.startTest();

            OcrolusFileUploadJob ocrolusFileUpload = new OcrolusFileUploadJob(categoryAttachmentIdToApplicationId);
            DataBase.executeBatch(ocrolusFileUpload);

        Test.stopTest();

        List<clcommon__Category_Attachment_Association__c> actualCategoryAttachmentList = [
            SELECT Id, Name, Wasabi_Link__c
                FROM clcommon__Category_Attachment_Association__c
                WHERE Id = :categoryAttachment.Id
        ];

        System.assertEquals(1, actualCategoryAttachmentList.size());
    }

    @isTest
    private static void ocrolusFileUploadJobExceptionTest(){
        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        collect__Loan_Account__c collContract = new collect__Loan_Account__c();
        collContract.collect__External_ID__c = testExternalId;
        insert collContract;

        clcommon__Document_Definition__c documentDefinition = new clcommon__Document_Definition__c();
        documentDefinition.Name = 'CL Collections';
        documentDefinition.clcommon__Show_In_Portal__c = 'DELIVERED';
        documentDefinition.clcommon__Active__c = true;
        insert documentDefinition;

        DBManagerTestsStub documentDefinitionDBStubInstance = new DBManagerTestsStub();
        documentDefinitionDBStubInstance.genericReturnObject = new List<clcommon__Document_Definition__c> {documentDefinition};
        OriginationHelper.documentDefinitionDBInstance = (DocumentDefinitionDB) Test.createStub(DocumentDefinitionDB.class, documentDefinitionDBStubInstance);

        clcommon__Document_Category__c documentCategory = new clcommon__Document_Category__c();
        documentCategory.clcommon__Category_Name__c = documentDefinition.Name;
        documentCategory.clcommon__Show_In_Portal__c = documentDefinition.clcommon__Show_In_Portal__c;
        documentCategory.clcommon__Document_Definition__c = documentDefinition.Id;
        documentCategory.collect_Loan_Account__c = collContract.Id;
        insert documentCategory;

        List<clcommon__Category_Attachment_Association__c> categoryAttachmentList = New List<clcommon__Category_Attachment_Association__c>();
        clcommon__Category_Attachment_Association__c  categoryAttachment = New clcommon__Category_Attachment_Association__c();
        categoryAttachment.Name = 'Bank Statements';
        categoryAttachment.Wasabi_Link__c = null;
        categoryAttachment.clcommon__Document_Category__c = documentCategory.Id;
        insert categoryAttachment;
        categoryAttachmentList.add(categoryAttachment);

        TestUtility.runSetupData();
        genesis__Applications__c application = TestUtility.createApplication();
        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c ();
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Analytics_PK__c = '12872807';
        ocrolusReport.UUID__c = 'c0d78d78-7536-4f95-8241-e8cdc1cde360';
        ocrolusReport.Book_Name__c = '00D17000000L7TQEA0-APP-0000000102';
        insert ocrolusReport;

        Map<Id,Id> categoryAttachmentIdToApplicationId = new Map<Id,Id>();
        categoryAttachmentIdToApplicationId.put(categoryAttachmentList[0].Id,application.Id);

        Exception ex;
        Test.startTest();

                OcrolusFileUploadJob ocrolusFileUpload = new OcrolusFileUploadJob(categoryAttachmentIdToApplicationId);
                DataBase.executeBatch(ocrolusFileUpload);

        Test.stopTest();

        List<clcommon__Category_Attachment_Association__c> actualCategoryAttachmentList = [
            SELECT Id, Name, Wasabi_Link__c
                FROM clcommon__Category_Attachment_Association__c
                WHERE Id = :categoryAttachment.Id
        ];

        System.assertEquals(1, actualCategoryAttachmentList.size());
    }
}