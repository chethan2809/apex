public class PartnerProcessApplications {
    public static final String CONSENT_ACCEPTED = 'consentAccepted';
    public static final String CONSENT_ACCEPTED_TRUE = 'consentAccepted should be true';
    public static final  Set<String> REQUEST_KEYS_TO_VALIDATE = new Set<String>{
        'application',
        'consentAccepted',
        'partnerDetails'
    };

    public static Id validateRequest(Map<String, Object> requestMap) {
        String applicationName = (String) requestMap.get(PartnerAPIConstants.APPLICATION);
        Boolean consentAccepted = (Boolean) requestMap.get(PartnerProcessApplications.CONSENT_ACCEPTED);

        if(!consentAccepted){
            throw new PartnerProcessApplicationException(PartnerProcessApplications.CONSENT_ACCEPTED_TRUE);
        }

        Map<String, Object> partnerDetailsMap = (Map<String, Object>) requestMap.get(PartnerAPIConstants.PARTNER_DETAILS);
        String partnerEmail = (String) partnerDetailsMap.get(PartnerAPIConstants.PARTNER_EMAIL);
        String partnerAPIKey = (String) partnerDetailsMap.get(PartnerAPIConstants.PARTNER_API_KEY);

        Map<String, Object> responseData = PartnerAPIHelpers.genericPartnerAPIValidation(partnerEmail, applicationName, partnerAPIKey);
        genesis__Applications__c application = (genesis__Applications__c) responseData.get(PartnerAPIConstants.APPLICATION_DETAILS);

        return application.Id;
    }

    public static void invokeApplicationProcess(Id applicationId) {
        CCBPConsentCommentsAPI consentAPI = new CCBPConsentCommentsAPI();
        List<String> buildDisclosures = new List<String> { PortalConstants.CC_Broker_General_Disclosure };
        Map<String, Object> buildRequest = new Map<String, Object>{
            PortalConstants.APPLICATION_ID => applicationId,
            PartnerAPIConstants.PARTNER_INFO => true
        };
        clcommon.Response response = consentAPI.invokeAction(null, buildDisclosures, buildRequest);

        if(response.status != clcommon.Constants.SUCCESS){
            throw new PartnerProcessApplicationException(response.errorMessage);
        }
    }

    private class PartnerProcessApplicationException extends Exception {}
}