@RestResource(urlMapping='/v1/achreturns/*')
global class ACHReturnsAPI {
    @HttpPost
    global static void processACHReturns() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String requestBody = APIHelpers.sanitizeString(req.RequestBody.toString());
        Map<String, Object> responseMap = new Map<String, Object>();

        try {
            Map<String, Object> returnRecords = (Map<String, Object>) APIHelpers.objectValidation(
                JSON.deserializeUntyped(requestBody), 'Map', 'Request body'
            );

            if(returnRecords.isEmpty()) {
                throw new ACHReturnsAPIException('The payload passed in is empty');
            }

            Integer filesProcessedCount = ACHReturnsManager.processACHReturnFiles(returnRecords);

            responseMap.put('message', 'Saved ' + filesProcessedCount + ' files to ACH Return');

            res.statusCode = 200;
            List<Object> responseObject = new List<Object>();
            responseObject.add(responseMap);
            Blob responseBody = Blob.valueOf(JSON.serialize(responseObject));
            res.responseBody = responseBody;

        } catch (Exception e) {
            responseMap.put('message', e.getMessage() + e.getStackTraceString());
            res.statusCode = 500;
            List<Object> responseObject = new List<Object>();
            responseObject.add(responseMap);
            Blob responseBody = Blob.valueOf(JSON.serialize(responseObject));
            res.responseBody = responseBody;
        }
    }

    private class ACHReturnsAPIException extends Exception {}
}