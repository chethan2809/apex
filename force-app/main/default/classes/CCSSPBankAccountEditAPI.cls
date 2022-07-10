global class CCSSPBankAccountEditAPI implements clcommon.PortalCustomRemoteAPI1 {
    //DB Instances
    public static CaseDB caseDBInstance = new CaseDB();
    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    public static BankAccountDB bankAccountDBInstance = new BankAccountDB();
    global clcommon.Response invokeAction(String componentStrName,
                                          String[] disclosureNames,
                                          Map<String, Object> portalArguments) {
        String errorOriginText = '';
        SavePoint dbSavePoint = Database.setSavePoint();
        clcommon.Response response = new clcommon.Response();
        String accountId;
          try {
            errorOriginText = PortalConstants.CASE_TYPE_BANK_ACCOUNT_CHANGE;
            accountId = String.valueOf(portalArguments.get('accountId'));
            Boolean isValidAccount = PortalSecurityUtil.validateUserByBorrowerAccountId(accountId);
            if(isValidAccount){
                loan__Bank_Account__c bankAccountRecord = new loan__Bank_Account__c();
                bankAccountRecord.loan__Account__c = accountId;
                bankAccountRecord.loan__Bank_Name__c = String.valueOf(portalArguments.get('bankName'));
                bankAccountRecord.loan__Bank_Account_Number__c = String.valueOf(portalArguments.get('accountNumber'));
                bankAccountRecord.loan__Account_Type__c = String.valueOf(portalArguments.get('accountType'));
                bankAccountRecord.loan__Routing_Number__c = String.valueOf(portalArguments.get('routingNumber'));
                bankAccountRecord.loan__Account_Usage__c = PortalConstants.ACCOUNT_USAGE_BORROWER_INVESTOR;
                bankAccountRecord.loan__Active__c = false;

                Database.SaveResult srList = Database.insert(bankAccountRecord, false);
                Id newBankAccountId = srList.Id;
                response.status = PortalConstants.API_RESPONSE_STATUS_SUCCESS;
                response.errorMessage = null;

                //Fetching the assignment rules on case
                AssignmentRule AR = new AssignmentRule();
                AR = [select id from AssignmentRule where SObjectType = 'Case' and Active = true limit 1];
                //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
                dmlOpts.EmailHeader.TriggerUserEmail = true;
                dmlOpts.EmailHeader.triggerAutoResponseEmail = true;

                errorOriginText = PortalConstants.CASE_TYPE_BANK_ACCOUNT_CHANGE + ' - Case';
                Case conCase = new Case();
                conCase.AccountId = accountId;
                conCase.Bank_Account__c = newBankAccountId;
                conCase.Status = PortalConstants.NEW_CASE;
                conCase.Type = PortalConstants.CASE_TYPE_BANK_ACCOUNT_CHANGE;
                conCase.Origin = PortalConstants.CASE_ORIGIN;
                conCase.Priority = PortalConstants.CASE_PRIORITY;
                conCase.Description = PortalConstants.CASE_BANK_ACCOUNT_CHANGE_DESC;
                if(conCase !=null){
                    conCase.setOptions(dmlOpts);
                    caseDBInstance.addInsert(conCase);
                    caseDBInstance.executeInserts();
                }
            }
            else{
                Error_Log__c errorLog = ErrorLogs.createErrorLog (
                        PortalConstants.CASE_TYPE_BANK_ACCOUNT_CHANGE, PortalConstants.NO_PERMISSION_ERROR_MSG, null,
                        null, ErrorLogs.ERROR, null, true);
                    errorLogDBInstance.addInsert(errorLog);
                    errorLogDBInstance.executeInserts();
                    response.status = clcommon.Constants.API_EXCEPTION;
                    response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG_MESSAGE;
            }
         }
         catch (Exception e) {
            Database.rollback(dbSavePoint);
            Error_Log__c errorLog = ErrorLogs.createErrorLog (
                errorOriginText, e.getMessage(), e.getStackTraceString(), null, ErrorLogs.ERROR, accountId, true);
            errorLogDBInstance.addInsert(errorLog);
            errorLogDbInstance.executeInserts();
            response.status = PortalConstants.API_RESPONSE_STATUS_FAILED;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG_MESSAGE;
        }
        return response;
   }
}