global class PortalUpdateLoanNameAPI implements clcommon.PortalCustomRemoteAPI1 {
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames,Map<String, Object> argumentsFromPortal) {

        String loanId = (String)argumentsFromPortal.get('loanId');
        Map<String,Object> loanJson = (Map<String, Object>)JSON.deserializeUntyped((String)argumentsFromPortal.get('editLoanName'));
        loan__loan_account__c loanAccount = new loan__loan_account__c();
        loanAccount.Id = loanId;
        //loanAccount.Loan_Name__c = (String)loanJson.get('Name');
        update loanAccount;

        clcommon.Response response = new clcommon.Response();
         Map<String,Object> fields = new Map<String,Object>();
        //fields.put('contactId',contactId);

        List<clcommon.PortalCustomRemoteActionRecord> respList = new List<clcommon.PortalCustomRemoteActionRecord>();
        respList.add(new clcommon.PortalCustomRemoteActionRecord('KEY_RESPONSE', fields));
        response = clcommon.PortalActions.getCustomRemoteActionResponse(respList);
        return response;
    }
    /*private clcommon.Response getErrorResponse(String errorMessage) {
        clcommon.Response response = new clcommon.Response();
        response.status = clcommon.Constants.ERROR;
        response.errorMessage = errorMessage;
        response.errorCode = clcommon.Constants.API_EXCEPTION;
        return response;
    }*/
}