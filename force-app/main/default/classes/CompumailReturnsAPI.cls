@RestResource(urlMapping='/v1/ncoareturns/*')
global class CompumailReturnsAPI {
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    @HttpPost
    global static void processNCOAReturns() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String requestBody = APIHelpers.sanitizeString(req.RequestBody.toString());
        Map<String, Object> responseMap = new Map<String, Object>();

        try {
            Map<String, Object> returnRecords = (Map<String, Object>) APIHelpers.objectValidation(
                JSON.deserializeUntyped(requestBody), 'Map', 'Request body'
            );

            if(returnRecords.isEmpty()) {
                throw new CompumailReturnsAPIException('The payload passed in is empty');
            }

            Integer filesProcessedCount = CompumailReturnsManager.processNCOAReturnFiles(returnRecords);

            responseMap.put('message', 'Processed ' + filesProcessedCount + ' files  Compumail NCOA Return');

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

            Error_Log__c errorLog = ErrorLogs.createErrorLog('Compumail NCOA Returns API', e, null, false);
            errorLogDBInstance.addInsert(errorLog).executeInserts();
        }
    }

    private class CompumailReturnsAPIException extends Exception {}
}