@isTest(isParallel=true)
private class DocumentCategoryDBTests {

    private static DocumentCategoryDB documentCategoryDBInstance = new DocumentCategoryDB();

    @isTest
    private static void getDocumentCategoriesByIds() {
        Id categoryId = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());
        Set<Id> categoryIds = new Set<Id>();
        categoryIds.add(categoryId);

        Test.startTest();
            List<clcommon__Document_Category__c> documentCategoryList = documentCategoryDBInstance.getDocumentCategoriesByIds(categoryIds);
        Test.stopTest();

        System.assert(documentCategoryList != null);
        System.assert(documentCategoryList.isEmpty());
    }

    @isTest
    private static void getDocumentCategoriesByApplicationIdsAndName() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(applicationId);

        Test.startTest();
            List<clcommon__Document_Category__c> documentCategoryList = documentCategoryDBInstance.getDocumentCategoriesByApplicationIdsAndName(applicationIds, 'Loan Agreement');
        Test.stopTest();

        System.assert(documentCategoryList != null);
        System.assert(documentCategoryList.isEmpty());
    }

    @isTest
    private static void getDocumentCategoriesAndItsAttachmentsByAccountIdsAndName() {
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(accountId);

        Test.startTest();
            List<clcommon__Document_Category__c> documentCategoryList = documentCategoryDBInstance.getDocumentCategoriesAndItsAttachmentsByAccountIdsAndName(accountIds, 'Loan Agreement');
        Test.stopTest();

        System.assert(documentCategoryList != null);
        System.assert(documentCategoryList.isEmpty());
    }

    @isTest
    private static void getDocumentCategoriesByApplicationAndCollectionsIdsAndNames() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Id collectionIds = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Set<Id> applicationOrCollectionIds = new Set<Id>();
        applicationOrCollectionIds.add(applicationId);
        applicationOrCollectionIds.add(collectionIds);

        Test.startTest();
            List<clcommon__Document_Category__c> documentCategoryList = documentCategoryDBInstance.getDocumentCategoriesByApplicationAndCollectionsIdsAndNames(applicationOrCollectionIds, new Set<String>{'ID Verification'});
        Test.stopTest();

        System.assert(documentCategoryList != null);
        System.assert(documentCategoryList.isEmpty());
    }

    @isTest
    private static void getDocumentCategoriesAndItsAttachmentByApplicationIdsAndName() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(applicationId);

        Test.startTest();
            List<clcommon__Document_Category__c> documentCategoryList = documentCategoryDBInstance.getDocumentCategoriesAndItsAttachmentByApplicationIdsAndName(applicationIds, 'Loan Agreement');
        Test.stopTest();

        System.assert(documentCategoryList != null);
        System.assert(documentCategoryList.isEmpty());
    }

    @isTest
    private static void getDocumentCategoriesAndItsAttachmentsByCollectionsIdsAndName() {
        Id collectionCaseId = TestUtility.getFakeId(Collection_Case__c.getSObjectType());
        Set<Id> collectionCaseIds = new Set<Id>();
        collectionCaseIds.add(collectionCaseId);

        Test.startTest();
            List<clcommon__Document_Category__c> documentCategoryList = documentCategoryDBInstance.getDocumentCategoriesAndItsAttachmentsByCollectionsIdsAndName(collectionCaseIds, 'Loan Agreement');
        Test.stopTest();

        System.assert(documentCategoryList != null);
        System.assert(documentCategoryList.isEmpty());
    }
}