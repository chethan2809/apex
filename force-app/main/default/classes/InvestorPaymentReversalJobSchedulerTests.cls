@isTest
public class InvestorPaymentReversalJobSchedulerTests {

    @isTest
    private static void investorPaymentReversalJobScheduler() {
    String cronExp = '0 0 12 1 1 ? *';
        GeneralHelper.currentSystemDate = System.today();

        loan__Office_Name__c loanOfficeName = new loan__Office_Name__c();
        loanOfficeName.Id = TestUtility.getFakeId(loan__Office_Name__c.getSObjectType());

        DBManagerTestsStub loanOfficeNameDBStubInstance = new DBManagerTestsStub();
        loanOfficeNameDBStubInstance.genericReturnObject = new List<loan__Office_Name__c> {loanOfficeName};
        InvestorPayoutJobCaller.loanOfficeNameDBInstance = (LoanOfficeNameDB) Test.createStub(LoanOfficeNameDB.class, loanOfficeNameDBStubInstance);

        String query = '';

        Test.startTest();
            String jobId = System.schedule('InvestorPaymentReversalJobSchedulerTests',  cronExp, new InvestorPaymentReversalJobScheduler());
            CronTrigger triggerCron = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                                        FROM CronTrigger
                                        WHERE id = :jobId];
            System.assertEquals(cronExp, triggerCron.CronExpression);
            System.assertEquals(0, triggerCron.TimesTriggered);
        Test.stopTest();
    }
}