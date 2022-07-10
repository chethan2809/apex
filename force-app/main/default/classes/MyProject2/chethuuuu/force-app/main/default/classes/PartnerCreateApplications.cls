public class PartnerCreateApplications {
    public static final String LOAN_DETAILS = 'loanDetails';
    public static final String LOAN_PURPOSE = 'loanPurpose';
    public static final String ANNUAL_VOLUME = 'Annual_Volume__c';
    public static final String ACCOUNT_DETAILS = 'accountDetails';
    public static final String INDUSTRY = 'industry';
    public static final String BUSINESS_STRUCTURE_NAME = 'businessStructureName';
    public static final String CONTACT_DETAILS = 'contactDetails';
    public static final String TITLE = 'title';
    public static final String BUSINESS_INFO_BASIC_DETAILS = 'BusinessInfoBasicDetails';
    public static final String BUSINESS_INFO_BILLING_ADDRESS = 'BusinessInfoBillingAdd';
    public static final String BUSINESS_INFO_EST_DETAILS = 'BusinessInfoESTDetails';
    public static final String INDIVIDUAL_ACCOUNT_DETAILS = 'individualAccountDetails';
    public static final String LOAN_INFO = 'loanInfo';
    public static final String BUSINESS_LEGAL_STRUCTURE_NAME = 'businessLegalStructureName';
    public static final String APPLICATION_ID = 'applicationId=';
    public static final String ACCOUNT_DETAILS_NAME = 'AccountDetails';
    public static final String CONTACT_DETAILS_NAME = 'ContactDetails';
    public static final String INVALID_INDUSTRY = 'Invalid Industry';
    public static final  Map<String, String> BUSINESS_INFO_BASIC_DETAILS_MAP = new Map<String, String>{
        'Name' => 'name',
        'Industry' => 'industry',
        'Business_Tax_ID__c' => 'taxId',
        'Doing_Business_As_Name__c' => 'dba'
    };
    public static final  Map<String, String> BUSINESS_INFO_BILLING_ADDRESS_MAP = new Map<String, String>{
        'BillingBuildingNumber__c' => 'billingBuildingNumber',
        'BillingStreet' => 'billingStreet',
        'BillingCity' => 'billingCity',
        'BillingState' => 'billingState',
        'BillingPostalCode' => 'billingPostalCode',
        'BillingCountry' => 'billingCountry'
    };
    public static final  Map<String, String> BUSINESS_INFO_EST_DETAILS_MAP = new Map<String, String>{
        'clcommon__Legal_Entity_Type__r.clcommon__Legal_Entity_Type__c' => 'legalEntityType',
        'State_of_Incorporation_Organization__c' => 'stateOfFormation',
        'Biz_Start_Date__c' => 'bizStartDate',
        'Phone' => 'phone'
    };
    public static final  Map<String, String> INDIVIDUAL_ACCOUNT_DETAILS_MAP = new Map<String, String>{
        'clcommon__Contact__r.FirstName' => 'firstName',
        'clcommon__Contact__r.LastName' => 'lastName',
        'clcommon__Contact__r.MobilePhone' => 'phone',
        'clcommon__Contact__r.Title__c' => 'title',
        'clcommon__Contact__r.Email' => 'email',
        'clcommon__Contact__r.genesis__SSN__c' => 'socialSecurityNumber',
        'clcommon__Contact__r.Birthdate' => 'birthDate',
        'clcommon__Contact__r.MailingStreet' => 'mailingStreet',
        'clcommon__Contact__r.MailingBuildingNumber__c' => 'mailingBuildingNumber',
        'clcommon__Contact__r.MailingCity' => 'mailingCity',
        'clcommon__Contact__r.MailingState' => 'mailingState',
        'clcommon__Contact__r.MailingCountry' => 'mailingCountry',
        'clcommon__Contact__r.MailingPostalCode' => 'mailingPostalCode'
    };
    public static final  Map<String, String> LOAN_INFORMATION_MAP = new Map<String, String>{
        'What_is_used_for__c' => 'loanPurpose',
        'genesis__Loan_Amount__c' => 'loanAmount'
    };
    public static final  Map<String, String> PARTNER_INFORMATION_MAP = new Map<String, String>{
        'partnerEmail' => 'partnerEmail',
        'partnerAPIKey' => 'partnerAPIKey'
    };
    public static final  Map<String, String> APPLICATION_DETAILS_RESPONSE_MAP = new Map<String, String>{
        'Name' => 'Name'
    };
    public static final  Map<String, String> ACCOUNT_DETAILS_RESPONSE_MAP = new Map<String, String>{
        'Name' => 'Name',
        'Id' => 'Id'
    };
    public static final  Map<String, String> CONTACT_DETAILS_RESPONSE_MAP = new Map<String, String>{
        'FirstName' => 'FirstName',
        'LastName' => 'LastName',
        'Id' => 'Id'
    };
    public static final  Set<String> REQUEST_KEYS_TO_VALIDATE = new Set<String>{
        'loanDetails',
        'partnerDetails',
        'accountDetails',
        'contactDetails'
    };

    public static final Set<String> LOAN_DETAILS_SET = new Set<String> {
        'loanAmount'
    };
    public static final Set<String> PARTNER_DETAILS_SET = new Set<String> {
        'partnerAPIKey','partnerEmail'
    };
    public static final Set<String> ACCOUNT_DETAILS_SET = new Set<String> {
        'name','phone','industry','taxId','dba','businessStructureName','stateOfFormation','bizStartDate','billingStreet','billingCity','billingPostalCode','billingCountry','billingState'
    };
    public static final Set<String> CONTACT_DETAILS_SET = new Set<String> {
        'title','firstName','lastName','email','phone','birthDate','socialSecurityNumber','mailingStreet','mailingCity','mailingState','mailingCountry','mailingPostalCode'
    };

    public static Map<String, Object> buildRequest(Map<String, Object> requestMap) {
        Map<String, Object> partnerDetailsMap = (Map<String, object>) requestMap.get(PartnerAPIConstants.PARTNER_DETAILS);
        Map<String, Object> loanDetailsMap = (Map<String, object>) requestMap.get(PartnerCreateApplications.LOAN_DETAILS);
        loanDetailsMap.put(PartnerCreateApplications.ANNUAL_VOLUME, 0);

        Map<String, Object> borrowerAccountInfoMap = (Map<String, object>) requestMap.get(PartnerCreateApplications.ACCOUNT_DETAILS);
        String borrowerAccountIndustry = String.valueOf(borrowerAccountInfoMap.get(PartnerCreateApplications.INDUSTRY));
        String borrowerAccountBusinessStructureName = String.valueOf(borrowerAccountInfoMap.get(PartnerCreateApplications.BUSINESS_STRUCTURE_NAME));

        Map<String, Object> guarantorContactInfoMap = (Map<String, object>) requestMap.get(PartnerCreateApplications.CONTACT_DETAILS);

        validateIndustryPicklist(borrowerAccountIndustry);
        borrowerAccountIndustry = getIndustryPicklistAPIFromLabel(borrowerAccountIndustry);
        borrowerAccountInfoMap.put(PartnerCreateApplications.INDUSTRY, borrowerAccountIndustry);

        Map<String, Object> request = new Map<String, Object>();
        request.put(PartnerCreateApplications.BUSINESS_INFO_BASIC_DETAILS, JSON.serialize(constructRequestMap(borrowerAccountInfoMap, PartnerCreateApplications.BUSINESS_INFO_BASIC_DETAILS_MAP)));
        request.put(PartnerCreateApplications.BUSINESS_INFO_BILLING_ADDRESS,  JSON.serialize(constructRequestMap(borrowerAccountInfoMap, PartnerCreateApplications.BUSINESS_INFO_BILLING_ADDRESS_MAP)));
        request.put(PartnerCreateApplications.BUSINESS_INFO_EST_DETAILS, JSON.serialize(constructRequestMap(borrowerAccountInfoMap, PartnerCreateApplications.BUSINESS_INFO_EST_DETAILS_MAP)));
        request.put(PartnerCreateApplications.INDIVIDUAL_ACCOUNT_DETAILS, JSON.serialize(constructRequestMap(guarantorContactInfoMap, PartnerCreateApplications.INDIVIDUAL_ACCOUNT_DETAILS_MAP)));
        request.put(PartnerCreateApplications.LOAN_INFO, JSON.serialize(constructRequestMap(loanDetailsMap, PartnerCreateApplications.LOAN_INFORMATION_MAP)));
        request.put(PartnerAPIConstants.PARTNER_INFO, JSON.serialize(constructRequestMap(partnerDetailsMap, PartnerCreateApplications.PARTNER_INFORMATION_MAP)));
        request.put(PartnerCreateApplications.BUSINESS_LEGAL_STRUCTURE_NAME, borrowerAccountBusinessStructureName);

        return request;
    }

    public static Id createApplication(Map<String, Object> request) {
        CCBPCreateApplicationAPI createApplication = new CCBPCreateApplicationAPI();
        clcommon.Response apiResponse = createApplication.invokeAction(null, null, request);

        if(apiResponse.status != clcommon.Constants.SUCCESS){
            throw new PartnerCreateApplicationException(apiResponse.errorMessage);
        }

        String responseString = apiResponse.response.toString();
        String applicationId = responseString.substringBetween(PartnerCreateApplications.APPLICATION_ID, ',');

        return Id.valueOf(applicationId);
    }

    public static Map<String, Object> buildResponse(List<genesis__Applications__c> applications, List<clcommon__Party__c> parties) {
        Map<String, Object> constructedResponse = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();

        constructedResponse = PartnerAPIHelpers.constructResponseMap(applications.get(0), PartnerCreateApplications.APPLICATION_DETAILS_RESPONSE_MAP);
        mapResponse.put(PartnerAPIConstants.APPLICATION_DETAILS, constructedResponse);

        if(!parties.isEmpty()) {
            for(clcommon__Party__c party : parties){
                if(party.clcommon__Type__r.Name == GeneralConstants.PARTY_TYPE_BORROWER){
                    Account borrowerDetails = new Account();
                    borrowerDetails.Id = party.clcommon__Account__c;
                    borrowerDetails.Name = party.clcommon__Account__r.Name;
                    constructedResponse = PartnerAPIHelpers.constructResponseMap(borrowerDetails, PartnerCreateApplications.ACCOUNT_DETAILS_RESPONSE_MAP);
                    mapResponse.put(PartnerCreateApplications.ACCOUNT_DETAILS_NAME, constructedResponse);
                }
                else if(party.clcommon__Type__r.Name == GeneralConstants.PARTY_TYPE_GUARANTOR){
                    Contact guarantorDetails = new Contact();
                    guarantorDetails.Id = party.clcommon__Contact__c;
                    guarantorDetails.FirstName = party.clcommon__Contact__r.FirstName;
                    guarantorDetails.LastName = party.clcommon__Contact__r.LastName;
                    constructedResponse = PartnerAPIHelpers.constructResponseMap(guarantorDetails, PartnerCreateApplications.CONTACT_DETAILS_RESPONSE_MAP);
                    mapResponse.put(PartnerCreateApplications.CONTACT_DETAILS_NAME, constructedResponse);
                }
            }
        }
        return mapResponse;
    }

    public static void validateIndustryPicklist(String value) {
        List<String> picklistValues = DescribeHelper.getPickListValues('Lead', 'Industry');
        if(picklistValues.isEmpty() || !picklistValues.contains(value)){
            throw new PartnerCreateApplicationException(PartnerCreateApplications.INVALID_INDUSTRY);
        }
    }

    public static String getIndustryPicklistAPIFromLabel(String value) {
        Schema.sObjectField sObjectFieldName = Lead.Industry;
        DescribeHelper describeHelperInstance = new DescribeHelper();
        for( Schema.PickListEntry pickListValue : describeHelperInstance.getPickListEntries(sObjectFieldName)){
            if(pickListValue.isActive() && value == pickListValue.getLabel()){
                return pickListValue.getValue();
            }
        }
        return null;
    }

    public static Map<String, Object> constructRequestMap(Map<String, Object> mapRecord, Map<String, String> mapKeys){
        Map<String, Object> mapRequest = new Map<String, Object>();
        String fieldAPI;
        for(String key: mapKeys.keySet()){
            fieldAPI = mapKeys.get(key);
            mapRequest.put(key, mapRecord.get(fieldAPI));
        }
        return mapRequest;
    }

    public static Set<String> getPartnerEmail(Map<String, Object> argumentsFromPortal) {
        Set<String> partnerEmail = new Set<String>();
        if(argumentsFromPortal.containsKey(PartnerAPIConstants.PARTNER_INFO)) {
            Map<String, Object> partnerDetailsMap = (Map<String, Object>)JSON.deserializeUntyped((String)argumentsFromPortal.get(PartnerAPIConstants.PARTNER_INFO));
            partnerEmail.add((String)partnerDetailsMap.get(PartnerAPIConstants.PARTNER_EMAIL));
        }
        return partnerEmail;
    }

    private class PartnerCreateApplicationException extends Exception {}
}