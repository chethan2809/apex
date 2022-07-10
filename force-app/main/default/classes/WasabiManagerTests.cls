@isTest(isParallel=true)
private class WasabiManagerTests {

    @isTest
    private static void sendToWasabiForAttachmentType() {

        Attachment attachmentObj = new Attachment();
        attachmentObj.Id = TestUtility.getFakeId(Attachment.getSObjectType());
        attachmentObj.Name = 'Test File.txt';
        attachmentObj.Body = Blob.valueOf('Test File');

        DBManagerTestsStub attachmentStubInstance = new DBManagerTestsStub();
        attachmentStubInstance.genericReturnObject = new List<Attachment> {attachmentObj};
        WasabiManager.attachmentDBInstance = (AttachmentDB) Test.createStub(AttachmentDB.class, attachmentStubInstance);

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

        DBManagerTestsStub catAttAssociationSStubInstance = new DBManagerTestsStub();
        WasabiManager.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, catAttAssociationSStubInstance);

        Map<Id, clcommon__Category_Attachment_Association__c > catAttAssociationMap = new Map<Id, clcommon__Category_Attachment_Association__c >();
        catAttAssociationMap.put(attachmentObj.Id, catAttAssociation);

        CategoryAttachAssns.RequestType requestType = CategoryAttachAssns.RequestType.INSERT_FILE;

        Wasabi_Setting__mdt wasabiSetting = new Wasabi_Setting__mdt();
        wasabiSetting.Bucket_Name__c = 'Dummy Bucket';
        wasabiSetting.Base_Path__c = 'Dummy Path';
        CustomMetaDataHelper.defaultWasabiSetting = wasabiSetting;

        System.Test.setMock(HttpCalloutMock.class, new WasabiHTTPCallOutMocks.WasabiSendDocumentSuccessResponse());

        Test.startTest();
            WasabiManager.sendToWasabi(catAttAssociationMap, requestType);
        Test.stopTest();

        System.assertEquals(1, catAttAssociationSStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void sendToWasabiForAttachmentTypeWithAccount() {
        Attachment attachmentObj = new Attachment();
        attachmentObj.Id = TestUtility.getFakeId(Attachment.getSObjectType());
        attachmentObj.Name = 'Test File.txt';
        attachmentObj.Body = Blob.valueOf('Test File');

        DBManagerTestsStub attachmentStubInstance = new DBManagerTestsStub();
        attachmentStubInstance.genericReturnObject = new List<Attachment> {attachmentObj};
        WasabiManager.attachmentDBInstance = (AttachmentDB) Test.createStub(AttachmentDB.class, attachmentStubInstance);

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountRecord.Name = 'Account Tets';

        clcommon__Document_Category__c docCategory = new clcommon__Document_Category__c();
        docCategory.clcommon__Category_Name__c = 'Bank Statement';
        docCategory.genesis__Application__r = application;
        docCategory.clcommon__Account__r = accountRecord;

        clcommon__Category_Attachment_Association__c catAttAssociation = (clcommon__Category_Attachment_Association__c) JSON.deserialize(
            '{ "Name" : "Test-NameDummy"}' , clcommon__Category_Attachment_Association__c.class
        );
        catAttAssociation.Id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());
        catAttAssociation.clcommon__Document_Category__r = docCategory;

        DBManagerTestsStub catAttAssociationSStubInstance = new DBManagerTestsStub();
        WasabiManager.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, catAttAssociationSStubInstance);

        Map<Id, clcommon__Category_Attachment_Association__c > catAttAssociationMap = new Map<Id, clcommon__Category_Attachment_Association__c >();
        catAttAssociationMap.put(attachmentObj.Id, catAttAssociation);

        CategoryAttachAssns.RequestType requestType = CategoryAttachAssns.RequestType.INSERT_FILE;

        Wasabi_Setting__mdt wasabiSetting = new Wasabi_Setting__mdt();
        wasabiSetting.Bucket_Name__c = 'Dummy Bucket';
        wasabiSetting.Base_Path__c = 'Dummy Path';
        CustomMetaDataHelper.defaultWasabiSetting = wasabiSetting;

        System.Test.setMock(HttpCalloutMock.class, new WasabiHTTPCallOutMocks.WasabiSendDocumentSuccessResponse());

        Test.startTest();
            WasabiManager.sendToWasabi(catAttAssociationMap, requestType);
        Test.stopTest();

        System.assertEquals(1, catAttAssociationSStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void sendToWasabiForAttachmentTypeExceptionCheck() {

        Wasabi_Setting__mdt wasabiSetting = new Wasabi_Setting__mdt();
        wasabiSetting.Bucket_Name__c = 'Dummy Bucket';
        wasabiSetting.Base_Path__c = 'Dummy Path';
        CustomMetaDataHelper.defaultWasabiSetting = wasabiSetting;

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        WasabiManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Attachment attachmentObj = new Attachment();
        attachmentObj.Id = TestUtility.getFakeId(Attachment.getSObjectType());
        attachmentObj.Name = 'Test File.txt';
        attachmentObj.Body = Blob.valueOf('Test File');

        DBManagerTestsStub attachmentStubInstance = new DBManagerTestsStub();
        attachmentStubInstance.genericReturnObject = new List<Attachment> {attachmentObj};
        WasabiManager.attachmentDBInstance = (AttachmentDB) Test.createStub(AttachmentDB.class, attachmentStubInstance);

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

        DBManagerTestsStub catAttAssociationSStubInstance = new DBManagerTestsStub();
        WasabiManager.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, catAttAssociationSStubInstance);

        Map<Id, clcommon__Category_Attachment_Association__c > catAttAssociationMap = new Map<Id, clcommon__Category_Attachment_Association__c >();
        catAttAssociationMap.put(attachmentObj.Id, catAttAssociation);

        CategoryAttachAssns.RequestType requestType = CategoryAttachAssns.RequestType.INSERT_FILE;

        Test.startTest();
            WasabiManager.sendToWasabi(catAttAssociationMap, requestType);
        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void sendToWasabiForAttachmentTypeNoRecord() {
        Attachment attachmentObj = new Attachment();
        attachmentObj.Id = TestUtility.getFakeId(Attachment.getSObjectType());
        attachmentObj.Name = 'Test File.txt';
        attachmentObj.Body = Blob.valueOf('Test File');

        DBManagerTestsStub attachmentStubInstance = new DBManagerTestsStub();
        attachmentStubInstance.genericReturnObject = new List<Attachment> {attachmentObj};
        WasabiManager.attachmentDBInstance = (AttachmentDB) Test.createStub(AttachmentDB.class, attachmentStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        WasabiManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

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

        Map<Id, clcommon__Category_Attachment_Association__c > catAttAssociationMap = new Map<Id, clcommon__Category_Attachment_Association__c >();
        catAttAssociationMap.put(attachmentObj.Id, catAttAssociation);

        CategoryAttachAssns.RequestType requestType = CategoryAttachAssns.RequestType.INSERT_FILE;

        Wasabi_Setting__mdt wasabiSetting = new Wasabi_Setting__mdt();
        wasabiSetting.Bucket_Name__c = 'Dummy Bucket';
        wasabiSetting.Base_Path__c = 'Dummy Path';
        CustomMetaDataHelper.defaultWasabiSetting = wasabiSetting;

        System.Test.setMock(HttpCalloutMock.class, new WasabiHTTPCallOutMocks.WasabiSendDocumentSuccessResponse());

        Test.startTest();
            WasabiManager.sendToWasabi(catAttAssociationMap, requestType);
        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void deleteFilesFromWasabi() {

        Wasabi_Setting__mdt wasabiSetting = new Wasabi_Setting__mdt();
        wasabiSetting.Bucket_Name__c = 'Dummy Bucket';
        wasabiSetting.Base_Path__c = 'Dummy Path';
        CustomMetaDataHelper.defaultWasabiSetting = wasabiSetting;

        clcommon__Category_Attachment_Association__c catAttAssociation = new clcommon__Category_Attachment_Association__c();
        catAttAssociation.Id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());
        catAttAssociation.Wasabi_Link__c = 'DummyLink';

        Map<Id, clcommon__Category_Attachment_Association__c > catAttAssociationMap = new Map<Id, clcommon__Category_Attachment_Association__c >();
        catAttAssociationMap.put(catAttAssociation.Id, catAttAssociation);

        CategoryAttachAssns.RequestType requestType = CategoryAttachAssns.RequestType.DELETE_FILE;

        System.Test.setMock(HttpCalloutMock.class, new WasabiHTTPCallOutMocks.WasabiSendDocumentSuccessResponse());

        Test.startTest();
            WasabiManager.sendToWasabi(catAttAssociationMap, requestType);
        Test.stopTest();

        System.assertEquals('DummyLink', catAttAssociation.Wasabi_Link__c);
    }

    @isTest
    private static void deleteFilesFromWasabiException() {

        Wasabi_Setting__mdt wasabiSetting = new Wasabi_Setting__mdt();
        wasabiSetting.Bucket_Name__c = 'Dummy Bucket';
        wasabiSetting.Base_Path__c = 'Dummy Path';
        CustomMetaDataHelper.defaultWasabiSetting = wasabiSetting;

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        WasabiManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        clcommon__Category_Attachment_Association__c catAttAssociation = new clcommon__Category_Attachment_Association__c();
        catAttAssociation.Id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());
        catAttAssociation.Wasabi_Link__c = 'DummyLink';

        Map<Id, clcommon__Category_Attachment_Association__c > catAttAssociationMap = new Map<Id, clcommon__Category_Attachment_Association__c >();
        catAttAssociationMap.put(catAttAssociation.Id, catAttAssociation);

        CategoryAttachAssns.RequestType requestType = CategoryAttachAssns.RequestType.DELETE_FILE;

        Test.startTest();
            WasabiManager.sendToWasabi(catAttAssociationMap, requestType);
        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void sendToWasabiForContentVersionType() {

        Wasabi_Setting__mdt wasabiSetting = new Wasabi_Setting__mdt();
        wasabiSetting.Bucket_Name__c = 'Dummy Bucket';
        wasabiSetting.Base_Path__c = 'Dummy Path';
        CustomMetaDataHelper.defaultWasabiSetting = wasabiSetting;

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Test Document';
        contentVersion.Id = TestUtility.getFakeId(ContentVersion.getSObjectType());
        contentVersion.VersionData = Blob.valueOf('Test Content');

        DBManagerTestsStub contentVersionStubInstance = new DBManagerTestsStub();
        contentVersionStubInstance.genericReturnObject = new List<ContentVersion> {ContentVersion};
        WasabiManager.contentVersionDBInstance = (ContentVersionDB) Test.createStub(ContentVersionDB.class, contentVersionStubInstance);

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

        DBManagerTestsStub catAttAssociationSStubInstance = new DBManagerTestsStub();
        WasabiManager.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, catAttAssociationSStubInstance);

        Map<Id, clcommon__Category_Attachment_Association__c > catAttAssociationMap = new Map<Id, clcommon__Category_Attachment_Association__c >();
        catAttAssociationMap.put(contentVersion.Id, catAttAssociation);

        CategoryAttachAssns.RequestType requestType = CategoryAttachAssns.RequestType.INSERT_FILE;

        System.Test.setMock(HttpCalloutMock.class, new WasabiHTTPCallOutMocks.WasabiSendDocumentSuccessResponse());

        Test.startTest();
            WasabiManager.sendToWasabi(catAttAssociationMap, requestType);
        Test.stopTest();

        System.assertEquals(1, catAttAssociationSStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void sendToWasabiForContentVersionTypeWithAccount() {
        Wasabi_Setting__mdt wasabiSetting = new Wasabi_Setting__mdt();
        wasabiSetting.Bucket_Name__c = 'Dummy Bucket';
        wasabiSetting.Base_Path__c = 'Dummy Path';
        CustomMetaDataHelper.defaultWasabiSetting = wasabiSetting;

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Test Document';
        contentVersion.Id = TestUtility.getFakeId(ContentVersion.getSObjectType());
        contentVersion.VersionData = Blob.valueOf('Test Content');

        DBManagerTestsStub contentVersionStubInstance = new DBManagerTestsStub();
        contentVersionStubInstance.genericReturnObject = new List<ContentVersion> {ContentVersion};
        WasabiManager.contentVersionDBInstance = (ContentVersionDB) Test.createStub(ContentVersionDB.class, contentVersionStubInstance);

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountRecord.Name = 'Account Tets';

        clcommon__Document_Category__c docCategory = new clcommon__Document_Category__c();
        docCategory.clcommon__Category_Name__c = 'Bank Statement';
        docCategory.genesis__Application__r = application;
        docCategory.clcommon__Account__r = accountRecord;

        clcommon__Category_Attachment_Association__c catAttAssociation = (clcommon__Category_Attachment_Association__c) JSON.deserialize(
            '{ "Name" : "Test-NameDummy"}' , clcommon__Category_Attachment_Association__c.class
        );
        catAttAssociation.Id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());
        catAttAssociation.clcommon__Document_Category__r = docCategory;

        DBManagerTestsStub catAttAssociationSStubInstance = new DBManagerTestsStub();
        WasabiManager.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, catAttAssociationSStubInstance);

        Map<Id, clcommon__Category_Attachment_Association__c > catAttAssociationMap = new Map<Id, clcommon__Category_Attachment_Association__c >();
        catAttAssociationMap.put(contentVersion.Id, catAttAssociation);

        CategoryAttachAssns.RequestType requestType = CategoryAttachAssns.RequestType.INSERT_FILE;

        System.Test.setMock(HttpCalloutMock.class, new WasabiHTTPCallOutMocks.WasabiSendDocumentSuccessResponse());

        Test.startTest();
            WasabiManager.sendToWasabi(catAttAssociationMap, requestType);
        Test.stopTest();

        System.assertEquals(1, catAttAssociationSStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void sendToWasabiForContentVersionTypeExceptionCheck() {

        Wasabi_Setting__mdt wasabiSetting = new Wasabi_Setting__mdt();
        wasabiSetting.Bucket_Name__c = 'Dummy Bucket';
        wasabiSetting.Base_Path__c = 'Dummy Path';
        CustomMetaDataHelper.defaultWasabiSetting = wasabiSetting;

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        WasabiManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Test Document';
        contentVersion.Id = TestUtility.getFakeId(ContentVersion.getSObjectType());
        contentVersion.VersionData = Blob.valueOf('Test Content');

        DBManagerTestsStub contentVersionStubInstance = new DBManagerTestsStub();
        contentVersionStubInstance.genericReturnObject = new List<ContentVersion> {ContentVersion};
        WasabiManager.contentVersionDBInstance = (ContentVersionDB) Test.createStub(ContentVersionDB.class, contentVersionStubInstance);

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

        DBManagerTestsStub catAttAssociationSStubInstance = new DBManagerTestsStub();
        WasabiManager.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, catAttAssociationSStubInstance);

        Map<Id, clcommon__Category_Attachment_Association__c > catAttAssociationMap = new Map<Id, clcommon__Category_Attachment_Association__c >();
        catAttAssociationMap.put(contentVersion.Id, catAttAssociation);

        CategoryAttachAssns.RequestType requestType = CategoryAttachAssns.RequestType.INSERT_FILE;

        Test.startTest();
            WasabiManager.sendToWasabi(catAttAssociationMap, requestType);
        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void uploadUCCFilesToWasabi() {

        Wasabi_Setting__mdt wasabiSetting = new Wasabi_Setting__mdt();
        wasabiSetting.Bucket_Name__c = 'Dummy Bucket';
        wasabiSetting.Base_Path__c = 'Dummy Path';
        CustomMetaDataHelper.defaultWasabiSetting = wasabiSetting;

        Account accountRecord = new Account();
        accountRecord.Name = 'Test Account';

        UCC_Filing_Attachment__c uccFilingAttachment =  new UCC_Filing_Attachment__c();
        uccFilingAttachment.Account__c = accountRecord.Id;
        uccFilingAttachment.Account__r = accountRecord;

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        WasabiManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        String fileName = 'wasabi file';
        Blob fileBody = blob.valueOf('blob file');

        Test.startTest();
            WasabiManager.uploadUCCFilesToWasabi(uccFilingAttachment, fileName, fileBody);
        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }

}