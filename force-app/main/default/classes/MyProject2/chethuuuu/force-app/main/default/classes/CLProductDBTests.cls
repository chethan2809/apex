@isTest(isParallel=true)
private class CLProductDBTests {

    private static CLProductDB clProductDBInstance = new CLProductDB();

    @isTest
    private static void getAllProducts() {

        Test.startTest();
            List<clcommon__CL_Product__c> clProductList = clProductDBInstance.getAllProducts();
        Test.stopTest();

        System.assert(clProductList != null);
        System.assert(clProductList.isEmpty());
    }
}