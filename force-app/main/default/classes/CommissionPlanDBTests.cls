@isTest(isParallel=true)
private class CommissionPlanDBTests {

    private static CommissionPlanDB commissionPlanDBInstance = new CommissionPlanDB();

    @isTest
    private static void getCommissionPlanByIds() {
        Test.startTest();
            List<loan__Commission_Plan__c> loanCommissionPlanList = commissionPlanDBInstance.getCommissionPlanByIds();
        Test.stopTest();

        System.assert(loanCommissionPlanList != null);
        System.assert(loanCommissionPlanList.isEmpty());
    }
}