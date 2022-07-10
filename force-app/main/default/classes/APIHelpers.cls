public class APIHelpers {

    public static void constructRestResponse(RestResponse res, Integer statusCode, Blob body) {
        res.statusCode = statusCode;
        res.responseBody = body;
    }

    public static String sanitizeString(String value) {
        return String.escapeSingleQuotes(value);
    }

    public static Boolean validateId(String idToValidate) {
        return (idToValidate.length() == 15 || idToValidate.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', idToValidate);
    }

    public static Object objectValidation(Object objectToCheck, String typeToCheck, String fieldName) {
        Object returnObject;
        try {
            switch on typeToCheck {
                when 'String' {
                    returnObject = (String) objectToCheck;
                }
                when 'Integer' {
                    returnObject = (Integer) objectToCheck;
                }
                when 'DateTime' {
                    returnObject = DateTime.valueOfGmt((String) objectToCheck);
                }
                when 'Date' {
                    returnObject = Date.valueOf((String) objectToCheck);
                }
                when 'Id' {
                    returnObject = (Id) objectToCheck;
                }
                when 'Boolean' {
                    returnObject = (Boolean) objectToCheck;
                }
                when 'Decimal' {
                    returnObject = (Decimal) objectToCheck;
                }
                when 'Double' {
                    returnObject = (Double) objectToCheck;
                }
                when 'Long' {
                    returnObject = (Long) objectToCheck;
                }
                when 'SObject' {
                    returnObject = (SObject) objectToCheck;
                }
                when 'List' {
                    returnObject = (List<Object>) objectToCheck;
                }
                when 'Map' {
                    returnObject = (Map<String,Object>) objectToCheck;
                }
                when else {
                    returnObject = null;
                }
            }
            return returnObject;
        } catch (Exception e) {
            throw new TypeMismatchException('Type Mismatch found on field: ' + fieldName +' ('+typeToCheck+').');
        }
    }

    public static Boolean validateBodyRequiredFields(RestResponse response, Map<String, Object> requestBodyMap, Set<String> requiredFields) {
        for(String fieldName : requiredFields) {
            if(!requestBodyMap.containsKey(fieldName)) {
                Blob responseBody = Blob.valueOf('[{"message" : "There is no \''+ fieldName +'\' key in JSON Body"}]');
                APIHelpers.constructRestResponse(response, 400, responseBody);
                return false;
            } else if(requestBodyMap.get(fieldName) == null) {
                Blob responseBody = Blob.valueOf('[{"message" : Value of key \'' + fieldName +'\' is null in JSON Body"}]');
                APIHelpers.constructRestResponse(response, 400, responseBody);
                return false;
            }
        }

        return true;
    }

    public static Boolean validateBodyRequiredSubFieldsBySectionName(RestResponse response, Map<String, Object> requestBodyMap) {
        Map<String, List<String>> sectionNameToFieldNameListMap = new Map<String, List<String>>();
        Map<String, List<String>> sectionNameToFieldNameValueListMap = new Map<String, List<String>>();
        Map<String, Object> sectionDetailsMap = new Map<String, Object>();

        if(requestBodyMap.containsKey(PartnerCreateApplications.LOAN_DETAILS)){
            sectionDetailsMap.put(PartnerCreateApplications.LOAN_DETAILS, requestBodyMap.get(PartnerCreateApplications.LOAN_DETAILS));
            validateFieldsBySectionNames(
                PartnerCreateApplications.LOAN_DETAILS, sectionDetailsMap, PartnerCreateApplications.LOAN_DETAILS_SET, sectionNameToFieldNameListMap, sectionNameToFieldNameValueListMap
            );
        }

        if(requestBodyMap.containsKey(PartnerAPIConstants.PARTNER_DETAILS)){
            sectionDetailsMap.put(PartnerAPIConstants.PARTNER_DETAILS, requestBodyMap.get(PartnerAPIConstants.PARTNER_DETAILS));
            validateFieldsBySectionNames(
                PartnerAPIConstants.PARTNER_DETAILS, sectionDetailsMap, PartnerCreateApplications.PARTNER_DETAILS_SET, sectionNameToFieldNameListMap, sectionNameToFieldNameValueListMap
            );
        }

        if(requestBodyMap.containsKey(PartnerCreateApplications.ACCOUNT_DETAILS)){
            sectionDetailsMap.put(PartnerCreateApplications.ACCOUNT_DETAILS, requestBodyMap.get(PartnerCreateApplications.ACCOUNT_DETAILS));
            validateFieldsBySectionNames(
                PartnerCreateApplications.ACCOUNT_DETAILS, sectionDetailsMap, PartnerCreateApplications.ACCOUNT_DETAILS_SET, sectionNameToFieldNameListMap, sectionNameToFieldNameValueListMap
            );
        }

        if(requestBodyMap.containsKey(PartnerCreateApplications.CONTACT_DETAILS)){
            sectionDetailsMap.put(PartnerCreateApplications.CONTACT_DETAILS, requestBodyMap.get(PartnerCreateApplications.CONTACT_DETAILS));
            validateFieldsBySectionNames(
                PartnerCreateApplications.CONTACT_DETAILS, sectionDetailsMap, PartnerCreateApplications.CONTACT_DETAILS_SET, sectionNameToFieldNameListMap, sectionNameToFieldNameValueListMap
            );
        }

        if(!sectionNameToFieldNameListMap.isEmpty()){
            Blob responseBody = Blob.valueOf('[{"message" : "On Section \''+sectionNameToFieldNameListMap +'\' KeyWords are missing"}]');
            APIHelpers.constructRestResponse(response, 400, responseBody);

            return false;
        }
        if(!sectionNameToFieldNameValueListMap.isEmpty()){
            Blob responseBody = Blob.valueOf('[{"message" : "Value of keywords On Section \''+sectionNameToFieldNameValueListMap+'\' are missing"}]');
            APIHelpers.constructRestResponse(response, 400, responseBody);
            return false;
        }
        return true;
    }

    public static void validateFieldsBySectionNames(
        String sectionName, Map<String, Object> sectionDetailsMap, Set<String> requiredFieldsSet,
        Map<String, List<String>> sectionNameToFieldNameListMap, Map<String, List<String>> sectionNameToFieldNameValueListMap
    ){

        Boolean checkStateOfFormation = true;

        Map<String, Object> sectionValuesMap = (Map<String, Object>) sectionDetailsMap.get(sectionName);
        for(String fieldName : requiredFieldsSet) {
            if(!sectionValuesMap.containsKey(fieldName)) {
                if(sectionNameToFieldNameListMap.keySet().contains(sectionName)) {
                    sectionNameToFieldNameListMap.get(sectionName).add(fieldName);
                } else {
                    sectionNameToFieldNameListMap.put(sectionName, new List<String> {fieldName}
                    );
                }
            }
            if(sectionValuesMap.get(fieldName) == null || sectionValuesMap.get(fieldName) == '' && fieldName != 'stateOfFormation' &&
                ((sectionValuesMap.get(fieldName) != 'billingBuildingNumber') || 
                 (sectionValuesMap.get(fieldName) != 'mailingBuildingNumber') || 
                 (sectionValuesMap.get(fieldName) != 'loanPurpose')
                )) 
                {
                if(sectionNameToFieldNameValueListMap.keySet().contains(sectionName)) {
                    sectionNameToFieldNameValueListMap.get(sectionName).add(fieldName);
                } else {
                    sectionNameToFieldNameValueListMap.put(sectionName, new List<String> {fieldName}
                    );
                }
            }
            if(((sectionValuesMap.get(PartnerCreateApplications.BUSINESS_STRUCTURE_NAME) == GeneralConstants.LEGAL_TYPE_CORPORATION) ||
                (sectionValuesMap.get(PartnerCreateApplications.BUSINESS_STRUCTURE_NAME) == GeneralConstants.LEGAL_TYPE_PARTNERSHIP) ||
                (sectionValuesMap.get(PartnerCreateApplications.BUSINESS_STRUCTURE_NAME) == GeneralConstants.LEGAL_TYPE_LLP) ||
                (sectionValuesMap.get(PartnerCreateApplications.BUSINESS_STRUCTURE_NAME) == GeneralConstants.LEGAL_TYPE_LLC) ||
                (sectionValuesMap.get(PartnerCreateApplications.BUSINESS_STRUCTURE_NAME) == GeneralConstants.LEGAL_TYPE_LIMITED_PARTNERSHIP)
               )    
                && sectionValuesMap.get('stateOfFormation') == '' && checkStateOfFormation
            ){
                checkStateOfFormation = false;
                if(sectionNameToFieldNameValueListMap.keySet().contains(sectionName)) {
                    sectionNameToFieldNameValueListMap.get(sectionName).add('stateOfFormation');
                } else {
                    sectionNameToFieldNameValueListMap.put(sectionName, new List<String> {'stateOfFormation'});
                }
            }
        }
    }

    public static Boolean validateRequestParamsRequiredFields(RestResponse response, RestRequest request, Set<String> requiredFields) {
        for(String fieldName : requiredFields) {
            if(!request.params.containsKey(fieldName)) {
                Blob responseBody = Blob.valueOf('[{"message" : "There is no \''+ fieldName +'\' key in the request"}]');
                APIHelpers.constructRestResponse(response, 400, responseBody);
                return false;
            } else if(String.isBlank(request.params.get(fieldName))) {
                Blob responseBody = Blob.valueOf('[{"message" : Value of key \'' + fieldName +'\' is null in the request"}]');
                APIHelpers.constructRestResponse(response, 400, responseBody);
                return false;
            }
        }

        return true;
    }

    public static Boolean validateRequestHeadersFields(RestResponse response, RestRequest request, Set<String> requiredFields) {
        for(String fieldName : requiredFields) {
            if(!request.headers.containsKey(fieldName)) {
                Blob responseBody = Blob.valueOf('[{"message" : "There is no \''+ fieldName +'\' key in the request header"}]');
                APIHelpers.constructRestResponse(response, 400, responseBody);
                return false;
            } else if(String.isBlank(request.headers.get(fieldName))) {
                Blob responseBody = Blob.valueOf('[{"message" : Value of key \'' + fieldName +'\' is null in the request header"}]');
                APIHelpers.constructRestResponse(response, 400, responseBody);
                return false;
            }
        }

        return true;
    }

    public static Boolean validateExpectedHeaderValues(RestResponse response, Map<String,String> expectedHeaderToActualValue){
        for(String expectedHeaderValue : expectedHeaderToActualValue.keySet()) {
            if(expectedHeaderValue != expectedHeaderToActualValue.get(expectedHeaderValue)) {
                Blob responseBody = Blob.valueOf('[{"message" : "Expected header value \'' + expectedHeaderValue +
                    '\' does not match actual value \'' + expectedHeaderToActualValue.get(expectedHeaderValue) + '\'"}]');
                APIHelpers.constructRestResponse(response, 400, responseBody);
                return false;
            }
        }

        return true;
    }

    public static Boolean isRequestBodyEmpty(RestRequest request, RestResponse res) {
        if(checkForEmptyRequestBody(request)) {
            Blob responseBody = Blob.valueOf('[{"message" : "Body is Empty"}]');
            APIHelpers.constructRestResponse(res, 400, responseBody);
            return true;
        }

        return false;
    }

    public static Boolean checkForEmptyRequestBody(RestRequest request) {
        return request.requestBody == null || String.isEmpty(request.requestBody.toString());
    }

    public static Boolean isRequestParamsEmpty(RestRequest request, RestResponse res) {
        if(request.params == null || request.params.isEmpty()) {
            Blob responseBody = Blob.valueOf('[{"message" : "Params are Empty"}]');
            APIHelpers.constructRestResponse(res, 400, responseBody);
            return true;
        }

        return false;
    }

    public static void setErrorResponse(RestResponse res, Exception e) {
        Map<String,Object> bodyMap =
            new Map<String,Object> {'message' => e.getMessage(), 'stacktrace'=> e.getStackTraceString()};
        List<Object> responseListObject = new List<Object>();
        responseListObject.add(bodyMap);
        Blob responseBody = Blob.valueOf(JSON.serialize(responseListObject));
        APIHelpers.constructRestResponse(res, 500, responseBody);
    }

    public static void setErrorResponse(RestResponse res, String errorMessage) {
        Map<String,Object> bodyMap = new Map<String,Object> {'message' => errorMessage};
        List<Object> responseListObject = new List<Object>();
        responseListObject.add(bodyMap);
        Blob responseBody = Blob.valueOf(JSON.serialize(responseListObject));
        APIHelpers.constructRestResponse(res, 500, responseBody);
    }

    public static void setSuccessResponse(RestResponse res) {
        Map<String,Object> bodyMap = new Map<String,Object> {'message' => 'Success'};
        List<Object> responseListObject = new List<Object>();
        responseListObject.add(bodyMap);
        Blob responseBody = Blob.valueOf(JSON.serialize(responseListObject));
        APIHelpers.constructRestResponse(res, 200, responseBody);
    }

    public static Boolean isMacSignatureValid(RestResponse res, Blob signature, Blob dataToSign, Blob key, String algorithm) {
        String signatureBase64 = EncodingUtil.base64Encode(signature);
        String newSignatureBase64 = EncodingUtil.base64Encode(Crypto.generateMac(algorithm, dataToSign, key));
        Boolean isMacSignatureValid = signatureBase64.equals(newSignatureBase64);

        if(isMacSignatureValid){
                return true;
        }

        Blob responseBody = Blob.valueOf('[{"message" : "Authentication failure"}]');
        APIHelpers.constructRestResponse(res, 401, responseBody);
        return false;
    }

    public static void setErrorResponse(RestResponse res, Map<String,Object> responseBodyMap) {
        List<Object> responseListObject = new List<Object>();
        responseListObject.add(responseBodyMap);
        Blob responseBody = Blob.valueOf(JSON.serialize(responseListObject));
        APIHelpers.constructRestResponse(res, 500, responseBody);
    }

    public static void setSuccessResponse(RestResponse res, Map<String,Object> responseBodyMap) {
        List<Object> responseListObject = new List<Object>();
        responseListObject.add(responseBodyMap);
        Blob responseBody = Blob.valueOf(JSON.serialize(responseListObject));
        APIHelpers.constructRestResponse(res, 200, responseBody);
    }

    public static Boolean validateHMacSignatureAuthentication(
        RestResponse res, String signature, Blob dataToSign, Blob key, String algorithm
    ) {

        String newHMacSignature = EncodingUtil.convertToHex(Crypto.generateMac(algorithm, dataToSign, key));
        Boolean isHMacSignatureValid = signature.equals(newHMacSignature);

        if(isHMacSignatureValid){
            return true;
        }

        Blob responseBody = Blob.valueOf('[{"message" : "Authentication failure"}]');
        APIHelpers.constructRestResponse(res, 401, responseBody);
        return false;
    }

    private class TypeMismatchException extends Exception {}
}