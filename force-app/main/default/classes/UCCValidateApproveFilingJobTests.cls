@isTest
private class UCCValidateApproveFilingJobTests {

    @isTest
    private static void uccValidateApproveFilingTests() {
        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        UCCFilingManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        DBManagerTestsStub uccFilingDBStubInstance = new DBManagerTestsStub();
        UCCFilingManager.uccFilingDBInstance = (UCCFilingDB) Test.createStub(UCCFilingDB.class, uccFilingDBStubInstance);

        UCC_Filing_Detail__c uccFilingDetail = (UCC_Filing_Detail__c) JSON.deserialize(
            '{ "Name" : "UCC-00000"}' , UCC_Filing_Detail__c.class
        );
        UCCFilingDetail.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        List<UCC_Filing_Detail__c> uccFilingDetailList = new List<UCC_Filing_Detail__c>();
        UCCFilingDetailList.add(UCCFilingDetail);

        UCCValidateApproveFilingQueueableJob uccValidateApproveFilingQueueableInstance = new UCCValidateApproveFilingQueueableJob(UCCFilingDetailList);

        Test.startTest();
            System.enqueueJob(UCCValidateApproveFilingQueueableInstance);
        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }

}