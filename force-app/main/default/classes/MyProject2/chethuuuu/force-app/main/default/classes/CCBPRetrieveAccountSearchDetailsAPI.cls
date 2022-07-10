global class CCBPRetrieveAccountSearchDetailsAPI implements clcommon.PortalCustomRemoteAPI1 {
    public static AccountDB accountDBInstance = new AccountDB();
    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    public static AccountShareDB accountShareDBInstance = new AccountShareDB();
    public static UserDB userDBInstance = new UserDB();
    public static CLCommonRelationshipDB clCommonRelationshipDBInstance = new CLCommonRelationshipDB();
    public static CLCommonReciprocalRoleDB clCommonReciprocalRoleDBInstance = new CLCommonReciprocalRoleDB();
    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> argumentsFromPortal)
    {
        SavePoint dbSavePoint = Database.setSavePoint();
        clcommon.Response response = new clcommon.Response();
        List<sObject> mapList = new List<sObject>();
        Set<Id> brokerUserIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        List<clcommon__Relationship__c> relatedBorrowerAccountsList = new List<clcommon__Relationship__c>();
        List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
        try {
            List<User> brokerUserList = userDBInstance.getBrokerUserDetailsByLoggedInId();
            if(!brokerUserList.isEmpty()){
                List<clcommon__Reciprocal_Role__c> relationshipRoleList = clCommonReciprocalRoleDBInstance.getCLCommonRelationship(new Set<String> {Leads.BROKER});
                Id relationshipRoleId = relationshipRoleList.isEmpty() ? null : relationshipRoleList[0].Id;
                relatedBorrowerAccountsList = clCommonRelationshipDBInstance.getBorrowerDetailsByBrokerDetails(new Set<Id> {brokerUserList[0].AccountId}, new Set<Id> {relationshipRoleId});
            }
            if(!relatedBorrowerAccountsList.isEmpty()){
                for(clcommon__Relationship__c relatedBorrowerAccounts : relatedBorrowerAccountsList){
                    accountIds.add(relatedBorrowerAccounts.clcommon__Entity__c);
                }
            }
            brokerUserIds = CCBPBrokerHierarchyManager.getBrokerUserIds();
            List<User> brokerAccountsList = userDBInstance.getUserDetailsByIds(brokerUserIds);
            Set<Id> brokerAccountIds = new Set<Id>();
            for(User brokerAccount: brokerAccountsList){
                brokerAccountIds.add(brokerAccount.AccountId);
            }
            List<Account> borrowerAccountsList = accountDBInstance.getBorrowerAccountsByBrokerAccounts(brokerAccountIds);
            if(!borrowerAccountsList.isEmpty()){
                for(Account borrowerAccount : borrowerAccountsList){
                    accountIds.add(borrowerAccount.Id);
                }
            }
            List<Account> accountList = accountDBInstance.getBorrowerAccountsToShowInBrokerPortal(accountIds);
            if(accountList != null && accountList.size() > 0){
                for(Account acc: accountList){
                    mapList.add(acc);
                }
            }
            if(mapList != null && mapList.size() > 0){
                for (Integer i = 0; i < mapList.size(); i++) {
                    respList.add(new clcommon.PortalCustomRemoteActionRecord(mapList.get(i)));
                }
            }
        } catch (Exception e) {
            Database.rollback(dbSavePoint);
            response = getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
            Error_Log__c errorLog = ErrorLogs.createErrorLog (
                    PortalConstants.ERROR_RETRIEVE_ACC_SEARCH_YES_FLOW_CATCH_BP, e.getMessage(), e.getStackTraceString(),
                    null, ErrorLogs.ERROR, null, true);
            errorLogDBInstance.addInsert(errorLog);
            errorLogDBInstance.executeInserts();
            return response;
        }
        response = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
        return response;
    }
    private clcommon.Response getErrorResponse(String errorMessage) {
        clcommon.Response response = new clcommon.Response();
        response.status = clcommon.Constants.ERROR;
        response.errorMessage = errorMessage;
        response.errorCode = clcommon.Constants.API_EXCEPTION;
        return response;
    }
    private String getNamespaceForObjectName(){
        String namespace = 'genesis';
        if(String.isEmpty(namespace)){
            return '';
        }else{
            return namespace+'__';
        }
    }
}