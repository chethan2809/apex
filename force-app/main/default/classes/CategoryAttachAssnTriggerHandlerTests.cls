@isTest
public class CategoryAttachAssnTriggerHandlerTests {

    private static CategoryAttachAssnTriggerHandler catAttachAssnTriggerHandlerInstance = new CategoryAttachAssnTriggerHandler();

    @isTest
    private static void createCategoryAttachAssn() {
        Id attachmentId = TestUtility.getFakeId(Attachment.getSObjectType());
        Id newAttachmentId = TestUtility.getFakeId(Attachment.getSObjectType());
        Id documentCategoryId = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());
        String docCategoryName = 'Test Category';

        CAN_General_Settings__c generalSetting = new CAN_General_Settings__c();
        generalSetting.Id = TestUtility.getFakeId(CAN_General_Settings__c.getSObjectType());
        generalSetting.Delete_Docs_In_Wasabi__c = true;
        CustomSettingsHelper.generalSettings = generalSetting;

        clcommon__Category_Attachment_Association__c categoryAttachAssn = CategoryAttachAssns.createCategoryAttachAssn(docCategoryName, attachmentId, documentCategoryId);
        clcommon__Category_Attachment_Association__c categoryAttachAssn1 = CategoryAttachAssns.createCategoryAttachAssn(docCategoryName, newAttachmentId, documentCategoryId);

        categoryAttachAssn.Id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());
        categoryAttachAssn1.Id = categoryAttachAssn.Id;
        categoryAttachAssn1.Ocrolus_Uploaded_PK__c = '1234789';
        categoryAttachAssn1.Wasabi_Link__c = 'www.test.com';

        Map<Id, clcommon__Category_Attachment_Association__c> categoryAssoMap = new Map<Id, clcommon__Category_Attachment_Association__c>();
        categoryAssoMap.put(categoryAttachAssn.Id, categoryAttachAssn);
        Map<Id, clcommon__Category_Attachment_Association__c> newCategoryAssoMap = new Map<Id, clcommon__Category_Attachment_Association__c>();
        newCategoryAssoMap.put(categoryAttachAssn1.Id, categoryAttachAssn1);
        List<clcommon__Category_Attachment_Association__c> categoryAssoList = new List<clcommon__Category_Attachment_Association__c>();
        categoryAssoList.add(categoryAttachAssn1);

        DBManagerTestsStub insertCatAttAssociationDBStubInstance = new DBManagerTestsStub();
        insertCatAttAssociationDBStubInstance.genericReturnObject = new List<clcommon__Category_Attachment_Association__c> {categoryAttachAssn1};
        CategoryAttachAssnTriggerHandler.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, insertCatAttAssociationDBStubInstance);

        Test.startTest();
            catAttachAssnTriggerHandlerInstance.afterInsert(categoryAssoMap);
            catAttachAssnTriggerHandlerInstance.afterUpdate(newCategoryAssoMap, categoryAssoMap);
            catAttachAssnTriggerHandlerInstance.afterDelete(categoryAssoList);
        Test.stopTest();

        System.assert(categoryAttachAssn != Null);
        System.assertEquals(docCategoryName, categoryAttachAssn.Name);
    }

    @isTest
    private static void beforeDeleteTest(){

        List<clcommon__Category_Attachment_Association__c> categoryAttachList = new List<clcommon__Category_Attachment_Association__c>();

        clcommon__Category_Attachment_Association__c categoryAttachAssn = new clcommon__Category_Attachment_Association__c();
        categoryAttachAssn.Id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());
        categoryAttachList.add(categoryAttachAssn);

        Exception ex;
        Test.startTest();
        try{
            catAttachAssnTriggerHandlerInstance.beforeDelete(categoryAttachList);
        } catch (Exception e){
            ex = e;
        }
        Test.stopTest();

        TestUtility.assertNullException(ex);
    }
}