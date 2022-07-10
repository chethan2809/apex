@isTest(isParallel=true)
private class PricingMatrixDetailDBTests {

    private static PricingMatrixDetailDB pricingMatrixDetailDBInstance = new PricingMatrixDetailDB();

    @isTest
    private static void getAllPricingMatrixDetails() {

        Test.startTest();
            List<CAN_Pricing_Matrix_Detail__c> pricingMatrixDetailList = pricingMatrixDetailDBInstance.getAllPricingMatrixDetails();
        Test.stopTest();

        System.assert(pricingMatrixDetailList != null);
        System.assert(pricingMatrixDetailList.isEmpty());
    }

    @isTest
    private static void getPricingMatrixDetailsByRandomNumber() {

        Test.startTest();
            List<CAN_Pricing_Matrix_Detail__c> pricingMatrixDetailList = pricingMatrixDetailDBInstance.getPricingMatrixDetailsByRandomNumber(1);
        Test.stopTest();

        System.assert(pricingMatrixDetailList != null);
        System.assert(pricingMatrixDetailList.isEmpty());
    }
}