@isTest
private class CollectionContractTriggerHandlerTests {

    private static CollectionContractTriggerHandler collectionContractTriggerHandlerInstance = new CollectionContractTriggerHandler();

    @isTest
    private static void updateCollectionContractBatch() {
        loan__Loan_Account__c clContract = new loan__Loan_Account__c();
        clContract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        String testExternalId = clContract.Id;

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{clContract};
        CollectionContractTriggerHandler.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        List<collect__Loan_Account__c> collContractList = new List<collect__Loan_Account__c>();
        collect__Loan_Account__c collContract = new collect__Loan_Account__c();
        collContract.Id = TestUtility.getFakeId(collect__Loan_Account__c.getSObjectType());
        collContract.collect__External_ID__c = testExternalId;
        collContractList.add(collContract);

        set<Id> clCollectionIds = new set<Id>();
        clCollectionIds.add(collContract.collect__External_ID__c);

        DBManagerTestsStub collectionContractDBStubInstance = new DBManagerTestsStub();
        collectionContractDBStubInstance.genericReturnObject = new List<collect__Loan_Account__c>{collContract};
        CollectionContractTriggerHandler.collectionContractDBInstance = (CollectionContractDB) Test.createStub(CollectionContractDB.class, collectionContractDBStubInstance);

        Test.startTest();
            collectionContractTriggerHandlerInstance.beforeInsert(collContractList);
        Test.stopTest();
    }

    @isTest
    private static void beforeUpdateCollectionContractBatch() {
        loan__Loan_Account__c clContract = new loan__Loan_Account__c();
        clContract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        String testExternalId = clContract.Id;

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{clContract};
        CollectionContractTriggerHandler.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        List<collect__Loan_Account__c> collContractList = new List<collect__Loan_Account__c>();
        collect__Loan_Account__c collContract = new collect__Loan_Account__c();
        collContract.Id = TestUtility.getFakeId(collect__Loan_Account__c.getSObjectType());
        collContract.collect__External_ID__c = testExternalId;
        collContractList.add(collContract);

        set<Id> clCollectionIds = new set<Id>();
        clCollectionIds.add(collContract.collect__External_ID__c);

        DBManagerTestsStub collectionContractDBStubInstance = new DBManagerTestsStub();
        collectionContractDBStubInstance.genericReturnObject = new List<collect__Loan_Account__c>{collContract};
        CollectionContractTriggerHandler.collectionContractDBInstance = (CollectionContractDB) Test.createStub(CollectionContractDB.class, collectionContractDBStubInstance);

        Test.startTest();
            collectionContractTriggerHandlerInstance.beforeUpdate(collContractList);
        Test.stopTest();
    }

    @isTest
    private static void afterInsert(){
        String testExternalId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        collect__Loan_Account__c collContract = new collect__Loan_Account__c();
        collContract.Id = TestUtility.getFakeId(collect__Loan_Account__c.getSObjectType());
        collContract.collect__External_ID__c = testExternalId;

        Map<Id, collect__Loan_Account__c> newCollectionLoanAccountMap = new Map<Id, collect__Loan_Account__c>();
        newCollectionLoanAccountMap.put(collContract.Id, collContract);

        clcommon__Document_Definition__c documentDefinition = new clcommon__Document_Definition__c();
        documentDefinition.Name = 'CL Collections';
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
        documentCategory.collect_Loan_Account__c = collContract.Id;

        DBManagerTestsStub documentCategoryDBStubInstance = new DBManagerTestsStub();
        documentCategoryDBStubInstance.genericReturnObject = new List<clcommon__Document_Category__c>{documentCategory};
        CollectionContractTriggerHandler.documentCategoryDBInstance = (DocumentCategoryDB) Test.createStub(DocumentCategoryDB.class, documentCategoryDBStubInstance);

        Test.startTest();
            collectionContractTriggerHandlerInstance.afterInsert(newCollectionLoanAccountMap);
        Test.stopTest();

        System.assertEquals(1, documentCategoryDBStubInstance.forInsertSObjects.size());
    }
}