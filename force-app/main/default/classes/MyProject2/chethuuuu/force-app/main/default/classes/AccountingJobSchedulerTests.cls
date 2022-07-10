@isTest
public class AccountingJobSchedulerTests {
    @isTest
    private static void AccountingJobScheduler() {

        String cronExp = '0 0 12 1 1 ? *';

        String jobId;

        Exception ex;
        Test.startTest();
            try {
                jobId = System.schedule('AccountingJobSchedulerTests',  cronExp, new AccountingJobScheduler());
            }
            catch(Exception e) {
                ex = e;
            }

            /*CronTrigger triggerCron = [
                SELECT Id, CronExpression, TimesTriggered, NextFireTime
                FROM CronTrigger
                WHERE id = :jobId
            ];
            System.assertEquals(cronExp, triggerCron.CronExpression);
            System.assertEquals(0, triggerCron.TimesTriggered);*/
        Test.stopTest();
    }
}