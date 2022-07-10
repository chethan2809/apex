@isTest
private class CongaSignDocumentTriggerHandlerTests {

    private static CongaSignDocumentTriggerHandler congaTriggerHandler = new CongaSignDocumentTriggerHandler();

    @isTest
    private static void afterInsertCongaSign() {

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Status__c = Applications.STATUS_NEW_ENTERED;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        CongaSignDocumentTriggerHandler.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        String attachmentId = TestUtility.getFakeId(Attachment.getSObjectType());
        Id documentCategoryId = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());

        clcommon__Category_Attachment_Association__c catAttAssociation = new clcommon__Category_Attachment_Association__c();
        catAttAssociation.Name = 'Experian Business Credit Report';
        catAttAssociation.clcommon__Attachment_Id__c = attachmentId;
        catAttAssociation.clcommon__Document_Category__c = documentCategoryId;
        catAttAssociation.Id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());

        DBManagerTestsStub categoryAttachmentAssociationDBStub = new DBManagerTestsStub();
        categoryAttachmentAssociationDBStub.genericReturnObject = new List<clcommon__Category_Attachment_Association__c>{catAttAssociation};
        CategoryAttachAssnManager.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, categoryAttachmentAssociationDBStub);

        APXT_CongaSign__Transaction__c congaTransaction = new APXT_CongaSign__Transaction__c();
        congaTransaction.Id = TestUtility.getFakeId(APXT_CongaSign__Transaction__c.getSObjectType());
        congaTransaction.Parent_a6t__c = application.Id;
        congaTransaction.Parent_aEH__c = TestUtility.getFakeId(collect__Loan_Account__c.getSObjectType());

        List<APXT_CongaSign__Document__c> congaSignDocumentList = new List<APXT_CongaSign__Document__c>();
        APXT_CongaSign__Document__c congaSignDocument = new APXT_CongaSign__Document__c();
        congaSignDocument.Name = 'Test CongaSign Document';
        congaSignDocument.APXT_CongaSign__Type__c = 'Final';
        congaSignDocument.Id = TestUtility.getFakeId(APXT_CongaSign__Document__c.getSObjectType());
        congaSignDocument.APXT_CongaSign__DocumentOrder__c = 2;
        congaSignDocument.APXT_CongaSign__ContentDocumentId__c = documentCategoryId;
        congaSignDocument.APXT_CongaSign__ContentVersionId__c = TestUtility.getFakeId(ContentVersion.getSObjectType());
        congaSignDocument.APXT_CongaSign__Transaction__c = congaTransaction.Parent_a6t__c;
        congaSignDocumentList.add(congaSignDocument);

        DBManagerTestsStub congaSignDocumentDBStubInstance = new DBManagerTestsStub();
        congaSignDocumentDBStubInstance.genericReturnObject = new List<APXT_CongaSign__Document__c>{congaSignDocument};
        CongaSignDocumentTriggerHandler.congaSignDocumentDBInstance = (CongaSignDocumentDB) Test.createStub(CongaSignDocumentDB.class, congaSignDocumentDBStubInstance);

        Test.startTest();
            congaTriggerHandler.afterInsert(congaSignDocumentList);
        Test.stopTest();

        System.assertEquals(1, categoryAttachmentAssociationDBStub.forInsertSObjects.size());
    }
}