global class CCCDCollectionActivitiesAPI implements clcommon.PortalCustomRemoteAPI1 {

    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    public static CollectionActivitiesDB collectionActivitiesDBInstance = new CollectionActivitiesDB();

    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> params) {
        clcommon.Response response = new clcommon.Response();
        try {
            String actionType = '';
            boolean isCompleted;
            Id activityId;
            collect__Collection_Activity__c collectionActivity = new collect__Collection_Activity__c();
            if(params.containsKey(PortalConstants.ACTIVITY_ACTION_TYPE)){
                actionType = String.valueOf(params.get(PortalConstants.ACTIVITY_ACTION_TYPE));
            }
            if(actionType == PortalConstants.ACTIVITY_ACTION_TYPE_EDIT){
                activityId = (ID)String.valueOf(params.get('activityId'));
                collectionActivity = collectionActivitiesDBInstance.getCollectionActivitiesByIds(new Set<Id>{activityId})[0];
            }
            
            Id loanAccountId = (ID)String.valueOf(params.get('loanAccountId'));
            String contractName = String.valueOf(params.get('loanContractName'));
            boolean proofOfClaim = (boolean)params.get('proofOfClaim');
            String judgementEntered = String.valueOf(params.get('judgementEntered'))!=null ? String.valueOf(String.valueOf(params.get('judgementEntered'))):'';
            String oldestDueDate = String.valueOf(params.get('oldestDueDate'))!=null ? String.valueOf(String.valueOf(params.get('oldestDueDate'))):'';
            String demandLetterSent = String.valueOf(params.get('demandLetterSent'))!=null ? String.valueOf(String.valueOf(params.get('demandLetterSent'))):'';
            String daysPastDue = String.valueOf(params.get('daysPastDue'))!=null? String.valueOf(params.get('daysPastDue')):'0';
            String debitConsolidator = String.valueOf(params.get('debitConsolidator'))!=null ? String.valueOf(params.get('debitConsolidator')):'';
            String attorneyAssigned = String.valueOf(params.get('attorneyAssigned'))!=null ? String.valueOf(params.get('attorneyAssigned')):'';
            String judgementAmount = String.valueOf(params.get('judgementAmount'))!=null ? String.valueOf(params.get('judgementAmount')):'';
            String courtNumber = String.valueOf(params.get('courtNumber'))!=null ? String.valueOf(params.get('courtNumber')):'0';
            String bankruptcyChapter = String.valueOf(params.get('bankruptcyChapter'))!=null ? String.valueOf(params.get('bankruptcyChapter')):'';
            String legalDepartmentContact = String.valueOf(params.get('legalDepartmentContact'))!=null ? String.valueOf(params.get('legalDepartmentContact')):'';
            String hasAttorney = String.valueOf(params.get('hasAttorney'))!=null ? String.valueOf(params.get('hasAttorney')):'';
            String caseNumber = String.valueOf(params.get('caseNumber'))!=null ? String.valueOf(params.get('caseNumber')):'';
            String actionText = String.valueOf(params.get('actionText'))!=null ? String.valueOf(params.get('actionText')):'';
            String caseStatus = String.valueOf(params.get('caseStatus'))!=null ? String.valueOf(params.get('caseStatus')):'';
            String caseSubStatus = String.valueOf(params.get('caseSubStatus'))!=null ? String.valueOf(params.get('caseSubStatus')):'';

            collectionActivity.collect__Loan_Account_Id__c = loanAccountId;
            collectionActivity.collect__Loan_Account_Name__c = contractName;
            collectionActivity.Proof_of_Claim__c = proofOfClaim;
            if(judgementEntered != ''){
                collectionActivity.Judgement_Entered__c = Date.valueOf(judgementEntered);
            }
            if(oldestDueDate != ''){
                collectionActivity.collect__Oldest_Due_Date__c = Date.valueOf(oldestDueDate);
            }
            if(demandLetterSent != ''){
                collectionActivity.Demand_Letter_Sent__c = Date.valueOf(demandLetterSent);
            }
            if(daysPastDue != ''){
                collectionActivity.collect__Days_Past_Due__c = Integer.valueOf(daysPastDue);
            }
            collectionActivity.Debit_consolidator__c = debitConsolidator;
            collectionActivity.Attorney_Assigned__c = attorneyAssigned;
            if(judgementAmount != null){
                collectionActivity.Judgment_amount__c = Integer.valueOf(judgementAmount);
            }
            collectionActivity.Court__c = courtNumber;
            collectionActivity.Bankruptcy_Chapter__c = bankruptcyChapter;
            collectionActivity.Has_Attorney__c = hasAttorney;
            collectionActivity.Case_Number__c = caseNumber;
            collectionActivity.collect__Action__c = actionText;
            collectionActivity.Collection_Case_Status__c = caseStatus;
            collectionActivity.Collection_Case_Sub_Status__c = caseSubStatus;
            if(actionType == PortalConstants.ACTIVITY_ACTION_TYPE_CREATE){
                collectionActivitiesDBInstance.addInsert(collectionActivity);
                collectionActivitiesDBInstance.executeInserts();
            }
            else if(actionType == PortalConstants.ACTIVITY_ACTION_TYPE_EDIT){
                collectionActivity.collect__Completed__c = (boolean)params.get('isCompleted');
                if((boolean)params.get('isSupervisor')){
                	collectionActivity.Supervisor__c = true;
                    collectionActivity.collect__Account_Manager__c = (Id)params.get('accountManagerUserId');
                }
                else{
                    collectionActivity.Supervisor__c = false;
                    collectionActivity.collect__Account_Manager__c = null;
                }
                if(collectionActivity.collect__Completed__c){
                    collectionActivity.collect__Completion_Date__c = System.today();
                }
                else{
                    collectionActivity.collect__Completion_Date__c = null;
                }
                collectionActivitiesDBInstance.addUpdate(collectionActivity);
                collectionActivitiesDBInstance.executeUpdates();
            }
            response.status = PortalConstants.API_RESPONSE_STATUS_SUCCESS;
            response.errorMessage = null;
        } catch (Exception ex) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog (
                'Collection Activities', ex.getMessage(), ex.getStackTraceString(),
                null, ErrorLogs.ERROR, null, true);
            errorLogDBInstance.addInsert(errorLog);
            errorLogDBInstance.executeInserts();
        return getErrorResponse(PortalConstants.COLLECTION_ACTIVITIES_CREATION_ERROR);
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