@isTest
private class ErrorLogsTests {

    @isTest
    private static void createErrorLogToApplication() {
        TestUtility.runSetupData();
        genesis__Applications__c dummyApplication = TestUtility.createApplication();
        API_Detail__mdt apiDetails = new API_Detail__mdt();
		Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Error_Log__c errorLog;
        System.Test.startTest();
        try{
            HttpRequest request = CallOutHelper.createRequest(apiDetails.Endpoint_URL__c, 'POST');
            HttpResponse response = CallOutHelper.sendRequest(null);
        }catch (Exception e){
            e.setMessage('Message | message | Request: | Response : \\s\\|\\s');
            errorLog = ErrorLogs.createErrorLog('Test Origin', e, applicationId, false);
        }
        System.Test.stopTest();

        System.assertEquals('Test Origin', errorLog.Origin__c);
    }

    @isTest
    private static void createErrorLogToContact() {
        Contact dummyContact = TestUtility.createContact();
        API_Detail__mdt apiDetails = CustomMetaDataHelper.apiDetailsByName.get(Experians.EXPERIAN_BUSINESS_API_SANDBOX);

        Error_Log__c errorLog;
        System.Test.startTest();
        try{
            HttpRequest request = CallOutHelper.createRequest(apiDetails.Endpoint_URL__c, '');
            HttpResponse response = CallOutHelper.sendRequest(request);
        }catch (Exception e){
            errorLog = ErrorLogs.createErrorLog('Test Origin', e, dummyContact.Id, false);
        }
        System.Test.stopTest();

        System.assertEquals(dummyContact.Id, errorLog.Contact__c);
    }

    @isTest
    private static void createErrorLogToCLLoan() {
        Id contractId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        API_Detail__mdt apiDetails = CustomMetaDataHelper.apiDetailsByName.get(Experians.EXPERIAN_BUSINESS_API_SANDBOX);

        Error_Log__c errorLog;
        System.Test.startTest();
        try{
            HttpRequest request = CallOutHelper.createRequest(apiDetails.Endpoint_URL__c, '');
            HttpResponse response = CallOutHelper.sendRequest(request);
        }catch (Exception e){
            errorLog = ErrorLogs.createErrorLog('Test Origin', e, contractId, false);
        }
        System.Test.stopTest();

        System.assertEquals(contractId, errorLog.Loan_Account__c);
    }

    @isTest
    private static void constructErrorMessageFromDatabaseResult() {
        Database.SaveResult result = (Database.SaveResult)JSON.deserialize(
            '{ "success" : false, "errors": [{"statusCode" : "ERROR", "message" : "ERROR MESSAGE"}]}' , Database.SaveResult.class
        );

        Test.startTest();
            String message = ErrorLogs.constructErrorMessageFromDatabaseResult(result.getErrors());
        Test.stopTest();

        System.assertEquals('\nERROR: ERROR MESSAGE', message);
    }

    private class CallOutException extends Exception {}
}