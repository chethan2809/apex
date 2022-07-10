@isTest(isParallel=true)
private class CategoryAttachmentAssociationDBTests {

    private static CategoryAttachmentAssociationDB categoryAttachmentAssociationDBInstance = new CategoryAttachmentAssociationDB();

    @isTest
    private static void categoryAttachmentAssociationsByIds() {
        Id categoryAssociationId = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());
        Set<Id> categoryAssociationIds = new Set<Id>();
        categoryAssociationIds.add(categoryAssociationId);

        Test.startTest();
            List<clcommon__Category_Attachment_Association__c> categoryAttachmentAssociationsList = categoryAttachmentAssociationDBInstance.getCategoryAttachmentAssociationsByIds(categoryAssociationIds);
        Test.stopTest();

        System.assert(categoryAttachmentAssociationsList != null);
        System.assert(categoryAttachmentAssociationsList.isEmpty());
    }

    @isTest
    private static void categoryAttachmentAssociationsByAttachmentIds() {
        Id attachmentId = TestUtility.getFakeId(Attachment.getSObjectType());
        Set<Id> attachmentIds = new Set<Id>();
        attachmentIds.add(attachmentId);

        Test.startTest();
            List<clcommon__Category_Attachment_Association__c> categoryAttachmentAssociationsList = categoryAttachmentAssociationDBInstance.getCategoryAttachmentAssociationsByAttachmentIds(attachmentIds);
        Test.stopTest();

        System.assert(categoryAttachmentAssociationsList != null);
        System.assert(categoryAttachmentAssociationsList.isEmpty());
    }
}