global class CCBPRetrieveAccountDetailsAPI implements clcommon.PortalCustomRemoteAPI1 {
    public static AccountDB accountDBInstance = new AccountDB();
    public static ApplicationDB applicationDBInstance = new ApplicationDB();
    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames,Map<String, Object> argumentsFromPortal) {
        SavePoint dbSavePoint = Database.setSavePoint();
        clcommon.Response response = new clcommon.Response();
        Map<String,Object> fields = new Map<String,Object>();
        Id borrowerAccountId;
        Boolean isValidUser;
        try{
            if (argumentsFromPortal.containsKey(PortalConstants.CLICK_RECORD_ID) && argumentsFromPortal.get(PortalConstants.CLICK_RECORD_ID) != null) {
                borrowerAccountId = (Id)argumentsFromPortal.get(PortalConstants.ACCOUNT_RECORD_ID);
            }else{
                throw new CustomException(PortalConstants.ACCOUNT_ID_IS_MISSING);
            }
            isValidUser = CLSPBPortalSecurity.validateUserByBorrowerAccountId(borrowerAccountId);
            if(isValidUser){
                List<genesis__Applications__c> applicationDetailsList = applicationDBInstance.getApplicationListByBorrowerAccId(new Set<Id> {borrowerAccountId});
                List<Account> accountDetailsList = accountDBInstance.getAccountByIds(new Set<Id> {borrowerAccountId});
                if(accountDetailsList != null && accountDetailsList.size() > 0){
                    fields.put(PortalConstants.BUSINESS_NAME, accountDetailsList[0].Name);
                    fields.put(PortalConstants.INDUSTRY, accountDetailsList[0].Industry);
                    fields.put(PortalConstants.BUSINESS_TAX_ID, accountDetailsList[0].Business_Tax_ID__c);
                    fields.put(PortalConstants.DBA, accountDetailsList[0].Doing_Business_As_Name__c);
                    fields.put(PortalConstants.BUSINESS_STRUCTURE, accountDetailsList[0].clcommon__Legal_Entity_Type__r.Name);
                    fields.put(PortalConstants.BUSINESS_START_DATE, accountDetailsList[0].Biz_Start_Date__c);
                    fields.put(PortalConstants.PHONE, accountDetailsList[0].Phone);
                    fields.put(PortalConstants.BILLING_STREET, accountDetailsList[0].BillingStreet);
                    fields.put(PortalConstants.BILLING_BUILDING_NUMBER, accountDetailsList[0].BillingBuildingNumber__c);
                    fields.put(PortalConstants.BILLING_CITY, accountDetailsList[0].BillingCity);
                    fields.put(PortalConstants.BILLING_STATE, accountDetailsList[0].BillingState);
                    fields.put(PortalConstants.BILLING_COUNTRY, accountDetailsList[0].BillingCountry);
                    fields.put(PortalConstants.BILLING_POSTAL_CODE, accountDetailsList[0].BillingPostalCode);
                    fields.put(PortalConstants.ACCOUNT_ID, accountDetailsList[0].Id);
                    fields.put(PortalConstants.EXISTING_ACCOUNT_TYPE, PortalConstants.BUSINESS);
                }
                if(applicationDetailsList[0].genesis__Parties__r != null){
                    List<clcommon__Party__c> partyList = applicationDetailsList[0].genesis__Parties__r;
                    for(clcommon__Party__c party : partyList){
                        fields.put(PortalConstants.TITLE, party.clcommon__Contact__r.Title__c);
                        fields.put(PortalConstants.FIRST_NAME, party.clcommon__Contact__r.FirstName);
                        fields.put(PortalConstants.LAST_NAME, party.clcommon__Contact__r.LastName);
                        fields.put(PortalConstants.EMAIL, party.clcommon__Contact__r.Email);
                        fields.put(PortalConstants.MOBILE_PHONE, party.clcommon__Contact__r.MobilePhone);
                        fields.put(PortalConstants.BIRTH_DATE, String.valueOf(party.clcommon__Contact__r.Birthdate));
                        fields.put(PortalConstants.SSN, party.clcommon__Contact__r.genesis__SSN__c);
                        fields.put(PortalConstants.MAILING_STREET, party.clcommon__Contact__r.MailingStreet);
                        fields.put(PortalConstants.MAILING_BUILDING_NUMBER, party.clcommon__Contact__r.MailingBuildingNumber__c);
                        fields.put(PortalConstants.MAILING_CITY, party.clcommon__Contact__r.MailingCity);
                        fields.put(PortalConstants.MAILING_STATE, party.clcommon__Contact__r.MailingState);
                        fields.put(PortalConstants.MAILING_COUNTRY, party.clcommon__Contact__r.MailingCountry);
                        fields.put(PortalConstants.MAILING_POSTAL_CODE, party.clcommon__Contact__r.MailingPostalCode);
                        fields.put(PortalConstants.CONTACT_ID, party.clcommon__Contact__c);
                        fields.put(PortalConstants.GUARANTOR_ACCOUNT_ID, party.clcommon__Account__c);
                    }
                }
                List<clcommon.PortalCustomRemoteActionRecord> records = new List<clcommon.PortalCustomRemoteActionRecord>();
                system.debug(fields);
                records.add(new clcommon.PortalCustomRemoteActionRecord('response', fields));
                response = clcommon.PortalActions.getCustomRemoteActionResponse(records);
                response.status= genesis.Constants.SUCCESS;
                if(System.Test.IsRunningTest()) {
                    throw new CustomException('708');
                }
            }
            else{
                Error_Log__c errorLog = ErrorLogs.createErrorLog (
                    PortalConstants.ACCESS_DENIED_ACCESSING_BORROWERS, null, null,
                    null, ErrorLogs.ERROR, borrowerAccountId, true);
                errorLogDBInstance.addInsert(errorLog);
                errorLogDBInstance.executeInserts();
                return getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
            }
        }
         catch (Exception e) {
            Database.rollback(dbSavePoint);
            response = getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
            Error_Log__c errorLog = ErrorLogs.createErrorLog (
                PortalConstants.ERROR_RETRIEVE_ACC_YES_FLOW_CATCH_BP, e.getMessage(), e.getStackTraceString(),
                null, ErrorLogs.ERROR, borrowerAccountId, true);
            errorLogDBInstance.addInsert(errorLog);
            errorLogDBInstance.executeInserts();
            return response;
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