public class PartnerCalculatePricingManager {
    @TestVisible
    private static CANPricingDetailDB canPricingDetailDBInstance = new CANPricingDetailDB();

    public static Map<String, Object> calculatePricing(RestRequest request){
        Decimal term = Decimal.valueOf(request.params.get(PartnerCalculatePricing.TERM));

        genesis__Applications__c application = PartnerCalculatePricing.validateRequest(request);

        List<CAN_Pricing_Detail__c> canPricingDetails = canPricingDetailDBInstance.getCANPricingListByApplicationIdsAndStatuses(new Set<Id> { application.Id }, new Set<String>{ CANPricingDetails.STATUS_SENT_TO_CUSTOMER });

        PartnerCalculatePricing.validatePricingAndTerm(canPricingDetails, term);

        CAN_Pricing_Detail__c canPricingDetail =  PartnerCalculatePricing.calculateCANPricing(canPricingDetails, term);
        Map<String, Object> responseMap = PartnerCalculatePricing.buildResponse(canPricingDetail);

        return responseMap;
    }
}