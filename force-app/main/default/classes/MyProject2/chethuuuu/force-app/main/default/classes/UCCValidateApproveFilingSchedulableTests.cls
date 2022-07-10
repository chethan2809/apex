@isTest
private class UCCValidateApproveFilingSchedulableTests {

    @isTest
    private static void UCCValidateApproveFilingSchedule() {
        String cronExp = '0 0 12 1 1 ? *';

        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());

        List<UCC_Filing_Detail__c> uccFilingList = new List<UCC_Filing_Detail__c>();
        uccFilingList.add(uccFiling);

        DBManagerTestsStub uccFilingDBStubInstance = new DBManagerTestsStub();
        uccFilingDBStubInstance.genericReturnObject = new List<UCC_Filing_Detail__c>{uccFiling};
        UCCFilingManager.uccFilingDBInstance = (UCCFilingDB) Test.createStub(UCCFilingDB.class, uccFilingDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        UCCFilingManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Test.startTest();
        String jobId = System.schedule('UCCValidateApproveFilingSchedulableTests',  cronExp, new UCCValidateApproveFilingSchedulable(uccFilingList));
            CronTrigger triggerCron = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                                        FROM CronTrigger
                                        WHERE id = :jobId];
            System.assertEquals(cronExp, triggerCron.CronExpression);
            System.assertEquals(0, triggerCron.TimesTriggered);
            Test.stopTest();

            System.assertEquals(0, uccFilingDBStubInstance.forUpdateSObjects.size());
            System.assertEquals(0, errorLogDBStubInstance.forInsertSObjects.size());
        }
    }