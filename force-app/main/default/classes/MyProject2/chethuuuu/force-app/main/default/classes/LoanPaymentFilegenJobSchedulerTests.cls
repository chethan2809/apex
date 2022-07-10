@isTest
public class LoanPaymentFilegenJobSchedulerTests {
    @isTest
    private static void LoanPaymentFilegenJobScheduler() {
        TestUtility.runSetupData();
        String cronExp = '0 0 12 1 1 ? *';

        Boolean runNextJob = false;

        Test.startTest();
            String jobId = System.schedule('LoanPaymentFileGenJobSchedulerTests',  cronExp, new LoanPaymentFilegenJobScheduler(runNextJob, 2000));
            String jobId1 = System.schedule('LoanPaymentFileGenJobSchedulerTests1',  cronExp, new LoanPaymentFilegenJobScheduler());
            CronTrigger triggerCron = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                                        FROM CronTrigger
                                        WHERE id = :jobId];
            System.assertEquals(cronExp, triggerCron.CronExpression);
            System.assertEquals(0, triggerCron.TimesTriggered);
        Test.stopTest();
    }
}