@isTest
private class ApplicationButtonControllerTests {

    @isTest
    private static void convertApplicationToContract() {

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        ApplicationButtonController.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        genesis__Applications__c application = generateDummyApplication();

        Id applicationId = application.Id;

        Id pricingDetailId = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Application__c = applicationId;
        pricingDetail.Id = pricingDetailId;
        pricingDetail.Status__c = CANPricingDetails.STATUS_ACCEPTED;
        pricingDetail.term_audit_complete__c = true;

        DBManagerTestsStub canPricingDBStubInstance = new DBManagerTestsStub();
        canPricingDBStubInstance.genericReturnObject = new List<CAN_Pricing_Detail__c>{pricingDetail};
        ApplicationManager.canPricingDetailDBInstance = (CANPricingDetailDB) Test.createStub(CANPricingDetailDB.class, canPricingDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationButtonController.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        Test.startTest();
            String actualValue = ApplicationButtonController.convertApplicationToContract(applicationId);
        Test.stopTest();

        String expectedValue = 'Unable to find application.';
        System.assertEquals(expectedValue, actualValue);
        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
        System.assertEquals(1, applicationDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void convertApplicationToContractValidationFail() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        DBManagerTestsStub canPricingDBStubInstance = new DBManagerTestsStub();
        canPricingDBStubInstance.genericReturnObject = new List<CAN_Pricing_Detail__c>();
        ApplicationManager.canPricingDetailDBInstance = (CANPricingDetailDB) Test.createStub(CANPricingDetailDB.class, canPricingDBStubInstance);

        Test.startTest();
            String actualValue = ApplicationButtonController.convertApplicationToContract(applicationId);
        Test.stopTest();

        String expectedValue = 'There was no Active Pricing record found';
        System.assertEquals(expectedValue, actualValue);
    }

    @isTest
    private static void uploadFilesToFolder() {
        Id attachmentId = TestUtility.getFakeId(Attachment.getSObjectType());
        Id documentCategoryId = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());

        Attachment attachmentObj = new Attachment();
        attachmentObj.Id = attachmentId;
        attachmentObj.Name = 'Test File.txt';
        attachmentObj.Body = Blob.valueOf('Test File');

        DBManagerTestsStub attachmentStubInstance = new DBManagerTestsStub();
        attachmentStubInstance.genericReturnObject = new List<Attachment> {attachmentObj};
        ApplicationButtonController.attachmentDBInstance = (AttachmentDB) Test.createStub(AttachmentDB.class, attachmentStubInstance);

        DBManagerTestsStub categoryAttachmentAssociationDBStubInstance = new DBManagerTestsStub();
        ApplicationButtonController.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, categoryAttachmentAssociationDBStubInstance);

        Test.startTest();
            String actualValue = ApplicationButtonController.uploadFilesToFolder(documentCategoryId, attachmentId);
        Test.stopTest();

        String expectedValue = 'Success';
        System.assertEquals(expectedValue, actualValue);
        System.assertEquals(1, attachmentStubInstance.forUpdateSObjects.size());
        System.assertEquals(1, categoryAttachmentAssociationDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void uploadFilesToFolderException() {
        Id documentCategoryId = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());

        Attachment attachmentObj = new Attachment();
        attachmentObj.Id = TestUtility.getFakeId(Attachment.getSObjectType());
        attachmentObj.Name = 'Test File.txt';
        attachmentObj.Body = Blob.valueOf('Test File');

        DBManagerTestsStub attachmentStubInstance = new DBManagerTestsStub();
        attachmentStubInstance.genericReturnObject = new List<Attachment> {attachmentObj};
        ApplicationButtonController.attachmentDBInstance = (AttachmentDB) Test.createStub(AttachmentDB.class, attachmentStubInstance);

        String actualValue;
        Exception ex;
        Test.startTest();
            try{
                actualValue = ApplicationButtonController.uploadFilesToFolder(documentCategoryId, 'Test Desc');
            }catch(Exception e){
                ex = e;
            }
        Test.stopTest();

        TestUtility.assertException(Ex);
        System.assert(ex.getMessage() != null);
        System.assertEquals(null, actualValue);
    }

    @isTest
    private static void moveFilesToFolder() {
        Id attachmentId = TestUtility.getFakeId(Attachment.getSObjectType());
        Id documentCategoryId = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());
        Id documentCategoryAsstId = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());

        clcommon__Category_Attachment_Association__c documentCategoryAsst = CategoryAttachAssns.createCategoryAttachAssn(
            'TestFile', attachmentId, documentCategoryId
        );
        documentCategoryAsst.Id = documentCategoryAsstId;
        documentCategoryAsst.Wasabi_Link__c = 'null/other/test.pdf';

        DBManagerTestsStub categoryAttachmentAssociationDBStubInstance = new DBManagerTestsStub();
        categoryAttachmentAssociationDBStubInstance.genericReturnObject = new List<clcommon__Category_Attachment_Association__c> {documentCategoryAsst};
        ApplicationButtonController.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, categoryAttachmentAssociationDBStubInstance);

        clcommon__Document_Category__c documentCategory = new clcommon__Document_Category__c();
        documentCategory.Id = documentCategoryId;
        documentCategory.clcommon__Category_Name__c = 'Dummy type';

        DBManagerTestsStub documentCategoryDBStubInstance = new DBManagerTestsStub();
        documentCategoryDBStubInstance.genericReturnObject = new List<clcommon__Document_Category__c> {documentCategory};
        ApplicationButtonController.documentCategoryDBInstance = (DocumentCategoryDB) Test.createStub(DocumentCategoryDB.class, documentCategoryDBStubInstance);

        System.Test.setMock(HttpCalloutMock.class, new WasabiHTTPCallOutMocks.WasabiSendDocumentSuccessResponse());
        System.Test.setMock(HttpCalloutMock.class, new WasabiHTTPCallOutMocks.WasabiGetDocumentSuccessResponse());

        Test.startTest();
            ApplicationButtonController.moveFilesToFolder('TestFileName',attachmentId, documentCategoryId, documentCategoryAsstId);
        Test.stopTest();

        System.assertEquals(1, categoryAttachmentAssociationDBStubInstance.forInsertSObjects.size());
        System.assertEquals(1, categoryAttachmentAssociationDBStubInstance.forDeleteSObjects.size());
    }

    @isTest
    private static void moveFilesToFolderException() {
        Id attachmentId = TestUtility.getFakeId(Attachment.getSObjectType());
        Id documentCategoryId = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());
        Id documentCategoryAsstId = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());

        clcommon__Category_Attachment_Association__c documentCategoryAsst = CategoryAttachAssns.createCategoryAttachAssn(
            'TestFile', attachmentId, documentCategoryId
        );
        documentCategoryAsst.Id = documentCategoryAsstId;
        documentCategoryAsst.Wasabi_Link__c = 'null/other/test.pdf';

        DBManagerTestsStub categoryAttachmentAssociationDBStubInstance = new DBManagerTestsStub();
        categoryAttachmentAssociationDBStubInstance.genericReturnObject = new List<clcommon__Category_Attachment_Association__c> {documentCategoryAsst};
        ApplicationButtonController.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, categoryAttachmentAssociationDBStubInstance);

        DBManagerTestsStub errorLogDBInstanceStub = new DBManagerTestsStub();
        ApplicationButtonController.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBInstanceStub);

        System.Test.setMock(HttpCalloutMock.class, new WasabiHTTPCallOutMocks.WasabiSendDocumentSuccessResponse());
        System.Test.setMock(HttpCalloutMock.class, new WasabiHTTPCallOutMocks.WasabiGetDocumentSuccessResponse());

        Exception ex;
        Test.startTest();
            ApplicationButtonController.moveFilesToFolder('TestFileName', attachmentId, documentCategoryId, documentCategoryAsstId);
        Test.stopTest();

        System.assertEquals(1, errorLogDBInstanceStub.forInsertSObjects.size());
    }

    @isTest
    private static void sendToWasabi() {

        Attachment attachmentObj = new Attachment();
        attachmentObj.Id = TestUtility.getFakeId(Attachment.getSObjectType());
        attachmentObj.Name = 'Test File.txt';
        attachmentObj.Body = Blob.valueOf('Test File');

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-000000001"}' , genesis__Applications__c.class
        );

        clcommon__Document_Category__c docCategory = new clcommon__Document_Category__c();
        docCategory.clcommon__Category_Name__c = 'Bank Statement';
        docCategory.genesis__Application__r = application;

        clcommon__Category_Attachment_Association__c catAttAssociation = (clcommon__Category_Attachment_Association__c) JSON.deserialize(
            '{ "Name" : "Test-NameDummy"}' , clcommon__Category_Attachment_Association__c.class
        );
        catAttAssociation.Id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());
        catAttAssociation.clcommon__Document_Category__r = docCategory;
        catAttAssociation.clcommon__Attachment_Id__c = attachmentObj.Id;

        DBManagerTestsStub catAttAssociationSStubInstance = new DBManagerTestsStub();
        catAttAssociationSStubInstance.genericReturnObject = new List<clcommon__Category_Attachment_Association__c> {catAttAssociation};
        ApplicationButtonController.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, catAttAssociationSStubInstance);

        Wasabi_Setting__mdt wasabiSetting = new Wasabi_Setting__mdt();
        wasabiSetting.Bucket_Name__c = 'Dummy Bucket';
        wasabiSetting.Base_Path__c = 'Dummy Path';
        CustomMetaDataHelper.defaultWasabiSetting = wasabiSetting;

        DBManagerTestsStub errorLogDBInstanceStub = new DBManagerTestsStub();
        ApplicationButtonController.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBInstanceStub);

        System.Test.setMock(HttpCalloutMock.class, new WasabiHTTPCallOutMocks.WasabiSendDocumentSuccessResponse());

        Test.startTest();
            ApplicationButtonController.sendToWasabi(catAttAssociation.Id);
        Test.stopTest();

        System.assertEquals(0, errorLogDBInstanceStub.forInsertSObjects.size());
    }

    @isTest
    private static void sendToWasabiExceptionCheck() {

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-000000001"}' , genesis__Applications__c.class
        );

        clcommon__Document_Category__c docCategory = new clcommon__Document_Category__c();
        docCategory.clcommon__Category_Name__c = 'Bank Statement';
        docCategory.genesis__Application__r = application;

        clcommon__Category_Attachment_Association__c catAttAssociation = (clcommon__Category_Attachment_Association__c) JSON.deserialize(
            '{ "Name" : "Test-NameDummy"}' , clcommon__Category_Attachment_Association__c.class
        );
        catAttAssociation.Id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());
        catAttAssociation.clcommon__Document_Category__r = docCategory;
        catAttAssociation.clcommon__Attachment_Id__c = null;

        DBManagerTestsStub catAttAssociationSStubInstance = new DBManagerTestsStub();
        catAttAssociationSStubInstance.genericReturnObject = new List<clcommon__Category_Attachment_Association__c> {catAttAssociation};
        ApplicationButtonController.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, catAttAssociationSStubInstance);

        Wasabi_Setting__mdt wasabiSetting = new Wasabi_Setting__mdt();
        wasabiSetting.Bucket_Name__c = 'Dummy Bucket';
        wasabiSetting.Base_Path__c = 'Dummy Path';
        CustomMetaDataHelper.defaultWasabiSetting = wasabiSetting;

        DBManagerTestsStub errorLogDBInstanceStub = new DBManagerTestsStub();
        ApplicationButtonController.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBInstanceStub);

        System.Test.setMock(HttpCalloutMock.class, new WasabiHTTPCallOutMocks.WasabiSendDocumentSuccessResponse());

        Test.startTest();
            ApplicationButtonController.sendToWasabi(catAttAssociation.Id);
        Test.stopTest();

        System.assertEquals(1, errorLogDBInstanceStub.forInsertSObjects.size());
    }

    @isTest
    private static void requestConsumerCreditCheck() {
        genesis__Applications__c application = generateDummyApplication();

        Id applicationId = application.Id;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationButtonController.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        Test.startTest();
            String actualValue = ApplicationButtonController.requestConsumerCreditCheck(applicationId);
        Test.stopTest();

        String expectedValue = 'Done! Please check the status';
        System.assertEquals(expectedValue, actualValue);
    }

    @isTest
    private static void runBusinessCreditCheck() {
        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        account.Last_Business_Credit_Pull__c = null;

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        ExperianManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        genesis__Applications__c application = generateDummyApplication();
        application.genesis__Account__c = account.Id;

        Id applicationId = application.Id;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationButtonController.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        Set<Id> accountIds = new Set<Id>();
        accountIds.add(account.Id);

        Credit_Report_Detail__c creditReportDetail = new Credit_Report_Detail__c();
        creditReportDetail.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        creditReportDetail.Type__c = 'Experian Business';
        creditReportDetail.Application__c = application.Id;
        creditReportDetail.Account__c = account.Id;

        DBManagerTestsStub creditReportDetailDBStubInstance = new DBManagerTestsStub();
        creditReportDetailDBStubInstance.genericReturnObject = new List<Credit_Report_Detail__c>{creditReportDetail};
        ExperianManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        ExperianManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        String actualValue;
        Exception ex;
        Test.startTest();
        try{
            actualValue = ApplicationButtonController.runBusinessCreditCheck(applicationId);
        }catch(Exception e){
            ex = e;
        }
        Test.stopTest();

        TestUtility.assertException(ex);
        System.assert(ex.getMessage() != null);
        System.assertEquals(null, actualValue);
    }

    @isTest
    private static void runLexisNexisCheck() {
        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        genesis__Applications__c application = generateDummyApplication();

        Contact contact = new Contact();
        contact.Id = TestUtility.getFakeId(Contact.getSObjectType());

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{contact};
        LexisNexisManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        Id applicationId = application.Id;
        Id accountId = account.Id;
        Id contactId = contact.Id;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationButtonController.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        party.genesis__Application__c = applicationId;
        party.clcommon__Contact__c = contactId;
        party.clcommon__Account__c = accountId;
        party.clcommon__Type__c = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = new List<clcommon__Party__c>{party};
        LexisNexisManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        String actualValue;
        Exception ex;
        Test.startTest();
        try{
            actualValue = ApplicationButtonController.runLexisNexisCheck(applicationId);
        }catch(Exception e){
            ex = e;
        }
        Test.stopTest();

        String expectedValue = 'Done! Please check the status';
        System.assertNotEquals(expectedValue, actualValue);
    }

    @isTest
    private static void runCANScoring() {
        genesis__Applications__c application = generateDummyApplication();
        application.Type__c = 'New';

        Id applicationId = application.Id;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationButtonController.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance2 = new DBManagerTestsStub();
        applicationDBStubInstance2.genericReturnObject = new List<genesis__Applications__c>{application};
        CANScoringManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance2);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CANScoringManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Test.startTest();
            String actualValue = ApplicationButtonController.runCANScoring(applicationId);
        Test.stopTest();

        String expectedValue = 'Done! Please check the status';
        System.assertEquals(expectedValue, actualValue);
    }

    @isTest
    private static void runOcrolusBankStatementProcess() {
        genesis__Applications__c application = generateDummyApplication();

        Id applicationId = application.Id;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationButtonController.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);
        OcrolusManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        clcommon__Category_Attachment_Association__c attachmentAssociation = new clcommon__Category_Attachment_Association__c();
        attachmentAssociation.Id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());
        attachmentAssociation.Wasabi_Link__c = 'https:test.wasabi.other/test.pdf';

        List<clcommon__Category_Attachment_Association__c> attachmentAssociationList = new List<clcommon__Category_Attachment_Association__c>{
            attachmentAssociation
        };
        String attachmentAssociationListJSON = '{"totalSize":1, "done":true, "records":' + JSON.serialize(attachmentAssociationList, false) + '}';

        clcommon__Document_Category__c documentCategory = (clcommon__Document_Category__c) JSON.deserialize(
            '{"clcommon__DocCat_Attachment_Associations__r" : ' + attachmentAssociationListJSON + '}',
            clcommon__Document_Category__c.class
        );
        documentCategory.Id = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());
        documentCategory.genesis__Application__c = applicationId;

        DBManagerTestsStub documentCategoryDBStubInstance = new DBManagerTestsStub();
        documentCategoryDBStubInstance.genericReturnObject = new List<clcommon__Document_Category__c>{documentCategory};
        OcrolusManager.documentCategoryDBInstance = (DocumentCategoryDB) Test.createStub(DocumentCategoryDB.class, documentCategoryDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Test.startTest();
            String actualValue = ApplicationButtonController.runOcrolusBankStatementProcess(applicationId);
        Test.stopTest();

        String expectedValue = 'Done! Please check the status';
        System.assertEquals(expectedValue, actualValue);
    }

    @isTest
    private static void runOcrolusDocumentGetStatus() {
        genesis__Applications__c application = generateDummyApplication();

        Id applicationId = application.Id;

        Test.startTest();
            String actualValue = ApplicationButtonController.runOcrolusDocumentGetStatus(applicationId);
        Test.stopTest();

        String expectedValue = 'No documents uploaded for the application';
        System.assertEquals(expectedValue, actualValue);
    }

    @isTest
    private static void acceptPricingOffer() {
        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Application__c = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        pricingDetail.Id = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());
        pricingDetail.Status__c = 'Sent To Customer';

        DBManagerTestsStub canPricingDBStubInstance = new DBManagerTestsStub();
        canPricingDBStubInstance.genericReturnObject = new List<CAN_Pricing_Detail__c>{pricingDetail};
        ApplicationButtonController.canPricingDetailDBInstance = (CANPricingDetailDB) Test.createStub(CANPricingDetailDB.class, canPricingDBStubInstance);

        Test.startTest();
            String actualValue = ApplicationButtonController.acceptPricingOffer(pricingDetail.Id);
        Test.stopTest();

        String expectedValue = 'Success';
        System.assertEquals(expectedValue, actualValue);
    }

    @isTest
    private static void acceptPricingOfferException() {

        Id pricingDetailId =  TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());

        DBManagerTestsStub canPricingDBStubInstance = new DBManagerTestsStub();
        ApplicationButtonController.canPricingDetailDBInstance = (CANPricingDetailDB) Test.createStub(CANPricingDetailDB.class, canPricingDBStubInstance);

        String actualValue;
        Exception ex;
        Test.startTest();
        try{
            actualValue = ApplicationButtonController.acceptPricingOffer(pricingDetailId);
        }catch(Exception e){
            ex = e;
        }
        Test.stopTest();

        TestUtility.assertException(ex);
        System.assert(ex.getMessage() != null);
        System.assertEquals(null, actualValue);
    }

    @isTest
    private static void createNewParty() {
        genesis__Applications__c application = generateDummyApplication();

        Id applicationId = application.Id;
        Id borrowerAccountId = TestUtility.getFakeId(Account.getSObjectType());
        Id contactId = TestUtility.getFakeId(Contact.getSObjectType());

        Contact contact = new Contact();
        contact.Id = contactId;
        contact.loan__Contact_Type__c = 'BROKER';

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact> {contact};
        ApplicationButtonController.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        ApplicationButtonController.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        account.Last_Business_Credit_Pull__c = null;

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        ApplicationButtonController.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        clcommon__Reciprocal_Role__c reciprocalRole = new clcommon__Reciprocal_Role__c();
        reciprocalRole.Id = TestUtility.getFakeId(clcommon__Reciprocal_Role__c.getSObjectType());

        DBManagerTestsStub reciprocalRoleDBStubInstance = new DBManagerTestsStub();
        reciprocalRoleDBStubInstance.genericReturnObject = new List<clcommon__Reciprocal_Role__c> {reciprocalRole};
        ApplicationButtonController.clCommonReciprocalRoleDBInstance = (CLCommonReciprocalRoleDB) Test.createStub(CLCommonReciprocalRoleDB.class, reciprocalRoleDBStubInstance);

        DBManagerTestsStub clCommonRelationshipDBStubInstance = new DBManagerTestsStub();
        ApplicationButtonController.clCommonRelationshipDBInstance = (CLCommonRelationshipDB) Test.createStub(CLCommonRelationshipDB.class, clCommonRelationshipDBStubInstance);

        String actualValue;
        Exception ex;
        Test.startTest();
        try{
            actualValue = ApplicationButtonController.createNewParty(contactId, applicationId, borrowerAccountId, 'Contact');
        }catch(Exception e){
            ex = e;
        }
        Test.stopTest();

        TestUtility.assertNullException(ex);
        System.assertEquals('Success', actualValue);
    }

    @isTest
    private static void updateApplicationPaymentDate() {
        genesis__Applications__c application = generateDummyApplication();
        Id applicationId = application.Id;

        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);
        Date currentDate = GeneralHelper.currentSystemDate;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationDailyUpdateManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        Test.startTest();
            String actualValue = ApplicationButtonController.updateApplicationPaymentDate(applicationId);
        Test.stopTest();

        String expectedValue = 'Updated successfully';
        System.assertEquals(expectedValue, actualValue);
    }

    private static genesis__Applications__c generateDummyApplication(){
        genesis__Applications__c application = new genesis__Applications__c();
        application.genesis__Status__c = 'NEW ENTERED';
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        return application;
    }

    @isTest
    private static void runDataMerchCheck() {
        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        account.Business_Tax_ID__c = '123456789';

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        DataMerchManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        genesis__Applications__c application = generateDummyApplication();
        application.genesis__Account__c = account.Id;

        Id applicationId = application.Id;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationButtonController.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        Credit_Report_Detail__c creditReportDetail = new Credit_Report_Detail__c();
        creditReportDetail.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        creditReportDetail.Type__c = 'Data Merch';
        creditReportDetail.Application__c = application.Id;
        creditReportDetail.Account__c = account.Id;

        DBManagerTestsStub creditReportDetailDBStubInstance = new DBManagerTestsStub();
        creditReportDetailDBStubInstance.genericReturnObject = new List<Credit_Report_Detail__c>{creditReportDetail};
        DataMerchManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        DataMerchManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        UnderWriter_Task__c uwTask = new UnderWriter_Task__c();
        uwTask.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        uwTask.Application__c = application.Id;
        uwTask.IsCompleted__c = false;
        uwTask.Task_Name__c = DataMerch.TASK_TYPE_DATA_MERCH;

        DBManagerTestsStub underWriterTaskDBStubInstance = new DBManagerTestsStub();
        underWriterTaskDBStubInstance.genericReturnObject = new List<UnderWriter_Task__c>{uwTask};
        DataMerchManager.underWriterTaskDBInstance = (UnderWriterTaskDB) Test.createStub(UnderWriterTaskDB.class, underWriterTaskDBStubInstance);

        GeneralHelper.currentSystemDate = Date.newInstance(2022, 05, 30);

        Data_Merch_Note__c dataMerchNote = new Data_Merch_Note__c();
        dataMerchNote.Id = TestUtility.getFakeId(Data_Merch_Note__c.getSObjectType());
        dataMerchNote.Account__c = account.Id;
        dataMerchNote.Application__c = application.Id;
        dataMerchNote.Added_at__c = GeneralHelper.currentSystemDate.addDays(-20);
        dataMerchNote.Note_Category__c = 'Suspicious Activity';

        DBManagerTestsStub dataMerchNoteDBStubInstance = new DBManagerTestsStub();
        dataMerchNoteDBStubInstance.genericReturnObject = new List<Data_Merch_Note__c>{dataMerchNote};
        DataMerchManager.dataMerchNoteDBInstance = (DataMerchNoteDB) Test.createStub(DataMerchNoteDB.class, dataMerchNoteDBStubInstance);

        String actualValue;
        Exception ex;
        Test.startTest();
        try{
            actualValue = ApplicationButtonController.runDataMerchCheck(applicationId);
        }catch(Exception e){
            ex = e;
        }
        Test.stopTest();

        TestUtility.assertException(ex);
        System.assert(ex.getMessage() != null);
        System.assertEquals(null, actualValue);
    }
}