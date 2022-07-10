@isTest
public class ExperianConsumerSchedulableTests {
    @isTest
    private static void experianConsumerSchedule() {
        TestUtility.runSetupData();
        String cronExp = '0 0 12 1 1 ? *';

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-0000000002"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();

        Test.startTest();
            String jobId = System.schedule('ExperianConsumerSchedulableTests',  cronExp, new ExperianConsumerSchedulable(applicationList));
            CronTrigger triggerCron = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                                        FROM CronTrigger
                                        WHERE id = :jobId];
            System.assertEquals(cronExp, triggerCron.CronExpression);
            System.assertEquals(0, triggerCron.TimesTriggered);
        Test.stopTest();
    }
}