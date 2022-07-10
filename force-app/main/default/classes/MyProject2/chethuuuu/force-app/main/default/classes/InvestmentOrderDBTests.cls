@isTest
private class InvestmentOrderDBTests {
    private static InvestmentOrderDB investmentOrderDBInstance = new InvestmentOrderDB();

    @isTest
    static void getIndustryProfilesByNames() {
        Set<Id> disbursalIds = new Set<Id> {TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType())};

        Test.startTest();
            List<loan__Investor_Loan__c> investmentOrderList = investmentOrderDBInstance.getInvestmentOrderListByDisbursalTxnIds(disbursalIds);
        Test.stopTest();

        System.assert(investmentOrderList != null);
        System.assert(investmentOrderList.isEmpty());
    }
}