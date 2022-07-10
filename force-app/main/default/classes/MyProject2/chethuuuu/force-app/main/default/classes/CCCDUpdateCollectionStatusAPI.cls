global class CCCDUpdateCollectionStatusAPI implements clcommon.PortalCustomRemoteAPI1 {

    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    public static CollectionContractDB collectionContractDBInstance = new CollectionContractDB();

    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> params) {
        clcommon.Response response = new clcommon.Response();
        System.debug('Params:'+params);
        try {
            collect__Loan_Account__c collectionLoanAccount = new collect__Loan_Account__c();
            Id contractId = (ID)String.valueOf(params.get('contractId'));
            String collectionStatus = String.valueOf(params.get('collectionStatus'));
            String collectionSubStatus = String.valueOf(params.get('collectionSubStatus'));
            collectionLoanAccount.Id = contractId;
            collectionLoanAccount.Collection_Status__c = collectionStatus;
            collectionLoanAccount.Collection_Sub_Status__c = collectionSubStatus;
            collectionContractDBInstance.addUpdate(collectionLoanAccount);
            collectionContractDBInstance.executeUpdates();
            response.status = PortalConstants.API_RESPONSE_STATUS_SUCCESS;
            response.errorMessage = null;
        } catch (Exception ex) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog (
                'Collection Contract Status', ex.getMessage(), ex.getStackTraceString(),
                null, ErrorLogs.ERROR, null, true);
            errorLogDBInstance.addInsert(errorLog);
            errorLogDBInstance.executeInserts();
        return getErrorResponse(PortalConstants.COLLECTION_STATUS_UPDATE_ERROR);
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