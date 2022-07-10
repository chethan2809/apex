@isTest
private class RepaymentSchedulesTests {
    @isTest
    public static void revertArchiveForUnPaidBilledScheduleTests() {

        loan__Repayment_Schedule__c loanRepaymentScheduleOld = new loan__Repayment_Schedule__c();
        loanRepaymentScheduleOld.Id = TestUtility.getFakeId(loan__Repayment_Schedule__c.getSObjectType());
        loanRepaymentScheduleOld.loan__Is_Archived__c = false;

        loan__Repayment_Schedule__c loanRepaymentScheduleNew = new loan__Repayment_Schedule__c();
        loanRepaymentScheduleNew.Id = loanRepaymentScheduleOld.Id;
        loanRepaymentScheduleNew.loan__Is_Archived__c = true;
        loanRepaymentScheduleNew.loan__Is_Billed__c = true;
        loanRepaymentScheduleNew.loan__isPaid__c = false;

        Test.startTest();
            RepaymentSchedules.revertArchiveForUnPaidBilledSchedule(loanRepaymentScheduleNew, loanRepaymentScheduleOld);
        Test.stopTest();

        System.assertEquals(false, loanRepaymentScheduleNew.loan__Is_Archived__c);
    }
}