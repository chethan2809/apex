@isTest(isParallel = true)
private class CategoryAttachAssnsTests {

    @isTest
    private static void createCategoryAttachAssn() {

        Id attachmentId = TestUtility.getFakeId(Attachment.getSObjectType());
        Id documentCategoryId = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());
        String docCategoryName = 'Test Category';
        String wasabiLink = 'Test Wasabi Link';
        String uploadedPk = '1234';
        String documentStatus = 'Test Status';
        String failureMessage = 'Test Message';

        Test.startTest();
            clcommon__Category_Attachment_Association__c categoryAttachAssn = CategoryAttachAssns.createCategoryAttachAssn(docCategoryName, attachmentId, documentCategoryId);
       	    clcommon__Category_Attachment_Association__c categoryAttachAssn1 = CategoryAttachAssns.createCategoryAttachAssn(docCategoryName, attachmentId, documentCategoryId, wasabiLink);
            clcommon__Category_Attachment_Association__c categoryAttachAssn2 = CategoryAttachAssns.setCategoryAttachAssnOcrolusFields(categoryAttachAssn1, uploadedPk, documentStatus, failureMessage);
        Test.stopTest();

        System.assertEquals(docCategoryName, categoryAttachAssn.Name);
    }

    @isTest
    private static void validateBeforeDeletionPass(){
        clcommon__Category_Attachment_Association__c categoryAttach = new clcommon__Category_Attachment_Association__c();
        categoryAttach.id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());
        categoryAttach.Ocrolus_Uploaded_PK__c = '47658';
        categoryAttach.Ocrolus_Document_Status__c = Ocrolus.OCROLUS_DOC_STATUS_VERIFYING;

        Exception ex;

        Test.startTest();
        try {
            CategoryAttachAssns.validateBeforeDeletion(categoryAttach);
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();

        TestUtility.assertException(ex);
        System.assertEquals(ex.getMessage(), 'Document Cannot Be Deleted When Under Ocrolus Verification In Progress');
    }

     @isTest
    private static void validateBeforeDeletionFail(){
        clcommon__Category_Attachment_Association__c categoryAttach = new clcommon__Category_Attachment_Association__c();
        categoryAttach.Id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());
        categoryAttach.Ocrolus_Document_Status__c = Ocrolus.OCROLUS_DOC_STATUS_VERIFYING;

        Exception ex;

        Test.startTest();
        try{
            CategoryAttachAssns.validateBeforeDeletion(categoryAttach);
        } catch(Exception e) {
            ex = e;
        }
        Test.stopTest();

        TestUtility.assertNullException(ex);
        System.assertEquals(null, categoryAttach.Ocrolus_Uploaded_PK__c);
    }
}