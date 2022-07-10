@isTest(isParallel=true)
private class FeeJunctionDBTests {

    private static FeeJunctionDB feeJunctionDBInstance = new FeeJunctionDB();

    @isTest
    private static void getAllActiveFeesAndFeeSets() {

        Test.startTest();
            List<loan__Fee_Junction__c> feeJunctionList = feeJunctionDBInstance.getAllActiveFeesAndFeeSets();
        Test.stopTest();

        System.assert(feeJunctionList != null);
        System.assert(feeJunctionList.isEmpty());
    }
}