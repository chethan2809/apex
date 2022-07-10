global with sharing class CCMPPaymentSchedule implements clcommon.PortalCustomRemoteAPI1{
    public static RepaymentScheduleDB paymentScheduleDBInstance = new RepaymentScheduleDB();
    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> argumentsFromPortal) {
        clcommon.Response res = new clcommon.Response();
        Map<String,Object> fields = new Map<String,Object>();
        List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
        try{
            if(argumentsFromPortal.get(PortalConstants.DOCUMENT_DELETE) == false){
                List<loan__repayment_schedule__c> repaymentScheduleList;
                Id loanId = (Id)argumentsFromPortal.get(PortalConstants.CONTRACT_ID);
                
                repaymentScheduleList = paymentScheduleDBInstance.getRepyamnetScheculeByLoanId(loanId);
                String csvContentString = PortalConstants.PAYMENT_SCHEDULE_DATE +',' +PortalConstants.AMOUNT+','+PortalConstants.PRINCIPAL_BALANCE+','+'\n';
                String fileRow = '';
                for(loan__repayment_schedule__c rps : repaymentScheduleList){
                    fileRow = '';
                    fileRow = fileRow +','+ rps.Due_Date_For_Portal__c;
                    fileRow = fileRow +','+ rps.loan__Due_Amount__c;
                    fileRow = fileRow +','+ rps.loan__Balance__c;
                    fileRow = fileRow.replaceFirst(',','');
                    csvContentString = csvContentString + fileRow + '\n';
                }
                
                ContentVersion newCSVFile = new ContentVersion();
                newCSVFile.title = PortalConstants.PAYMENT_SCHEDULE + ' - ' + repaymentScheduleList[0].loan__loan_account__r.Name;
                newCSVFile.VersionData = Blob.valueOf(csvContentString);
                newCSVFile.PathOnClient = newCSVFile.title + PortalConstants.PAYMENT_SCHEDULE_CSV;
                
                paymentScheduleDBInstance.addInsert(newCSVFile);
                paymentScheduleDBInstance.executeInserts();
                
                fields.put(PortalConstants.DOCUMENT_ID,newCSVFile.Id);
                respList.add(new clcommon.PortalCustomRemoteActionRecord('KEY_RESPONSE', fields));
                res = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
                res.Status = PortalConstants.API_RESPONSE_STATUS_SUCCESS;
                res.errorMessage = null;
            }
            if(argumentsFromPortal.get(PortalConstants.DOCUMENT_DELETE) == true){
                List<ContentVersion> deleteCSVFile;
                Id documentId = (Id)argumentsFromPortal.get(PortalConstants.DOCUMENT_ID);
                deleteCSVFile = paymentScheduleDBInstance.deleteContentDocument(documentId);
                ContentDocument doc = new ContentDocument(Id=deleteCSVFile[0].contentdocumentid);
                
                paymentScheduleDBInstance.addDelete(doc);
                paymentScheduleDBInstance.executeDeletes();
                
                res.Status = PortalConstants.API_RESPONSE_STATUS_SUCCESS;
                res.errorMessage = null;
            }
        }catch (Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog (
                PortalConstants.DOCUMENT_GENERATION_FAILED_STATUS, e.getMessage(), e.getStackTraceString(), null, 'Error', null, true);
            errorLogDBInstance.addInsert(errorLog);
            errorLogDBInstance.executeInserts();
            res.status = PortalConstants.API_RESPONSE_STATUS_FAILED;
            res.errorMessage = PortalConstants.DOCUMENT_GENERATION_FAILED_STATUS;
        }
        return res;
    }
}