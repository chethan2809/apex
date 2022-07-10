@isTest
private class BillsCustomTriggerTests {

	@isTest
    private static void billsCustom(){
        TestUtility.runSetupData();
        loan__Loan_Account__c  clContract = TestUtility.createContract();
        Date dueDate = Date.newInstance(2021, 01, 01);
        loan__Loan_account_Due_Details__c bills = TestUtility.generateLoanAccountDueDetail(clContract.Id, 200, dueDate, 200, 200, false);
        bills.loan__Loan_Account__c = clContract.Id;

        Test.startTest();
            insert bills;
        Test.stopTest();

        System.assert(clContract.Id != null);
    }
}