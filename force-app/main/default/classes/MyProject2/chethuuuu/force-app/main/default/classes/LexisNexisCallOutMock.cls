@isTest
global class LexisNexisCallOutMock implements HttpCalloutMock{

	global HTTPResponse respond(HTTPRequest request) {

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        response.setStatus('OK');
        response.setBody('{"response":"SUCCESS"}');
        return response;
    }

    global class LexisNexisSuccessResponse implements HttpCalloutMock {
        global HttpResponse respond(HTTPRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setStatus('OK');

            Map<String, Object> responseBody = new Map<String, Object>();
            Map<String, Object> bidResponseMap = new Map<String, Object>();
            Map<String, Object> responseMap = new Map<String, Object>();
            Map<String, Object> resultMap = new Map<String, Object>();
            Map<String, Object> companyResultsMap = new Map<String, Object>();
            Map<String, Object> businessIdsMap = new Map<String, Object>();
            businessIdsMap.put('DotID', 0);
            businessIdsMap.put('EmpID', 0);
            businessIdsMap.put('POWID', 0);
            businessIdsMap.put('SeleID', 0);
            businessIdsMap.put('OrgID', 0);
            businessIdsMap.put('UltID', 0);
            companyResultsMap.put('BusinessIds', businessIdsMap);
            resultMap.put('CompanyResults', companyResultsMap);
            responseMap.put('Result', resultMap);
            bidResponseMap.put('response', responseMap);
            responseBody.put('BIID20ResponseEx', bidResponseMap);

            response.setBody(JSON.serialize(responseBody));
            return response;
        }
    }

    global class FraudScoreSuccessResponse implements HttpCalloutMock {
        global HttpResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setStatus('OK');

            Map<String, Object> responseBody = new Map<String, Object>();
            List<Object> modelList = new List<Object>();
            Map<String, Object> modelMap = new Map<String, Object>();
            Map<String, Object> resultMap = new Map<String, Object>();
            Map<String, Object> responseMap = new Map<String, Object>();
            modelMap.put('Model', modelList);
            resultMap.put('Result', modelMap);
            responseMap.put('response', resultMap);
            responseBody.put('SmallBusinessAnalyticsResponseEx', responseMap);

            response.setBody(JSON.serialize(responseBody));
            return response;
        }
    }
}