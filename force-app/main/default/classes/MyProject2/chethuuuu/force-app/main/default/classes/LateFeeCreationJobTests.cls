@isTest
public class LateFeeCreationJobTests {
    @isTest
    private static void lateFeeCreationJob() {
        GeneralHelper.currentSystemDate = System.today();
        Exception ex;
        Test.startTest();
        try {
            LateFeeCreationJob.execute();
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();
        System.assertEquals(null, ex);
    }

    @isTest
    private static void lateFeeCreationJobScheduler() {
        String cronExp = '0 0 12 1 1 ? *';
        GeneralHelper.currentSystemDate = System.today();

        Test.startTest();
            String jobId = System.schedule('LateFeeCreationJobTests',  cronExp, new LateFeeCreationJob());
            CronTrigger triggerCron = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                                        FROM CronTrigger
                                        WHERE id = :jobId];
            System.assertEquals(cronExp, triggerCron.CronExpression);
            System.assertEquals(0, triggerCron.TimesTriggered);
        Test.stopTest();
    }
}