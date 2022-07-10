public class UCCFilingCallout {

    public static String createFiling(UCC_Filing_Detail__c uccFiling, UCC_Setting__mdt uccSettings, Map<Id, Id> contractIdToAccountIdMap, Map<Id, Account> accountMap, loan__Loan_Account__c loanAccount) {
        API_Detail__mdt apiDetails;
        if(GeneralHelper.getOrgInformation.isSandbox){
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(UCCFilings.UCC_FILING_API_SANDBOX);
        }else{
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(UCCFilings.UCC_FILING_UPLOAD_API_PRODUCTION);
        }
        String contentType = 'text/xml; charset=utf-8';
        HttpRequest request = CallOutHelper.createUCCRequest(apiDetails.Endpoint_URL__c, 'POST', contentType);
        request.setHeader('SOAPAction', 'https://eservices.cscfinancialonline.com/CreateFiling');
        request.setHeader('Content-Type', contentType);
        String reqBody =  UCCCalloutParser.getCreateFilingRequestBody(uccFiling, uccSettings, contractIdToAccountIdMap, accountMap, loanAccount, apiDetails);
        request.setBody(reqBody);
        HttpResponse response = CallOutHelper.sendRequest(request);

        String orderID = UCCCalloutParser.parseCreateFilingResponse(response);
        return orderID;
    }

    public static String validateFiling(UCC_Filing_Detail__c uccFiling, UCC_Setting__mdt uccSettings) {
        API_Detail__mdt apiDetails;
        if(GeneralHelper.getOrgInformation.isSandbox){
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(UCCFilings.UCC_FILING_API_SANDBOX);
        }else{
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(UCCFilings.UCC_FILING_UPLOAD_API_PRODUCTION);
        }
        String contentType = 'text/xml; charset=utf-8';
        HttpRequest request = CallOutHelper.createUCCRequest(apiDetails.Endpoint_URL__c, 'POST', contentType);
        request.setHeader('SOAPAction', 'https://eservices.cscfinancialonline.com/ValidateFiling');
        request.setHeader('Content-Type', contentType);
        String reqBody =  UCCCalloutParser.getValidateFilingRequestBody(uccFiling, uccSettings, apiDetails);
        request.setBody(reqBody);
        HttpResponse response = CallOutHelper.sendRequest(request);

        String validationMessage = UCCCalloutParser.parseValidateFilingResponse(response);
        return validationMessage;
    }

    public static String approveFiling(UCC_Filing_Detail__c uccFiling, UCC_Setting__mdt uccSettings) {
        API_Detail__mdt apiDetails;
        if(GeneralHelper.getOrgInformation.isSandbox){
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(UCCFilings.UCC_FILING_API_SANDBOX);
        }else{
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(UCCFilings.UCC_FILING_UPLOAD_API_PRODUCTION);
        }
        String contentType = 'text/xml; charset=utf-8';
        HttpRequest request = CallOutHelper.createUCCRequest(apiDetails.Endpoint_URL__c, 'POST', contentType);
        request.setHeader('SOAPAction', 'https://eservices.cscfinancialonline.com/ApproveOrder');
        request.setHeader('Content-Type', contentType);
        String reqBody =  UCCCalloutParser.getApproveFilingRequestBody(uccFiling, uccSettings, apiDetails);
        request.setBody(reqBody);
        HttpResponse response = CallOutHelper.sendRequest(request);

        String orderID = UCCCalloutParser.parseCreateFilingResponse(response);
        return orderID;
    }

    public static Map<String, List<String>> getOrderInformationByOrderId(String orderId) {
        API_Detail__mdt apiDetails;
        if(GeneralHelper.getOrgInformation.isSandbox){
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(UCCFilings.UCC_FILING_API_SANDBOX);
        }else{
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(UCCFilings.UCC_FILING_UPLOAD_API_PRODUCTION);
        }
        UCC_Setting__mdt uccSettings = CustomMetaDataHelper.defaultuccSetting;
        String contentType = 'text/xml; charset=utf-8';
        HttpRequest request = CallOutHelper.createUCCRequest(apiDetails.Endpoint_URL__c, 'POST', contentType);
        request.setHeader('SOAPAction', 'https://eservices.cscfinancialonline.com/GetOrderInformation');
        String reqBody =  UCCCalloutParser.getOrderInformationRequestBody(orderId, uccSettings, apiDetails);
        request.setBody(reqBody);
        HttpResponse response = CallOutHelper.sendRequest(request);
        Map<String, List<String>> responseMap = XMLParser.parseXMLResponse(response, null, UCCFilings.UCC_GET_ORDER_RESPONSE);
        return responseMap;
    }

    public static Map<String, List<String>> uccFilingContinuation(String orderId) {
        API_Detail__mdt apiDetails;
        if(GeneralHelper.getOrgInformation.isSandbox){
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(UCCFilings.UCC_FILING_API_SANDBOX);
        }else{
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(UCCFilings.UCC_FILING_UPLOAD_API_PRODUCTION);
        }
        String contentType = 'text/xml; charset=utf-8';
        UCC_Setting__mdt uccSettings = CustomMetaDataHelper.defaultuccSetting;
        HttpRequest request = CallOutHelper.createUCCRequest(apiDetails.Endpoint_URL__c, 'POST', contentType);
        request.setHeader('SOAPAction', 'https://eservices.cscfinancialonline.com/ContinueFiling');
        String reqBody =  UCCCalloutParser.uccFilingContinuationRequestBody(orderId, uccSettings, apiDetails);
        request.setBody(reqBody);
        HttpResponse response = CallOutHelper.sendRequest(request);
        Map<String, List<String>> responseMap = XMLParser.parseXMLResponse(response, UCCFilings.UCC_CONTINUATION_RESPONSE, null);
        return responseMap;
    }

    public static String terminateUCC(String OrderId) {
        API_Detail__mdt apiDetails;
        if(GeneralHelper.getOrgInformation.isSandbox){
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(UCCFilings.UCC_FILING_API_SANDBOX);
        }else{
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(UCCFilings.UCC_FILING_UPLOAD_API_PRODUCTION);
        }
        String contentType = 'text/xml; charset=utf-8';
        UCC_Setting__mdt uccSettings = CustomMetaDataHelper.defaultuccSetting;
        HttpRequest request = CallOutHelper.createUCCRequest(apiDetails.Endpoint_URL__c, 'POST', contentType);
        request.setHeader('SOAPAction', 'https://eservices.cscfinancialonline.com/TerminateFiling');
        request.setHeader('Content-Type', contentType);
        String reqBody =  UCCCalloutParser.getTerminateFilingRequestBody(OrderId, uccSettings, apiDetails);
        request.setBody(reqBody);
        HttpResponse response = CallOutHelper.sendRequest(request);

        String requestOrderID = UCCCalloutParser.parseTerminateFilingResponse(response);
        return requestOrderID;

    }

    public static Map<String, List<String>> updateUCC(UCC_Filing_Detail__c uccDetail, Account accountDetails) {
        API_Detail__mdt apiDetails;
        if(GeneralHelper.getOrgInformation.isSandbox){
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(UCCFilings.UCC_FILING_API_SANDBOX);
        }else{
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(UCCFilings.UCC_FILING_UPLOAD_API_PRODUCTION);
        }
        UCC_Setting__mdt uccSettings = CustomMetaDataHelper.defaultuccSetting;
        String contentType = 'text/xml; charset=utf-8';
        HttpRequest request = CallOutHelper.createUCCRequest(apiDetails.Endpoint_URL__c, 'POST', contentType);
        request.setHeader('SOAPAction', 'https://eservices.cscfinancialonline.com/UpdateFiling');
        request.setHeader('Content-Type', contentType);
        String reqBody =  UCCCalloutParser.getUpdateFilingRequestBody(uccDetail, uccSettings, accountDetails, apiDetails);
        request.setBody(reqBody);
        HttpResponse response = CallOutHelper.sendRequest(request);
        Map<String, List<String>> responseMap = XMLParser.parseXMLResponse(response, null, UCCFilings.UCC_GET_ORDER_RESPONSE);
        return responseMap;
    }

    public static String getPlaceID(UCC_Filing_Detail__c uccFiling, loan__Loan_Account__c loanAccount, Map<Id, Id> contractIdToAccountIdMap, Map<Id, Account> accountMap) {
        String uccFilingAddress;
        String placeID = '';
        API_Detail__mdt apiDetails;
        if(GeneralHelper.getOrgInformation.isSandbox){
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(UCCFilings.UCC_FILING_API_SANDBOX);
        }else{
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(UCCFilings.UCC_FILING_UPLOAD_API_PRODUCTION);
        }
        List<Object> resultObjectList = new List<Object>();
        String apiKey = apiDetails.Google_API_Key_For_County__c;
        if(loanAccount.Application__r.Business_Type__c == GeneralConstants.LEGAL_TYPE_SOLE_PROP){
            uccFilingAddress = validateStringValue(String.valueOf(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingStreet))
                                + ',' + validateStringValue(String.valueOf(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingCity)) + ',' + validateStringValue(String.valueOf(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingState)) + ','
                                + validateStringValue(String.valueOf(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingPostalCode)) + ',' + validateStringValue(String.valueOf(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingCountry));
        } else {
            uccFilingAddress = validateStringValue(String.valueOf(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingStreet))
                                + ',' + validateStringValue(String.valueOf(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingCity)) + ',' + validateStringValue(String.valueOf(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingState)) + ','
                                + validateStringValue(String.valueOf(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingPostalCode)) + ',' + validateStringValue(String.valueOf(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingCountry));
        }
        String finalURL = 'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?null=null&input=' + uccFilingAddress +'&inputtype=textquery&key=' + apiKey;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(finalURL);
        request.setMethod('GET');
        HttpResponse response = CallOutHelper.sendRequest(request);
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        if(responseMap.get('candidates') != null){
        	resultObjectList = (List<Object>) responseMap.get('candidates');
        }
        Map<String, Object> placeIDObjectMap = new Map<String, Object>();
        if(!resultObjectList.isEmpty()){
            placeIDObjectMap = (Map<String, Object>) resultObjectList[0];
        }
        if(placeIDObjectMap.get('place_id') != null){
        	placeID = (String) placeIDObjectMap.get('place_id');
        }
        return placeID;
    }

    public static String getCountyParishForUCC(String placeID) {
        String longNameCountyParish;
        Map<String, Object> resultObjectMap = new Map<String, Object>();
        API_Detail__mdt apiDetails;
        if(GeneralHelper.getOrgInformation.isSandbox){
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(UCCFilings.UCC_FILING_API_SANDBOX);
        }else{
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(UCCFilings.UCC_FILING_UPLOAD_API_PRODUCTION);
        }
        String apiKey = apiDetails.Google_API_Key_For_County__c;
        String finalURL = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=' + placeID + '&fields=address_component&key=' + apiKey;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(finalURL);
        request.setMethod('GET');
        HttpResponse response = CallOutHelper.sendRequest(request);
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        if(responseMap.get('result') != null){
            resultObjectMap = (Map<String, Object>) responseMap.get('result');
        }
        List<Object> addressComponentsList = new List<Object>();
        if(resultObjectMap.get('address_components') != null){
        	addressComponentsList = (List<Object>) resultObjectMap.get('address_components');
        }
        for(Object obj : addressComponentsList){
            Map<String, Object> addressComponentsMap = (Map<String, Object>) obj;
            List<Object> typesList = (List<Object>)addressComponentsMap.get('types');
            if(typesList.contains('administrative_area_level_2')){
                longNameCountyParish = (String)addressComponentsMap.get('long_name');
            }
        }
        return longNameCountyParish;
    }

    @TestVisible
    private static String validateStringValue(String value) {
        String stringValue = (String)value;
        if (stringValue == null) {
            return null;
        }
        return stringValue.replaceAll('\n','').replaceAll('\r','').replaceAll(' ', '+').escapeCSV();
    }

    public static Map<String, List<String>> getUCCAttachmentsByAttachmentId(String attachmentId) {
        API_Detail__mdt apiDetails;
        if(GeneralHelper.getOrgInformation.isSandbox){
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(UCCFilings.UCC_FILING_API_SANDBOX);
        }else{
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(UCCFilings.UCC_FILING_UPLOAD_API_PRODUCTION);
        }
        UCC_Setting__mdt uccSettings = CustomMetaDataHelper.defaultuccSetting;
        String contentType = 'text/xml; charset=utf-8';
        HttpRequest request = CallOutHelper.createUCCRequest(apiDetails.Endpoint_URL__c, 'POST', contentType);
        request.setHeader('SOAPAction', 'https://eservices.cscfinancialonline.com/GetAttachment');
        String reqBody =  UCCCalloutParser.getUCCAttachmentsRequestBody(attachmentId, uccSettings, apiDetails);
        request.setBody(reqBody);
        HttpResponse response = CallOutHelper.sendRequest(request);
        Map<String, List<String>> responseMap = XMLParser.parseXMLResponse(response, UCCFilings.UCC_GET_ATTACHMENT_RESPONSE, null);
        return responseMap;
    }

    public static blob getUCCAttachmentsFromExternalURL(String attachmentLink) {
        attachmentLink = attachmentLink.replace(' ', '%20');
        HttpRequest request = CallOutHelper.createRequest(attachmentLink, 'GET');
        request.setCompressed(true);
        HttpResponse response = CallOutHelper.sendRequest(request);
        blob returnFile = response.getBodyAsBlob();
        return returnFile;
    }
}