@isTest
public class RepaymentScheduleTriggerTests {

    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    @isTest
    private static void beforeUpdate(){
        TestUtility.runSetupData();

        loan__Loan_Account__c loanAccount = TestUtility.createContract();
        loan__Repayment_Schedule__c loanRepaymentSchedule = TestUtility.generateRepaymentSchedule(
        loanAccount.Id, GeneralHelper.currentSystemDate.addMonths(1), 553, 193.35
        );
        insert loanRepaymentSchedule;

        loanRepaymentSchedule.loan__Is_Archived__c = false;

        Exception ex;
        Test.startTest();
            try {
                update loanRepaymentSchedule;
            } catch (Exception e) {
                ex = e;
            }
        Test.stopTest();

        TestUtility.assertNullException(ex);
    }
}