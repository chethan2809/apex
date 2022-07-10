global class CCBPBrokerProfileEditAPI implements clcommon.PortalCustomRemoteAPI1 {
    public static UserDB userDBInstance = new UserDB();
    public static ContactDB contactDB = new ContactDB();
    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> argumentsFromPortal)
    {
        SavePoint dbSavePoint = Database.setSavePoint();
        clcommon.Response response = new clcommon.Response();
        Contact newContactDetails = new Contact();
        List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
        try {
            Contact brokerContactDetails = (Contact)JSON.deserialize((String)argumentsFromPortal.get(PortalConstants.BROKER_CONTACT_DETAILS),Contact.class);
            List<User> brokerUserDetails = userDBInstance.getBrokerUserDetailsByLoggedInId();
            String editType = (String)argumentsFromPortal.get(PortalConstants.EDIT_TYPE);
            Boolean isValidLoggedInUser;
            Id brokerContactId = (Id)brokerContactDetails.get(PortalConstants.ID);
            isValidLoggedInUser = CLSPBPortalSecurity.validLoggedInBrokerUser(brokerContactId);
            if(isValidLoggedInUser){
                if(editType.equals(PortalConstants.PHONE)){
                    newContactDetails.MobilePhone = String.valueOf(brokerContactDetails.get(PortalConstants.MOBILE_PHONE));
                    newContactDetails.Id = brokerUserDetails[0].ContactId;
                    contactDB.addUpdate(newContactDetails);
                    contactDB.executeUpdates();
                    brokerUserDetails[0].Phone = newContactDetails.MobilePhone;
                    userDBInstance.addUpdate(brokerUserDetails[0]);
                    userDBInstance.executeUpdates();
                }
                else if(editType.equals(PortalConstants.EMAIL)){
                    newContactDetails.Email = String.valueOf(brokerContactDetails.get(PortalConstants.EMAIL));
                    newContactDetails.Id = brokerUserDetails[0].ContactId;
                    contactDB.addUpdate(newContactDetails);
                    contactDB.executeUpdates();
                    brokerUserDetails[0].Email = newContactDetails.Email;
                    userDBInstance.addUpdate(brokerUserDetails[0]);
                    userDBInstance.executeUpdates();
                }
                else if(editType.equals(PortalConstants.ADDRESS)){
                    newContactDetails.MailingStreet = String.valueOf(brokerContactDetails.get('MailingStreet'))!=null ? String.valueOf(brokerContactDetails.get('MailingStreet')) : '';
                    newContactDetails.MailingCity = String.valueOf(brokerContactDetails.get('MailingCity'))!=null ? String.valueOf(brokerContactDetails.get('MailingCity')) : '';
                    newContactDetails.MailingState = String.valueOf(brokerContactDetails.get('MailingState'))!=null ? String.valueOf(brokerContactDetails.get('MailingState')) : '';
                    newContactDetails.MailingCountry = String.valueOf(brokerContactDetails.get('MailingCountry'))!=null ? String.valueOf(brokerContactDetails.get('MailingCountry')) : '';
                    newContactDetails.MailingPostalCode = String.valueOf(brokerContactDetails.get('MailingPostalCode'))!=null ? String.valueOf(brokerContactDetails.get('MailingPostalCode')) : '';
                    newContactDetails.Id = brokerUserDetails[0].ContactId;
                    contactDB.addUpdate(newContactDetails);
                    contactDB.executeUpdates();
                }
            }
            else{
                Error_Log__c errorLog = ErrorLogs.createErrorLog (
                            PortalConstants.ACCESS_DENIED_CHANGING_BROKER_DETAILS, null, null,
                            null, ErrorLogs.ERROR, brokerContactId, true);
                errorLogDBInstance.addInsert(errorLog);
                errorLogDBInstance.executeInserts();
                return getErrorResponse(PortalConstants.ACCESS_DENIED_CHANGING_BROKER_DETAILS);
            }
        }catch (Exception e) {
            Database.rollback(dbSavePoint);
            response = getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
            Error_Log__c errorLog = ErrorLogs.createErrorLog (
                    PortalConstants.ERROR_EDIT_BROKER_PROFILE_CATCH_BP, e.getMessage(), e.getStackTraceString(),
                    null, ErrorLogs.ERROR, newContactDetails.Id, true);
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
    @TestVisible
    private String getNamespaceForObjectName(){
        String namespace = 'genesis';
        if(String.isEmpty(namespace)){
            return '';
        }else{
            return namespace+'__';
        }
    }
}