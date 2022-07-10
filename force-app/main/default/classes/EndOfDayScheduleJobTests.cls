@isTest
private class EndOfDayScheduleJobTests {
    @isTest
    private static void endOfDaySchedule() {
        TestUtility.runSetupData();

        clcommon__DAG_Schedule__c paymentDagSchedule = new clcommon__DAG_Schedule__c();
        paymentDagSchedule.clcommon__DAG_Name__c = 'CAN Start of Day Dynamic Jobs';
        insert paymentDagSchedule;

        List<String> paymentJobs = new List<String> {'loan.EndOfDayDynamicJob'};

        List<clcommon__Job__c> jobsForInsert = new List<clcommon__Job__c>();
        for(String j :paymentJobs) {
            clcommon__Job__c newJob = new clcommon__Job__c();
            newJob.clcommon__DAG__c = paymentDagSchedule.Id;
            newJob.clcommon__Batch_Size__c = 1;
            newJob.clcommon__Class__c = j;
            newJob.clcommon__Fail_Type__c = 'Logging';
            newJob.clcommon__Label__c = j.substringAfter('loan.');
            newJob.clcommon__Number_Of_Instances__c = 1;
            jobsForInsert.add(newJob);
        }

        insert jobsForInsert;

        List<clcommon__Job_Dependency__c> jobsDependenciesForInsert = new List<clcommon__Job_Dependency__c>();
        Id parentJobId = null;
        for(clcommon__Job__c j :jobsForInsert) {
            clcommon__Job_Dependency__c newDependenciesJob = new clcommon__Job_Dependency__c();
            newDependenciesJob.clcommon__DAG__c = j.clcommon__DAG__c;
            newDependenciesJob.clcommon__Dependent_Job__c = parentJobId;
            newDependenciesJob.clcommon__Job__c = j.Id;
            newDependenciesJob.clcommon__Relationship__c = 'Completion';
            parentJobId = j.Id;
            jobsDependenciesForInsert.add(newDependenciesJob);
        }
        insert jobsDependenciesForInsert;

        String cronExp = '0 0 12 1 1 ? *';
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 1, 1);

        Test.startTest();
            String jobId = System.schedule('EndOfDayScheduleTests',  cronExp, new EndOfDayScheduleJob());

            CronTrigger triggerCron = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                                        FROM CronTrigger
                                        WHERE id = :jobId];
            System.assertEquals(cronExp, triggerCron.CronExpression);
            System.assertEquals(0, triggerCron.TimesTriggered);
        Test.stopTest();
    }
}