global class CLCollectionsCongaURLAPI implements clcommon.PortalCustomRemoteAPI1 {
    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> params) {

        clcommon.Response res = new clcommon.Response();
        Map<String,Object> fields = new Map<String,Object>();
        List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();

        try {
            String baseURL = System.URL.getSalesforceBaseUrl().toExternalForm();
            String orgId = UserInfo.getOrganizationId();
            Id contractId = (Id)params.get('contractId');
            String congaDocURL = PortalConstants.CONGA_BASE_URL;
            Id contractQuery = (Id)params.get('contractQuery');
            Id externalId = (Id)params.get('externalId');
            Id contactId = (Id)params.get('contactId');

            congaDocURL = congaDocURL.replace(PortalConstants.SFDC_BASEURL_KEY, baseURL);
            congaDocURL = congaDocURL.replace(PortalConstants.ORG_ID_KEY, orgId);
            congaDocURL = congaDocURL.replace(PortalConstants.REC_ID_KEY, contractId);
            congaDocURL = congaDocURL.replace(PortalConstants.CONTRACT_QUERY, contractQuery);
            congaDocURL = congaDocURL.replace(PortalConstants.CL_EXTERNAL_ID, externalId);
            congaDocURL = congaDocURL.replace(PortalConstants.RECIPIENT_ID_KEY, contactId);
            

            fields.put('congaDocURL',congaDocURL);
            respList.add(new clcommon.PortalCustomRemoteActionRecord('KEY_RESPONSE', fields));
            res = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
            res.Status = PortalConstants.API_RESPONSE_STATUS_SUCCESS;
            res.errorMessage = null;
        } catch (Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog (
                PortalConstants.CONGA_URL_GENERATION_FAILED_STATUS, e.getMessage(), e.getStackTraceString(), null, 'Error', null, true);
            errorLogDBInstance.addInsert(errorLog);
            errorLogDBInstance.executeInserts();
            res.status = PortalConstants.API_RESPONSE_STATUS_FAILED;
            res.errorMessage = PortalConstants.CONGA_URL_GENERATION_FAILED_STATUS;
        }
    return res;
    }
}