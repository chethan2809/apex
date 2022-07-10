public class RepaymentScheduleTriggerHandler {

    public static void beforeUpdate(List<loan__Repayment_Schedule__c> newList, Map<Id, loan__Repayment_Schedule__c> oldMap){

        for(loan__Repayment_Schedule__c repaymentSchedule : newList){
            loan__Repayment_Schedule__c oldRepaymentSchedule = oldMap.get(repaymentSchedule.Id);
            RepaymentSchedules.revertArchiveForUnPaidBilledSchedule(repaymentSchedule, oldRepaymentSchedule);
        }
    }
}