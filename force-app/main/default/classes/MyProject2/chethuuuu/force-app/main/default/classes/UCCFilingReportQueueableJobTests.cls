@IsTest
private class UCCFilingReportQueueableJobTests {
    @isTest
    private static void uccFilingReportQueueable() {
        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());

        UCC_Filing_Attachment__c uccAttachment =  new UCC_Filing_Attachment__c();
        uccAttachment.UCC_Filing_Detail__c = uccFiling.Id;

        List<UCC_Filing_Detail__c> uccFilingList = new List<UCC_Filing_Detail__c>();
        uccFilingList.add(uccFiling);

        UCCFilingReportQueueableJob uccFilingReportQueueableInstance = new UCCFilingReportQueueableJob(uccFilingList);

        DBManagerTestsStub uccFilingDBStubInstance = new DBManagerTestsStub();
        uccFilingDBStubInstance.genericReturnObject = new List<UCC_Filing_Detail__c>{uccFiling};
        UCCFilingManager.uccFilingDBInstance = (UCCFilingDB) Test.createStub(UCCFilingDB.class, uccFilingDBStubInstance);

        Test.startTest();
            System.enqueueJob(uccFilingReportQueueableInstance);
        Test.stopTest();

        System.assertEquals(0, uccFilingDBStubInstance.forUpdateSObjects.size());

    }
}