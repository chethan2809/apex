public class UCCCalloutParser {

    public static string getCreateFilingRequestBody(UCC_Filing_Detail__c uccDetail, UCC_Setting__mdt uccSettings, Map<Id, Id> contractIdToAccountIdMap, Map<Id, Account> accountMap, loan__Loan_Account__c loanAccount, API_Detail__mdt apiDetails)
    {
        String loginGuid = apiDetails.Login_GUID__c;
        String requestXML;
        requestXML = '<?xml version="1.0" encoding="utf-8"?>';
        requestXML = requestXML + '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">';
       	requestXML = requestXML + '<soap:Body>';
        requestXML = requestXML + '<CreateFiling xmlns="https://eservices.cscfinancialonline.com/">';
        requestXML = requestXML + '<params>';
        requestXML = requestXML + '<param name="contactNo">1</param>';
        requestXML = requestXML + '<param name="loginGuid">' + loginGuid + '</param>';
        requestXML = requestXML + '<param name="xmlFiling">';
        requestXML = requestXML + '<Document xmlns="">';
        requestXML = requestXML + '<Header>';
        requestXML = requestXML + '<Filer>';
        requestXML = requestXML + '<Names>';
        requestXML = requestXML + '<OrganizationName>' + validateStringValue(uccDetail.Filer_Organization_Name__c) + '</OrganizationName>';
        requestXML = requestXML + '<MailAddress>' + validateStringValue(uccDetail.Filer_Mail_Address__c) + '</MailAddress>';
        requestXML = requestXML + '<City>' + validateStringValue(uccDetail.Filer_City__c) + '</City>';
        requestXML = requestXML + '<State>' + validateStringValue(uccDetail.Filer_State__c) + '</State>';
        requestXML = requestXML + '<PostalCode>' + validateStringValue(uccDetail.Filer_PostalCode__c) + '</PostalCode>';
        requestXML = requestXML + '</Names>';
        requestXML = requestXML + '<ClientAccountNum></ClientAccountNum>';
        requestXML = requestXML + '<ContactName>' + validateStringValue(uccDetail.Filer_Contact_Name__c) + '</ContactName>';
        requestXML = requestXML + '<ContactPhone>'+ validateStringValue(uccDetail.Filer_Contact_Phone__c) + '</ContactPhone>';
        requestXML = requestXML + '<ContactEmail>' + validateStringValue(uccDetail.Filer_Contact_Email__c) + '</ContactEmail>';
        requestXML = requestXML + '<ContactFax>' + validateStringValue(uccDetail.Filer_Contact_Fax__c) + '</ContactFax>';
        requestXML = requestXML + '</Filer>';
        requestXML = requestXML + '</Header>';
        requestXML = requestXML + '<Record>';
        requestXML = requestXML + '<SeqNumber>1</SeqNumber>';
        requestXML = requestXML + '<TransType Type="Initial"/>';
        requestXML = requestXML + '<Diligenz>';
        requestXML = requestXML + '<References>';
        requestXML = requestXML + '<ReferenceField Index="Yes">';
        requestXML = requestXML + '<ReferenceFieldName>QueueID</ReferenceFieldName>';
        requestXML = requestXML + '<ReferenceFieldValue>' + accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).Merchant_ID__c + '</ReferenceFieldValue>';
        requestXML = requestXML + '</ReferenceField>';
        requestXML = requestXML + '<ReferenceField>';
        requestXML = requestXML + '<ReferenceFieldName>MerchantID</ReferenceFieldName>';
        requestXML = requestXML + '<ReferenceFieldValue>' + accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).Merchant_ID__c + '</ReferenceFieldValue>';
        requestXML = requestXML + '</ReferenceField>';
        requestXML = requestXML + '</References>';
        requestXML = requestXML + '<FilingJurisdiction>';
        requestXML = requestXML + '<State>' + uccDetail.Jurisdiction_State__c + '</State>';
        requestXML = requestXML + '<JurisdictionName>' + uccDetail.Jurisdiction_Name__c + '</JurisdictionName>';
        requestXML = requestXML + '<JurisdictionID>' + uccDetail.Jurisdiction_ID__c + '</JurisdictionID>';
        requestXML = requestXML + '</FilingJurisdiction>';
        requestXML = requestXML + '<ContactName></ContactName>';
        requestXML = requestXML + '</Diligenz>';
        requestXML = requestXML + '<FLStampTax Tax = ' + (uccDetail.Jurisdiction_State__c == 'FL' ? '"Paid"' : '"NA"') + '> </FLStampTax>';
        requestXML = requestXML + '<SubmitterRef>Optional Filer Reference</SubmitterRef>';
        requestXML = requestXML + '<SearchToReflect/>';
        requestXML = requestXML + '<STRCertified/>';
        requestXML = requestXML + '<StrDocuments/>';
        requestXML = requestXML + '<StrUpdatedFrom/>';
        requestXML = requestXML + '<Debtors>';
        requestXML = requestXML + '<DebtorName>';
        requestXML = requestXML + '<Names>';
        requestXML = requestXML + '<OrganizationName>' + validateStringValue(uccDetail.Debtor_Organization_Name__c) + '</OrganizationName>';
        requestXML = requestXML + '<MailAddress>' + validateStringValue(uccDetail.Debtor_Mail_Address__c) + '</MailAddress>';
        requestXML = requestXML + '<City>' + validateStringValue(uccDetail.Debtor_City__c) + '</City>';
        requestXML = requestXML + '<State>' + validateStringValue(uccDetail.Debtor_Organization_State__c) + '</State>';
        requestXML = requestXML + '<PostalCode>' + validateStringValue(uccDetail.Debtor_Organization_PostalCode__c) + '</PostalCode>';
        requestXML = requestXML + '<County/>';
        requestXML = requestXML + '<Country>' + validateStringValue(uccDetail.Debtor_Organization_Country__c) + '</Country>';
        requestXML = requestXML + '<OrganizationalType Type="NOType">' + validateStringValue(uccDetail.Debtor_Organizational_Type__c) + '</OrganizationalType>';
        requestXML = requestXML + '<OrganizationalJuris>' + validateStringValue(uccDetail.Debtor_Organizational_Jurisdiction__c) + '</OrganizationalJuris>';
        requestXML = requestXML + '<OrganizationalID>' + validateStringValue(uccDetail.Debtor_Organizational_ID__c) + '</OrganizationalID>';
        requestXML = requestXML + '</Names>  </DebtorName>';
        requestXML = requestXML + '<DebtorName>';
        requestXML = requestXML + '<Names>';
        requestXML = requestXML + '<IndividualName>';
        requestXML = requestXML + '<LastName>' + validateStringValue(uccDetail.Debtor_Individual_LastName__c) + '</LastName>';
        requestXML = requestXML + '<FirstName>' + validateStringValue(uccDetail.Debtor_Individual_FirstName__c) + '</FirstName>';
        requestXML = requestXML + '<MiddleName>' + validateStringValue(uccDetail.Debtor_Individual_MiddleName__c) + '</MiddleName>';
        requestXML = requestXML + '<Suffix>' + validateStringValue(uccDetail.Debtor_Individual_Suffix__c) + '</Suffix>';
        requestXML = requestXML + '</IndividualName>';
        requestXML = requestXML + '<MailAddress>' + validateStringValue(uccDetail.Debtor_Individual_MailAddress__c) + '</MailAddress>';
        requestXML = requestXML + '<City>' + validateStringValue(uccDetail.Debtor_Individual_City__c) + '</City>';
        requestXML = requestXML + '<State>' + validateStringValue(uccDetail.Debtor_Individual_State__c) + '</State>';
        requestXML = requestXML + '<PostalCode>' + validateStringValue(uccDetail.Debtor_Individual_PostalCode__c) + '</PostalCode>';
        requestXML = requestXML + '<Country>' + validateStringValue(uccDetail.Debtor_Individual_Country__c) + '</Country>';
        requestXML = requestXML + '</Names> </DebtorName>';
        requestXML = requestXML + '</Debtors>';
        requestXML = requestXML + '<Secured>  <SecuredName>';
        requestXML = requestXML + '<Names>';
        requestXML = requestXML + '<OrganizationName>' + validateStringValue(uccDetail.Secured_Organization_Name__c) + '</OrganizationName>';
        requestXML = requestXML + '<MailAddress>' + validateStringValue(uccDetail.Secured_MailAddress__c) + '</MailAddress>';
        requestXML = requestXML + '<City>' + validateStringValue(uccDetail.Secured_City__c) + '</City>';
        requestXML = requestXML + '<State>' + validateStringValue(uccDetail.Secured_State__c) + '</State>';
        requestXML = requestXML + '<PostalCode>' + validateStringValue(uccDetail.Secured_postalCode__c) + '</PostalCode>';
        requestXML = requestXML + '<Country>' + validateStringValue(uccDetail.Secured_Country__c) + '</Country>';
        requestXML = requestXML + '</Names>';
        requestXML = requestXML + '</SecuredName> </Secured>';
        requestXML = requestXML + '<Collateral>';
        requestXML = requestXML + '<ColText>' + validateStringValue(uccDetail.Collateral_Text1__c) + '</ColText>';
        requestXML = requestXML + '</Collateral>';
        requestXML = requestXML + '</Record>';
        requestXML = requestXML + '</Document>  </param>';
        requestXML = requestXML + '</params>';
        requestXML = requestXML + '</CreateFiling>';
        requestXML = requestXML + '</soap:Body>';
        requestXML = requestXML + '</soap:Envelope>';
        return requestXML;
    }

    public static string getOrderInformationRequestBody(String orderId, UCC_Setting__mdt uccSettings, API_Detail__mdt apiDetails) {
        String loginGuid = apiDetails.Login_GUID__c;
        String requestXML;
        requestXML ='<?xml version="1.0" encoding="utf-8"?>';
        requestXML = requestXML + '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">';
       	requestXML = requestXML + '<soap:Body>';
        requestXML = requestXML + '<GetOrderInformation xmlns="https://eservices.cscfinancialonline.com/">';
        requestXML = requestXML + '<params>';
        requestXML = requestXML + '<param name="loginGuid">' + loginGuid + '</param>';
        requestXML = requestXML + '<param name="contactNo">1</param>';
        requestXML = requestXML + '<param name="orderID">' + orderId + '</param>';
        requestXML = requestXML + '</params>';
        requestXML = requestXML + '</GetOrderInformation>';
        requestXML = requestXML + '</soap:Body>';
        requestXML = requestXML + '</soap:Envelope>';
        return requestXML;
    }

    public static string getValidateFilingRequestBody(UCC_Filing_Detail__c uccDetail, UCC_Setting__mdt uccSettings, API_Detail__mdt apiDetails)
    {
        String loginGuid = apiDetails.Login_GUID__c;
        String requestXML;
        String orderID;
        if(!uccDetail.Is_Terminated__c){
            orderID = uccDetail.Order_ID__c;
        } else {
            orderID = uccDetail.Terminated_Order_ID__c;
        }
        requestXML = '<?xml version="1.0" encoding="utf-8"?>';
        requestXML = requestXML + '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">';
       	requestXML = requestXML + '<soap:Body>';
        requestXML = requestXML + '<ValidateFiling xmlns="https://eservices.cscfinancialonline.com/">';
        requestXML = requestXML + '<params>';
        requestXML = requestXML + '<param name="contactNo">1</param>';
        requestXML = requestXML + '<param name="loginGuid">' +loginGuid + '</param>';
        requestXML = requestXML + '<param name="orderID">' + orderID + '</param>';
        requestXML = requestXML + '</params>';
        requestXML = requestXML + '</ValidateFiling>';
        requestXML = requestXML + '</soap:Body>';
        requestXML = requestXML + '</soap:Envelope>';

        return requestXML;
    }

    public static string uccFilingContinuationRequestBody(String orderId, UCC_Setting__mdt uccDetails, API_Detail__mdt apiDetails) {

        String loginGuid = apiDetails.Login_GUID__c;
        String requestXML;
        requestXML = '<?xml version="1.0" encoding="utf-8"?>';
        requestXML = requestXML + '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">';
       	requestXML = requestXML + '<soap:Body>';
        requestXML = requestXML + '<ContinueFiling xmlns="https://eservices.cscfinancialonline.com/">';
        requestXML = requestXML + '<params>';
        requestXML = requestXML + '<param name="loginGuid">' + loginGuid + '</param>';
        requestXML = requestXML + '<param name="contactNo">1</param>';
        requestXML = requestXML + '<param name="orderID">' + orderId + '</param>';
        requestXML = requestXML + '</params>';
        requestXML = requestXML + '</ContinueFiling>';
        requestXML = requestXML + '</soap:Body>';
        requestXML = requestXML + '</soap:Envelope>';

        return requestXML;
    }

    public static string getApproveFilingRequestBody(UCC_Filing_Detail__c uccDetail, UCC_Setting__mdt uccDetails, API_Detail__mdt apiDetails)
    {
        String loginGuid = apiDetails.Login_GUID__c;
        String requestXML;
        String orderID;
        if(!uccDetail.Is_Terminated__c){
            orderID = uccDetail.Order_ID__c;
        } else {
            orderID = uccDetail.Terminated_Order_ID__c;
        }
        requestXML ='<?xml version="1.0" encoding="utf-8"?>';
        requestXML = requestXML + '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">';
       	requestXML = requestXML + '<soap:Body>';
        requestXML = requestXML + '<ApproveOrder xmlns="https://eservices.cscfinancialonline.com/">';
        requestXML = requestXML + '<params>';
        requestXML = requestXML + '<param name="contactNo">1</param>';
        requestXML = requestXML + '<param name="loginGuid">' + loginGuid + '</param>';
        requestXML = requestXML + '<param name="orderID">' + orderID + '</param>';
        requestXML = requestXML + '</params>';
        requestXML = requestXML + '</ApproveOrder>';
        requestXML = requestXML + '</soap:Body>';
        requestXML = requestXML + '</soap:Envelope>';

        return requestXML;
    }

    public static string parseCreateFilingResponse(HttpResponse responseObj)
    {
        string orderID ='';
        if(responseObj.getStatusCode() == 200) {
            orderID = responseObj.getBody().subStringBetween('<OrderID>','</OrderID>');
            return orderID;
        } else if (responseObj.getStatusCode() != 200) {
            orderID = responseObj.getBody().subStringBetween('<faultstring>','</faultstring>');
            return 'Failure: ' + orderID;
        }
        return orderID;
    }

    public static string parseValidateFilingResponse(HttpResponse responseObj)
    {
        string validationMessage ='';
        validationMessage = responseObj.getBody().subStringBetween('<Messages>','</Messages>');
        return validationMessage;
    }

    public static string parseTerminateFilingResponse(HttpResponse responseObj)
    {
        string orderID ='';
        if(responseObj.getStatusCode() == 200) {
            orderID = responseObj.getBody().subStringBetween('<OrderID>','</OrderID>');
            return orderID;
        } else if (responseObj.getStatusCode() != 200) {
            orderID = responseObj.getBody().subStringBetween('<faultstring>','</faultstring>');
            return 'Failure: ' + orderID;
        }
        return orderID;
    }

    public static string getUpdateFilingRequestBody(UCC_Filing_Detail__c uccDetail , UCC_Setting__mdt uccSettings, Account accountDetails, API_Detail__mdt apiDetails)
    {
        String loginGuid = apiDetails.Login_GUID__c;
        String requestXML;
        requestXML = '<?xml version="1.0" encoding="utf-8"?>';
        requestXML = requestXML + '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">';
       	requestXML = requestXML + '<soap:Body>';
        requestXML = requestXML + '<UpdateFiling xmlns="https://eservices.cscfinancialonline.com/">';
        requestXML = requestXML + '<params>';
        requestXML = requestXML + '<param name="contactNo">1</param>';
        requestXML = requestXML + '<param name="loginGuid">' + loginGuid + '</param>';
        requestXML = requestXML + '<param name="orderID">' + uccDetail.Order_ID__c + '</param>';
        requestXML = requestXML + '<param name="xmlFiling">';
        requestXML = requestXML + '<Document xmlns="">';
        requestXML = requestXML + '<Header>';
        requestXML = requestXML + '<Filer>';
        requestXML = requestXML + '<Names>';
        requestXML = requestXML + '<OrganizationName/>';
        requestXML = requestXML + '<MailAddress/>';
        requestXML = requestXML + '<City/>';
        requestXML = requestXML + '<State/>';
        requestXML = requestXML + '<PostalCode/>';
        requestXML = requestXML + '</Names>';
        requestXML = requestXML + '<ClientAccountNum/>';
        requestXML = requestXML + '<ContactName/>';
        requestXML = requestXML + '<ContactPhone/>';
        requestXML = requestXML + '<ContactEmail/>';
        requestXML = requestXML + '<ContactFax/>';
        requestXML = requestXML + '</Filer>';
        requestXML = requestXML + '</Header>';
        requestXML = requestXML + '<Record>';
        requestXML = requestXML + '<SeqNumber>1</SeqNumber>';
        requestXML = requestXML + '<TransType Type="Initial"/>';
        requestXML = requestXML + '<Diligenz>';
        requestXML = requestXML + '<References>';
        requestXML = requestXML + '<ReferenceField Index="Yes">';
        requestXML = requestXML + '<ReferenceFieldName>QueueID</ReferenceFieldName>';
        requestXML = requestXML + '<ReferenceFieldValue>' + accountDetails.Merchant_ID__c + '</ReferenceFieldValue>';
        requestXML = requestXML + '</ReferenceField>';
        requestXML = requestXML + '<ReferenceField>';
        requestXML = requestXML + '<ReferenceFieldName>MerchantID</ReferenceFieldName>';
        requestXML = requestXML + '<ReferenceFieldValue>' + accountDetails.Merchant_ID__c + '</ReferenceFieldValue>';
        requestXML = requestXML + '</ReferenceField>';
        requestXML = requestXML + '<ReferenceField>';
        requestXML = requestXML + '<ReferenceFieldName>CompanyID</ReferenceFieldName>';
        requestXML = requestXML + '<ReferenceFieldValue></ReferenceFieldValue>';
        requestXML = requestXML + '</ReferenceField>';
        requestXML = requestXML + '</References>';
        requestXML = requestXML + '<FilingJurisdiction>';
        requestXML = requestXML + '<State>' + uccDetail.Jurisdiction_State__c + '</State>';
        requestXML = requestXML + '<JurisdictionName>' + uccDetail.Jurisdiction_Name__c + '</JurisdictionName>';
        requestXML = requestXML + '<JurisdictionID>' + uccDetail.Jurisdiction_ID__c + '</JurisdictionID>';
        requestXML = requestXML + '</FilingJurisdiction>';
        requestXML = requestXML + '<ContactName></ContactName>';
        requestXML = requestXML + '</Diligenz>';
        requestXML = requestXML + '<SubmitterRef>Optional Filer Reference</SubmitterRef>';
        requestXML = requestXML + '<SearchToReflect/>';
        requestXML = requestXML + '<STRCertified/>';
        requestXML = requestXML + '<StrDocuments/>';
        requestXML = requestXML + '<StrUpdatedFrom/>';
        requestXML = requestXML + '<Debtors>';
        requestXML = requestXML + '<DebtorName>';
        requestXML = requestXML + '<Names>';
        requestXML = requestXML + '<OrganizationName>' + validateStringValue(uccDetail.Debtor_Organization_Name__c) + '</OrganizationName>';
        requestXML = requestXML + '<MailAddress>' + validateStringValue(uccDetail.Debtor_Mail_Address__c) + '</MailAddress>';
        requestXML = requestXML + '<City>' + validateStringValue(uccDetail.Debtor_City__c) + '</City>';
        requestXML = requestXML + '<State>' + validateStringValue(uccDetail.Debtor_Organization_State__c) + '</State>';
        requestXML = requestXML + '<PostalCode>' + validateStringValue(uccDetail.Debtor_Organization_PostalCode__c) + '</PostalCode>';
        requestXML = requestXML + '<County/>';
        requestXML = requestXML + '<Country>' + validateStringValue(uccDetail.Debtor_Organization_Country__c) + '</Country>';
        requestXML = requestXML + '<OrganizationalType Type="NOType">' + validateStringValue(uccDetail.Debtor_Organizational_Type__c) + '</OrganizationalType>';
        requestXML = requestXML + '<OrganizationalJuris>' + validateStringValue(uccDetail.Debtor_Organizational_Jurisdiction__c) + '</OrganizationalJuris>';
        requestXML = requestXML + '<OrganizationalID>' + validateStringValue(uccDetail.Debtor_Organizational_ID__c) + '</OrganizationalID>';
        requestXML = requestXML + '</Names>';
        requestXML = requestXML + '</DebtorName>';
        requestXML = requestXML + '<DebtorName>';
        requestXML = requestXML + '<Names>';
        requestXML = requestXML + '<IndividualName>';
        requestXML = requestXML + '<LastName>' + validateStringValue(uccDetail.Secured_Organization_Name__c) + '</LastName>';
        requestXML = requestXML + '<FirstName>' + validateStringValue(uccDetail.Debtor_Individual_FirstName__c) + '</FirstName>';
        requestXML = requestXML + '<MiddleName>' + validateStringValue(uccDetail.Debtor_Individual_MiddleName__c) + '</MiddleName>';
        requestXML = requestXML + '<Suffix>' + validateStringValue(uccDetail.Debtor_Individual_Suffix__c) + '</Suffix>';
        requestXML = requestXML + '</IndividualName>';
        requestXML = requestXML + '<MailAddress>' + validateStringValue(uccDetail.Debtor_Individual_MailAddress__c) + '</MailAddress>';
        requestXML = requestXML + '<City>' + validateStringValue(uccDetail.Debtor_Individual_City__c) + '</City>';
        requestXML = requestXML + '<State>' + validateStringValue(uccDetail.Debtor_Individual_State__c) + '</State>';
        requestXML = requestXML + '<PostalCode>' + validateStringValue(uccDetail.Debtor_Individual_PostalCode__c) + '</PostalCode>';
        requestXML = requestXML + '<Country>' + validateStringValue(uccDetail.Debtor_Individual_Country__c) + '</Country>';
        requestXML = requestXML + '</Names>';
        requestXML = requestXML + '</DebtorName>';
        requestXML = requestXML + '</Debtors>';
        requestXML = requestXML + '<Secured>';
        requestXML = requestXML + '<SecuredName>';
        requestXML = requestXML + '<Names>';
        requestXML = requestXML + '<OrganizationName>' + validateStringValue(uccDetail.Secured_Organization_Name__c) + '</OrganizationName>';
        requestXML = requestXML + '<MailAddress>' + validateStringValue(uccDetail.Secured_MailAddress__c) + '</MailAddress>';
        requestXML = requestXML + '<City>' + validateStringValue(uccDetail.Secured_City__c) + '</City>';
        requestXML = requestXML + '<State>' + validateStringValue(uccDetail.Secured_State__c) + '</State>';
        requestXML = requestXML + '<PostalCode>' + validateStringValue(uccDetail.Secured_postalCode__c) + '</PostalCode>';
        requestXML = requestXML + '<Country>' + validateStringValue(uccDetail.Secured_Country__c) + '</Country>';
        requestXML = requestXML + '</Names>';
        requestXML = requestXML + '</SecuredName> ';
        requestXML = requestXML + '</Secured>';
        requestXML = requestXML + '<Collateral>';
        requestXML = requestXML + '<ColText>' + validateStringValue(uccDetail.Collateral_Text1__c) + '</ColText>';
        requestXML = requestXML + '</Collateral>';
        requestXML = requestXML + '</Record>';
        requestXML = requestXML + '</Document>';
        requestXML = requestXML + '</param>';
        requestXML = requestXML + '</params>';
        requestXML = requestXML + '</UpdateFiling>';
        requestXML = requestXML + '</soap:Body>';
        requestXML = requestXML + '</soap:Envelope>';

        return requestXML;
    }

    public static string getTerminateFilingRequestBody(String OrderId, UCC_Setting__mdt uccSettings, API_Detail__mdt apiDetails)
    {
        String loginGuid = apiDetails.Login_GUID__c;
        String requestXML;
        requestXML =  '<?xml version="1.0" encoding="utf-8"?>';
        requestXML = requestXML + '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">';
       	requestXML = requestXML + '<soap:Body>';
        requestXML = requestXML + '<TerminateFiling xmlns="https://eservices.cscfinancialonline.com/">';
        requestXML = requestXML + '<params>';
        requestXML = requestXML + '<param name="contactNo">1</param>';
        requestXML = requestXML + '<param name="loginGuid">' + loginGuid + '</param>';
        requestXML = requestXML + '<param name="orderID">' + OrderId + '</param>';
        requestXML = requestXML + '</params>';
        requestXML = requestXML + '</TerminateFiling>';
        requestXML = requestXML + '</soap:Body>';
        requestXML = requestXML + '</soap:Envelope>';

        return requestXML;
    }

    public static string getUCCAttachmentsRequestBody(String attachmentId, UCC_Setting__mdt uccSettings, API_Detail__mdt apiDetails) {
        String loginGuid = apiDetails.Login_GUID__c;
        String requestXML;
        requestXML ='<?xml version="1.0" encoding="utf-8"?>';
        requestXML = requestXML + '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">';
       	requestXML = requestXML + '<soap:Body>';
        requestXML = requestXML + '<GetAttachment xmlns="https://eservices.cscfinancialonline.com/">';
        requestXML = requestXML + '<params>';
        requestXML = requestXML + '<param name="loginGuid">' + loginGuid + '</param>';
        requestXML = requestXML + '<param name="contactNo">1</param>';
        requestXML = requestXML + '<param name="attachmentID">' + attachmentId + '</param>';
        requestXML = requestXML + '</params>';
        requestXML = requestXML + '</GetAttachment>';
        requestXML = requestXML + '</soap:Body>';
        requestXML = requestXML + '</soap:Envelope>';
        return requestXML;
    }

    @TestVisible
    private static String validateStringValue(String value) {
        String stringValue = (String)value;
        if (stringValue == null) {
            return '';
        }
        return stringValue.replaceAll('\n','').replaceAll('\r','').replaceAll('&', '&#38;').replaceAll('<', '&#60;').replaceAll('>', '&#62;').replaceAll('"', '&#34;').escapeXML();
    }

}