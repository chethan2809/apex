@RestResource(urlMapping = '/v1/partner/calculatepricing/*')
global class  PartnerCalculatePricingAPI {
    @HttpGet
    global static void calculatePricing()
    {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;

        if(!APIHelpers.validateRequestParamsRequiredFields(response, request, PartnerCalculatePricing.REQUEST_KEYS_TO_VALIDATE)){
            return;
        }

        try{
            Map<String, Object> responseMap = PartnerCalculatePricingManager.calculatePricing(request);
            APIHelpers.setSuccessResponse(response, responseMap);
        }
        catch(Exception e){
            PartnerAPIHelpers.generateErrorLog('PartnerCalculatePricingAPI', JSON.serialize(request.params), e.getMessage() + e.getStackTraceString(),
                request.params.get(PartnerAPIConstants.PARTNER_EMAIL), request.params.get(PartnerAPIConstants.PARTNER_API_KEY));
            APIHelpers.setErrorResponse(response, e.getMessage());
        }
    }
}