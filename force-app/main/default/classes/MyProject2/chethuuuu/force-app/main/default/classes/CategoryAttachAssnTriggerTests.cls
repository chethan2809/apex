@isTest
private class CategoryAttachAssnTriggerTests {

    @isTest
    private static Void categoryAttachmentInsertUpdateDelete(){
        clcommon__Document_Category__c doc = new clcommon__Document_Category__c();
        doc.clcommon__Category_Name__c ='doc1';
        insert doc;

        clcommon__Category_Attachment_Association__c category = new clcommon__Category_Attachment_Association__c();
        category.Name = 'Test';
        category.clcommon__Document_Category__c = doc.id;

        Exception ex;
        Test.startTest();
        try {
            insert category;
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        category.Name = 'User';
        update category;

        List<clcommon__Category_Attachment_Association__c> categoryAttachmentListUpdated = [
            SELECT Id, Name, clcommon__Document_Category__c
            FROM clcommon__Category_Attachment_Association__c
        ];

        System.assert(category.Id != null);
        System.assertEquals(1, categoryAttachmentListUpdated.size());
        System.assertEquals('User', categoryAttachmentListUpdated[0].Name);

        List<clcommon__Category_Attachment_Association__c> categoryAttachmentListForDelete = [
            SELECT Id, Name, clcommon__Document_Category__c
            FROM clcommon__Category_Attachment_Association__c
        ];

        delete categoryAttachmentListForDelete;

        List<clcommon__Category_Attachment_Association__c> categoryAttachmentListDeleted = [
            SELECT Id, Name, clcommon__Document_Category__c
            FROM clcommon__Category_Attachment_Association__c
        ];

        System.assertEquals(0, categoryAttachmentListDeleted.size());
    }
}