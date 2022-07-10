@isTest
private class WasabiQueueableJobTests {

    @isTest
    private static void requestWasabiQueueable() {

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        WasabiManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        DBManagerTestsStub catAttAssociationSStubInstance = new DBManagerTestsStub();
        WasabiManager.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, catAttAssociationSStubInstance);

        clcommon__Category_Attachment_Association__c catAttAssociation = (clcommon__Category_Attachment_Association__c) JSON.deserialize(
            '{ "Name" : "Test-Name"}' , clcommon__Category_Attachment_Association__c.class
        );
        catAttAssociation.Id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());

        Map<Id, clcommon__Category_Attachment_Association__c > catAttAssociationMap = new Map<Id, clcommon__Category_Attachment_Association__c >();
        catAttAssociationMap.put(catAttAssociation.Id, catAttAssociation);

        CategoryAttachAssns.RequestType requestType;

        WasabiQueueableJob wasabiQueueableInstance = new WasabiQueueableJob(catAttAssociationMap, requestType);

        Test.startTest();
            System.enqueueJob(wasabiQueueableInstance);
        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
        System.assertEquals(0, catAttAssociationSStubInstance.forUpdateSObjects.size());
    }
}