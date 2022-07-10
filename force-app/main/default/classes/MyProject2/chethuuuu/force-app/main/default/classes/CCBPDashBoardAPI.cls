global class CCBPDashBoardAPI implements clcommon.PortalCustomRemoteAPI1 {
    public static ApplicationDB applicationDBInstance = new ApplicationDB();
    public static PartyDB partyDBInstance = new PartyDB();
    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    public static UserDB userDBInstance = new UserDB();
    public static AccountDB accountDBInstance = new AccountDB();
    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> argumentsFromPortal) {
        SavePoint dbSavePoint = Database.setSavePoint();
        clcommon.Response response = new clcommon.Response();
        List<SObject> mapList = new List<SObject>();
        List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
        List<clcommon__Party__c> brokerApplicationList;
        try {
            if(argumentsFromPortal.containsKey(PortalConstants.SELECTED_STATUS)){
                Map<String,Object> statusMap = (Map<String,Object>)JSON.deserializeUntyped((String)argumentsFromPortal.get(PortalConstants.SELECTED_STATUS));
                String bucket = (String)statusMap.get(PortalConstants.RADIO_FILTER);
                Date lastNinetyDays = (GeneralHelper.currentSystemDate).addDays(PortalConstants.LAST_NINETY_DAYS);
                
                if(bucket.equalsIgnoreCase(PortalConstants.RECENT)){
                    brokerApplicationList = partyDBInstance.getRecentApplicationsListForBrokerPortalDashboard(CCBPBrokerHierarchyManager.getBrokerUserIds());
                }else if(!bucket.equalsIgnoreCase('All') && !bucket.equalsIgnoreCase('Funded') && !bucket.equalsIgnoreCase('Closed Declined')){ 
                    brokerApplicationList = partyDBInstance.getApplicationsListForBrokerPortalOnCategories(new Set<String> {bucket}, CCBPBrokerHierarchyManager.getBrokerUserIds());
                }else if(bucket.equalsIgnoreCase('Funded')){
                    brokerApplicationList = partyDBInstance.getApplicationsListForBrokerPortalOnCategoryFunded(new Set<String> {bucket}, CCBPBrokerHierarchyManager.getBrokerUserIds(), lastNinetyDays);
                }else if(bucket.equalsIgnoreCase('Closed Declined')){
                    brokerApplicationList = partyDBInstance.getApplicationsListForBrokerPortalOnCategoryClosedDeclined(new Set<String> {bucket}, CCBPBrokerHierarchyManager.getBrokerUserIds(), lastNinetyDays);
                }else{
                    brokerApplicationList = partyDBInstance.getALLApplicationsListForBrokerPortal(CCBPBrokerHierarchyManager.getBrokerUserIds());
                }
                if(brokerApplicationList != null && !brokerApplicationList.isEmpty()){
                    for(clcommon__Party__c app: brokerApplicationList){
                        mapList.add(app);
                    }
                    for (Integer i = 0; i < mapList.size(); i++) {
                        respList.add(new clcommon.PortalCustomRemoteActionRecord(mapList.get(i)));
                    }
                }
            } else if(argumentsFromPortal.containsKey(PortalConstants.SEARCH_DETAILS)){
                Date fromDate = null;
                Date toDate = null;
                integer minLoanAmount = null;
                integer maxLoanAmount = null;
                String application;
                String applicationId = '%%';
                String accountName;
                String account = '%%';
                String status;
                String applicationStatus = '%%';
                Map<String,Object> searchMap = (Map<String,Object>)JSON.deserializeUntyped((String)argumentsFromPortal.get(PortalConstants.SEARCH_DETAILS));
                if (searchMap.containsKey(PortalConstants.BROKER_PORTAL_STATUS) && searchMap.get(PortalConstants.BROKER_PORTAL_STATUS) != null){
                    status = String.valueOf(searchMap.get(PortalConstants.BROKER_PORTAL_STATUS));
                    applicationStatus =  '%'+status+'%';
                }
                if (searchMap.containsKey(PortalConstants.APPLICATION) && searchMap.get(PortalConstants.APPLICATION) != null){
                    application = String.valueOf(searchMap.get(PortalConstants.APPLICATION));
                    applicationId =  '%'+application+'%';
                }
                if (searchMap.containsKey(PortalConstants.ACCOUNT) && searchMap.get(PortalConstants.ACCOUNT) != null){
                    accountName = String.valueOf(searchMap.get(PortalConstants.ACCOUNT));
                    account =  '%'+accountName+'%';
                }
                if (searchMap.containsKey(PortalConstants.START_DATE_FILTER) && String.isNotBlank(String.valueOf(searchMap.get(PortalConstants.START_DATE_FILTER)))){
                    fromDate = Date.valueOf(String.valueOf(searchMap.get(PortalConstants.START_DATE_FILTER)));
                }
                if (searchMap.containsKey(PortalConstants.END_DATE_FILTER) && String.isNotBlank(String.valueOf(searchMap.get(PortalConstants.END_DATE_FILTER)))){
                    toDate = Date.valueOf(String.valueOf(searchMap.get(PortalConstants.END_DATE_FILTER)));
                }
                if (searchMap.containsKey(PortalConstants.MINIMUM_AMOUNT) && String.isNotBlank(String.valueOf(searchMap.get(PortalConstants.MINIMUM_AMOUNT)))){
                    minLoanAmount = Integer.valueOf(String.valueOf(searchMap.get(PortalConstants.MINIMUM_AMOUNT)));
                }
                if (searchMap.containsKey(PortalConstants.MAXIMUM_AMOUNT) && String.isNotBlank(String.valueOf(searchMap.get(PortalConstants.MAXIMUM_AMOUNT)))){
                    maxLoanAmount= Integer.valueOf(String.valueOf(searchMap.get(PortalConstants.MAXIMUM_AMOUNT)));
                }
                brokerApplicationList = partyDBInstance.getALLApplicationsListForBrokerPortalAdvancedFilter(new Set<Date> {fromDate},
                                                                                                            new Set<Date> {toDate},
                                                                                                            new Set<Integer> {minLoanAmount},
                                                                                                            new Set<Integer> {maxLoanAmount},
                                                                                                            new Set<String> {applicationId},
                                                                                                            new Set<String> {account},
                                                                                                            CCBPBrokerHierarchyManager.getBrokerUserIds());
                for (clcommon__Party__c parties : brokerApplicationList ) {
                    mapList.add(parties);
                }
                for (Integer i = 0; i < mapList.size(); i++) {
                    respList.add(new clcommon.PortalCustomRemoteActionRecord(mapList.get(i)));
                }
            }
        }catch (Exception e) {
            system.debug(e.getMessage() + '---'+e.getStackTraceString());
            Database.rollback(dbSavePoint);
            response = getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
            Error_Log__c errorLog = ErrorLogs.createErrorLog (
                    PortalConstants.ERROR_RETRIEVE_APPLICATIONS_BASED_ON_STATUS_CATCH_BP, e.getMessage(), e.getStackTraceString(),
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
}