@isTest
private class CollectionsFileUploadTests {
    @isTest
    private static void CollectionsFileUploadTests() {
        Id attachmentId = TestUtility.getFakeId(Attachment.getSObjectType());

        Id documentCategoryId = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());

        Map<String,Object> newMap = new Map<String,Object>();
        newMap.put('contentVersionId','0686w0000016zBqAAI');
        newMap.put('name','TestName');

        Id collectionCaseId = TestUtility.getFakeId(Collection_Case__c.getSObjectType());

        Collection_Case__c collectionCase = new Collection_Case__c();
        collectionCase.Id = collectionCaseId;

        clcommon__Document_Category__c documentCategory = new clcommon__Document_Category__c();
        documentCategory.Id = documentCategoryId;
        documentCategory.clcommon__Category_Name__c = 'Dummy type';
        documentCategory.Collection_Case__c = collectionCase.Id;

        DBManagerTestsStub documentCategoryDBStubInstance = new DBManagerTestsStub();
        documentCategoryDBStubInstance.genericReturnObject = new List<clcommon__Document_Category__c> {documentCategory};
        CategoryAttachAssnManager.documentCategoryDBInstance = (DocumentCategoryDB) Test.createStub(DocumentCategoryDB.class, documentCategoryDBStubInstance);

        DBManagerTestsStub categoryAttachmentAssociationDBStubInstance = new DBManagerTestsStub();
        CategoryAttachAssnManager.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, categoryAttachmentAssociationDBStubInstance);

        String str = '{"collectionCase":{"loanPurpose":"Expansion","loanAmount":"20000.00"},"accountDetails":{"name":"BorrowerAcc989","phone":"8454243000","industry":"Business Services","taxId":"45456699","dba":"Test Business Trading Name","businessStructureName":"Corporation","stateOfFormation":"AZ","bizStartDate":"1990-06-07","billingStreet":"1123 Old Albany Post Road","billingBuildingNumber":"108","billingCity":"Garrison","billingState":"NY","billingPostalCode":"10524","billingCountry":"US","legalEntityType":""},"contactDetails":{"title":"CEO","firstName":"Ira989","lastName":"Boyar989","email":"iraboyar998@mailinator.com","phone":"8454243000","birthDate":"1998-10-06","socialSecurityNumber":"45456298","mailingStreet":"627 Horseblock Rd","mailingBuildingNumber":"108","mailingCity":"Farmingville","mailingState":"NY","mailingCountry":"US","mailingPostalCode":"11738"}}';
        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(str);

        List<Object> listOfFiles = new List<Object>();
        listOfFiles.add(newMap);

        Test.startTest();
            CollectionsFileUpload.collectionsFileUpload(listOfFiles, collectionCase.Id);
        Test.stopTest();

        System.assert(collectionCase.Id != null );
    }
}