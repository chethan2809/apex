@isTest
private class DocumentCategoryTriggerHandlerTests {

    private static DocumentCategoryTriggerHandler documentCategoryTriggerHandlerInstance = new DocumentCategoryTriggerHandler();

    @isTest
    private static void afterInsert(){
        clcommon__Document_Category__c documentCategory = new clcommon__Document_Category__c();
        documentCategory.id = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());

        Map<Id, clcommon__Document_Category__c> documentCategoryMap = new Map<Id, clcommon__Document_Category__c>();
        documentCategoryMap.put(documentCategory.Id, documentCategory);

        Test.startTest();
            documentCategoryTriggerHandlerInstance.afterInsert(documentCategoryMap);
        Test.stopTest();

        System.assert(documentCategoryMap != null);
    }
}