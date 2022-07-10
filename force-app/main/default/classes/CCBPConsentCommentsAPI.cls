global class CCBPConsentCommentsAPI implements clcommon.PortalCustomRemoteAPI1
{
    DisclosureDefinitionDB disclosureDefinitionDB = new DisclosureDefinitionDB();
    PartyDB partyDB = new PartyDB();
    DisclosureAcknowledgementDB disclosureAcknowledgementDB = new DisclosureAcknowledgementDB();
    ApplicationDB applicationDB = new ApplicationDB();
    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    final string generalDisclosure = PortalConstants.CC_Broker_General_Disclosure;
    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> argumentsFromPortal){
        SavePoint dbSavePoint = Database.setSavePoint();
        clcommon.Response response = new clcommon.Response();
        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        Boolean creditCheckConsent = false;
        Id applicationId = (Id)argumentsFromPortal.get(PortalConstants.APPLICATION_ID);
        try {
            Boolean isValidApplication;
            if(argumentsFromPortal.containsKey(PartnerAPIConstants.PARTNER_INFO)) {
                isValidApplication = true;
            }else{
            	isValidApplication = CLSPBPortalSecurity.validApplication(applicationId);
            }
            if(isValidApplication){
                applicationList = applicationDB.getApplicationPartiesConsentById(new Set<Id>{applicationId});
                List<clcommon__Disclosure_Definition__c> disclosuresList = disclosureDefinitionDB.getDisclosureDefinition();
                Map<String,clcommon__Disclosure_Definition__c> disclosureNameToObjectMap = new Map<String,clcommon__Disclosure_Definition__c>();
                for(clcommon__Disclosure_Definition__c disclosure : disclosuresList){
                    disclosureNameToObjectMap.put(disclosure.Name,disclosure);
                }
                List<clcommon__Disclosure_Acknowledgement__c> disclosureAcknowledgementList = new List<clcommon__Disclosure_Acknowledgement__c>();
                List<clcommon__Party__c> partyList = applicationList[0].genesis__Parties__r;
                if(disclosureNames != null && disclosureNames.size() > 0){
                    for(clcommon__Party__c party : partyList){
                        for(String disclosure : disclosureNames){
                            clcommon__Disclosure_Acknowledgement__c disclosureAcknowledgement = new clcommon__Disclosure_Acknowledgement__c();
                            if(disclosure.equalsIgnoreCase(generalDisclosure)){
                                creditCheckConsent = true;
                                disclosureAcknowledgement = DisclosureAcknowledgements.acceptDisclosureAcknowledgement(party, disclosureNameToObjectMap, generalDisclosure);
                            }
                            disclosureAcknowledgementDB.addInsert(disclosureAcknowledgement);
                        }
                        party.genesis__Credit_Check_Consent__c = creditCheckConsent;
                    }
                    applicationList[0].Credit_Check_Consent__c = creditCheckConsent;
                }
                applicationDB.addUpdates(applicationList);
                applicationDB.executeUpdates();
                partyDB.addUpdates(partyList);
                PartyDB.executeUpdates();
                disclosureAcknowledgementDB.executeInserts();
                response.status = clcommon.Constants.SUCCESS;
            }else{
                Error_Log__c errorLog = ErrorLogs.createErrorLog (
                            PortalConstants.ACCESS_DENIED_SUBMITTING_APPLICATION, null, null,
                            null, ErrorLogs.ERROR, applicationId, true);
                errorLogDBInstance.addInsert(errorLog);
                errorLogDBInstance.executeInserts();
                return getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
            }
        } catch (Exception e) {
            Database.rollback(dbSavePoint);
            response = getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
            Error_Log__c errorLog = ErrorLogs.createErrorLog (
                PortalConstants.ERROR_CONSENT_COMMENTS_CATCH_BP, e.getMessage(), e.getStackTraceString(),
                null, ErrorLogs.ERROR, applicationId, true);
            errorLogDBInstance.addInsert(errorLog);
            errorLogDBInstance.executeInserts();
            return response;
        }
        Map<String,Object> fields = new Map<String,Object>();
        fields.put(PortalConstants.APPLICATION_ID, applicationList[0].Id);
        List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
        respList.add(new clcommon.PortalCustomRemoteActionRecord('KEY_RESPONSE', fields));
        response = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
        return response;
    }
    private clcommon.Response getErrorResponse(String errorMessage){
        clcommon.Response response = new clcommon.Response();
        response.status = clcommon.Constants.ERROR;
        response.errorMessage = errorMessage;
        response.errorCode = clcommon.Constants.API_EXCEPTION;
        return response;
    }
}