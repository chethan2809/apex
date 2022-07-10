@RestResource(urlMapping='/v1/partner/createapplication/*')
global class PartnerCreateApplicationAPI {
    @HTTPPost
    global static void createApplication() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;

        if(APIHelpers.isRequestBodyEmpty(request, response)) {
            return;
        }

        String requestBody = request.requestBody.toString();
        Map<String, Object> requestMap = (Map<String, Object>) APIHelpers.objectValidation(
            JSON.deserializeUntyped(requestBody), 'Map', 'Request body'
        );

        if(requestMap == null || requestMap.keySet().isEmpty()) {
            Blob responseBody = Blob.valueOf('[{"message" : "' + 'No records found in payload' + '"}]');
            APIHelpers.constructRestResponse(response, 400, responseBody);
            return;
        }

        if(!APIHelpers.validateBodyRequiredFields(response, requestMap, PartnerCreateApplications.REQUEST_KEYS_TO_VALIDATE)){
            return;
        }

        if(!APIHelpers.validateBodyRequiredSubFieldsBySectionName(response, requestMap)){
            return;
        }

        try {
            Map<String, Object> responseMap = PartnerCreateApplicationManager.createPartnerApplication(requestMap);
            APIHelpers.setSuccessResponse(response, responseMap);
        } catch(Exception e) {
            Map<String, Object> partnerDetailsMap = (Map<String, object>) requestMap.get(PartnerAPIConstants.PARTNER_DETAILS);
            String partnerEmail = String.valueOf(partnerDetailsMap.get(PartnerAPIConstants.PARTNER_EMAIL));
            String partnerAPIKey = String.valueOf(partnerDetailsMap.get(PartnerAPIConstants.PARTNER_API_KEY));
            PartnerAPIHelpers.generateErrorLog('PartnerCreateApplicationAPI', (request.requestBody).toString(), e.getMessage() + e.getStackTraceString(), partnerEmail, partnerAPIKey);
            APIHelpers.setErrorResponse(response, e.getMessage());
        }
    }
}