@isTest
private class RePaymentScheduleDBTests {

    private static RepaymentScheduleDB repaymentScheduleDBInstance = new RepaymentScheduleDB();

    @isTest
    private static void RePaymentScheduleDBTests() {
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);

        TestUtility.runSetupData();
        Id contractId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loan__Loan_Account__c clContractId = new loan__Loan_Account__c();
        clContractId.Id = contractId;

        loan__Repayment_Schedule__c repaymentSchedule =  TestUtility.generateRepaymentSchedule(
            clContractId.Id, GeneralHelper.currentSystemDate, 15000, 3000
        );

        Test.startTest();
        List<loan__repayment_schedule__c> repaymentScheduleList = repaymentScheduleDBInstance.getRepyamnetScheculeByLoanId(clContractId.Id);
        Test.stopTest();

        System.assert(repaymentScheduleList != null);
        System.assert(clContractId.Id != null);
    }
}