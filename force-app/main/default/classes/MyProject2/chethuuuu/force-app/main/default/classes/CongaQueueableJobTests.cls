@isTest
private class CongaQueueableJobTests {
    @isTest
    private static void congaAPIQueueable() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Total_Competitors_Amount__c = 1000;
        application.Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;

        Map<String, Object> requestRecord = new Map<String, Object>();
        requestRecord.put('parentId', application.Id);
        requestRecord.put('templateType', 'Loan Agreement-A Application');
        requestRecord.put('sendForESign', true);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        CongaManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        CAN_Conga_Settings__c congaSettings = new CAN_Conga_Settings__c();
        congaSettings.Id = TestUtility.getFakeId(CAN_Conga_Settings__c.getSObjectType());
        congaSettings.Conga_Sign_BLA_Subject__c = 'Please sign your document';
        CustomSettingsHelper.congaSettings = congaSettings;

        System.Test.setMock(HttpCalloutMock.class, new CongaCalloutMock.CongaCalloutSuccessResponse());

        CongaQueueableJob congaQueueableJobInstance = new CongaQueueableJob(requestRecord);

        Test.startTest();
            System.enqueueJob(congaQueueableJobInstance);
        Test.stopTest();

        System.assertEquals('Please sign your document', CustomSettingsHelper.congaSettings.Conga_Sign_BLA_Subject__c);
    }

    @isTest
    private static void congaAPIQueueableExceptionCheck() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Total_Competitors_Amount__c = 1000;
        application.Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;

        Map<String, Object> requestRecord = new Map<String, Object>();
        requestRecord.put('parentId', application.Id);
        requestRecord.put('templateType', 'Loan Agreement-A Application');
        requestRecord.put('sendForESign', true);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>();
        CongaManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CongaQueueableJob.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        CongaQueueableJob congaQueueableJobInstance = new CongaQueueableJob(requestRecord);

        Test.startTest();
            System.enqueueJob(congaQueueableJobInstance);
        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }
}