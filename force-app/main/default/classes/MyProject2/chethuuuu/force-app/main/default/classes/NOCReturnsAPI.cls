@RestResource(urlMapping='/v1/nocreturns/*')
global class NOCReturnsAPI {
    @HttpPost
    global static void processNOCReturns() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String requestBody = APIHelpers.sanitizeString(req.RequestBody.toString());
        Map<String, Object> responseMap = new Map<String, Object>();

        try {
            Map<String, Object> returnRecords = (Map<String, Object>) APIHelpers.objectValidation(
                JSON.deserializeUntyped(requestBody), 'Map', 'Request body'
            );

            if(returnRecords.isEmpty()) {
                throw new NOCReturnsAPIException('The payload passed in is empty');
            }

            Integer filesProcessedCount = NOCReturnsManager.processNOCReturnFiles(returnRecords);

            //responseMap.put('message', 'Saved ' + filesProcessedCount + ' files to ACH Return');

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

    private class NOCReturnsAPIException extends Exception {}
}