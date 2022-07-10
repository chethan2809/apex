global class CustomPortalSubmitConsentAPI implements clcommon.PortalCustomRemoteAPI1
{
    DisclosureDefinitionDB disclosureDefinitionDB = new DisclosureDefinitionDB();
    PartyDB partyDB = new PartyDB();
    DisclosureAcknowledgementDB disclosureAcknowledgementDB = new DisclosureAcknowledgementDB();
    ApplicationDB applicationDB = new ApplicationDB();
    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    global clcommon.Response invokeAction(String componentStrName,
            String[] disclosureNames,
            Map<String, Object> argumentsFromPortal){

        final string generalDisclosure = 'clx_consumer_GeneralDisclosure';

        SavePoint dbSavePoint = Database.setSavePoint();
        clcommon.Response response = new clcommon.Response();
        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        Boolean creditCheckConsent = false;
        Boolean electronicConsent = false;
        String applicationId = (Id)argumentsFromPortal.get(GeneralConstants.APPLICATION_ID);
        Boolean isValidApp = PortalSecurityUtil.validateUserApplication(applicationId);
        if(isValidApp){
            try {
                applicationList =  applicationDB.getApplicationPartiesConsentById(new Set<Id>{applicationId});
                applicationList[0].Portal_Stage__c = (String)argumentsFromPortal.get('portalStage');
                applicationList[0].Portal_Sub_Stage__c = (String)argumentsFromPortal.get('portalSubstage');

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
            } catch (Exception e) {
                Database.rollback(dbSavePoint);
                Error_Log__c errorLog = ErrorLogs.createErrorLog (
                        'Submit Consent from Merchant Portal', e.getMessage(), e.getStackTraceString(),
                        null, ErrorLogs.ERROR, applicationId, true);
                errorLogDBInstance.addInsert(errorLog);
                errorLogDBInstance.executeInserts();
                response = getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
                return response;
            }
            Map<String,Object> fields = new Map<String,Object>();
            fields.put('applicationId',applicationList[0].Id);
            List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
            respList.add(new clcommon.PortalCustomRemoteActionRecord('KEY_RESPONSE', fields));
            response = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
        }
        else{
            Error_Log__c errorLog = ErrorLogs.createErrorLog (
                'Submit Consent from Merchant Portal',PortalConstants.NO_PERMISSION_ERROR_MSG, null,
                null, ErrorLogs.ERROR, applicationId, true);
            errorLogDBInstance.addInsert(errorLog);
            errorLogDBInstance.executeInserts();
            response = getErrorResponse(PortalConstants.SOMETHING_WENT_WRONG_MESSAGE);
        }
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