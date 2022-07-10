@isTest
private class APIHelpersTests {

    @isTest
    private static void sanitizeString() {
        String sanitizeValue = 'Test Value';
        Test.startTest();
            String sanitizeString = APIHelpers.sanitizeString(sanitizeValue);
        Test.stopTest();

        System.assertEquals(sanitizeValue, sanitizeString);
    }

    @isTest
    private static void objectValidationCheckString() {
        String s = 'Test';
        String typeToCheck = 'String';
        object inputObject = s;

        Test.startTest();
            Object testObject = APIHelpers.objectValidation(inputObject, typeToCheck, 'X');
        Test.stopTest();

        System.assert(testObject instanceof String, 'Return Object is not a string');
    }

    @isTest
    static void objectValidationCheckIntegerFail() {
        String s = '100';
        String typeToCheck = 'Integer';
        Object inputObject = s;
        Object testObject;

        String exString;
        Test.startTest();
            try{
                testObject = APIHelpers.objectValidation(inputObject, typeToCheck, 'X');
            } catch (Exception e) {
                exString = e.getMessage();
            }
        Test.stopTest();

        System.assertNotEquals(null, exString, 'Exception expected and none occurred');
    }

    @isTest
    static void objectValidationCheckIntegerPass() {
        Integer i = 100;
        String typeToCheck = 'Integer';
        Object inputObject = i;

        Test.startTest();
            Object testObject = APIHelpers.objectValidation(inputObject, typeToCheck, 'X');
        Test.stopTest();

        System.assert(testObject instanceof Integer, 'Type was supposed to be Integer');
    }

    @isTest
    static void objectValidationCheckDateTimePass() {
        String dt = '2019-09-13 15:55:00';
        String typeToCheck = 'DateTime';
        Object inputObject = dt;
        Object testObject;
        Test.startTest();
            testObject = APIHelpers.objectValidation(inputObject, typeToCheck, 'X');
        Test.stopTest();

        System.assert(testObject instanceof Datetime, 'Type was supposed to be DateTime');
    }

    @isTest
    static void objectValidationCheckDatePass() {
        String d = '2019-01-01';
        String typeToCheck = 'Date';
        Object inputObject = d;
        Object testObject;
        Test.startTest();
            testObject = APIHelpers.objectValidation(inputObject, typeToCheck, 'X');
        Test.stopTest();

        System.assert(testObject instanceof Date, 'Type was supposed to be Date');
    }

    @isTest
    static void objectValidationCheckIdPass() {
        Id id = TestUtility.getFakeId(Account.getSObjectType());
        String typeToCheck = 'Id';
        Object inputObject = id;
        Object testObject;
        Test.startTest();
            testObject = APIHelpers.objectValidation(inputObject, typeToCheck, 'X');
        Test.stopTest();

        System.assert(testObject instanceof Id, 'Type was supposed to be Id');
    }

    @isTest
    static void objectValidationCheckBooleanPass() {
        Boolean b = false;
        String typeToCheck = 'Boolean';
        Object inputObject = b;
        Object testObject;
        Test.startTest();
            testObject = APIHelpers.objectValidation(inputObject, typeToCheck, 'X');
        Test.stopTest();

        System.assert(testObject instanceof Boolean, 'Type was supposed to be Boolean');
    }

    @isTest
    static void objectValidationCheckDecimalPass() {
        Decimal d = 0.213213213213;
        String typeToCheck = 'Decimal';
        Object inputObject = d;
        Object testObject;
        Test.startTest();
            testObject = APIHelpers.objectValidation(inputObject, typeToCheck, 'X');
        Test.stopTest();

        System.assert(testObject instanceof Decimal, 'Type was supposed to be Decimal');
    }

    @isTest
    static void objectValidationCheckDoublePass() {
        Double d = 0.213213213213;
        String typeToCheck = 'Double';
        Object inputObject = d;
        Object testObject;
        Test.startTest();
            testObject = APIHelpers.objectValidation(inputObject, typeToCheck, 'X');
        Test.stopTest();

        System.assert(testObject instanceof Double, 'Type was supposed to be Double');
    }

    @isTest
    static void objectValidationCheckLongPass() {
        Long l = 2147483648L;
        String typeToCheck = 'Long';
        Object inputObject = l;
        Object testObject;
        Test.startTest();
            testObject = APIHelpers.objectValidation(inputObject, typeToCheck, 'X');
        Test.stopTest();

        System.assert(testObject instanceof Long, 'Type was supposed to be Long');
    }

    @isTest
    static void objectValidationCheckSObjectPass() {
        Account a = new Account();
        String typeToCheck = 'SObject';
        Object inputObject = a;
        Object testObject;
        Test.startTest();
            testObject = APIHelpers.objectValidation(inputObject, typeToCheck, 'X');
        Test.stopTest();

        System.assert(testObject instanceof SObject, 'Type was supposed to be SObject');
    }

    @isTest
    static void objectValidationCheckListPass() {
        List<Object> listObject = new List<Object>();
        String typeToCheck = 'List';
        Object inputObject = listObject;
        Object testObject;
        Test.startTest();
            testObject = APIHelpers.objectValidation(inputObject, typeToCheck, 'X');
        Test.stopTest();

        System.assert(testObject instanceof List<Object>, 'Type was supposed to be List');
    }

    @isTest
    static void objectValidationCheckMapPass() {
        Map<String,Object> mapSO = new Map<String,Object>();
        String typeToCheck = 'Map';
        Object inputObject = mapSO;
        Object testObject;
        Test.startTest();
            testObject = APIHelpers.objectValidation(inputObject, typeToCheck, 'X');
        Test.stopTest();

        System.assert(testObject instanceof Map<String,Object>, 'Type was supposed to be Map');
    }

    @isTest
    static void objectValidationNullCheck() {
        String nullObject = '';
        String typeToCheck = '';
        Object inputObject = nullObject;
        Object testObject;
        Test.startTest();
            testObject = APIHelpers.objectValidation(inputObject, typeToCheck, '');
        Test.stopTest();

        System.assert(testObject == null);
    }

    @isTest
    static void isRequestBodyEmpty() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        Test.startTest();
            Boolean result = APIHelpers.isRequestBodyEmpty(req,res);
        Test.stopTest();

        System.assert(result);
    }

    @isTest
    static void isRequestBodyEmptyEmptyString() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('');

        Test.startTest();
            Boolean result = APIHelpers.isRequestBodyEmpty(req,res);
        Test.stopTest();

        System.assert(result);
    }

    @isTest
    static void validateId() {
        Id fakeId = TestUtility.getFakeId(Account.getSObjectType());

        Test.startTest();
            Boolean result = APIHelpers.validateId(fakeId);
        Test.stopTest();

        System.assert(result);
    }

    @isTest
    static void validateBodyRequiredFields() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        Map<String, Object> requestBodyMap = new Map<String, Object>();
        requestBodyMap.put('a','a');

        Boolean valid;
        Test.startTest();
            valid = APIHelpers.validateBodyRequiredFields(res, requestBodyMap, new Set<String>{'a'});
        Test.stopTest();

        System.assert(valid);
    }

    @isTest
    static void validateBodyRequiredFieldsFail() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        Map<String, Object> requestBodyMap = new Map<String, Object>();
        requestBodyMap.put('a','a');

        Boolean valid;
        Test.startTest();
            valid = APIHelpers.validateBodyRequiredFields(res, requestBodyMap, new Set<String>{'b'});
        Test.stopTest();

        System.assert(!valid);
    }

    @isTest
    static void validateBodyRequiredFieldsNull() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        Map<String, Object> requestBodyMap = new Map<String, Object>();
        requestBodyMap.put('Y', null);

        Boolean valid;
        Test.startTest();
            valid = APIHelpers.validateBodyRequiredFields(res, requestBodyMap, new Set<String>{'Y'});
        Test.stopTest();

        System.assert(!valid);
    }

    @isTest
    static void validateBodyRequiredSubFieldsByLoanDetails() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        Map<String, Object> requestBodyMapValues = new Map<String, Object>();
        requestBodyMapValues.put('Name', 'Test');

        Map<String, Object> requestBodyMap = new Map<String, Object>();
        requestBodyMap.put(PartnerCreateApplications.LOAN_DETAILS, requestBodyMapValues);

        Boolean valid;
        Test.startTest();
            valid = APIHelpers.validateBodyRequiredSubFieldsBySectionName(res, requestBodyMap);
        Test.stopTest();

        System.assert(!valid);
    }

    @isTest
    static void validateBodyRequiredSubFieldsByPartnerDetails() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        Map<String, Object> requestBodyMapValues = new Map<String, Object>();
        requestBodyMapValues.put('Name', 'Test');

        Map<String, Object> requestBodyMap = new Map<String, Object>();
        requestBodyMap.put(PartnerAPIConstants.PARTNER_DETAILS, requestBodyMapValues);

        Boolean valid;
        Test.startTest();
            valid = APIHelpers.validateBodyRequiredSubFieldsBySectionName(res, requestBodyMap);
        Test.stopTest();

        System.assert(!valid);
    }

    @isTest
    static void validateBodyRequiredSubFieldsByAccountDetails() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        Map<String, Object> requestBodyMapValues = new Map<String, Object>();
        requestBodyMapValues.put('Name', 'Test');

        Map<String, Object> requestBodyMap = new Map<String, Object>();
        requestBodyMap.put(PartnerCreateApplications.ACCOUNT_DETAILS, requestBodyMapValues);

        Boolean valid;
        Test.startTest();
            valid = APIHelpers.validateBodyRequiredSubFieldsBySectionName(res, requestBodyMap);
        Test.stopTest();

        System.assert(!valid);
    }

    @isTest
    static void validateBodyRequiredSubFieldsByContactDetails() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        Map<String, Object> requestBodyMapValues = new Map<String, Object>();
        requestBodyMapValues.put('Name', 'Test');

        Map<String, Object> requestBodyMap = new Map<String, Object>();
        requestBodyMap.put(PartnerCreateApplications.CONTACT_DETAILS, requestBodyMapValues);

        Boolean valid;
        Test.startTest();
            valid = APIHelpers.validateBodyRequiredSubFieldsBySectionName(res, requestBodyMap);
        Test.stopTest();

        System.assert(!valid);
    }

    @isTest
    static void validateFieldsBySectionNames() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        Map<String, Object> requestBodyMapValues = new Map<String, Object>();
        requestBodyMapValues.put('City', 'Test');

        Map<String, Object> requestBodyMap = new Map<String, Object>();
        requestBodyMap.put('abc', requestBodyMapValues);

        String sectionName = 'abc';
        Set<String> requiredFieldsSet = new Set<String>{'Name', 'Phone'};
        Map<String, List<String>> sectionNameToFieldNameListMap = new Map<String, List<String>>();
        Map<String, List<String>> sectionNameToFieldNameValueListMap = new Map<String, List<String>>();

        Test.startTest();
            APIHelpers.validateFieldsBySectionNames(
                sectionName, requestBodyMap, requiredFieldsSet, sectionNameToFieldNameListMap, sectionNameToFieldNameValueListMap
            );
        Test.stopTest();

        System.assert(sectionNameToFieldNameListMap.containsKey(sectionName));
    }

    @isTest
    static void validateRequestParamsRequiredFields() {
        RestRequest req = new RestRequest();
        req.addParameter('KEY', 'VALUE');
        RestResponse res = new RestResponse();

        Boolean valid;
        Test.startTest();
            valid = APIHelpers.validateRequestParamsRequiredFields(res, req, new Set<String>{'KEY'});
        Test.stopTest();

        System.assert(valid);
    }

    @isTest
    static void validateRequestParamsNoKey() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        Boolean valid;
        Test.startTest();
            valid = APIHelpers.validateRequestParamsRequiredFields(res, req, new Set<String>{'KEY'});
        Test.stopTest();

        System.assert(!valid);
        System.assertEquals(400, res.statusCode);
        System.assertEquals('[{"message" : "There is no \'KEY\' key in the request"}]', res.responseBody.toString());
    }

    @isTest
    static void validateRequestParamsFieldsNoValue() {
        RestRequest req = new RestRequest();
        req.addParameter('KEY', '');

        RestResponse res = new RestResponse();

        Boolean valid;
        Test.startTest();
            valid = APIHelpers.validateRequestParamsRequiredFields(res, req, new Set<String>{'KEY'});
        Test.stopTest();

        System.assert(!valid);
        System.assertEquals(400, res.statusCode);
        System.assertEquals('[{"message" : Value of key \'KEY\' is null in the request"}]', res.responseBody.toString());
    }

    @isTest
    static void validateRequestHeaderRequiredFields() {
        RestRequest req = new RestRequest();
        req.addHeader('KEY', 'VALUE');

        RestResponse res = new RestResponse();

        Boolean valid;
        Test.startTest();
            valid = APIHelpers.validateRequestHeadersFields(res, req, new Set<String>{'KEY'});
        Test.stopTest();

        System.assert(valid);
    }

    @isTest
    static void validateRequestHeaderFieldsNoKey() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        Boolean valid;
        Test.startTest();
            valid = APIHelpers.validateRequestHeadersFields(res, req, new Set<String>{'KEY'});
        Test.stopTest();

        System.assert(!valid);
        System.assertEquals(400, res.statusCode);
        System.assertEquals('[{"message" : "There is no \'KEY\' key in the request header"}]', res.responseBody.toString());
    }

    @isTest
    static void validateHeaderFieldsNoValue() {
        RestRequest req = new RestRequest();
        req.addHeader('KEY', '');

        RestResponse res = new RestResponse();

        Boolean valid;
        Test.startTest();
            valid = APIHelpers.validateRequestHeadersFields(res, req, new Set<String>{'KEY'});
        Test.stopTest();

        System.assert(!valid);
        System.assertEquals(400, res.statusCode);
        System.assertEquals('[{"message" : Value of key \'KEY\' is null in the request header"}]', res.responseBody.toString());
    }

    @isTest
    static void validateExpectedHeaderValue() {
        RestResponse res = new RestResponse();

        Boolean valid;
        Test.startTest();
            valid = APIHelpers.validateExpectedHeaderValues(res, new Map<String,String>{'Header Value' => 'Header Value'});
        Test.stopTest();

        System.assert(valid);
    }

    @isTest
    static void validateExpectedHeaderValueMisMatch() {
        RestResponse res = new RestResponse();

        Boolean valid;
        Test.startTest();
            valid = APIHelpers.validateExpectedHeaderValues(res, new Map<String,String>{'Header Value' => 'Header Mismatch'});
        Test.stopTest();

        System.assert(!valid);
        System.assertEquals(400, res.statusCode);
        System.assertEquals(
            '[{"message" : "Expected header value \'Header Value\' does not match actual value \'Header Mismatch\'"}]',
            res.responseBody.toString()
        );
    }

    @isTest
    static void isRequestParamsEmptyTrueWithResponse(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        Test.startTest();
            Boolean isRequestParamsEmpty = APIHelpers.isRequestParamsEmpty(req, res);
        Test.stopTest();

        System.assert(isRequestParamsEmpty);
        System.assertEquals(res.statusCode, 400);
        System.assertEquals(res.responseBody, Blob.valueOf('[{"message" : "Params are Empty"}]'));
    }

    @isTest
    static void isRequestParamsEmptyFalseWithResponse(){
        RestRequest req = new RestRequest();
        req.addParameter('KEY', 'VALUE');

        RestResponse res = new RestResponse();

        Test.startTest();
            Boolean isRequestParamsEmpty = APIHelpers.isRequestParamsEmpty(req, res);
        Test.stopTest();

        System.assert(!isRequestParamsEmpty);
        System.assertEquals(res.statusCode, null);
        System.assertEquals(res.responseBody, null);
    }

    @isTest
    static void setErrorResponseWithErrorMessage(){
        RestResponse res = new RestResponse();
        String errorMessage = 'error message';

        Test.startTest();
            APIHelpers.setErrorResponse(res, errorMessage);
        Test.stopTest();

        System.assertEquals(500, res.statusCode);
        System.assertEquals(Blob.valueOf('[{"message":"error message"}]'), res.responseBody);
    }

    @isTest
    static void setErrorResponseWithException(){
        RestResponse res = new RestResponse();

        Exception testException;
        Test.startTest();
            try {
                Integer i = 1/0;
            } catch (Exception e) {
                APIHelpers.setErrorResponse(res, e);
                testException = e;
            }
        Test.stopTest();

        System.assertEquals(500, res.statusCode);
        System.assertEquals('[{"stacktrace":"'+testException.getStackTraceString()+'","message":"Divide by 0"}]',
            res.responseBody.toString());
    }

    @isTest
    static void setErrorResponseWithResponseBodyMap(){
        RestResponse res = new RestResponse();
        Map<String,Object> responseBodyMap = new Map<String,Object> {'errorMessage' => 'error message'};

        Test.startTest();
            APIHelpers.setErrorResponse(res, responseBodyMap);
        Test.stopTest();

        System.assertEquals(500, res.statusCode);
        System.assertEquals(Blob.valueOf('[{"errorMessage":"error message"}]'), res.responseBody);
    }

    @isTest
    static void setSuccessResponse(){
        RestResponse res = new RestResponse();

        Test.startTest();
            APIHelpers.setSuccessResponse(res);
        Test.stopTest();

        System.assertEquals(200, res.statusCode);
        System.assertEquals(Blob.valueOf('[{"message":"Success"}]'), res.responseBody);
    }

    @isTest
    static void setSuccessResponseWithResponseBodyMap(){
        RestResponse res = new RestResponse();
        Map<String,Object> responseBodyMap = new Map<String,Object> {'errorMessage' => null};

        Test.startTest();
            APIHelpers.setSuccessResponse(res, responseBodyMap);
        Test.stopTest();

        System.assertEquals(200, res.statusCode);
        System.assertEquals(Blob.valueOf('[{"errorMessage":null}]'), res.responseBody);
    }

    @isTest
    static void validateHMacSignatureAuthenticationTrue(){
        RestResponse res = new RestResponse();
        String signature = '21886a3f4f3cd3e177c196ee52d3e80443b085cf5e8cb7cc1c69bac78799a67238da1372759fb80eaab57e8e' +
            + 'b27f2c6e663d5f520d60270790567ddbf7cd2ef9';
        Blob dataToSign = Blob.valueOf('FAKE REQUEST BODY');
        Blob key = Blob.valueOf('FAKE KEY');
        String algorithm = 'hmacSHA512';

        Test.startTest();
            Boolean isHMacSignatureValid = APIHelpers.validateHMacSignatureAuthentication(
                res, signature, dataToSign, key, algorithm
            );
        Test.stopTest();

        System.assert(isHMacSignatureValid);
    }

    @isTest
    static void validateHMacSignatureAuthenticationFalse(){
        RestResponse res = new RestResponse();
        String signature = 'FAKE SIGNATURE';
        Blob dataToSign = Blob.valueOf('FAKE REQUEST BODY');
        Blob key = Blob.valueOf('DUMMY KEY');
        String algorithm = 'hmacSHA512';

        Test.startTest();
            Boolean isHMacSignatureValid = APIHelpers.validateHMacSignatureAuthentication(
                res, signature, dataToSign, key, algorithm
            );
        Test.stopTest();

        System.assert(!isHMacSignatureValid);
        System.assertEquals(401, res.statusCode);
        System.assertEquals(Blob.valueOf('[{"message" : "Authentication failure"}]'), res.responseBody);
    }

    @isTest
    static void isMacSignatureValid(){
        RestResponse res = new RestResponse();
        Blob signature = Blob.valueOf('FAKE SIGNATURE');
        Blob dataToSign = Blob.valueOf('FAKE REQUEST BODY');
        Blob key = Blob.valueOf('DUMMY KEY');
        String algorithm = 'hmacSHA512';

        Test.startTest();
            Boolean isMacSignatureValid = APIHelpers.isMacSignatureValid(
                res, signature, dataToSign, key, algorithm
            );
        Test.stopTest();

        System.assert(!isMacSignatureValid);
        System.assertEquals(401, res.statusCode);
        System.assertEquals(Blob.valueOf('[{"message" : "Authentication failure"}]'), res.responseBody);
    }
}