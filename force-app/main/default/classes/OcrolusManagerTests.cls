@isTest
private class OcrolusManagerTests {

    @isTest
    private static void manualRequestOcrolusFileUpload() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountRecord.Name = 'DELTA FRESH, L.L.C';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'John';
        contactRecord.LastName = 'Boos';

        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        opportunityRecord.Name = 'Test Opportunity';
        opportunityRecord.AccountId = accountRecord.Id;
        opportunityRecord.Primary_Contact__c = contactRecord.Id;
        opportunityRecord.StageName = 'App Submitted';
        opportunityRecord.Sub_Status__c = 'Score Pending';
        opportunityRecord.CloseDate = System.today().addMonths(2).addDays(19);

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = accountRecord.Id;
        application.Opportunity__c = opportunityRecord.Id;
        application.Primary_Guarantor__c = contactRecord.Id;
        application.Industry_Rating__c = 'B';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 1413777;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 1;
        application.genesis__Payment_Frequency__c = 'DAILY';
        application.Auto_Renewed__c = true;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Max_Daily_Payment__c = 851.2645;

        clcommon__Document_Definition__c documentDefinition = new clcommon__Document_Definition__c();
        documentDefinition.Id = TestUtility.getFakeId(clcommon__Document_Definition__c.getSObjectType());
        documentDefinition.Name = 'Bank Statements';
        documentDefinition.clcommon__Show_In_Portal__c = 'DELIVERED';
        documentDefinition.clcommon__Active__c = true;

        clcommon__Category_Attachment_Association__c categoryAttachment = new clcommon__Category_Attachment_Association__c();
        categoryAttachment.Id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());
        categoryAttachment.Name = 'Bank Statements';
        categoryAttachment.Wasabi_Link__c = 'happiest-minds-test/APP-0000000102/Bank_Statements/428551jul.pdf';
        categoryAttachment.Ocrolus_Document_Status__c = 'VERIFICATION_COMPLETE';
        categoryAttachment.Ocrolus_Uploaded_PK__c = '12872807';

        List<clcommon__Category_Attachment_Association__c> categoryAttachmentList = new List<clcommon__Category_Attachment_Association__c> {categoryAttachment};
        String jsonCategoryAttachmentList = '{"totalSize" : 1, "done" : true, "records" : ' + JSON.serialize(categoryAttachmentList, false) + '}';

        clcommon__Document_Category__c documentCategory = (clcommon__Document_Category__c) JSON.deserialize(
            '{"clcommon__DocCat_Attachment_Associations__r" : ' + jsonCategoryAttachmentList + '}', clcommon__Document_Category__c.class);
        documentCategory.Id = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());
        documentCategory.clcommon__Category_Name__c = documentDefinition.Name;
        documentCategory.clcommon__Show_In_Portal__c = documentDefinition.clcommon__Show_In_Portal__c;
        documentCategory.clcommon__Document_Definition__c = documentDefinition.Id;
        documentCategory.genesis__Application__c = application.Id;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        OcrolusManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub documentCategoryDBInstance = new DBManagerTestsStub();
        documentCategoryDBInstance.genericReturnObject = new List<clcommon__Document_Category__c> {documentCategory};
        OcrolusManager.documentCategoryDBInstance = (DocumentCategoryDB) Test.createStub(DocumentCategoryDB.class, documentCategoryDBInstance);

        DBManagerTestsStub documentDefinitionDBStubInstance = new DBManagerTestsStub();
        OriginationHelper.documentDefinitionDBInstance = (DocumentDefinitionDB) Test.createStub(DocumentDefinitionDB.class, documentDefinitionDBStubInstance);

        DBManagerTestsStub categoryAttachmentAssnDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, categoryAttachmentAssnDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.ocrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        Test.setMock(HttpCalloutMock.class, new OcrolusCalloutMock.OcrolusCallOutMockCreateBookByNameSuccessResponse());
        Test.startTest();

            OcrolusManager.manualRequestOcrolusFileUpload(new Set<Id>{application.Id});

        Test.stopTest();

        System.assertEquals(1, applicationDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void manualRequestOcrolusFileUploadException() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountRecord.Name = 'DELTA FRESH, L.L.C';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'John';
        contactRecord.LastName = 'Boos';

        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        opportunityRecord.Name = 'Test Opportunity';
        opportunityRecord.AccountId = accountRecord.Id;
        opportunityRecord.Primary_Contact__c = contactRecord.Id;
        opportunityRecord.StageName = 'App Submitted';
        opportunityRecord.Sub_Status__c = 'Score Pending';
        opportunityRecord.CloseDate = System.today().addMonths(2).addDays(19);

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = accountRecord.Id;
        application.Opportunity__c = opportunityRecord.Id;
        application.Primary_Guarantor__c = contactRecord.Id;
        application.Industry_Rating__c = 'B';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 1413777;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 1;
        application.genesis__Payment_Frequency__c = 'DAILY';
        application.Auto_Renewed__c = true;

        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        clcommon__Document_Definition__c documentDefinition = new clcommon__Document_Definition__c();
        documentDefinition.Id = TestUtility.getFakeId(clcommon__Document_Definition__c.getSObjectType());
        documentDefinition.Name = 'Bank Statements';
        documentDefinition.clcommon__Show_In_Portal__c = 'DELIVERED';
        documentDefinition.clcommon__Active__c = true;

        clcommon__Category_Attachment_Association__c categoryAttachment = new clcommon__Category_Attachment_Association__c();
        categoryAttachment.Id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());
        categoryAttachment.Name = 'Bank Statements';
        categoryAttachment.Wasabi_Link__c = 'happiest-minds-test/APP-0000000102/Bank_Statements/428551jul.pdf';
        categoryAttachment.Ocrolus_Document_Status__c = 'VERIFICATION_COMPLETE';
        categoryAttachment.Ocrolus_Uploaded_PK__c = '12872807';

        List<clcommon__Category_Attachment_Association__c> categoryAttachmentList = new List<clcommon__Category_Attachment_Association__c> {categoryAttachment};
        String jsonCategoryAttachmentList = '{"totalSize" : 1, "done" : true, "records" : ' + JSON.serialize(categoryAttachmentList, false) + '}';

        clcommon__Document_Category__c documentCategory = (clcommon__Document_Category__c) JSON.deserialize(
            '{"clcommon__DocCat_Attachment_Associations__r" : ' + jsonCategoryAttachmentList + '}', clcommon__Document_Category__c.class);
        documentCategory.Id = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());
        documentCategory.clcommon__Category_Name__c = documentDefinition.Name;
        documentCategory.clcommon__Show_In_Portal__c = documentDefinition.clcommon__Show_In_Portal__c;
        documentCategory.clcommon__Document_Definition__c = documentDefinition.Id;
        documentCategory.genesis__Application__c = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Max_Daily_Payment__c = 851.2645;
        ocrolusReport.Document_Status__c = Ocrolus.OCROLUS_DOC_STATUS_COMPLETE;
        ocrolusReport.Analytics_PK__c = '1234111';

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        OcrolusManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub documentCategoryDBInstance = new DBManagerTestsStub();
        documentCategoryDBInstance.genericReturnObject = new List<clcommon__Document_Category__c> {documentCategory};
        OcrolusManager.documentCategoryDBInstance = (DocumentCategoryDB) Test.createStub(DocumentCategoryDB.class, documentCategoryDBInstance);

        DBManagerTestsStub documentDefinitionDBStubInstance = new DBManagerTestsStub();
        OriginationHelper.documentDefinitionDBInstance = (DocumentDefinitionDB) Test.createStub(DocumentDefinitionDB.class, documentDefinitionDBStubInstance);

        DBManagerTestsStub categoryAttachmentAssnDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, categoryAttachmentAssnDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        ocrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c> {ocrolusReport};
        OcrolusManager.ocrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        Exception ex;
        Test.setMock(HttpCalloutMock.class, new OcrolusCalloutMock.OcrolusCallOutMockCreateBookByNameSuccessResponse());
        Test.startTest();
            try {
                OcrolusManager.manualRequestOcrolusFileUpload(new Set<Id>{application.Id});
            } catch(Exception e) {
                ex = e;
            }

        Test.stopTest();

        System.assertEquals('There was no Bank Statement uploaded to Wasabi for this application', ex.getMessage());
    }

    @isTest
    private static void manualRequestOcrolusFileUploadCalloutException() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountRecord.Name = 'DELTA FRESH, L.L.C';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'John';
        contactRecord.LastName = 'Boos';

        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        opportunityRecord.Name = 'Test Opportunity';
        opportunityRecord.AccountId = accountRecord.Id;
        opportunityRecord.Primary_Contact__c = contactRecord.Id;
        opportunityRecord.StageName = 'App Submitted';
        opportunityRecord.Sub_Status__c = 'Score Pending';
        opportunityRecord.CloseDate = System.today().addMonths(2).addDays(19);

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = accountRecord.Id;
        application.Opportunity__c = opportunityRecord.Id;
        application.Primary_Guarantor__c = contactRecord.Id;
        application.Industry_Rating__c = 'B';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 1413777;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 1;
        application.genesis__Payment_Frequency__c = 'DAILY';
        application.Auto_Renewed__c = true;

        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        clcommon__Document_Definition__c documentDefinition = new clcommon__Document_Definition__c();
        documentDefinition.Id = TestUtility.getFakeId(clcommon__Document_Definition__c.getSObjectType());
        documentDefinition.Name = 'Bank Statements';
        documentDefinition.clcommon__Show_In_Portal__c = 'DELIVERED';
        documentDefinition.clcommon__Active__c = true;

        clcommon__Category_Attachment_Association__c categoryAttachment = new clcommon__Category_Attachment_Association__c();
        categoryAttachment.Id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());
        categoryAttachment.Name = 'Bank Statements';
        categoryAttachment.Wasabi_Link__c = 'happiest-minds-test/APP-0000000102/Bank_Statements/428551jul.pdf';
        categoryAttachment.Ocrolus_Document_Status__c = 'VERIFICATION_COMPLETE';
        categoryAttachment.Ocrolus_Uploaded_PK__c = '12872807';

        List<clcommon__Category_Attachment_Association__c> categoryAttachmentList = new List<clcommon__Category_Attachment_Association__c> {categoryAttachment};
        String jsonCategoryAttachmentList = '{"totalSize" : 1, "done" : true, "records" : ' + JSON.serialize(categoryAttachmentList, false) + '}';

        clcommon__Document_Category__c documentCategory = (clcommon__Document_Category__c) JSON.deserialize(
            '{"clcommon__DocCat_Attachment_Associations__r" : ' + jsonCategoryAttachmentList + '}', clcommon__Document_Category__c.class);
        documentCategory.Id = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());
        documentCategory.clcommon__Category_Name__c = documentDefinition.Name;
        documentCategory.clcommon__Show_In_Portal__c = documentDefinition.clcommon__Show_In_Portal__c;
        documentCategory.clcommon__Document_Definition__c = documentDefinition.Id;
        documentCategory.genesis__Application__c = application.Id;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Max_Daily_Payment__c = 851.2645;
        ocrolusReport.Document_Status__c = Ocrolus.OCROLUS_DOC_STATUS_COMPLETE;
        ocrolusReport.Analytics_PK__c = '1234111';

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        OcrolusManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub documentCategoryDBInstance = new DBManagerTestsStub();
        documentCategoryDBInstance.genericReturnObject = new List<clcommon__Document_Category__c> {documentCategory};
        OcrolusManager.documentCategoryDBInstance = (DocumentCategoryDB) Test.createStub(DocumentCategoryDB.class, documentCategoryDBInstance);

        DBManagerTestsStub documentDefinitionDBStubInstance = new DBManagerTestsStub();
        OriginationHelper.documentDefinitionDBInstance = (DocumentDefinitionDB) Test.createStub(DocumentDefinitionDB.class, documentDefinitionDBStubInstance);

        DBManagerTestsStub categoryAttachmentAssnDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, categoryAttachmentAssnDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.ocrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        Test.startTest();

            OcrolusManager.manualRequestOcrolusFileUpload(new Set<Id>{application.Id});

        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void manualRequestOcrolusFileUploadForManualRenewal() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountRecord.Name = 'DELTA FRESH, L.L.C';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'John';
        contactRecord.LastName = 'Boos';

        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        opportunityRecord.Name = 'Test Opportunity';
        opportunityRecord.AccountId = accountRecord.Id;
        opportunityRecord.Primary_Contact__c = contactRecord.Id;
        opportunityRecord.StageName = 'App Submitted';
        opportunityRecord.Sub_Status__c = 'Score Pending';
        opportunityRecord.CloseDate = System.today().addMonths(2).addDays(19);

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = accountRecord.Id;
        application.Opportunity__c = opportunityRecord.Id;
        application.Primary_Guarantor__c = contactRecord.Id;
        application.Industry_Rating__c = 'B';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 1413777;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 1;
        application.genesis__Payment_Frequency__c = 'DAILY';
        application.Auto_Renewed__c = true;
        application.Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;

        clcommon__Document_Definition__c documentDefinition = new clcommon__Document_Definition__c();
        documentDefinition.Id = TestUtility.getFakeId(clcommon__Document_Definition__c.getSObjectType());
        documentDefinition.Name = 'Bank Statements';
        documentDefinition.clcommon__Show_In_Portal__c = 'DELIVERED';
        documentDefinition.clcommon__Active__c = true;

        clcommon__Category_Attachment_Association__c categoryAttachment = new clcommon__Category_Attachment_Association__c();
        categoryAttachment.Id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());
        categoryAttachment.Name = 'Bank Statements';
        categoryAttachment.Wasabi_Link__c = 'happiest-minds-test/APP-0000000102/Bank_Statements/428551jul.pdf';
        categoryAttachment.Ocrolus_Document_Status__c = 'VERIFICATION_COMPLETE';
        categoryAttachment.Ocrolus_Uploaded_PK__c = '12872807';

        List<clcommon__Category_Attachment_Association__c> categoryAttachmentList = new List<clcommon__Category_Attachment_Association__c> {categoryAttachment};
        String jsonCategoryAttachmentList = '{"totalSize" : 1, "done" : true, "records" : ' + JSON.serialize(categoryAttachmentList, false) + '}';

        clcommon__Document_Category__c documentCategory = (clcommon__Document_Category__c) JSON.deserialize(
            '{"clcommon__DocCat_Attachment_Associations__r" : ' + jsonCategoryAttachmentList + '}', clcommon__Document_Category__c.class);
        documentCategory.Id = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());
        documentCategory.clcommon__Category_Name__c = documentDefinition.Name;
        documentCategory.clcommon__Show_In_Portal__c = documentDefinition.clcommon__Show_In_Portal__c;
        documentCategory.clcommon__Document_Definition__c = documentDefinition.Id;
        documentCategory.genesis__Application__c = application.Id;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Max_Daily_Payment__c = 851.2645;
        ocrolusReport.Document_Status__c = Ocrolus.OCROLUS_DOC_STATUS_COMPLETE;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        OcrolusManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub documentCategoryDBInstance = new DBManagerTestsStub();
        documentCategoryDBInstance.genericReturnObject = new List<clcommon__Document_Category__c> {documentCategory};
        OcrolusManager.documentCategoryDBInstance = (DocumentCategoryDB) Test.createStub(DocumentCategoryDB.class, documentCategoryDBInstance);

        DBManagerTestsStub documentDefinitionDBStubInstance = new DBManagerTestsStub();
        OriginationHelper.documentDefinitionDBInstance = (DocumentDefinitionDB) Test.createStub(DocumentDefinitionDB.class, documentDefinitionDBStubInstance);

        DBManagerTestsStub categoryAttachmentAssnDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, categoryAttachmentAssnDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        ocrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c> {ocrolusReport};
        OcrolusManager.ocrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);
        Ocrolus.isManualRun = false;

        Test.setMock(HttpCalloutMock.class, new OcrolusCalloutMock.OcrolusCallOutMockCreateBookByNameSuccessResponse());
        Test.startTest();

            OcrolusManager.requestOcrolusFileUpload(new List<genesis__Applications__c>{application});

        Test.stopTest();

        System.assertEquals(1, applicationDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void processOcrolusAnalytics() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountRecord.Name = 'DELTA FRESH, L.L.C';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'John';
        contactRecord.LastName = 'Boos';

        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        opportunityRecord.Name = 'Test Opportunity';
        opportunityRecord.AccountId = accountRecord.Id;
        opportunityRecord.Primary_Contact__c = contactRecord.Id;
        opportunityRecord.StageName = 'App Submitted';
        opportunityRecord.Sub_Status__c = 'Score Pending';
        opportunityRecord.CloseDate = System.today().addMonths(2).addDays(19);

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = accountRecord.Id;
        application.Opportunity__c = opportunityRecord.Id;
        application.Primary_Guarantor__c = contactRecord.Id;
        application.Industry_Rating__c = 'B';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 1413777;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 1;
        application.genesis__Payment_Frequency__c = 'DAILY';
        application.Auto_Renewed__c = true;
        application.genesis__Status__c = Applications.STATUS_BANK_STATEMENT_PROCESSING;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Analytics_PK__c = '12872807';
        ocrolusReport.Max_Daily_Payment__c = 851.2645;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        OcrolusManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        ocrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c> {ocrolusReport};
        OcrolusManager.ocrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Map<String, Object> ocrolusAnalyticsMap = new Map<String, Object>();
        Map<String, Object> ocrolusIndicatorsForBusinessType = new Map<String, Object>();
        Map<String, Object> ocrolusIndicators = new Map<String, Object>();
        ocrolusIndicatorsForBusinessType.put('OfferGAV', 808708.2436);
        ocrolusIndicatorsForBusinessType.put('MaxDailyPayment', 851.2645);
        ocrolusIndicatorsForBusinessType.put('Volatility', null);
        ocrolusIndicatorsForBusinessType.put('NumberOfDeposits', 10);
        ocrolusIndicatorsForBusinessType.put('NumberOfBankStatements', 11);
        ocrolusIndicatorsForBusinessType.put('PrimaryBankAccountNumber', null);
        ocrolusIndicatorsForBusinessType.put('PrimaryBankAccountName', '128642520 CENTRIS FEDERAL CREDIT UNION CHECKING');

        ocrolusIndicators.put('non_sole', ocrolusIndicatorsForBusinessType);
        ocrolusIndicators.put('sole', ocrolusIndicatorsForBusinessType);
        ocrolusIndicators.put('NumberOfCompetitors', 1);
        ocrolusIndicators.put('DebtConsolidator', false);
        ocrolusIndicators.put('SuspiciousActivity', false);
        ocrolusIndicators.put('PotentialFraud', false);
        ocrolusIndicators.put('EndingBalanceMismatch', false);
        ocrolusIndicators.put('BeginEndingBalanceMismatch', true);
        List<String> competitorList = new List<String>();
        competitorList.add('Vader Servicing');

        ocrolusAnalyticsMap.put('pk', 12872807);
        ocrolusAnalyticsMap.put('Indicators', ocrolusIndicators);
        ocrolusAnalyticsMap.put('competitors', competitorList);

        Test.startTest();

            OcrolusManager.processOcrolusAnalytics(ocrolusAnalyticsMap);

        Test.stopTest();

        System.assertEquals(1, ocrolusReportDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void getBookDocumentStatus() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountRecord.Name = 'DELTA FRESH, L.L.C';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'John';
        contactRecord.LastName = 'Boos';

        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        opportunityRecord.Name = 'Test Opportunity';
        opportunityRecord.AccountId = accountRecord.Id;
        opportunityRecord.Primary_Contact__c = contactRecord.Id;
        opportunityRecord.StageName = 'App Submitted';
        opportunityRecord.Sub_Status__c = 'Score Pending';
        opportunityRecord.CloseDate = System.today().addMonths(2).addDays(19);

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = accountRecord.Id;
        application.Opportunity__c = opportunityRecord.Id;
        application.Primary_Guarantor__c = contactRecord.Id;
        application.Industry_Rating__c = 'B';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 1413777;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 1;
        application.genesis__Payment_Frequency__c = 'DAILY';
        application.Auto_Renewed__c = true;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Analytics_PK__c = '12872807';
        ocrolusReport.Max_Daily_Payment__c = 851.2645;

       clcommon__Document_Definition__c documentDefinition = new clcommon__Document_Definition__c();
        documentDefinition.Id = TestUtility.getFakeId(clcommon__Document_Definition__c.getSObjectType());
        documentDefinition.Name = 'Bank Statements';
        documentDefinition.clcommon__Show_In_Portal__c = 'DELIVERED';
        documentDefinition.clcommon__Active__c = true;

        clcommon__Category_Attachment_Association__c categoryAttachment = new clcommon__Category_Attachment_Association__c();
        categoryAttachment.Id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());
        categoryAttachment.Name = 'Bank Statements';
        categoryAttachment.Wasabi_Link__c = 'happiest-minds-test/APP-0000000102/Bank_Statements/428551jul.pdf';
        categoryAttachment.Ocrolus_Document_Status__c = 'VERIFYING';
        categoryAttachment.Ocrolus_Uploaded_PK__c = '26509187';

        List<clcommon__Category_Attachment_Association__c> categoryAttachmentList = new List<clcommon__Category_Attachment_Association__c> {categoryAttachment};
        String jsonCategoryAttachmentList = '{"totalSize" : 1, "done" : true, "records" : ' + JSON.serialize(categoryAttachmentList, false) + '}';

        clcommon__Document_Category__c documentCategory = (clcommon__Document_Category__c) JSON.deserialize(
            '{"clcommon__DocCat_Attachment_Associations__r" : ' + jsonCategoryAttachmentList + '}', clcommon__Document_Category__c.class);
        documentCategory.Id = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());
        documentCategory.clcommon__Category_Name__c = documentDefinition.Name;
        documentCategory.clcommon__Show_In_Portal__c = documentDefinition.clcommon__Show_In_Portal__c;
        documentCategory.clcommon__Document_Definition__c = documentDefinition.Id;
        documentCategory.genesis__Application__c = application.Id;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        OcrolusManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        ocrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c> {ocrolusReport};
        OcrolusManager.ocrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        DBManagerTestsStub documentCategoryDBInstance = new DBManagerTestsStub();
        documentCategoryDBInstance.genericReturnObject = new List<clcommon__Document_Category__c> {documentCategory};
        OcrolusManager.documentCategoryDBInstance = (DocumentCategoryDB) Test.createStub(DocumentCategoryDB.class, documentCategoryDBInstance);

        DBManagerTestsStub categoryAttachmentAssnDBStubInstance = new DBManagerTestsStub();
        categoryAttachmentAssnDBStubInstance.genericReturnObject = new List<clcommon__Category_Attachment_Association__c> {categoryAttachment};
        OcrolusManager.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, categoryAttachmentAssnDBStubInstance);

        Test.setMock(HttpCalloutMock.class, new OcrolusCalloutMock.OcrolusCallOutMockGetBookStatusSuccessResponse());
        Test.startTest();

            callGetBookDocumentStatus(new Set<Id> {application.Id});

        Test.stopTest();

        System.assertEquals(1, categoryAttachmentAssnDBStubInstance.forUpdateSObjects.size());
    }

    @future (callout=true)
    private static void callGetBookDocumentStatus(Set<Id> applicationIds) {
        OcrolusManager.getBookDocumentStatus(applicationIds);
    }

    @isTest
    private static void getBookDocumentStatusException() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountRecord.Name = 'DELTA FRESH, L.L.C';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'John';
        contactRecord.LastName = 'Boos';

        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        opportunityRecord.Name = 'Test Opportunity';
        opportunityRecord.AccountId = accountRecord.Id;
        opportunityRecord.Primary_Contact__c = contactRecord.Id;
        opportunityRecord.StageName = 'App Submitted';
        opportunityRecord.Sub_Status__c = 'Score Pending';
        opportunityRecord.CloseDate = System.today().addMonths(2).addDays(19);

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = accountRecord.Id;
        application.Opportunity__c = opportunityRecord.Id;
        application.Primary_Guarantor__c = contactRecord.Id;
        application.Industry_Rating__c = 'B';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 1413777;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 1;
        application.genesis__Payment_Frequency__c = 'DAILY';
        application.Auto_Renewed__c = true;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Analytics_PK__c = '12872807';
        ocrolusReport.Max_Daily_Payment__c = 851.2645;

        clcommon__Document_Definition__c documentDefinition = new clcommon__Document_Definition__c();
        documentDefinition.Id = TestUtility.getFakeId(clcommon__Document_Definition__c.getSObjectType());
        documentDefinition.Name = 'Bank Statements';
        documentDefinition.clcommon__Show_In_Portal__c = 'DELIVERED';
        documentDefinition.clcommon__Active__c = true;

        clcommon__Category_Attachment_Association__c categoryAttachment = new clcommon__Category_Attachment_Association__c();
        categoryAttachment.Id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());
        categoryAttachment.Name = 'Bank Statements';
        categoryAttachment.Wasabi_Link__c = 'happiest-minds-test/APP-0000000102/Bank_Statements/428551jul.pdf';
        categoryAttachment.Ocrolus_Document_Status__c = 'VERIFYING';
        categoryAttachment.Ocrolus_Uploaded_PK__c = '26509187';

        List<clcommon__Category_Attachment_Association__c> categoryAttachmentList = new List<clcommon__Category_Attachment_Association__c> {categoryAttachment};
        String jsonCategoryAttachmentList = '{"totalSize" : 1, "done" : true, "records" : ' + JSON.serialize(categoryAttachmentList, false) + '}';

        clcommon__Document_Category__c documentCategory = (clcommon__Document_Category__c) JSON.deserialize(
            '{"clcommon__DocCat_Attachment_Associations__r" : ' + jsonCategoryAttachmentList + '}', clcommon__Document_Category__c.class);
        documentCategory.Id = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());
        documentCategory.clcommon__Category_Name__c = documentDefinition.Name;
        documentCategory.clcommon__Show_In_Portal__c = documentDefinition.clcommon__Show_In_Portal__c;
        documentCategory.clcommon__Document_Definition__c = documentDefinition.Id;
        documentCategory.genesis__Application__c = application.Id;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        OcrolusManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        ocrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c> {ocrolusReport};
        OcrolusManager.ocrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        DBManagerTestsStub documentCategoryDBInstance = new DBManagerTestsStub();
        documentCategoryDBInstance.genericReturnObject = new List<clcommon__Document_Category__c> {documentCategory};
        OcrolusManager.documentCategoryDBInstance = (DocumentCategoryDB) Test.createStub(DocumentCategoryDB.class, documentCategoryDBInstance);

        DBManagerTestsStub categoryAttachmentAssnDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, categoryAttachmentAssnDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Test.startTest();

            callGetBookDocumentStatus(new Set<Id> {application.Id});

        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void getOcrolusAnalyticsExcel() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountRecord.Name = 'DELTA FRESH, L.L.C';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'John';
        contactRecord.LastName = 'Boos';

        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        opportunityRecord.Name = 'Test Opportunity';
        opportunityRecord.AccountId = accountRecord.Id;
        opportunityRecord.Primary_Contact__c = contactRecord.Id;
        opportunityRecord.StageName = 'App Submitted';
        opportunityRecord.Sub_Status__c = 'Score Pending';
        opportunityRecord.CloseDate = System.today().addMonths(2).addDays(19);

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = accountRecord.Id;
        application.Opportunity__c = opportunityRecord.Id;
        application.Primary_Guarantor__c = contactRecord.Id;
        application.Industry_Rating__c = 'B';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 1413777;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 1;
        application.genesis__Payment_Frequency__c = 'DAILY';
        application.Auto_Renewed__c = true;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Analytics_PK__c = '12872807';
        ocrolusReport.Max_Daily_Payment__c = 851.2645;

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        ocrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c> {ocrolusReport};
        OcrolusManager.ocrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        DBManagerTestsStub attachmentDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.attachmentDBDBInstance = (AttachmentDB) Test.createStub(AttachmentDB.class, attachmentDBStubInstance);


        DBManagerTestsStub categoryAttachmentAssnDBStubInstance = new DBManagerTestsStub();
        CategoryAttachAssnManager.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, categoryAttachmentAssnDBStubInstance);

        Test.setMock(HttpCalloutMock.class, new OcrolusCalloutMock.OcrolusCallOutMockGetOcrolusAnalyticsExcelSuccessResponse());
        Test.startTest();

            OcrolusManager.getOcrolusAnalyticsExcel(new Set<Id> {ocrolusReport.Id});

        Test.stopTest();

        System.assertEquals(1, categoryAttachmentAssnDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void getOcrolusAnalyticsExcelException() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountRecord.Name = 'DELTA FRESH, L.L.C';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'John';
        contactRecord.LastName = 'Boos';

        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        opportunityRecord.Name = 'Test Opportunity';
        opportunityRecord.AccountId = accountRecord.Id;
        opportunityRecord.Primary_Contact__c = contactRecord.Id;
        opportunityRecord.StageName = 'App Submitted';
        opportunityRecord.Sub_Status__c = 'Score Pending';
        opportunityRecord.CloseDate = System.today().addMonths(2).addDays(19);

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = accountRecord.Id;
        application.Opportunity__c = opportunityRecord.Id;
        application.Primary_Guarantor__c = contactRecord.Id;
        application.Industry_Rating__c = 'B';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 1413777;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 1;
        application.genesis__Payment_Frequency__c = 'DAILY';
        application.Auto_Renewed__c = true;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Analytics_PK__c = '12872807';
        ocrolusReport.Max_Daily_Payment__c = 851.2645;

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        ocrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c> {ocrolusReport};
        OcrolusManager.ocrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Test.startTest();

            OcrolusManager.getOcrolusAnalyticsExcel(new Set<Id> {ocrolusReport.Id});

        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }

     @isTest
    private static void createOcrolusAnalyticsReportException() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountRecord.Name = 'DELTA FRESH, L.L.C';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'John';
        contactRecord.LastName = 'Boos';

        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        opportunityRecord.Name = 'Test Opportunity';
        opportunityRecord.AccountId = accountRecord.Id;
        opportunityRecord.Primary_Contact__c = contactRecord.Id;
        opportunityRecord.StageName = 'App Submitted';
        opportunityRecord.Sub_Status__c = 'Score Pending';
        opportunityRecord.CloseDate = System.today().addMonths(2).addDays(19);

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = accountRecord.Id;
        application.Opportunity__c = opportunityRecord.Id;
        application.Primary_Guarantor__c = contactRecord.Id;
        application.Industry_Rating__c = 'B';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 1413777;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 1;
        application.genesis__Payment_Frequency__c = 'DAILY';
        application.Auto_Renewed__c = true;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Analytics_PK__c = '12872807';
        ocrolusReport.Max_Daily_Payment__c = 851.2645;

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        ocrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c> {ocrolusReport};
        OcrolusManager.ocrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Test.setMock(HttpCalloutMock.class, new OcrolusCalloutMock.OcrolusCallOutMockGetOcrolusAnalyticsExcelSuccessResponse());
        Test.startTest();

            OcrolusManager.getOcrolusAnalyticsExcel(new Set<Id> {ocrolusReport.Id});

        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void processDeleteFileForSuccess(){

        String docUploadedPKIds = '23457889';
        Set<String> docUploadedPKId = new Set<String>();
        docUploadedPKId.add(docUploadedPKIds);

        Test.setMock(HttpCalloutMock.class, new OcrolusCalloutMock.OcrolusCallOutMockGetdeleteFileSuccessResponse());

        Exception ex;
        Test.startTest();
        try{
            OcrolusManager.processDeleteFile(docUploadedPKId);
        } catch (Exception e){
            ex = e;
        }
        Test.stopTest();

        TestUtility.assertNullException(ex);
        System.assert(docUploadedPKId != null);
    }

    @isTest
    private static void processDeleteFileForFailure(){

        String docUploadedPKIds = null;
        Set<String> docUploadedPKId = new Set<String>();
        docUploadedPKId.add(docUploadedPKIds);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Test.setMock(HttpCalloutMock.class, new OcrolusCalloutMock.OcrolusCallOutMockGetdeleteFileFailureResponse());
        Test.startTest();
        OcrolusManager.processDeleteFile(docUploadedPKId);
        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void processDeleteFileAsync(){

        String docUploadedPKIds = '23457889';
        Set<String> docUploadedPKId = new Set<String>();
        docUploadedPKId.add(docUploadedPKIds);

        Test.setMock(HttpCalloutMock.class, new OcrolusCalloutMock.OcrolusCallOutMockGetdeleteFileSuccessResponse());

        Exception ex;
        Test.startTest();
        try{
            OcrolusManager.processDeleteFileAsync(docUploadedPKId);
        } catch (Exception e){
            ex = e;
        }
        Test.stopTest();

        TestUtility.assertNullException(ex);
        System.assert(docUploadedPKId != null);
    }

    @isTest
    private static void processOcrolusAnalyticsWithDeclineApplication() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountRecord.Name = 'DELTA FRESH, L.L.C';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'John';
        contactRecord.LastName = 'Boos';

        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        opportunityRecord.Name = 'Test Opportunity';
        opportunityRecord.AccountId = accountRecord.Id;
        opportunityRecord.Primary_Contact__c = contactRecord.Id;
        opportunityRecord.StageName = 'App Submitted';
        opportunityRecord.Sub_Status__c = 'Score Pending';
        opportunityRecord.CloseDate = System.today().addMonths(2).addDays(19);

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-00000102"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = accountRecord.Id;
        application.Opportunity__c = opportunityRecord.Id;
        application.Primary_Guarantor__c = contactRecord.Id;
        application.Industry_Rating__c = 'B';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 1413777;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 1;
        application.genesis__Payment_Frequency__c = 'DAILY';
        application.Auto_Renewed__c = true;
        application.genesis__Account__c = accountRecord.Id;
        application.genesis__Status__c = Applications.STATUS_DECLINED;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Analytics_PK__c = '12872807';
        ocrolusReport.Max_Daily_Payment__c = 851.2645;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        OcrolusManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        ocrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c> {ocrolusReport};
        OcrolusManager.ocrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Map<String, Object> ocrolusAnalyticsMap = new Map<String, Object>();
        Map<String, Object> ocrolusIndicatorsForBusinessType = new Map<String, Object>();
        Map<String, Object> ocrolusIndicators = new Map<String, Object>();
        ocrolusIndicatorsForBusinessType.put('OfferGAV', 808708.2436);
        ocrolusIndicatorsForBusinessType.put('MaxDailyPayment', 851.2645);
        ocrolusIndicatorsForBusinessType.put('Volatility', null);
        ocrolusIndicatorsForBusinessType.put('NumberOfDeposits', 10);
        ocrolusIndicatorsForBusinessType.put('NumberOfBankStatements', 11);
        ocrolusIndicatorsForBusinessType.put('PrimaryBankAccountNumber', null);
        ocrolusIndicatorsForBusinessType.put('PrimaryBankAccountName', '128642520 CENTRIS FEDERAL CREDIT UNION CHECKING');

        ocrolusIndicators.put('non_sole', ocrolusIndicatorsForBusinessType);
        ocrolusIndicators.put('sole', ocrolusIndicatorsForBusinessType);
        ocrolusIndicators.put('NumberOfCompetitors', 1);
        ocrolusIndicators.put('DebtConsolidator', false);
        ocrolusIndicators.put('SuspiciousActivity', false);
        ocrolusIndicators.put('PotentialFraud', false);
        ocrolusIndicators.put('EndingBalanceMismatch', false);
        ocrolusIndicators.put('BeginEndingBalanceMismatch', true);
        List<String> competitorList = new List<String>();
        competitorList.add('Vader Servicing');

        ocrolusAnalyticsMap.put('pk', 12872807);
        ocrolusAnalyticsMap.put('Indicators', ocrolusIndicators);
        ocrolusAnalyticsMap.put('competitors', competitorList);

        Exception ex;
        Test.startTest();

        try{
            OcrolusManager.processOcrolusAnalytics(ocrolusAnalyticsMap);
        } catch(Exception e){
            ex = e;
        }

        Test.stopTest();

        TestUtility.assertException(ex);
        System.assertEquals('Application status is not in Bank Statement Processing', ex.getMessage());
    }

    @isTest
    private static void processOcrolusAnalyticsWithBankUploadprocessingFailed() {

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Industry_Rating__c = 'B';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 1413777;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 1;
        application.genesis__Payment_Frequency__c = 'DAILY';
        application.Auto_Renewed__c = true;
        application.genesis__Status__c = Applications.STATUS_BANK_STATEMENT_PROCESSING_FAILED;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Analytics_PK__c = '12872807';
        ocrolusReport.Max_Daily_Payment__c = 851.2645;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        OcrolusManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        ocrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c> {ocrolusReport};
        OcrolusManager.ocrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Map<String, Object> ocrolusAnalyticsMap = new Map<String, Object>();
        ocrolusAnalyticsMap.put('pk', ocrolusReport.Analytics_PK__c);
        ocrolusAnalyticsMap.put('TransactionId', 'Test1234');
        ocrolusAnalyticsMap.put('Message', 'TestMessage');

        Test.startTest();
            OcrolusManager.processOcrolusAnalytics(ocrolusAnalyticsMap);
        Test.stopTest();

        System.assertEquals(0, ocrolusReportDBStubInstance.forUpdateSObjects.size());
    }
}