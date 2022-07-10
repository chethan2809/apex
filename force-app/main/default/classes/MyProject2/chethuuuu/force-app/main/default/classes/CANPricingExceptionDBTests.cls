@IsTest(isParallel=true)
private class CANPricingExceptionDBTests {
    private static CANPricingExceptionDB canPricingDBInstance = new CANPricingExceptionDB();
    @isTest
    private static void getCANPricingExceptionByApplicationIds() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(applicationId);

        Test.startTest();
            List<CAN_Pricing_Exception__c> canPricingExceptionList = canPricingDBInstance.getPricingExceptionByApplicationId(applicationIds);
        Test.stopTest();

        System.assert(canPricingExceptionList != null);
        System.assert(canPricingExceptionList.isEmpty());
    }

}