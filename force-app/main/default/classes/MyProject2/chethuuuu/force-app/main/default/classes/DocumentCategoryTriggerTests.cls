@isTest
public class DocumentCategoryTriggerTests {

    @isTest
    private static void afterInsertDocumentCategoryTrigger(){
        clcommon__Document_Category__c documentCategory = new clcommon__Document_Category__c();
        documentCategory.clcommon__Category_Name__c ='doc1';

        Exception ex;
        Test.startTest();
        try{
            insert documentCategory;
        }
         catch(Exception e) {
            ex = e;
        }
        Test.stopTest();

        list<clcommon__Document_Category__c> actualDocumentCategory =[
            SELECT Id, clcommon__Category_Name__c
            FROM clcommon__Document_Category__c
        ];

        System.assert(documentCategory.Id != null);
        System.assertEquals(1, actualDocumentCategory.size());
        System.assertEquals('doc1', actualDocumentCategory[0].clcommon__Category_Name__c);
    }
}