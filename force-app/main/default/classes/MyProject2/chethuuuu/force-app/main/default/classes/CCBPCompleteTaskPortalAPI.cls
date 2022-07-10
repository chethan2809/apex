global class CCBPCompleteTaskPortalAPI implements clcommon.PortalCustomRemoteAPI1 {
    @testVisible
    private static EmailDB emailDBInstance = new EmailDB();
    private static EmailTemplateDB emailTemplateDBInstance = new EmailTemplateDB();
    private static TaskDB taskDbInstance = new TaskDB();
    private static UserDB userDbInstance = new UserDB();
    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> argumentsFromPortal) {
        SavePoint dbSavePoint = Database.setSavePoint();
        clcommon.Response response = new clcommon.Response();
        List<Task> taskList = new List<Task>();
        List<User> underWritersList = new List<User>();
        Map<String,Object> fields = new Map<String,Object>();
        Id applicationId = (Id)argumentsFromPortal.get(PortalConstants.APPLICATION_ID);
        Id taskId = (Id)argumentsFromPortal.get(PortalConstants.TASK_ID);
        Boolean isValidApp = CLSPBPortalSecurity.validApplication(applicationId);
        String comments = (String)argumentsFromPortal.get(PortalConstants.REVIEW_COMMENT);
        if(isValidApp){
            try {
                taskList = taskDbInstance.getIncompleteTasksByApplicationAndTaskIds
                                        (new Set<Id> {applicationId}, new Set<Id> {taskId});
                    if(taskList != null && !taskList.isEmpty()){
                        taskList[0].Status = PortalConstants.TASK_COMPLETED;
                        taskList[0].OwnerId = taskList[0].CreatedById;
                        taskList[0].Description = comments + ' - ' + PortalConstants.TASK_COMPLETED_COMMENT;
                    }
                    else{
                        return getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
                    }
                    if(taskId != NULL && taskList != null && !taskList.isEmpty()){
                        taskDbInstance.addUpdates(taskList);
                        taskDbInstance.executeUpdates();
                        underWritersList = userDbInstance.getUserDetailsByUnderWriterIds(new Set<Id> {taskList[0].OwnerId});
                        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                        Set<String> templateNames = new Set<String>();
                        List<String> toAddresses = new List<String>();
                        toAddresses.add(underWritersList[0].Email);
                        templateNames.add(PortalConstants.UNDERWRITER_NOTIFICATION);
                        List<EmailTemplate> templates = emailTemplateDBInstance.getTemplatesByName(templateNames);
                        String emailSubject = templates[0].Subject;
                        String emailBody = templates[0].Body;
                        emailSubject = emailSubject.replace('{!Task.Subject}', taskList[0].Subject);
                        emailBody = emailBody.replace('{!Task.CreatedBy}', underWritersList[0].Name + ',' + '<br><br>');
                        emailBody = emailBody.replace('[Email Body]', PortalConstants.UNDERWRITER_TASK_BP_EMAIL_BODY + '<br><br>' + PortalConstants.UNDERWRITER_TASK_DETAILS_BP + '<br><br>');
                        emailBody = emailBody.replace('{!Task.genesis__Application__c}', taskList[0].genesis__Application__r.Name + '<br>');
                        emailBody = emailBody.replace('{!Task.Subject}', taskList[0].Subject + '<br>');
                        emailBody = emailBody.replace('{!Task.Status}', taskList[0].Status + '<br>') ;
                        emailBody = emailBody.replace('{!Task.Description}', taskList[0].Description + '<br><br>');
                        emailBody = emailBody.replace('[Thanks]', PortalConstants.THANKS + ',' + '<br>' + PortalConstants.CAN_CAPITAL);
                        OrgWideEmailAddress orgWideAddress = GeneralHelper.orgWideEmailAddressByEmail.get(
                            GeneralConstants.CAN_SALESFORCE_NOTIFICATION_EMAIL_ADDRESS
                        );
                        Messaging.SingleEmailMessage email = Emails.getEmailMessageSetup(
                            toAddresses, null, CustomMetaDataHelper.defaultGeneralSetting.From_Email__c, emailSubject,
                            emailBody, true, null, orgWideAddress
                        );
                        emailList.add(email);
                        emailDBInstance.sendBulkEmail(emailList);
                        response.status = clcommon.Constants.SUCCESS;
                        fields.put(PortalConstants.API_RESPONSE_STATUS_SUCCESS, PortalConstants.TASK_COMPLETED_MESSAGE);
                        List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
                        respList.add(new clcommon.PortalCustomRemoteActionRecord('KEY_RESPONSE', fields));
                        response = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
                        return response;
                    }
            } catch (Exception e) {
                Database.rollback(dbSavePoint);
                response.status = clcommon.Constants.API_EXCEPTION;
                response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG_MESSAGE;
                Error_Log__c errorLog = ErrorLogs.createErrorLog (
                    PortalConstants.ERROR_TASK_COMPLETION_CATCH_BP, e.getMessage(),
                    e.getStackTraceString(), null, ErrorLogs.ERROR, applicationId, true);
                errorLogDBInstance.addInsert(errorLog);
                errorLogDBInstance.executeInserts();
                return response;
            }
        }else{
            Error_Log__c errorLog = ErrorLogs.createErrorLog (
                        PortalConstants.ACCESS_DENIED_SUBMITTING_TASK, null, null,
                        null, ErrorLogs.ERROR, applicationId, true);
            errorLogDBInstance.addInsert(errorLog);
            errorLogDBInstance.executeInserts();
            return getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
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