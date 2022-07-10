@isTest
private class CollectionCaseTriggerHandlerTests {
    @isTest
    private static void afterInsert(){
        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        Collection_Case__c collectionCase = new Collection_Case__c();
        collectionCase.Id = TestUtility.getFakeId(Collection_Case__c.getSObjectType());
        collectionCase.Contract_Number__c = 'LAI0000002';
        collectionCase.CL_Contract_Id__c = testExternalId;
        collectionCase.Account__c = TestUtility.getFakeId(Account.getSObjectType());

        Map<Id, Collection_Case__c> newCollectionLoanAccountMap = new Map<Id, Collection_Case__c>();
        newCollectionLoanAccountMap.put(collectionCase.Id, collectionCase);

        clcommon__Document_Definition__c documentDefinition = new clcommon__Document_Definition__c();
        documentDefinition.Name = GeneralConstants.DOCUMENT_TYPE_COLLECTIONS;
        documentDefinition.Document_Category__c = 'Collection';
        documentDefinition.Id = TestUtility.getFakeId(clcommon__Document_Definition__c.getSObjectType());
        documentDefinition.clcommon__Show_In_Portal__c = 'DELIVERED';
        documentDefinition.clcommon__Active__c = true;

        DBManagerTestsStub documentDefinitionDBStubInstance = new DBManagerTestsStub();
        documentDefinitionDBStubInstance.genericReturnObject = new List<clcommon__Document_Definition__c> {documentDefinition};
        OriginationHelper.documentDefinitionDBInstance = (DocumentDefinitionDB) Test.createStub(DocumentDefinitionDB.class, documentDefinitionDBStubInstance);

        clcommon__Document_Category__c documentCategory = new clcommon__Document_Category__c();
        documentCategory.clcommon__Category_Name__c = documentDefinition.Name;
        documentCategory.clcommon__Show_In_Portal__c = documentDefinition.clcommon__Show_In_Portal__c;
        documentCategory.clcommon__Document_Definition__c = documentDefinition.Id;
        documentCategory.Id = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());
        documentCategory.Collection_Case__c = collectionCase.Id;

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        CollectionCaseTriggerHandler.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub documentCategoryDBStubInstance = new DBManagerTestsStub();
        documentCategoryDBStubInstance.genericReturnObject = new List<clcommon__Document_Category__c>{documentCategory};
        CollectionCaseTriggerHandler.documentCategoryDBInstance = (DocumentCategoryDB) Test.createStub(DocumentCategoryDB.class, documentCategoryDBStubInstance);

        Test.startTest();
            new CollectionCaseTriggerHandler().afterInsert(newCollectionLoanAccountMap);
        Test.stopTest();

        System.assert(collectionCase.Contract_Number__c != null);
    }

    @isTest
    private static void beforeUpdateTest() {

        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Collection_Case__c oldCollectionCase = new Collection_Case__c();
        oldCollectionCase.Id = TestUtility.getFakeId(Collection_Case__c.getSObjectType());
        oldCollectionCase.Contract_Number__c = 'LAI0000002';
        oldCollectionCase.CL_Contract_Id__c = testExternalId;
        oldCollectionCase.Account__c = TestUtility.getFakeId(Account.getSObjectType());
        Map<Id, Collection_Case__c> oldCollectionCaseMap = new Map<Id, Collection_Case__c> ();
        oldCollectionCaseMap.put(oldCollectionCase.Id, oldCollectionCase);

        Collection_Case__c collectionCase = new Collection_Case__c();
        collectionCase.Id = oldCollectionCase.Id;
        collectionCase.Contract_Number__c = 'LAI0000002';
        collectionCase.CL_Contract_Id__c = testExternalId;
        collectionCase.Account__c = oldCollectionCase.Account__c;
        Map<Id, Collection_Case__c> collectionCaseMap = new Map<Id, Collection_Case__c> ();
        collectionCaseMap.put(collectionCase.Id, collectionCase);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        CollectionCaseTriggerHandler.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Test.startTest();
            new CollectionCaseTriggerHandler().beforeUpdate(collectionCaseMap, oldCollectionCaseMap);
        Test.stopTest();

        System.assert(collectionCase.Contract_Number__c != null);
    }

    @isTest
    private static void afterUpdateTest() {

        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Collection_Case__c oldCollectionCase = new Collection_Case__c();
        oldCollectionCase.Id = TestUtility.getFakeId(Collection_Case__c.getSObjectType());
        oldCollectionCase.Contract_Number__c = 'LAI0000002';
        oldCollectionCase.CL_Contract_Id__c = testExternalId;
        oldCollectionCase.Account__c = TestUtility.getFakeId(Account.getSObjectType());
        Map<Id, Collection_Case__c> oldCollectionCaseMap = new Map<Id, Collection_Case__c> ();
        oldCollectionCaseMap.put(oldCollectionCase.Id, oldCollectionCase);

        Collection_Case__c collectionCase = new Collection_Case__c();
        collectionCase.Id = oldCollectionCase.Id;
        collectionCase.Contract_Number__c = 'LAI0000002';
        collectionCase.CL_Contract_Id__c = testExternalId;
        collectionCase.Account__c = oldCollectionCase.Account__c;
        Map<Id, Collection_Case__c> collectionCaseMap = new Map<Id, Collection_Case__c> ();
        collectionCaseMap.put(collectionCase.Id, collectionCase);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        CollectionCaseTriggerHandler.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Test.startTest();
            new CollectionCaseTriggerHandler().afterUpdate(collectionCaseMap, oldCollectionCaseMap);
        Test.stopTest();

        System.assert(collectionCase.Contract_Number__c != null);
    }
}