@isTest(isParallel=true)
private class CANPricingDetailDBTests {

    private static CANPricingDetailDB canPricingDetailDBInstance = new CANPricingDetailDB();

    @isTest
    private static void getUnArchivedPricingDetailsByApplicationIds() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(applicationId);

        Test.startTest();
            List<CAN_Pricing_Detail__c> canPricingDetailList = canPricingDetailDBInstance.getUnArchivedPricingDetailsByApplicationIds(applicationIds);
        Test.stopTest();

        System.assert(canPricingDetailList != null);
        System.assert(canPricingDetailList.isEmpty());
    }

    @isTest
    private static void getCANPricingRecordByApplicationId() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        Test.startTest();
            List<CAN_Pricing_Detail__c> canPricingDetailList = canPricingDetailDBInstance.getCANPricingRecordByApplicationId(applicationId, 'Archived');
        Test.stopTest();

        System.assert(canPricingDetailList != null);
        System.assert(canPricingDetailList.isEmpty());
    }

    @isTest
    private static void getCANPricingListByIds() {
        Id pricingId = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());
        Set<Id> pricingIds = new Set<Id>();
        pricingIds.add(pricingId);

        Test.startTest();
            List<CAN_Pricing_Detail__c> canPricingDetailList = canPricingDetailDBInstance.getCANPricingListByIds(pricingIds);
        Test.stopTest();

        System.assert(canPricingDetailList != null);
        System.assert(canPricingDetailList.isEmpty());
    }

    @isTest
    private static void getCANPricingListByApplicationIdsAndStatuses() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Set<Id> applicationIds = new Set<Id>();
        applicationIds.add(applicationId);

        Set<String> statuses = new Set<String> { 'Sent To Customer' };

        Test.startTest();
            List<CAN_Pricing_Detail__c> canPricingDetailList = canPricingDetailDBInstance.getCANPricingListByApplicationIdsAndStatuses(applicationIds, statuses);
        Test.stopTest();

        System.assert(canPricingDetailList != null);
        System.assert(canPricingDetailList.isEmpty());
    }

    @isTest
    private static void getCANPricingByApplicationId() {
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
       
        Test.startTest();
        List<CAN_Pricing_Detail__c> canPricingDetailList = canPricingDetailDBInstance.getCANPricingByApplicationId(applicationId);
        Test.stopTest();

        System.assert(canPricingDetailList != null);
        System.assert(canPricingDetailList.isEmpty());
    }
}