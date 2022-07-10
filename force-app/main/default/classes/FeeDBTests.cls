@isTest(isParallel=true)
private class FeeDBTests {

    private static FeeDB feeDBInstance = new FeeDB();

    @isTest
    private static void getAllActiveFees() {

        Test.startTest();
            List<loan__Fee__c> feeList = feeDBInstance.getAllActiveFees();
        Test.stopTest();

        System.assert(feeList != null);
        System.assert(feeList.isEmpty());
    }
}