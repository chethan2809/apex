@RestResource(urlMapping = '/v1/partner/uploaddocs/*')
global class PartnerDocumentUploadAPI {
    @HttpPost
    global static void uploadDocument()
    {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        SavePoint dbSavePoint;

        if(!APIHelpers.validateRequestParamsRequiredFields(response, request, PartnerDocumentUploads.REQUEST_KEYS_TO_VALIDATE)){
            return;
        }

        if(request.requestBody == null || request.requestBody.size() == 0){
            String errorMsg = PartnerDocumentUploads.REQUEST_BODY_IS_EMPTY;
            APIHelpers.setErrorResponse(response, errorMsg);
            return;
        }

        try{
            dbSavePoint = Database.setSavePoint();
            PartnerDocumentUploadManager.uploadDocument(request);
            APIHelpers.setSuccessResponse(response);
        }
        catch(Exception e){
            Database.rollback(dbSavePoint);
            PartnerAPIHelpers.generateErrorLog('PartnerDocumentUploadAPI', JSON.serialize(request.params), e.getMessage() + e.getStackTraceString(), request.params.get(PartnerAPIConstants.PARTNER_EMAIL), request.params.get(PartnerAPIConstants.PARTNER_API_KEY));
            APIHelpers.setErrorResponse(response, e.getMessage());
        }
    }
}