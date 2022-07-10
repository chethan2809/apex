@isTest
public class EndOfDayScheduleJobTest {
    @isTest
    private static void EndOfDaySchedule() {
        String cronExp = '0 0 12 1 1 ? *';

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-0000000002"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        applicationList.add(application);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        CANScoringManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CANScoringManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);
    // TestUtility.runSetupData();
       // loan__Loan_Account__c loanaccount = new loan__Loan_Account__c();
       // loanaccount.loan__Account_Type__c = 'New';
      //  loanaccount.loan__Branch__c = 'CAN Capital';
       // loanaccount.loan__Status_Order__c ='14.321';
       // insert loanaccount;
        //loanaccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Test.startTest();
     //String jobId = System.schedule('EndOfDayScheduleJobTest',  cronExp, new EndOfDaySchedule(applicationList));
            CronTrigger triggerCron = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                                        FROM CronTrigger]; 
                  //                      WHERE id = :jobId];
            System.assertEquals(cronExp, triggerCron.CronExpression);
            System.assertEquals(0, triggerCron.TimesTriggered);
        Test.stopTest();     
        System.assertEquals(0, applicationDBStubInstance.forUpdateSObjects.size());
        System.assertEquals(0, errorLogDBStubInstance.forInsertSObjects.size());

    }
}