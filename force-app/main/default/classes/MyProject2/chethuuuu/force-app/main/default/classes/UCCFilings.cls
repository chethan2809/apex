public class UCCFilings {

    public static final Set<String> UCC_GET_ORDER_RESPONSE = new Set<String> {'OrderInfo', 'Filer', 'DebtorName', 'SecuredName', 'IndividualName', 'Note', 'Attachment'};
    public static final Set<String> UCC_CONTINUATION_RESPONSE = new Set<String> {'OrderID'};
    public static final Set<String> UCC_GET_ATTACHMENT_RESPONSE = new Set<String> {'AttachmentURL'};
    public static final String UCC_FILING_API_SANDBOX = 'UCC_Filing_API_Sandbox';
    public static final String UCC_FILING_UPLOAD_API_PRODUCTION = 'UCC_Filing_API_Production';
    public static final String STATE_FLORIDA = 'FL';
    public static final String STATE_NEW_JERSEY = 'NJ';
    public static final String STATE_GEORGIA = 'GA';
    public static final String STATE_LOUISIANA = 'LA';
    public static final String STATE_OKLAHOMA = 'OK';
    public static final String STATE_OKLAHOMA_JURISDICTION = 'Central_Index_Oklahoma_County';
    public static final String SECRETARY_OF_STATE = '(S.O.S)';

    public static UCC_Filing_Detail__c createUCCRecords(Map<Id, Id> contractIdToAccountIdMap, loan__Loan_Account__c loanAccount, Map<Id, Account> accountMap, UCC_Setting__mdt uccDetails, Map<String, JurisdictionID_To_Name_Mapping__mdt> jurisdictionIDToNameMapping, String jurisdictionID, String jurisdictionName) {
        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Account__c = accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).Id;
        uccFiling.Secured_Organization_Name__c = validateStringValue(String.valueOf(uccDetails.Secured_Organization_Name__c));
        uccFiling.Secured_MailAddress__c = validateStringValue(String.valueOf(uccDetails.Secured_MailAddress__c));
        uccFiling.Secured_City__c = validateStringValue(String.valueOf(uccDetails.Secured_City__c));
        uccFiling.Secured_Country__c = validateStringValue(String.valueOf(uccDetails.Secured_Country__c));
        uccFiling.Secured_State__c = validateStringValue(String.valueOf(uccDetails.Secured_State__c));
        uccFiling.Secured_postalCode__c = validateStringValue(String.valueOf(uccDetails.Secured_postalCode__c));
        uccFiling.Filer_Contact_Fax__c = validateStringValue(String.valueOf(uccDetails.Filer_Contact_Fax__c));
        uccFiling.Filer_Contact_Name__c = validateStringValue(String.valueOf(uccDetails.Filer_Contact_Name__c));
        uccFiling.Filer_Contact_Phone__c = validateStringValue(String.valueOf(uccDetails.Filer_Contact_Phone__c));
        uccFiling.Filer_Mail_Address__c = validateStringValue(String.valueOf(uccDetails.Filer_Mail_Address__c));
        uccFiling.Filer_Organization_Name__c = validateStringValue(String.valueOf(uccDetails.Filer_Organization_Name__c));
        uccFiling.Filer_PostalCode__c = validateStringValue(String.valueOf(uccDetails.Filer_PostalCode__c));
        uccFiling.Filer_State__c = validateStringValue(String.valueOf(uccDetails.Filer_State__c));
        uccFiling.Filer_City__c = validateStringValue(String.valueOf(uccDetails.Filer_City__c));

        if(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingState == STATE_GEORGIA || accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingState == STATE_LOUISIANA){
            uccFiling.Jurisdiction_ID__c = jurisdictionID;
            uccFiling.Jurisdiction_Name__c = jurisdictionName;
            uccFiling.Jurisdiction_State__c = validateStringValue(String.valueOf(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingState));
        } else if(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingState == STATE_OKLAHOMA){
            uccFiling.Jurisdiction_ID__c = validateStringValue(String.valueOf(jurisdictionIDToNameMapping.get(STATE_OKLAHOMA_JURISDICTION).Jurisdiction_ID__c));
            uccFiling.Jurisdiction_Name__c = validateStringValue(String.valueOf(jurisdictionIDToNameMapping.get(STATE_OKLAHOMA_JURISDICTION).DeveloperName));
            uccFiling.Jurisdiction_State__c = validateStringValue(String.valueOf(jurisdictionIDToNameMapping.get(STATE_OKLAHOMA_JURISDICTION).State__c));
        } else {
            uccFiling.Jurisdiction_ID__c = validateStringValue(String.valueOf(jurisdictionIDToNameMapping.get(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingState).Jurisdiction_ID__c));
            uccFiling.Jurisdiction_Name__c = validateStringValue(String.valueOf(SECRETARY_OF_STATE));
            uccFiling.Jurisdiction_State__c = validateStringValue(String.valueOf(jurisdictionIDToNameMapping.get(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingState).State__c));
        }
        if(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingState == STATE_FLORIDA){
            uccFiling.Collateral_Text1__c = validateStringValue(String.valueOf(uccDetails.Florida_Collateral_Text__c));
        } else if(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingState == STATE_NEW_JERSEY){
            uccFiling.Collateral_Text1__c = validateStringValue(String.valueOf(uccDetails.NJ_Collateral_Text__c));
        } else {
            uccFiling.Collateral_Text1__c = validateStringValue(String.valueOf(uccDetails.Non_NJ_Collateral_Text__c));
        }
        if(loanAccount.Application__r.Business_Type__c == GeneralConstants.LEGAL_TYPE_SOLE_PROP) {
            uccFiling.Debtor_Individual_LastName__c = validateStringValue(String.valueOf(loanAccount.Primary_Contact__r.LastName));
            uccFiling.Debtor_Individual_FirstName__c = validateStringValue(String.valueOf(loanAccount.Primary_Contact__r.FirstName));
            uccFiling.Debtor_Individual_MiddleName__c = validateStringValue(String.valueOf(loanAccount.Primary_Contact__r.MiddleName));
            uccFiling.Debtor_Individual_Suffix__c = validateStringValue(String.valueOf(loanAccount.Primary_Contact__r.Suffix));
            uccFiling.Debtor_Individual_City__c = validateStringValue(String.valueOf(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingCity));
            uccFiling.Debtor_Individual_State__c = validateStringValue(String.valueOf(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingState));
            uccFiling.Debtor_Individual_PostalCode__c = validateStringValue(String.valueOf(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingPostalCode));
            uccFiling.Debtor_Individual_Country__c = validateStringValue(String.valueOf(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingCountry));
            uccFiling.Debtor_Individual_MailAddress__c = validateStringValue(String.valueOf(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingStreet));
        }

        uccFiling.Debtor_Organization_Name__c = validateStringValue(String.valueOf(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).Legal_Name__c));
        uccFiling.Debtor_City__c = validateStringValue(String.valueOf(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingCity));
        uccFiling.Debtor_Organization_State__c = validateStringValue(String.valueOf(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingState));
        uccFiling.Debtor_Organization_PostalCode__c = validateStringValue(String.valueOf(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingPostalCode));
        uccFiling.Debtor_Organization_Country__c = validateStringValue(String.valueOf(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingCountry));
        uccFiling.Debtor_Organizational_Type__c = validateStringValue(String.valueOf(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).clcommon__Legal_Entity_Type__r.Name));
        uccFiling.Debtor_Organizational_Jurisdiction__c = uccFiling.Jurisdiction_State__c;
        uccFiling.Debtor_Organizational_ID__c = validateStringValue(String.valueOf(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).Merchant_ID__c));
        uccFiling.Debtor_Mail_Address__c = validateStringValue(String.valueOf(accountMap.get(contractIdToAccountIdMap.get(loanAccount.Id)).BillingStreet));
        return uccFiling;
    }

    public static UCC_Filing_Detail__c createUCCRecord(Account accountRecord) {
        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Account__c = accountRecord.Id;
        uccFiling.Order_Id__c = accountRecord.UCC_Order_Number__c;
        return uccFiling;
    }

    public static UCC_Validation_Log__c createUCCValidationLog(UCC_Filing_Detail__c uccFiling, String validationMessage) {
        UCC_Validation_Log__c validationLog = new UCC_Validation_Log__c();
        validationLog.UCC_Filing_Detail__c = uccFiling.Id;
        validationLog.Validation_message__c = validationMessage;

        return validationLog;
    }

    public static void setAccountAndUCCValues(UCC_Filing_Detail__c uccFiling, Account accountRecord, Map<String, String> uccFilingResponseMap) {
        Map<String, String> notesDescription = new Map<String, String>();
        for(String uccFilingModel : uccFilingResponseMap.keySet()) {
            if(String.isNotBlank(uccFilingResponseMap.get(uccFilingModel))) {
                if(uccFilingModel.substringBetween('FilerNames', '0') == 'OrganizationName') {
                    uccFiling.Filer_Organization_Name__c = uccFilingResponseMap.get(uccFilingModel);
                } else if(uccFilingModel.substringBetween('FilerNames', '0') == 'MailAddress') {
                    uccFiling.Filer_Mail_Address__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('FilerNames', '0') == 'City') {
                    uccFiling.Filer_City__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('FilerNames', '0') == 'State') {
                    uccFiling.Filer_State__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('FilerNames', '0') == 'PostalCode') {
                    uccFiling.Filer_PostalCode__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('Filer', '0') == 'ClientAccountNum') {
                    uccFiling.Filer_Client_AccountNum__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('Filer', '0') == 'ContactName') {
                    uccFiling.Filer_Contact_Name__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('Filer', '0') == 'ContactPhone') {
                    uccFiling.Filer_Contact_Phone__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('Filer', '0') == 'ContactEmail') {
                    uccFiling.Filer_Contact_Email__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('Filer', '0') == 'ContactFax') {
                    uccFiling.Filer_Contact_Fax__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('OrderInfo', '0') == 'OrderID') {
                    uccFiling.Order_ID__c = uccFilingResponseMap.get(uccFilingModel);
                    accountRecord.UCC_Order_Number__c = uccFilingResponseMap.get(uccFilingModel);
                } else if(uccFilingModel.substringBetween('OrderInfo', '0') == 'CreateDate') {
                    uccFiling.UCC_Created_Date__c = Date.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('OrderInfo', '0') == 'ParentOrderID') {
                    uccFiling.Parent_Order_ID__c = uccFilingResponseMap.get(uccFilingModel);
                } else if(uccFilingModel.substringBetween('OrderInfo', '0') == 'AccountID') {
                    uccFiling.UCC_Account_ID__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('OrderInfo', '0') == 'OrderStatus') {
                    uccFiling.Order_Status__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                    accountRecord.UCC_Order_Status__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('OrderInfo', '0') == 'FilingNumber') {
                    uccFiling.Filing_Number__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('OrderInfo', '0') == 'FilingDate') {
                    if(!(uccFilingResponseMap.get(uccFilingModel).left(1) == '0')) {
                        uccFiling.Filing_Date__c = Date.valueOf(uccFilingResponseMap.get(uccFilingModel));
                        accountRecord.UCC_Filing_Date__c = Date.valueOf(uccFilingResponseMap.get(uccFilingModel));
                    }
                } else if(uccFilingModel.substringBetween('OrderInfo', '0') == 'ExpirationDate') {
                    if(!(uccFilingResponseMap.get(uccFilingModel).left(1) == '0')) {
                        uccFiling.Expiration_Date__c = Date.valueOf(uccFilingResponseMap.get(uccFilingModel));
                        accountRecord.UCC_Expiration_Date__c = Date.valueOf(uccFilingResponseMap.get(uccFilingModel));
                    }
                } else if(uccFilingModel.substringBetween('OrderInfo', '0') == 'OriginalFilingNumber') {
                    uccFiling.Original_Filing_Number__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('OrderInfo', '0') == 'OriginalFilingDate') {
                    if(!(uccFilingResponseMap.get(uccFilingModel).left(1) == '0')) {
                        uccFiling.Original_Filing_Date__c = Date.valueOf(uccFilingResponseMap.get(uccFilingModel));
                    }
                } else if(uccFilingModel.substringBetween('OrderInfo', '0') == 'ApproveDate') {
                    if(!(uccFilingResponseMap.get(uccFilingModel).left(1) == '0')) {
                        uccFiling.Approve_Date__c = Date.valueOf(uccFilingResponseMap.get(uccFilingModel));
                    }
                } else if(uccFilingModel.substringBetween('OrderInfo', '0') == 'CompleteDate') {
                    if(!(uccFilingResponseMap.get(uccFilingModel).left(1) == '0')) {
                        uccFiling.Complete_Date__c = Date.valueOf(uccFilingResponseMap.get(uccFilingModel));
                    }
                } else if(uccFilingModel.substringBetween('DebtorNameNames', '0') == 'OrganizationName') {
                    uccFiling.Debtor_Organization_Name__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('DebtorNameNames', '0') == 'MailAddress') {
                    uccFiling.Debtor_Mail_Address__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('DebtorNameNames', '0') == 'City') {
                    uccFiling.Debtor_City__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('DebtorNameNames', '0') == 'State') {
                    uccFiling.Debtor_Organization_State__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('DebtorNameNames', '0') == 'PostalCode') {
                    uccFiling.Debtor_Organization_PostalCode__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('DebtorNameNames', '0') == 'Country') {
                    uccFiling.Debtor_Organization_Country__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('IndividualName', '0') == 'LastName') {
                    uccFiling.Debtor_Individual_LastName__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('IndividualName', '0') == 'FirstName') {
                    uccFiling.Debtor_Individual_FirstName__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('IndividualName', '0') == 'MiddleName') {
                    uccFiling.Debtor_Individual_MiddleName__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('IndividualName', '0') == 'Suffix') {
                    uccFiling.Debtor_Individual_Suffix__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('DebtorNameNames', '1') == 'MailAddress') {
                    uccFiling.Debtor_Individual_MailAddress__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('DebtorNameNames', '1') == 'City') {
                    uccFiling.Debtor_Individual_City__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('DebtorNameNames', '1') == 'State') {
                    uccFiling.Debtor_Individual_State__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('DebtorNameNames', '1') == 'PostalCode') {
                    uccFiling.Debtor_Individual_PostalCode__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('DebtorNameNames', '1') == 'Country') {
                    uccFiling.Debtor_Individual_Country__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('SecuredNameNames', '0') == 'OrganizationName') {
                    uccFiling.Secured_Organization_Name__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('SecuredNameNames', '0') == 'MailAddress') {
                    uccFiling.Secured_MailAddress__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('SecuredNameNames', '0') == 'City') {
                    uccFiling.Secured_City__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('SecuredNameNames', '0') == 'State') {
                    uccFiling.Secured_State__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('SecuredNameNames', '0') == 'PostalCode') {
                    uccFiling.Secured_postalCode__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                } else if(uccFilingModel.substringBetween('SecuredNameNames', '0') == 'Country') {
                    uccFiling.Secured_Country__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
                }
            }
        }
    }

    public static List<UCC_Notes__c> createNotes(Id uccFilingId, Map<String, String> uccFilingResponseMap, List<String> existingUCCNoteDescriptions) {
        Map<String, String> notesDescriptionMap = new Map<String, String>();
        Map<String, String> notesCreatedDateMap = new Map<String, String>();
        List<UCC_Notes__c> notes = new List<UCC_Notes__c>();
        for(String uccFilingModel : uccFilingResponseMap.keySet()) {
            if(String.isNotBlank(uccFilingResponseMap.get(uccFilingModel)) && uccFilingModel.contains('NoteDescription')
            ) {
                notesDescriptionMap.put(uccFilingModel.removeStart('NoteDescription'), uccFilingResponseMap.get(uccFilingModel));
            } else if(String.isNotBlank(uccFilingResponseMap.get(uccFilingModel)) && uccFilingModel.contains('NoteCreateDate')
            ) {
                notesCreatedDateMap.put(uccFilingModel.removeStart('NoteCreateDate'), uccFilingResponseMap.get(uccFilingModel));
            }
        }
        for(String note : notesDescriptionMap.keySet()) {
            if(existingUCCNoteDescriptions != null && existingUCCNoteDescriptions.contains(notesDescriptionMap.get(note))) {
                continue;
            }
            if(!note.contains('null')) {
                UCC_Notes__c uccNOte = UCCNotes.createUCCNote(uccFilingId, String.valueOf(notesDescriptionMap.get(note)), Date.valueOf(notesCreatedDateMap.get(note)));
                notes.add(uccNOte);
            }
        }
        return notes;
    }

    public static Map<Id, Map<String, String>> prepareUCCFilingIdToModelValueResponseMap(Map<Id, Map<String, List<String>>> uccFilingIdToOrderResponseMap) {
        Map<String, List<String>> orderResponseMap = new Map<String, List<String>>();
        Map<Id, Map<String, String>> uccFilingIdToModelValueResponseMap = new Map<Id, Map<String, String>>();

        for(Id uccFilingId : uccFilingIdToOrderResponseMap.keySet()) {
            orderResponseMap = uccFilingIdToOrderResponseMap.get(uccFilingId);
            Map<String, String> uccModelValueResponseMap = new Map<String, String>();
            if(!orderResponseMap.isEmpty()) {
                for(String uccFilingModel : orderResponseMap.keySet()) {
                    uccModelValueResponseMap = prepareModelValueResponseMap(
                        uccFilingModel, orderResponseMap.get(uccFilingModel), uccModelValueResponseMap
                    );
                }
            }
            if(!uccModelValueResponseMap.isEmpty()) {
                uccFilingIdToModelValueResponseMap.put(uccFilingId, uccModelValueResponseMap);
            }
        }
        return uccFilingIdToModelValueResponseMap;
    }

    @TestVisible
    private static Map<String, String> prepareModelValueResponseMap(String uccFilingModel, List<String> uccFilingModelValues, Map<String, String> uccFilingResponseMap) {
        Integer i=0;
        for(String uccFilingModelValue: uccFilingModelValues) {
            if(uccFilingModelValue != null && String.isNotBlank(uccFilingModelValue)) {
                uccFilingResponseMap.put(uccFilingModel+i, uccFilingModelValue);
            }
            i++;
        }
        return uccFilingResponseMap;
    }

    public static void setContinuationFields(UCC_Filing_Detail__c uccFiling, Map<String, String> uccFilingResponseMap) {
        for(String uccFilingModel : uccFilingResponseMap.keySet()) {
            if(String.isNotBlank(uccFilingResponseMap.get(uccFilingModel)) && uccFilingModel.removeEnd('0') == 'OrderID'
            ) {
                uccFiling.Order_ID__c = uccFilingResponseMap.get(uccFilingModel);
                uccFiling.Is_UCC_Continued__c = true;
                uccFiling.UCC_Continuation_Reports_Pulled__c = false;
                uccFiling.Is_UCC_Continuation_Approved__c = false;
            }
        }
    }

    @TestVisible
    private static String validateStringValue(String value) {
        String stringValue = (String)value;
        if (stringValue == null) {
            return null;
        }
        return stringValue.replaceAll('\n','').replaceAll('\r','').escapeXML();
    }

    public static Boolean isTerminateChanged(UCC_Filing_Detail__c newUCCFiling, UCC_Filing_Detail__c oldUCCFiling) {
        return (newUCCFiling.Is_Terminated__c != oldUCCFiling.Is_Terminated__c);
    }

    public static Boolean isUCCContinued(UCC_Filing_Detail__c newUCCFiling, UCC_Filing_Detail__c oldUCCFiling) {
        return (newUCCFiling.Is_UCC_Continued__c != oldUCCFiling.Is_UCC_Continued__c);
    }

    public static void getUCCAttachmentIDs(UCC_Filing_Detail__c uccFiling, Map<String, String> uccFilingResponseMap) {
        for(String uccFilingModel : uccFilingResponseMap.keySet()) {
            if(uccFilingModel.substringBetween('OrderInfo', '0') == 'OrderStatus') {
                uccFiling.Order_Status__c = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
            }
        }
    }
    public static List<UCC_Filing_Attachment__c> getUCCAttachments(UCC_Filing_Detail__c uccFiling, Map<String, String> uccFilingResponseMap, Set<String> existingUCCAttachmentsIds) {
        Map<String, String> attachmentIDMap = new Map<String, String>();
        Map<String, String> attachmentDescriptionMap = new Map<String, String>();
        List<UCC_Filing_Attachment__c> uccAttachments = new List<UCC_Filing_Attachment__c>();
        for(String uccFilingModel : uccFilingResponseMap.keySet()) {
            if(String.isNotBlank(uccFilingResponseMap.get(uccFilingModel)) && uccFilingModel.contains('AttachmentAttachmentID')
            ) {
                attachmentIDMap.put(uccFilingModel.removeStart('AttachmentAttachmentID'), uccFilingResponseMap.get(uccFilingModel));
            } else if(String.isNotBlank(uccFilingResponseMap.get(uccFilingModel)) && uccFilingModel.contains('AttachmentDescription')) {
                attachmentDescriptionMap.put(uccFilingModel.removeStart('AttachmentDescription'), uccFilingResponseMap.get(uccFilingModel));
            }
        }

        for(String uccAttachment : attachmentIDMap.keySet()) {
            if(!uccAttachment.contains('null')) {
                String attachmentID = String.valueOf(attachmentIDMap.get(uccAttachment));
                if(existingUCCAttachmentsIds.contains(attachmentID)) {
                    continue;
                }
                UCC_Filing_Attachment__c uccFilingAttachment = UCCFilingAttachments.createUCCFilingAttachments(uccFiling, String.valueOf(attachmentIDMap.get(uccAttachment)), String.valueOf(attachmentDescriptionMap.get(uccAttachment)));
                uccAttachments.add(uccFilingAttachment);
            }
        }
        return uccAttachments;
    }

    public static String setUCCAttachmentLinks(UCC_Filing_Attachment__c uccFilingAttachment, Map<String, String> uccFilingResponseMap) {
        String attachmentLink;
        for(String uccFilingModel : uccFilingResponseMap.keySet()) {
            if(String.isNotBlank(uccFilingResponseMap.get(uccFilingModel)) && uccFilingModel.removeEnd('0') == 'AttachmentURL'
            ) {
                attachmentLink = String.valueOf(uccFilingResponseMap.get(uccFilingModel));
            }
        }
        return attachmentLink;
    }

    public static Map<Id, List<String>> getExistingUCCNotes(List<UCC_Notes__c> existingUCCNotes) {
        Map<Id, List<String>> uccFilingIdToDescriptionListMap = new Map<Id, List<String>>();
        for(UCC_Notes__c existingUCCNote : existingUCCNotes) {
            if(uccFilingIdToDescriptionListMap.keySet().contains(existingUCCNote.UCC_Filing_Detail__c)) {
                uccFilingIdToDescriptionListMap.get(existingUCCNote.UCC_Filing_Detail__c).add(existingUCCNote.Description__c);
            } else {
                uccFilingIdToDescriptionListMap.put(
                    existingUCCNote.UCC_Filing_Detail__c, new List<String> {existingUCCNote.Description__c}
                );
            }
        }
        return uccFilingIdToDescriptionListMap;
    }
}