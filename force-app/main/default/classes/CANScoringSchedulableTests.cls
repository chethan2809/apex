@isTest
private class CANScoringSchedulableTests {

    @isTest
    private static void canScoringSchedule() {
        String cronExp = '0 0 12 1 1 ? *';

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();

        Id jobId;
        Test.startTest();
            jobId = System.schedule('CANScoringSchedulableTests', cronExp, new CANScoringSchedulable(applicationList));

            List<CronTrigger> triggerCron = [
                SELECT Id, CronExpression, TimesTriggered, NextFireTime
                FROM CronTrigger
                WHERE Id = :jobId
            ];

            System.assertEquals(1, triggerCron.size());
            System.assertEquals(cronExp, triggerCron.get(0).CronExpression);
        Test.stopTest();
    }
}