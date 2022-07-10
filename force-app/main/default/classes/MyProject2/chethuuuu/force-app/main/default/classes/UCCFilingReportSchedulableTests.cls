@IsTest
private class UCCFilingReportSchedulableTests {
    @IsTest
    private static void UCCFilingReportSchedulable() {
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
        String cronExp = '0 0 12 1 1 ? *';

        Test.startTest();
            String jobId = System.schedule('UCCFilingReportSchedulableTests',  cronExp, new UCCFilingReportSchedulable(uccFilingList));
            CronTrigger triggerCron = [
                SELECT Id, CronExpression, TimesTriggered, NextFireTime
                FROM CronTrigger
                WHERE id = :jobId
            ];
        Test.stopTest();

        System.assertEquals(cronExp, triggerCron.CronExpression);
        System.assertEquals(0, triggerCron.TimesTriggered);
    }
}