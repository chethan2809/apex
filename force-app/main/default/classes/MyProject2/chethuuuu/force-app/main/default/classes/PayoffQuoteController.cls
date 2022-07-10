global without sharing class PayoffQuoteController implements clcommon.PortalCustomRemoteAPI1{
    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    public static CLContractDB clContractDBInstance = new CLContractDB();

    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> params){
        clcommon.Response res = new clcommon.Response();
        res.status=PortalConstants.API_RESPONSE_STATUS_SUCCESS;
        res.errorMessage = null;
        String contractId;
        try{
            contractId = String.valueOf(params.get('contractId'));
            List<loan__Loan_Account__c> contractList = clContractDBInstance.getLoanAccountsByIds(new Set<Id>{contractId});
            if(!contractList.isEmpty()){
                Boolean isValidAccount = PortalSecurityUtil.validateUserByBorrowerAccountId(contractList[0].loan__Account__c);
                if(isValidAccount){
                    Salesforce_Base_URL__c sfURL;
                    sfURL = Salesforce_Base_URL__c.getInstance('BaseURL');
                    String baseURL = sfURL.URL__c;
                    loan__Loan_Account__c contract = [select Id from loan__Loan_Account__c where Id =:contractId];
                    Date sysDate = GeneralHelper.currentSystemDate;
                    String transactDate =  sysDate.year()  + '-' + sysDate.month() + '-' + sysDate.day();
                    string endpointURL = baseURL + System.Label.PayQuoteAPIURL + contract.Id;
                    string jsonBody = '{"transactionDate" : \"' + transactDate + '\",\"payOffDate\" : \"' + transactDate + '\"}';
                    Http http = new Http();
                    HttpRequest req = new HttpRequest();
                    HttpResponse res1 = new HttpResponse();
                    req.setEndpoint(endpointURL);
                    req.setMethod('POST');
                    req.setHeader('Content-Type', 'application/json;charset=UTF-8');
                    req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
                    req.setBody(jsonBody);
                    try {
                        res1 =  http.send(req);
                        if(res1.getStatus() == 'OK'){
                            res.status=PortalConstants.API_RESPONSE_STATUS_SUCCESS;
                            res.errorMessage = null;
                        }
                        else{
                            res.status=PortalConstants.API_RESPONSE_STATUS_FAILED;
                            res.errorMessage = res1.getStatus();
                        }
                    }
                    catch(System.CalloutException e){
                        String description = 'Error: '+e.getMessage() + '; Stack Trace: '+e.getStackTraceString();
                        ErrorLogs.createErrorLog ('Error:', e.getMessage(), e.getStackTraceString(),
                        null, 'Error', null, true);
                        res.status=PortalConstants.API_RESPONSE_STATUS_FAILED;
                        res.errorMessage = PortalConstants.SOMETHING_WENT_WRONG_MESSAGE;
                    }
                }
                else{
                    Error_Log__c errorLog = ErrorLogs.createErrorLog (
                        PortalConstants.MP_PAYOFF_QUOTE_GENERATION_ERROR, PortalConstants.NO_PERMISSION_ERROR_MSG, null,
                        null, ErrorLogs.ERROR, null, true);
                    errorLogDBInstance.addInsert(errorLog);
                    errorLogDBInstance.executeInserts();
                    res.status = clcommon.Constants.API_EXCEPTION;
                    res.errorMessage = PortalConstants.SOMETHING_WENT_WRONG_MESSAGE;
                }
            }
            else{
                Error_Log__c errorLog = ErrorLogs.createErrorLog (
                        PortalConstants.MP_PAYOFF_QUOTE_GENERATION_ERROR, PortalConstants.UNABLE_TO_FIND_CONTRACT_INFO, null,
                        null, ErrorLogs.ERROR, contractId, true);
                    errorLogDBInstance.addInsert(errorLog);
                    errorLogDBInstance.executeInserts();
                    res.status = clcommon.Constants.API_EXCEPTION;
                    res.errorMessage = PortalConstants.SOMETHING_WENT_WRONG_MESSAGE;
            }
        }catch(Exception e){
            Error_Log__c errorLog = ErrorLogs.createErrorLog (
                    PortalConstants.MP_PAYOFF_QUOTE_GENERATION_ERROR, e.getMessage(), e.getStackTraceString(),
                    null, ErrorLogs.ERROR, contractId, true);
            errorLogDBInstance.addInsert(errorLog);
            errorLogDBInstance.executeInserts();
            res.status=PortalConstants.API_RESPONSE_STATUS_FAILED;
            res.errorMessage = PortalConstants.SOMETHING_WENT_WRONG_MESSAGE;
        }
        return res;
    }
}