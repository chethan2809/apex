@RestResource(urlMapping='/v1/healthcheck/*')
global class HealthCheckAPI {
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    public final static String EOD_JOBS = 'EODJobs';

    @HttpGet
    global static void processHealthCheckGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.statusCode = 200;
    }

    @HttpPost
    global static void processHealthCheckPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String reqParameter = req.requestURI.substring(
            req.requestURI.lastIndexOf('/')+1
        );
        String requestBody = APIHelpers.sanitizeString(req.RequestBody.toString());
        Map<String, Object> responseMap = new Map<String, Object>();
        if(reqParameter == EOD_JOBS) {
            try {
                Map<String, Object> returnRecords = (Map<String, Object>) APIHelpers.objectValidation(
                    JSON.deserializeUntyped(requestBody), 'Map', 'Request body'
                );

                if(returnRecords.isEmpty()) {
                    throw new HealthCheckAPIException('The payload passed in is empty');
                }

                Map<String, Object> dateMap = (Map<String, Object>) returnRecords.get('inputBody');
                System.debug('00dateValue'+dateMap);
                String dateValue = (String) dateMap.get('Date');
                System.debug('00dateValue'+dateValue);

                Date responseDate = GeneralHelper.getDateFromUntypedString(dateValue, 0, 1, 2, '-');

                System.debug('00responseDate'+responseDate);

                /*if(responseDate != GeneralHelper.currentSystemDate) {
                    throw new HealthCheckAPIException('The entered date is not current date');
                }*/

                clcommon__DAG_Logging__c dagLoggings = [SELECT Id, Name FROM clcommon__DAG_Logging__c WHERE DAY_ONLY(clcommon__Start_Time__c) = :responseDate];

                System.debug('00dagLoggings'+dagLoggings);
                responseMap.put('message', 'Success');

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
    }

    private class HealthCheckAPIException extends Exception {}
}