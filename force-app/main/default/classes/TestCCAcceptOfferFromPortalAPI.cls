@isTest
public class TestCCAcceptOfferFromPortalAPI {
    @isTest
    private static void testcreateAcceptedPricingRecordFromBrokerPortal()
    {
        Id appId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        CAN_Pricing_Detail__c canPricingDetails = new CAN_Pricing_Detail__c();
        canPricingDetails.Standard_Commission__c = 100;
        canPricingDetails.Commission_Amount__c = 1000;
        canPricingDetails.Application__c = appId;

        test.startTest();
        CAN_Pricing_Detail__c canPricingDetailsBrokerPortal = CCAcceptOfferFromPortalAPI.createAcceptedPricingRecordFromBrokerPortal(canPricingDetails, appId);
        CAN_Pricing_Detail__c canPricingDetailsMerchantPortal = CCAcceptOfferFromPortalAPI.createAcceptedPricingRecordFromMerchantPortal(canPricingDetails, appId);
        test.stopTest();

        System.assert(canPricingDetailsBrokerPortal != null);
        System.assert(canPricingDetailsMerchantPortal != null);
        System.assertEquals(100, canPricingDetailsBrokerPortal.Standard_Commission__c);
    }

}