@isTest(isParallel=true)
private class AutomatedPaymentSetupDBTests {

    private static AutomatedPaymentSetupDB automatedPaymentSetupDBInstance = new AutomatedPaymentSetupDB();

    @isTest
    private static void getAPSRecordsByContractIds() {
        Id contractId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Set<Id> contractIds = new Set<Id>();
        contractIds.add(contractId);

        Test.startTest();
            List<loan__Automated_Payment_Setup__c> loanAutomatedPaymentSetup = automatedPaymentSetupDBInstance.getAPSRecordsByContractIds(contractIds);
        Test.stopTest();

        System.assert(loanAutomatedPaymentSetup != null);
        System.assert(loanAutomatedPaymentSetup.isEmpty());
    }
}