public class PartnerCalculatePricing {
    public static final String NO_PRICING_DETAILS_AVAILABLE = 'No pricing details available';
    public static final String INVALID_TERM = 'Term is invalid';
    public static final String TERM = 'term';
    public static final  Set<String> REQUEST_KEYS_TO_VALIDATE = new Set<String>{
        'application',
        'partnerEmail',
        'partnerAPIKey',
        'term'
    };
    public static final  Map<String, String> PRICING_RESPONSE_MAP = new Map<String, String>{
        'Maximum Term' => 'Maximum_Term__c',
        'Maximum Amount' => 'Maximum_Amount__c',
        'Daily Payment Amount' => 'Daily_Payment_Amount__c',
        'Buy Rate' => 'Buy_Rate__c',
        'Pricing Factor' => 'Pricing_Factor__c',
        'Maximum Commission %' => 'Max_Broker_Commission__c',
        'Weekly Payment Amount' => 'Weekly_Payment_Amount__c',
        'Origination Fee %' => 'Origination_Fee_Percentage__c'
    };

    public static genesis__Applications__c validateRequest(RestRequest request) {
        String applicationName = request.params.get(PartnerAPIConstants.APPLICATION);
        String partnerEmail = request.params.get(PartnerAPIConstants.PARTNER_EMAIL);
        String partnerAPIKey = request.params.get(PartnerAPIConstants.PARTNER_API_KEY);

        Map<String, Object> responseData = PartnerAPIHelpers.genericPartnerAPIValidation(partnerEmail, applicationName, partnerAPIKey);
        genesis__Applications__c application = (genesis__Applications__c) responseData.get(PartnerAPIConstants.APPLICATION_DETAILS);

        return application;
    }

    public static Map<String, Object> buildResponse(CAN_Pricing_Detail__c canPricingDetail) {
		Map<String, Object> constructResponseMap = PartnerAPIHelpers.constructResponseMap(canPricingDetail, PartnerCalculatePricing.PRICING_RESPONSE_MAP);
		constructResponseMap.put(PartnerAPIConstants.MINIMUM_TERM, CANPricingDetails.DEFAULT_MINIMUM_TERM);
        Map<String, Object> resultMap = new Map<String, Object>{
            PartnerAPIConstants.PRICING_DETAILS => constructResponseMap
        };

        return resultMap;
    }

    public static CAN_Pricing_Detail__c calculateCANPricing(List<CAN_Pricing_Detail__c> canPricingDetail, Decimal term) {
        CAN_Pricing_Detail__c pricingDetail = canPricingDetail.get(0);
        pricingDetail.Term__c = term;
        pricingDetail = CANPricingDetails.calculateCANPricing(pricingDetail);

        return pricingDetail;
    }

    public static void validatePricingAndTerm(List<CAN_Pricing_Detail__c> canPricingDetail, Decimal term){
        if(canPricingDetail.isEmpty()){
            throw new PartnerCalculatePricingException(PartnerCalculatePricing.NO_PRICING_DETAILS_AVAILABLE);
        }

        if(term < CANPricingDetails.DEFAULT_MINIMUM_TERM || term > canPricingDetail.get(0).Maximum_Term__c){
            throw new PartnerCalculatePricingException(PartnerCalculatePricing.INVALID_TERM);
        }
    }

    private class PartnerCalculatePricingException extends Exception {}
}