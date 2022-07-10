@isTest
public class LateFeeCreationJobSchedulerTests {
    @isTest
    private static void LateFeeCreationJobScheduler() {
        TestUtility.runSetupData();
        String cronExp = '0 0 12 1 1 ? *';
        GeneralHelper.currentSystemDate = System.today();
        CAN_General_Settings__c canGeneralSettings = CAN_General_Settings__c.getOrgDefaults();
        CustomSettingsHelper.generalSettings = canGeneralSettings;

        Test.startTest();
            String jobId = System.schedule('LateFeeCreationJobSchedulerTests',  cronExp, new LateFeeCreationJobScheduler());
            CronTrigger triggerCron = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                                        FROM CronTrigger
                                        WHERE id = :jobId];
            System.assertEquals(cronExp, triggerCron.CronExpression);
            System.assertEquals(0, triggerCron.TimesTriggered);
        Test.stopTest();
    }
}