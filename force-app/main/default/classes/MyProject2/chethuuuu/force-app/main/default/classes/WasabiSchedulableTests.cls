@isTest
private class WasabiSchedulableTests {

    @isTest
    private static void WasabiSchedule() {

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        WasabiManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        clcommon__Category_Attachment_Association__c catAttAssociation = (clcommon__Category_Attachment_Association__c) JSON.deserialize(
            '{ "Name" : "Test-Name"}' , clcommon__Category_Attachment_Association__c.class
        );
        catAttAssociation.Id = TestUtility.getFakeId(clcommon__Category_Attachment_Association__c.getSObjectType());

        DBManagerTestsStub catAttAssociationSStubInstance = new DBManagerTestsStub();
        WasabiManager.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, catAttAssociationSStubInstance);

        Map<Id, clcommon__Category_Attachment_Association__c > catAttAssociationMap = new Map<Id, clcommon__Category_Attachment_Association__c >();
        catAttAssociationMap.put(catAttAssociation.Id, catAttAssociation);

        CategoryAttachAssns.RequestType requestType;
        String cronExp = '0 0 12 1 1 ? *';

        Test.startTest();
            String jobId = System.schedule('WasabiSchedulableTests',  cronExp, new WasabiSchedulable(catAttAssociationMap, requestType));
            CronTrigger triggerCron = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                                        FROM CronTrigger 
                                        WHERE id = :jobId];
            System.assertEquals(cronExp, triggerCron.CronExpression);
            System.assertEquals(0, triggerCron.TimesTriggered);
        Test.stopTest();

        System.assertEquals(0, catAttAssociationSStubInstance.forUpdateSObjects.size());
        System.assertEquals(0, errorLogDBStubInstance.forInsertSObjects.size());
    }
}