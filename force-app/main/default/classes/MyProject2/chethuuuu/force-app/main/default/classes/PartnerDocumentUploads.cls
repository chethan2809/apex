public class PartnerDocumentUploads {
    public static final String DOCUMENT_TYPE = 'documentType';
    public static final String NO_DOCUMENT_CATEGORY = 'There was no document category found for the requested documentType';
    public static final String REQUEST_BODY_IS_EMPTY = 'The request body is empty';
    public static final String NAME = 'name';
    public static final  Set<String> REQUEST_KEYS_TO_VALIDATE = new Set<String>{
        'application',
        'partnerEmail',
        'partnerAPIKey',
        'name',
        'documentType'
    };

    public static Id validateRequest(RestRequest request) {
        String applicationName = request.params.get(PartnerAPIConstants.APPLICATION);
        String partnerEmail = request.params.get(PartnerAPIConstants.PARTNER_EMAIL);
        String partnerAPIKey = request.params.get(PartnerAPIConstants.PARTNER_API_KEY);

        Map<String, Object> responseDataMap = PartnerAPIHelpers.genericPartnerAPIValidation(partnerEmail, applicationName, partnerAPIKey);
        genesis__Applications__c application = (genesis__Applications__c) responseDataMap.get(PartnerAPIConstants.APPLICATION_DETAILS);

        return application.Id;
    }
}