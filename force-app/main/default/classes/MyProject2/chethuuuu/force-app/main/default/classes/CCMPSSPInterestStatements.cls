global class CCMPSSPInterestStatements implements clcommon.PortalCustomRemoteAPI1 {
     public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
     public static CLContractDB clContractDBInstance = new CLContractDB();

     public static LoanPaymentTransactionDB loanPaymentTransactionDBInstance = new LoanPaymentTransactionDB();
     global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> params) {
          clcommon.Response res = new clcommon.Response();
          if(params.containsKey(PortalConstants.CONTRACT_ID)){
               Map<String,Object> fields = new Map<String,Object>();
               List<SObject> mapList = new List<SObject>();
               List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
               Id contractId = (Id)params.get(PortalConstants.CONTRACT_ID);
               List<loan__Loan_Account__c> contractList = clContractDBInstance.getLoanAccountsByIds(new Set<Id>{contractId});
               if(!contractList.isEmpty()){
                   Boolean isValidAccount = PortalSecurityUtil.validateUserByBorrowerAccountId(contractList[0].loan__Account__c);
                   if(isValidAccount){
                         String startMonth = String.valueOf(params.get('fromMonth')).split('-')[1];
                         String strStartMonth = String.valueOf(params.get('fromMonth')).split('-')[0];
                         String endMonth = String.valueOf(params.get('toMonth')).split('-')[1];
                         String strEndMonth = String.valueOf(params.get('toMonth')).split('-')[0];

                         Date startDate = Date.parse(startMonth + '/01/' + String.valueOf(params.get('fromYear')));
                         Date endDate = Date.parse(endMonth + '/01/' + String.valueOf(params.get('toYear'))).addMonths(1).toStartOfMonth().addDays(-1);
                         List<AggregateResult> aggregatedInterest;
                         try{
                              aggregatedInterest = loanPaymentTransactionDBInstance.getAggregatedInterestByContractId(contractId, startDate, endDate);
                         }
                         catch(Exception ex){
                              Error_Log__c errorLog = ErrorLogs.createErrorLog (
                              PortalConstants.ERROR_INTEREST_STATEMENT_GENERATION_SSP, ex.getMessage(), ex.getStackTraceString(),
                              null, ErrorLogs.ERROR, contractId, true);
                              errorLogDBInstance.addInsert(errorLog);
                              errorLogDBInstance.executeInserts();
                              res.Status = PortalConstants.API_RESPONSE_STATUS_FAILED;
                              res.errorMessage = PortalConstants.SOMETHING_WENT_WRONG_MESSAGE;
                         }
                         fields.put('fromMonthYear',strStartMonth + '-'+ String.valueOf(params.get('fromYear')));
                         fields.put('toMonthYear',strEndMonth + '-' + String.valueOf(params.get('toYear')));
                         fields.put('interestAmount',aggregatedInterest[0].get('expr0') != null ? aggregatedInterest[0].get('expr0') : 0);
                         respList.add(new clcommon.PortalCustomRemoteActionRecord('KEY_RESPONSE', fields));
                         res = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
                   }
                   else{
                    Error_Log__c errorLog = ErrorLogs.createErrorLog (
                         PortalConstants.ERROR_INTEREST_STATEMENT_GENERATION_SSP, PortalConstants.NO_PERMISSION_ERROR_MSG, null,
                         null, ErrorLogs.ERROR, null, true);
                     errorLogDBInstance.addInsert(errorLog);
                     errorLogDBInstance.executeInserts();
                     res.status = clcommon.Constants.API_EXCEPTION;
                     res.errorMessage = PortalConstants.SOMETHING_WENT_WRONG_MESSAGE;
                    }
               }
               else{
                    Error_Log__c errorLog = ErrorLogs.createErrorLog (
                         PortalConstants.ERROR_INTEREST_STATEMENT_GENERATION_SSP, PortalConstants.UNABLE_TO_FIND_CONTRACT_INFO, null,
                         null, ErrorLogs.ERROR, contractId, true);
                    errorLogDBInstance.addInsert(errorLog);
                    errorLogDBInstance.executeInserts();
                    res.status = clcommon.Constants.API_EXCEPTION;
                    res.errorMessage = PortalConstants.SOMETHING_WENT_WRONG_MESSAGE;
               }
          }
          else{
               Error_Log__c errorLog = ErrorLogs.createErrorLog (
                    PortalConstants.ERROR_INTEREST_STATEMENT_GENERATION_SSP, PortalConstants.CONTRACT_ID_MISSING, null,
                    null, 'Error', null, true);
                    errorLogDBInstance.addInsert(errorLog);
                    errorLogDBInstance.executeInserts();
               res.Status = PortalConstants.API_RESPONSE_STATUS_FAILED;
               res.errorMessage = PortalConstants.SOMETHING_WENT_WRONG_MESSAGE;
          }
        return res;
      }
 }