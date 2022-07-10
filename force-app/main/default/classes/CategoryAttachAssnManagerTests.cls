@isTest
private class CategoryAttachAssnManagerTests {

   	@TestSetup
    static void makeData(){
        TestUtility.runSetupData();
        loan__Conditions_On_Spread__c spread = new loan__Conditions_On_Spread__c();
        spread.loan__Operator__c = '=';
        spread.loan__Value__c = 'True';
        spread.loan__Parameter__c = 'True';
        insert spread;

        Account account_1 = TestUtility.createAccount();
        genesis__Applications__c application = TestUtility.createApplication();
        Lead leadRecord = TestUtility.createLead();

    }

    @isTest
    private static void createAccountDocumentCategoryAssociationByAttachmentIdTestMethod(){
        Account acc_1 = new Account();
        acc_1 = [Select id from Account LIMIT 1];
        Attachment attachmentObj = new Attachment();
        attachmentObj.Body = Blob.valueOf('Dummy File Body');
        attachmentObj.Name = 'name.pdf';
        attachmentObj.parentId = acc_1.Id;
        Insert attachmentObj;

        clcommon__Document_Category__c documentCategoryAssociationByContentVersionId_1 = new clcommon__Document_Category__c();
        documentCategoryAssociationByContentVersionId_1.clcommon__Category_Name__c = GeneralConstants.DOCUMENT_TYPE_EXPERIAN_BUSINESS_REPORT;
        documentCategoryAssociationByContentVersionId_1.clcommon__Account__c = acc_1.Id;
        insert documentCategoryAssociationByContentVersionId_1;

        Map<Id, Attachment> accountIdToAttachment = new Map<Id, Attachment>();
        accountIdToAttachment.put(attachmentObj.parentId, attachmentObj);

        String documentType = GeneralConstants.DOCUMENT_TYPE_EXPERIAN_BUSINESS_REPORT;

        genesis__Applications__c appl = [SELECT id,genesis__Account__c
                                         FROM genesis__Applications__c
                                         LIMIT 1];

        Map<Id, Attachment> accountIdToAttachment1 = new Map<Id, Attachment>();
        accountIdToAttachment1.put(appl.genesis__Account__c, attachmentObj);

        clcommon__Document_Definition__c docDef = new clcommon__Document_Definition__c();
        docDef.Name = documentType;
        docDef.clcommon__Active__c = true;
        insert docDef;

        Test.startTest();
            CategoryAttachAssnManager.createAccountDocumentCategoryAssociationByAttachmentId(accountIdToAttachment, documentType);
            CategoryAttachAssnManager.createAccountDocumentCategoryAssociationByAttachmentId(accountIdToAttachment1, documentType);
        Test.stopTest();

        System.assert(attachmentObj != Null);
        System.assertEquals(True, docDef.clcommon__Active__c);
    }

    @isTest
    private static void createBulkDocumentCategoryAssociationForApplicationTestMethod() {
        Id attachmentId = TestUtility.getFakeId(Attachment.getSObjectType());
        Id documentCategoryId = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        clcommon__Document_Category__c documentCategory = new clcommon__Document_Category__c();
        documentCategory.Id = documentCategoryId;
        documentCategory.clcommon__Category_Name__c = 'Dummy type';

        DBManagerTestsStub documentCategoryDBStubInstance = new DBManagerTestsStub();
        documentCategoryDBStubInstance.genericReturnObject = new List<clcommon__Document_Category__c> {documentCategory};
        CategoryAttachAssnManager.documentCategoryDBInstance = (DocumentCategoryDB) Test.createStub(DocumentCategoryDB.class, documentCategoryDBStubInstance);

        DBManagerTestsStub categoryAttachmentAssociationDBStubInstance = new DBManagerTestsStub();
        CategoryAttachAssnManager.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, categoryAttachmentAssociationDBStubInstance);

        Map<Id, String> attachmentIdToFileName = new Map<Id, String>();
        attachmentIdToFileName.put(attachmentId, 'Test File.pdf');


        Test.startTest();
            CategoryAttachAssnManager.createBulkDocumentCategoryAssociationForApplication(attachmentIdToFileName, applicationId, GeneralConstants.DOCUMENT_TYPE_OTHERS);
        Test.stopTest();

        System.assertEquals(1, categoryAttachmentAssociationDBStubInstance.forInsertSObjects.Size());
    }

    @isTest
    private static void createDocumentCategoryAssociationForApplicationsByAttachmentIdTestMethod(){

        Id attachmentId = TestUtility.getFakeId(Attachment.getSObjectType());
        Id documentCategoryId = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        clcommon__Document_Category__c documentCategory = new clcommon__Document_Category__c();
        documentCategory.Id = documentCategoryId;
        documentCategory.clcommon__Category_Name__c = 'Dummy type';

        DBManagerTestsStub documentCategoryDBStubInstance = new DBManagerTestsStub();
        documentCategoryDBStubInstance.genericReturnObject = new List<clcommon__Document_Category__c> {documentCategory};
        CategoryAttachAssnManager.documentCategoryDBInstance = (DocumentCategoryDB) Test.createStub(DocumentCategoryDB.class, documentCategoryDBStubInstance);

        DBManagerTestsStub categoryAttachmentAssociationDBStubInstance = new DBManagerTestsStub();
        CategoryAttachAssnManager.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, categoryAttachmentAssociationDBStubInstance);

        Attachment attachmentObj = new Attachment();
        attachmentObj.Body = Blob.valueOf('Dummy Text body');
        attachmentObj.Name = String.valueOf('test.xlsx');
        attachmentObj.parentId = applicationId;
        attachmentObj.Id = attachmentId;

        Map<Id, Attachment> applicationIdToAttachment = new Map<Id, Attachment>();
        applicationIdToAttachment.put(applicationId, attachmentObj);

        Test.startTest();
            CategoryAttachAssnManager.createDocumentCategoryAssociationForApplicationsByAttachmentId(applicationIdToAttachment, GeneralConstants.DOCUMENT_TYPE_OTHERS);
        Test.stopTest();

        System.assertEquals(1, categoryAttachmentAssociationDBStubInstance.forInsertSObjects.Size());
    }

    @isTest
    private static void createDocumentCategoryAssociationForSignedDocumentsTestMethod(){

        Set<Id> finalCongaSignDocumentIds = new Set<Id>();
        Set<String> definitionNames = new Set<String> {
            GeneralConstants.DOCUMENT_TYPE_LOAN_AGREEMENT, GeneralConstants.DOCUMENT_TYPE_COLLECTIONS,
            GeneralConstants.DOCUMENT_TYPE_CL_COLLECTIONS
        };

        genesis__Applications__c application = [SELECT id,genesis__Account__c
                                                FROM genesis__Applications__c
                                                LIMIT 1];

        APXT_CongaSign__Transaction__c congaTransaction = new APXT_CongaSign__Transaction__c();
        congaTransaction.Parent_a6t__c = application.Id;
        insert congaTransaction;

        clcommon__Document_Category__c documentCategoryAssociationByContentVersionId = new clcommon__Document_Category__c();
        documentCategoryAssociationByContentVersionId.clcommon__Category_Name__c = GeneralConstants.DOCUMENT_TYPE_LOAN_AGREEMENT;
        documentCategoryAssociationByContentVersionId.genesis__Application__c = application.id;
        insert documentCategoryAssociationByContentVersionId;

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Test Document';
        contentVersion.PathOnClient = 'TestDocument.pdf';
        contentVersion.VersionData = Blob.valueOf('Test Content');
        contentVersion.IsMajorVersion = true;
        Insert contentVersion;

        List<ContentDocument> contentDocument = [
            SELECT Id, Title, LatestPublishedVersionId
            FROM contentDocument
        ];

		System.assertEquals(ContentDocument.size(), 1);

        List<ContentVersion> cvList = [
        	SELECT Id, Title, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :contentVersion.Id
        ];

        System.assertEquals(cvList.size(), 1);

        List<APXT_CongaSign__Document__c> congaSignDocumentList = new List<APXT_CongaSign__Document__c>();
        APXT_CongaSign__Document__c congaSignDocument = new APXT_CongaSign__Document__c();
        congaSignDocument.Name = 'Test CongaSign Document';
        congaSignDocument.APXT_CongaSign__Type__c = 'Final';
        congaSignDocument.APXT_CongaSign__DocumentOrder__c = 2;
        congaSignDocument.APXT_CongaSign__ContentDocumentId__c = documentCategoryAssociationByContentVersionId.Id;
        congaSignDocument.APXT_CongaSign__ContentVersionId__c = contentVersion.Id;
        congaSignDocument.APXT_CongaSign__Transaction__c = congaTransaction.id;
        Insert congaSignDocument;

        List<APXT_CongaSign__Document__c> conDocList =  new List<APXT_CongaSign__Document__c>();
        conDocList = [SELECT id,Name,APXT_CongaSign__Transaction__c,APXT_CongaSign__Transaction__r.Parent_a6t__c,
                      		 APXT_CongaSign__ContentVersionId__c
                      FROM APXT_CongaSign__Document__c];

        APXT_CongaSign__Transaction__c conTran = new APXT_CongaSign__Transaction__c();
        conTran = [SELECT id,Parent_a6t__c
                   FROM APXT_CongaSign__Transaction__c
                   Limit 1];

        congaSignDocumentList.add(congaSignDocument);

        Test.startTest();
            CategoryAttachAssnManager.createDocumentCategoryAssociationForSignedDocuments(conDocList);
        Test.stopTest();

        System.assert(conTran != Null);
        System.assertEquals(congaSignDocumentList.Size(), 1);
    }

    @isTest
    private static void deleteLocalAttachmentsAndContentVersionsAsync() {
        Id attachmentId = TestUtility.getFakeId(Attachment.getSObjectType());

        Attachment attachmentObj = new Attachment();
        attachmentObj.Id = attachmentId;

        DBManagerTestsStub attachmentDBStubInstance = new DBManagerTestsStub();
        attachmentDBStubInstance.genericReturnObject = new List<Attachment> {attachmentObj};
        CategoryAttachAssnManager.attachmentDBInstance = (AttachmentDB) Test.createStub(AttachmentDB.class, attachmentDBStubInstance);

        Id contentDocumentId = TestUtility.getFakeId(ContentDocument.getSObjectType());
        ContentVersion contentVersion = (ContentVersion) JSON.deserialize(
            '{"ContentDocumentId" : "' + contentDocumentId + '"}',
            ContentVersion.class
        );
        contentVersion.Title = 'Test Document';
        contentVersion.Id = TestUtility.getFakeId(ContentVersion.getSObjectType());
        contentVersion.VersionData = Blob.valueOf('Test Content');

        DBManagerTestsStub contentVersionStubInstance = new DBManagerTestsStub();
        contentVersionStubInstance.genericReturnObject = new List<ContentVersion> {ContentVersion};
        CategoryAttachAssnManager.contentVersionDBInstance = (ContentVersionDB) Test.createStub(ContentVersionDB.class, contentVersionStubInstance);

        DBManagerTestsStub contentDocumentStubInstance = new DBManagerTestsStub();
        CategoryAttachAssnManager.contentDocumentDBInstance = (ContentDocumentDB) Test.createStub(ContentDocumentDB.class, contentDocumentStubInstance);

        Set<Id> attachmentIdsForDeletion = new Set<Id>();
        attachmentIdsForDeletion.add(attachmentId);
        attachmentIdsForDeletion.add(contentVersion.Id);

        Test.startTest();
            CategoryAttachAssnManager.deleteLocalAttachmentsAndContentVersionsAsync(attachmentIdsForDeletion);
        Test.stopTest();

        System.assertEquals(1, attachmentDBStubInstance.forDeleteSObjects.size());
        System.assertEquals(1, contentDocumentStubInstance.forDeleteSObjects.size());
    }

    @isTest
    private static void deleteLocalAttachmentsAndContentVersionsException() {
        Id attachmentId = TestUtility.getFakeId(Attachment.getSObjectType());

        Attachment attachmentObj = new Attachment();
        attachmentObj.Id = attachmentId;

        DBManagerTestsStub attachmentDBStubInstance = new DBManagerTestsStub();
        attachmentDBStubInstance.genericReturnObject = new List<Attachment> {attachmentObj};
        CategoryAttachAssnManager.attachmentDBInstance = (AttachmentDB) Test.createStub(AttachmentDB.class, attachmentDBStubInstance);

        Id contentDocumentId = TestUtility.getFakeId(ContentDocument.getSObjectType());
        ContentVersion contentVersion = (ContentVersion) JSON.deserialize(
            '{"ContentDocumentId" : "' + contentDocumentId + '"}',
            ContentVersion.class
        );
        contentVersion.Title = 'Test Document';
        contentVersion.Id = TestUtility.getFakeId(ContentVersion.getSObjectType());
        contentVersion.VersionData = Blob.valueOf('Test Content');

        DBManagerTestsStub contentVersionStubInstance = new DBManagerTestsStub();
        contentVersionStubInstance.genericReturnObject = new List<ContentVersion> {ContentVersion};
        CategoryAttachAssnManager.contentVersionDBInstance = (ContentVersionDB) Test.createStub(ContentVersionDB.class, contentVersionStubInstance);

        DBManagerTestsStub errorLogStubInstance = new DBManagerTestsStub();
        CategoryAttachAssnManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogStubInstance);

        Set<Id> attachmentIdsForDeletion = new Set<Id>();
        attachmentIdsForDeletion.add(attachmentId);
        attachmentIdsForDeletion.add(contentVersion.Id);

        Test.startTest();
            CategoryAttachAssnManager.deleteLocalAttachmentsAndContentVersions(attachmentIdsForDeletion);
        Test.stopTest();

        System.assertEquals(1, errorLogStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void createBulkDocumentCategoryAssociationForCollectionCaseTests() {
        Id attachmentId = TestUtility.getFakeId(Attachment.getSObjectType());
        Id documentCategoryId = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());
        Id collectionCaseId = TestUtility.getFakeId(Collection_Case__c.getSObjectType());

        clcommon__Document_Category__c documentCategory = new clcommon__Document_Category__c();
        documentCategory.Id = documentCategoryId;
        documentCategory.clcommon__Category_Name__c = 'Dummy type';

        DBManagerTestsStub documentCategoryDBStubInstance = new DBManagerTestsStub();
        documentCategoryDBStubInstance.genericReturnObject = new List<clcommon__Document_Category__c> {documentCategory};
        CategoryAttachAssnManager.documentCategoryDBInstance = (DocumentCategoryDB) Test.createStub(DocumentCategoryDB.class, documentCategoryDBStubInstance);

        DBManagerTestsStub categoryAttachmentAssociationDBStubInstance = new DBManagerTestsStub();
        CategoryAttachAssnManager.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, categoryAttachmentAssociationDBStubInstance);

        Map<Id, String> attachmentIdToFileName = new Map<Id, String>();
        attachmentIdToFileName.put(attachmentId, 'Test File.pdf');


        Test.startTest();
            CategoryAttachAssnManager.createBulkDocumentCategoryAssociationForCollectionCase(attachmentIdToFileName, collectionCaseId, GeneralConstants.DOCUMENT_TYPE_OTHERS);
        Test.stopTest();

        System.assertEquals(1, categoryAttachmentAssociationDBStubInstance.forInsertSObjects.Size());
    }

    @isTest
    private static void createCollectionsDocumentCategoryAssociationByAttachmentIdTestMethod(){
        Id attachmentId = TestUtility.getFakeId(Attachment.getSObjectType());
        Id documentCategoryId = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());
        Id collectionCaseId = TestUtility.getFakeId(Collection_Case__c.getSObjectType());

        String documentType = GeneralConstants.DOCUMENT_TYPE_EXPERIAN_BUSINESS_REPORT;

        Collection_Case__c collectionCase = new Collection_Case__c();
        collectionCase.Id = collectionCaseId;

        Attachment attachmentObj = new Attachment();
        attachmentObj.Body = Blob.valueOf('Dummy File Body');
        attachmentObj.Name = 'name.pdf';
        attachmentObj.parentId = collectionCaseId;
        attachmentObj.Id = attachmentId;

        clcommon__Document_Category__c documentCategoryAssociationByContentVersionId = new clcommon__Document_Category__c();
        documentCategoryAssociationByContentVersionId.clcommon__Category_Name__c = documentType;
        documentCategoryAssociationByContentVersionId.Collection_Case__c = collectionCaseId;
        documentCategoryAssociationByContentVersionId.Id = documentCategoryId;

        DBManagerTestsStub documentCategoryDBStubInstance = new DBManagerTestsStub();
        documentCategoryDBStubInstance.genericReturnObject = new List<clcommon__Document_Category__c> {documentCategoryAssociationByContentVersionId};
        CategoryAttachAssnManager.documentCategoryDBInstance = (DocumentCategoryDB) Test.createStub(DocumentCategoryDB.class, documentCategoryDBStubInstance);

        DBManagerTestsStub categoryAttachmentAssociationDBStubInstance = new DBManagerTestsStub();
        CategoryAttachAssnManager.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, categoryAttachmentAssociationDBStubInstance);

        Map<Id, Attachment> accountIdToAttachment = new Map<Id, Attachment>();
        accountIdToAttachment.put(attachmentObj.parentId, attachmentObj);

        clcommon__Document_Definition__c docDef = new clcommon__Document_Definition__c();
        docDef.Name = documentType;
        docDef.clcommon__Active__c = true;
        docDef.Id = TestUtility.getFakeId(clcommon__Document_Definition__c.getSObjectType());

        Test.startTest();
            CategoryAttachAssnManager.createCollectionsDocumentCategoryAssociationByAttachmentId(accountIdToAttachment, documentType);
        Test.stopTest();

        System.assert(attachmentObj != Null);
        System.assertEquals(True, docDef.clcommon__Active__c);
    }
}