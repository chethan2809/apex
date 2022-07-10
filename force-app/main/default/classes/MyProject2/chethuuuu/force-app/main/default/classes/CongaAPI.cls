@RestResource(urlMapping='/v1/congaautomation/*')
global class CongaAPI {
    @HttpPost
    global static void processCongaDocuments() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String requestBody = APIHelpers.sanitizeString(req.RequestBody.toString());
        Map<String, Object> responseMap = new Map<String, Object>();

        try {
            Map<String, Object> requestRecord = (Map<String, Object>) APIHelpers.objectValidation(
                JSON.deserializeUntyped(requestBody), 'Map', 'Request body'
            );

            if(requestRecord.isEmpty()) {
                throw new CongaAPIException('The payload passed in is empty');
            }

            System.enqueueJob(new CongaQueueableJob(requestRecord));

            APIHelpers.setSuccessResponse(res, null);

        } catch (Exception e) {
            APIHelpers.setErrorResponse(res, e);
        }
    }

    private class CongaAPIException extends Exception {}
}