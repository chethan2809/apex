@isTest
public class RepaymentScheduleTriggerHandlerTests {
    @isTest
    public static void beforeUpdateTest(){

        List<loan__Repayment_Schedule__c> newList = new List<loan__Repayment_Schedule__c>();
        Map<Id, loan__Repayment_Schedule__c> oldMap = new Map<Id, loan__Repayment_Schedule__c>();

        loan__Repayment_Schedule__c loanRepaymentScheduleNew = new loan__Repayment_Schedule__c();
        loanRepaymentScheduleNew.Id = TestUtility.getFakeId(loan__Repayment_Schedule__c.getSObjectType());
        loanRepaymentScheduleNew.loan__Is_Archived__c = true;
        loanRepaymentScheduleNew.loan__Is_Billed__c = true;
        loanRepaymentScheduleNew.loan__isPaid__c = false;
        newList.add(loanRepaymentScheduleNew);

        loan__Repayment_Schedule__c loanRepaymentScheduleOldMap = new loan__Repayment_Schedule__c();
        loanRepaymentScheduleNew.Id = TestUtility.getFakeId(loan__Repayment_Schedule__c.getSObjectType());
        loanRepaymentScheduleNew.loan__Is_Archived__c = false;
        oldMap.put(loanRepaymentScheduleNew.Id, loanRepaymentScheduleOldMap);

        Test.startTest();
            RepaymentScheduleTriggerHandler.beforeUpdate(newList, oldMap);
        Test.stopTest();

        System.assertEquals(false, loanRepaymentScheduleNew.loan__Is_Archived__c);
    }
}