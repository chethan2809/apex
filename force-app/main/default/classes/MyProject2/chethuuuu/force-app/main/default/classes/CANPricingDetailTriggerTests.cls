@isTest
private class CANPricingDetailTriggerTests {

    @isTest
    private static void  canPricingInsertUpdate() {
        CAN_Pricing_Detail__c canPricing = new CAN_Pricing_Detail__c();
        canPricing.Maximum_Amount__c = 50000;
        canPricing.Selected_Amount__c = 10000 ;

        Exception ex;
        Test.startTest();
        try {
            insert canPricing;
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        canPricing.Maximum_Amount__c = 12000;
        update canPricing;

        list<CAN_Pricing_Detail__c> canPricingList = [
            SELECT Id,Maximum_Amount__c, Selected_Amount__c
            FROM CAN_Pricing_Detail__c
        ];

        System.assert(canPricing.Id != null);
        System.assertEquals(1, canPricingList.size());
        System.assertEquals(12000, canPricingList[0].Maximum_Amount__c);
    }
}