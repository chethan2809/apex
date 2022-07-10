@isTest(isParallel=true)
private class DocumentDefinitionDBTests {

    private static DocumentDefinitionDB documentDefinitionDBInstance = new DocumentDefinitionDB();

    @isTest
    private static void getAllDocumentDefinitions() {
        Test.startTest();
            List<clcommon__Document_Definition__c> documentDefinitionList = documentDefinitionDBInstance.getAllDocumentDefinitions();
        Test.stopTest();

        System.assert(documentDefinitionList != null);
        System.assert(documentDefinitionList.isEmpty());
    }
}