@isTest(isParallel=true)
private class DocumentCategoriesTests {

    @isTest
    private static void createDocumentCategory() {
        Id documentDefinitionId = TestUtility.getFakeId(clcommon__Document_Definition__c.getSObjectType());
        clcommon__Document_Definition__c documentDefinition = new clcommon__Document_Definition__c();
        documentDefinition.Name = 'Test Document';
        documentDefinition.Id = documentDefinitionId;
        documentDefinition.clcommon__Show_In_Portal__c = 'DELIVERED';

        Test.startTest();
            clcommon__Document_Category__c documentCategoryObject = DocumentCategories.createDocumentCategory(documentDefinition);
        Test.stopTest();

        System.assert(documentCategoryObject != null);
        System.assertEquals(documentDefinitionId, documentCategoryObject.clcommon__Document_Definition__c);
        System.assertEquals('Test Document', documentCategoryObject.clcommon__Category_Name__c);
        System.assertEquals('DELIVERED', documentCategoryObject.clcommon__Show_In_Portal__c);
    }

    @isTest
    private static void getCategoryAttachmentListByApplicationId() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        clcommon__Document_Definition__c documentDefinition = new clcommon__Document_Definition__c();
        documentDefinition.Id = TestUtility.getFakeId(clcommon__Document_Definition__c.getSObjectType());
        documentDefinition.Name = 'Bank Statements';
        documentDefinition.clcommon__Show_In_Portal__c = 'DELIVERED';
        documentDefinition.clcommon__Active__c = true;

        clcommon__Category_Attachment_Association__c categoryAttachmentOne = new clcommon__Category_Attachment_Association__c();
        categoryAttachmentOne.Id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());
        categoryAttachmentOne.Name = 'Bank Statements';
        categoryAttachmentOne.Wasabi_Link__c = 'happiest-minds-test/APP-0000000102/Bank_Statements/428551jul.pdf';
        categoryAttachmentOne.Ocrolus_Document_Status__c = 'VERIFYING';
        categoryAttachmentOne.Ocrolus_Uploaded_PK__c = '26509187';

        clcommon__Category_Attachment_Association__c categoryAttachmentTwo = new clcommon__Category_Attachment_Association__c();
        categoryAttachmentTwo.Id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());
        categoryAttachmentTwo.Name = 'Bank Statements';
        categoryAttachmentTwo.Wasabi_Link__c = 'happiest-minds-test/APP-0000000102/Bank_Statements/428551jul.pdf';
        categoryAttachmentTwo.Ocrolus_Document_Status__c = 'VERIFYING';
        categoryAttachmentTwo.Ocrolus_Uploaded_PK__c = '26509187';

        List<clcommon__Category_Attachment_Association__c> categoryAttachmentList = new List<clcommon__Category_Attachment_Association__c> {
            categoryAttachmentOne, categoryAttachmentTwo
        };
        String jsonCategoryAttachmentList = '{"totalSize" : 2, "done" : true, "records" : ' + JSON.serialize(categoryAttachmentList, false) + '}';

        clcommon__Document_Category__c documentCategory = (clcommon__Document_Category__c) JSON.deserialize(
            '{"clcommon__DocCat_Attachment_Associations__r" : ' + jsonCategoryAttachmentList + '}', clcommon__Document_Category__c.class);
        documentCategory.Id = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());
        documentCategory.clcommon__Category_Name__c = documentDefinition.Name;
        documentCategory.clcommon__Show_In_Portal__c = documentDefinition.clcommon__Show_In_Portal__c;
        documentCategory.clcommon__Document_Definition__c = documentDefinition.Id;
        documentCategory.genesis__Application__c = application.Id;

        Test.startTest();
            Map<Id, List<clcommon__Category_Attachment_Association__c>> applicationIdToCategoryAttachmentList =
                DocumentCategories.getCategoryAttachmentListByApplicationId(new List<clcommon__Document_Category__c> {documentCategory});
        Test.stopTest();

        System.assert(applicationIdToCategoryAttachmentList.containsKey(application.Id));
        System.assertEquals(2, applicationIdToCategoryAttachmentList.get(application.Id).size());
    }

    @isTest
    private static void getCategoryAttachmentListByAppIdWhenNoWasabiLinkForAllDocs() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        clcommon__Document_Definition__c documentDefinition = new clcommon__Document_Definition__c();
        documentDefinition.Id = TestUtility.getFakeId(clcommon__Document_Definition__c.getSObjectType());
        documentDefinition.Name = 'Bank Statements';
        documentDefinition.clcommon__Show_In_Portal__c = 'DELIVERED';
        documentDefinition.clcommon__Active__c = true;

        clcommon__Category_Attachment_Association__c categoryAttachment = new clcommon__Category_Attachment_Association__c();
        categoryAttachment.Id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());
        categoryAttachment.Name = 'Bank Statements';
        categoryAttachment.Wasabi_Link__c = null;
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

        Test.startTest();
            Map<Id, List<clcommon__Category_Attachment_Association__c>> applicationIdToCategoryAttachmentList =
                DocumentCategories.getCategoryAttachmentListByApplicationId(new List<clcommon__Document_Category__c> {documentCategory});
        Test.stopTest();

        System.assert(applicationIdToCategoryAttachmentList.isEmpty());
    }

    @isTest
    private static void getCategoryAttachmentListByAppIdWhenNoWasabiLinkForPartialDocs() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        clcommon__Document_Definition__c documentDefinition = new clcommon__Document_Definition__c();
        documentDefinition.Id = TestUtility.getFakeId(clcommon__Document_Definition__c.getSObjectType());
        documentDefinition.Name = 'Bank Statements';
        documentDefinition.clcommon__Show_In_Portal__c = 'DELIVERED';
        documentDefinition.clcommon__Active__c = true;

        clcommon__Category_Attachment_Association__c categoryAttachmentOne = new clcommon__Category_Attachment_Association__c();
        categoryAttachmentOne.Id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());
        categoryAttachmentOne.Name = 'Bank Statements';
        categoryAttachmentOne.Wasabi_Link__c = 'happiest-minds-test/APP-0000000102/Bank_Statements/428551jul.pdf';
        categoryAttachmentOne.Ocrolus_Document_Status__c = 'VERIFYING';
        categoryAttachmentOne.Ocrolus_Uploaded_PK__c = '26509187';

        clcommon__Category_Attachment_Association__c categoryAttachmentTwo = new clcommon__Category_Attachment_Association__c();
        categoryAttachmentTwo.Id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());
        categoryAttachmentTwo.Name = 'Bank Statements';
        categoryAttachmentTwo.Wasabi_Link__c = null;
        categoryAttachmentTwo.Ocrolus_Document_Status__c = 'VERIFYING';
        categoryAttachmentTwo.Ocrolus_Uploaded_PK__c = '26509187';

        List<clcommon__Category_Attachment_Association__c> categoryAttachmentList = new List<clcommon__Category_Attachment_Association__c> {
            categoryAttachmentOne, categoryAttachmentTwo
        };
        String jsonCategoryAttachmentList = '{"totalSize" : 2, "done" : true, "records" : ' + JSON.serialize(categoryAttachmentList, false) + '}';

        clcommon__Document_Category__c documentCategory = (clcommon__Document_Category__c) JSON.deserialize(
            '{"clcommon__DocCat_Attachment_Associations__r" : ' + jsonCategoryAttachmentList + '}', clcommon__Document_Category__c.class);
        documentCategory.Id = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());
        documentCategory.clcommon__Category_Name__c = documentDefinition.Name;
        documentCategory.clcommon__Show_In_Portal__c = documentDefinition.clcommon__Show_In_Portal__c;
        documentCategory.clcommon__Document_Definition__c = documentDefinition.Id;
        documentCategory.genesis__Application__c = application.Id;

        Test.startTest();
            Map<Id, List<clcommon__Category_Attachment_Association__c>> applicationIdToCategoryAttachmentList =
                    DocumentCategories.getCategoryAttachmentListByApplicationId(new List<clcommon__Document_Category__c> {documentCategory});
        Test.stopTest();

        System.assert(applicationIdToCategoryAttachmentList.isEmpty());
    }

    @isTest
    private static void getCategoryAttachmentListByApplicationIdWhenNoDocuments() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        clcommon__Document_Definition__c documentDefinition = new clcommon__Document_Definition__c();
        documentDefinition.Id = TestUtility.getFakeId(clcommon__Document_Definition__c.getSObjectType());
        documentDefinition.Name = 'Bank Statements';
        documentDefinition.clcommon__Show_In_Portal__c = 'DELIVERED';
        documentDefinition.clcommon__Active__c = true;

        List<clcommon__Category_Attachment_Association__c> categoryAttachmentList = new List<clcommon__Category_Attachment_Association__c>();
        String jsonCategoryAttachmentList = '{"totalSize" : 0, "done" : true, "records" : ' + JSON.serialize(categoryAttachmentList, false) + '}';

        clcommon__Document_Category__c documentCategory = (clcommon__Document_Category__c) JSON.deserialize(
            '{"clcommon__DocCat_Attachment_Associations__r" : ' + jsonCategoryAttachmentList + '}', clcommon__Document_Category__c.class);
        documentCategory.Id = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());
        documentCategory.clcommon__Category_Name__c = documentDefinition.Name;
        documentCategory.clcommon__Show_In_Portal__c = documentDefinition.clcommon__Show_In_Portal__c;
        documentCategory.clcommon__Document_Definition__c = documentDefinition.Id;
        documentCategory.genesis__Application__c = application.Id;

        Test.startTest();
            Map<Id, List<clcommon__Category_Attachment_Association__c>> applicationIdToCategoryAttachmentList =
                DocumentCategories.getCategoryAttachmentListByApplicationId(new List<clcommon__Document_Category__c> {documentCategory});
        Test.stopTest();

        System.assert(applicationIdToCategoryAttachmentList.isEmpty());
    }
}