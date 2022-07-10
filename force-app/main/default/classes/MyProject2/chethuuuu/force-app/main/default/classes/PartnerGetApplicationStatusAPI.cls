@RestResource(urlMapping = '/v1/partner/applicationstatus/*')
global class  PartnerGetApplicationStatusAPI {
    @HttpGet
    global static void getApplicationStatus()
    {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;

        if(!APIHelpers.validateRequestParamsRequiredFields(response, request, PartnerGetApplicationStatus.REQUEST_KEYS_TO_VALIDATE)){
            return;
        }

        try{
            Map<String, Object> responseMap = PartnerGetApplicationStatusManager.getApplicationStatus(request);
            APIHelpers.setSuccessResponse(response, responseMap);
        }
        catch(Exception e){
            PartnerAPIHelpers.generateErrorLog('PartnerGetApplicationStatusAPI', JSON.serialize(request.params), e.getMessage() + e.getStackTraceString(),
                request.params.get(PartnerAPIConstants.PARTNER_EMAIL), request.params.get(PartnerAPIConstants.PARTNER_API_KEY));
            APIHelpers.setErrorResponse(response, e.getMessage());
        }
    }
}