@isTest(isParallel=true)
private class ConditionsOnSpreadDBTests {

    private static ConditionsOnSpreadDB conditionsOnSpreadDBInstance = new ConditionsOnSpreadDB();

    @isTest
    private static void getDefaultConditionsOnSpread() {

        Test.startTest();
            List<loan__Conditions_On_Spread__c> loanConditionList = conditionsOnSpreadDBInstance.getDefaultConditionsOnSpread();
        Test.stopTest();

        System.assert(loanConditionList != null);
        System.assert(loanConditionList.isEmpty());
    }
}