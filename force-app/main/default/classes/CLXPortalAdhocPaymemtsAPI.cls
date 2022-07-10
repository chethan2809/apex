global class CLXPortalAdhocPaymemtsAPI implements clcommon.PortalCustomRemoteAPI1 {

    public static CLContractDB clContractDBInstance = new CLContractDB();
    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> argumentsFromPortal) {
        // Init parameter.
        clcommon.Response response = new clcommon.Response();
        String contractId = (String)argumentsFromPortal.get('contractId');
        List<loan__Loan_Account__c> contractList = clContractDBInstance.getLoanAccountsByIds(new Set<Id>{contractId});
        if(!contractList.isEmpty()){
            Boolean isValidAccount = PortalSecurityUtil.validateUserByBorrowerAccountId(contractList[0].loan__Account__c);
            if(isValidAccount){
                Decimal paymentAmt = (Decimal)argumentsFromPortal.get('paymentAmt');
                Boolean payoffFlg = (Boolean)argumentsFromPortal.get('payoffFlg');
                String responseMsg;
                try{
                    responseMsg = CLXPortalAPS.createAdhocPayment(contractId, paymentAmt,payoffFlg);
                    if (responseMsg == null){
                        return getErrorResponse(PortalConstants.ERROR_MESSAGE);
                    }
                    if ((!responseMsg.equalsIgnoreCase(CLXConstants.PAYOFF_SUC_RESPONSE))&&(!responseMsg.equalsIgnoreCase(CLXConstants.PAYMENT_SUC_RESPONSE))&&(!responseMsg.equalsIgnoreCase(CLXConstants.PAYMENT_FAIL_RESPONSE))){
                        return getErrorResponse(responseMsg);
                    }
                    response.status = clcommon.Constants.SUCCESS;
                    Map<String,Object> fields = new Map<String,Object>();
                    fields.put('responseMsg',responseMsg);
                    List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
                    respList.add(new clcommon.PortalCustomRemoteActionRecord('KEY_RESPONSE', fields));
                    response = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
                }catch (Exception e) {
                    Error_Log__c errorLog = ErrorLogs.createErrorLog (
                    PortalConstants.MP_ONE_TIME_PAYMENT_ACH_ERROR, e.getMessage(), e.getStackTraceString(),
                    null, ErrorLogs.ERROR, contractId, true);
                    errorLogDBInstance.addInsert(errorLog);
                    errorLogDBInstance.executeInserts();
                    response.status = clcommon.Constants.API_EXCEPTION;
                    response.errorMessage = PortalConstants.MP_ONE_TIME_PAYMENT_ACH_ERROR;
                }
            }
            else{
                Error_Log__c errorLog = ErrorLogs.createErrorLog (
                PortalConstants.MP_ONE_TIME_PAYMENT_ACH_ERROR, PortalConstants.NO_PERMISSION_ERROR_MSG, null,
                null, ErrorLogs.ERROR, null, true);
                errorLogDBInstance.addInsert(errorLog);
                errorLogDBInstance.executeInserts();
                response.status = clcommon.Constants.API_EXCEPTION;
                response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG_MESSAGE;
            }
        }
        else{
            Error_Log__c errorLog = ErrorLogs.createErrorLog (
                    PortalConstants.MP_ONE_TIME_PAYMENT_ACH_ERROR, PortalConstants.UNABLE_TO_FIND_CONTRACT_INFO, null,
                    null, ErrorLogs.ERROR, contractId, true);
            errorLogDBInstance.addInsert(errorLog);
            errorLogDBInstance.executeInserts();
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG_MESSAGE;
        }
        return response;
    }

    private clcommon.Response getErrorResponse(String errorMessage) {
        clcommon.Response response = new clcommon.Response();
        response.status = clcommon.Constants.ERROR;
        response.errorMessage = errorMessage;
        response.errorCode = clcommon.Constants.API_EXCEPTION;
        return response;
    }
}