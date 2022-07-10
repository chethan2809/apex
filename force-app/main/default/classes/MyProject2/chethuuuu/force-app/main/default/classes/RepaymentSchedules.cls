public class RepaymentSchedules {

    public static void revertArchiveForUnPaidBilledSchedule(loan__Repayment_Schedule__c repaymentSchedule, loan__Repayment_Schedule__c oldRepaymentSchedule) {

        if(oldRepaymentSchedule.loan__Is_Archived__c != repaymentSchedule.loan__Is_Archived__c
            && repaymentSchedule.loan__Is_Archived__c && repaymentSchedule.loan__Is_Billed__c && !repaymentSchedule.loan__isPaid__c
        ) {
            repaymentSchedule.loan__Is_Archived__c = false;
        }
    }
}