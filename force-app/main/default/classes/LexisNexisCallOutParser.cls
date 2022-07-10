public class LexisNexisCallOutParser {

    private Account accountRecord;
    private Map<String, List<Contact>> contactListByPartyType;
    private List<Contact> listOfContacts;
    private String requestType;

    public LexisNexisCallOutParser(
        Account accountRecord, Map<String, List<Contact>> contactListByPartyType, List<Contact> listOfContacts, String requestType
    ) {
        this.accountRecord = accountRecord;
        this.contactListByPartyType = contactListByPartyType;
        this.listOfContacts = listOfContacts;
        this.requestType = requestType;
        createListOfContacts();
    }

    public void createListOfContacts() {
        if(requestType == 'BID') {
            listOfContacts = new List<Contact>();
            if(contactListByPartyType.get(LexisNexiss.PARTY_TYPE_PRIMARY_GUARANTOR) != null) {
                listOfContacts.addAll(contactListByPartyType.get(LexisNexiss.PARTY_TYPE_PRIMARY_GUARANTOR));
            }
            if(contactListByPartyType.get(LexisNexiss.PARTY_TYPE_ADDITIONAL_GUARANTORS) != null) {
                listOfContacts.addAll(contactListByPartyType.get(LexisNexiss.PARTY_TYPE_ADDITIONAL_GUARANTORS));
            }
            if(contactListByPartyType.get(LexisNexiss.PARTY_TYPE_BENEFICIAL_OWNER) != null) {
                listOfContacts.addAll(contactListByPartyType.get(LexisNexiss.PARTY_TYPE_BENEFICIAL_OWNER));
            }
        }
    }

    public Map<String, Object> requestBodyForBusinessInstantId() {
        Map<String, Object> reqBody = new Map<String, Object>();
        reqBody.put('BusinessInstantID20Request', prepareRequestBody());

        return reqBody;
    }

    public Map<String,Object> requestBodyForFraudPoint() {
        Map<String,Object> reqBody = new Map<String,Object>();
        reqBody.put('SmallBusinessAnalyticsRequest', prepareRequestBody());

        return reqBody;
    }

    public Map<String, Object> prepareRequestBody() {
        Map<String, Object> paramBody = new Map<String, Object>();
        paramBody.put('User', userDetails());
        paramBody.put('Options', optionsDetails());
        paramBody.put('SearchBy', searchByDetails());
        return paramBody;
    }

    public Map<String, Object> userDetails() {
        Map<String, Object> user = new Map<String, Object>();
        user.put('ReferenceCode', requestType == 'FraudPoint' ? '80a69948-df5e-4712-a87a-d67de7190236' : null);
        user.put('BillingCode', null);
        user.put('QueryId', null);
        user.put('GLBPurpose', requestType == 'FraudPoint' ? '1' : null);
        user.put('DLPurpose', requestType == 'FraudPoint' ? '3' : null);
        user.put('EndUser', prepareEndUser());
        user.put('MaxWaitSeconds', 0);
        user.put('AccountNumber', requestType == 'BID' ? 'S2018044978' : null);
        user.put('OutputType', 'X');

        return user;
    }

    public Map<String, Object> optionsDetails() {
        Map<String, Object> optionsDetails = new Map<String, Object>();
        if(requestType == 'BID') {
            optionsDetails.put('GlobalWatchlistThreshold', 0);
            optionsDetails.put('WatchListsRequested', watchListDetails());
            optionsDetails.put('BIID20ProductType', 2);
            optionsDetails.put('DOBMatchOptions', dobMatchOptionDetails());
            optionsDetails.put('DOBRadius', 0);
            optionsDetails.put('ExactAddrMatch', false);
            optionsDetails.put('ExactDOBMatch', false);
            optionsDetails.put('ExactDriverLicenseMatch', false);
            optionsDetails.put('ExactFirstNameMatch', false);
            optionsDetails.put('ExactFirstNameMatchAllowNicknames', false);
            optionsDetails.put('ExactLastNameMatch', false);
            optionsDetails.put('ExactPhoneMatch', false);
            optionsDetails.put('ExactSSNMatch', false);
            optionsDetails.put('ExcludeWatchLists', false);
            optionsDetails.put('IncludeAdditionalWatchlists', false);
            optionsDetails.put('IncludeCLOverride', false);
            optionsDetails.put('IncludeDLVerification', false);
            optionsDetails.put('IncludeDOBInCVI', false);
            optionsDetails.put('IncludeDPBC', false);
            optionsDetails.put('IncludeDriverLicenseInCVI', false);
            optionsDetails.put('IncludeMIOverride', false);
            optionsDetails.put('IncludeMSOverride', false);
            optionsDetails.put('IncludeOFAC', false);
            optionsDetails.put('LastSeenThreshold', null);
            optionsDetails.put('NameInputOrder', null);
            optionsDetails.put('PoBoxCompliance', false);
            optionsDetails.put('UseDOBFilter', false);
        }
        optionsDetails.put('AttributesVersionRequest', attributeVersionDetails());
        optionsDetails.put('IncludeModels', includeModelDetails());

        return optionsDetails;
    }

    public Map<String, Object> searchByDetails() {
        Map<String, Object> searchBy = new Map<String, Object>();
        searchBy.put('Company', companyDetails());
        for(Contact contactRecord : listOfContacts) {
            Integer index = listOfContacts.indexOf(contactRecord);
            searchBy.put('AuthorizedRep' + String.valueOf(index+1), getAuthRepDetails(contactRecord, index+1));
        }

        return searchBy;
    }

    public Map<String, Object> prepareEndUser() {
        Map<String, Object> endUser = new Map<String, Object>();
        endUser.put('CompanyName', null);
        endUser.put('StreetAddress1',null);
        endUser.put('City', null);
        endUser.put('State',null);
        endUser.put('Zip5', null);
        endUser.put('Phone', null);

        return endUser;
    }

    public Map<String, Object> watchListDetails() {
        Map<String, Object> watchListDetails = new Map<String, Object>();
        List<String> watchListDetail = new List<String>();
        watchListDetail.add(null);
        watchListDetails.put('WatchList', (watchListDetail));

        return watchListDetails;
    }

    public Map<String, Object> dobMatchOptionDetails() {
        Map<String, Object> dobMatchOptionDetails = new Map<String, Object>();
        Map<String, String> matchDetails = new Map<String, String>();
        List<Map<String, String>> matchDetail = new List<Map<String, String>>();

        matchDetails.put('MatchType',null);
        matchDetails.put('MatchYearRadius',null);
        matchDetail.add(matchDetails);

        dobMatchOptionDetails.put('DOBMatchOption', (matchDetail));

        return dobMatchOptionDetails;
    }

    public Map<String, Object> attributeVersionDetails() {
        Map<String, Object> attributeVersionDetails = new Map<String, Object>();
        List<String> attributeVersionDetail = new List<String> ();
        attributeVersionDetail.add(null);
        attributeVersionDetails.put('Name', (attributeVersionDetail));

        return attributeVersionDetails;
    }

    public Map<String,Object> includeModelDetails() {
        Map<String, Object> includeModelDetails = new Map<String, Object>();

        includeModelDetails.put('Names', prepareIncludeModelDetails());
        includeModelDetails.put('ModelOptions', modelOptionDetails());
        return includeModelDetails;
    }

    public Map<String, List<Map<String, Object>>> modelOptionDetails() {
        Map<String, List<Map<String, Object>>> finalModel = new Map<String, List<Map<String, Object>>>();

        finalModel.put('ModelOption', prepareModelOption());

        return finalModel;
    }

    public List<Map<String, Object>> prepareModelOption() {
        List<Map<String, Object>> modelOptionDetail = new List<Map<String, Object>>();
        Map<String, Object> modelOptionDetails = new Map<String, Object>();
        modelOptionDetails.put('OptionName', null);
        modelOptionDetails.put('OptionValue',null);

        modelOptionDetail.add(modelOptionDetails);

        return modelOptionDetail;
    }

    public Map<String, List<String>> prepareIncludeModelDetails() {
        List<String> optionDetails = new List<String>();
        optionDetails.add(requestType == 'FraudPoint' ? 'BBFM1808_1_0' : null);
        Map<String, List<String>> optionDetail = new Map<String, List<String>>();
        optionDetail.put('Name', (optionDetails));
        return optionDetail;
    }

    public Map<String, Object> companyDetails() {
        Map<String, Object> companyDetails = new Map<String, Object>();
        companyDetails.put('CompanyName', accountRecord.Legal_Name__c);
        companyDetails.put('AlternateCompanyName', null);
        String buildingNumber = accountRecord.BillingBuildingNumber__c != null ? accountRecord.BillingBuildingNumber__c + ' ' : '';

        companyDetails.put('Address', addressDetails(
            buildingNumber + accountRecord.BillingStreet, accountRecord.BillingCity, accountRecord.BillingState, accountRecord.BillingPostalCode)
        );

        companyDetails.put('Phone', validatePhoneNumber(accountRecord.Phone));
        companyDetails.put('FEIN', accountRecord.Business_Tax_ID__c);

        if(requestType == 'FraudPoint'){
            companyDetails.put('FaxNumber', accountRecord.Fax);
            companyDetails.put('SICCode', accountRecord.Sic);
            companyDetails.put('NAICCode', null);
            companyDetails.put('BusinessStructure', null);
            companyDetails.put('YearsInBusiness', null);
            companyDetails.put('BusinessStartDate', prepareDateField(null));
            companyDetails.put('YearlyRevenue', accountRecord.AnnualRevenue);
            companyDetails.put('BusinessIds', prepareBusinessIds());
        }

        return companyDetails;
    }

    public Map<String, Object> getAuthRepDetails(Contact contactRecord, Integer sequence) {
        Map<String, Object> authRepDetails = new Map<String, Object>();
        Map<String, Object> addressDetails = (prepareAddress(contactRecord));
        authRepDetails.put('Sequence', String.valueOf(sequence));
        authRepDetails.put('Name', (nameDetails(contactRecord)));
        authRepDetails.put('FormerLastName', null);
        authRepDetails.put('UniqueId', null);
        authRepDetails.put('Address', addressDetails(
            String.valueOf(addressDetails.get('line1')), String.valueOf(addressDetails.get('city')),
            String.valueOf(addressDetails.get('state')), String.valueOf(addressDetails.get('zipCode')))
        );
        authRepDetails.put('DOB', (prepareDateField(contactRecord.Birthdate)));
        authRepDetails.put('Age', null);
        if(requestType == 'BID') {
            authRepDetails.put('SSN', GeneralHelper.cleanSpecialCharacters(contactRecord.genesis__SSN__c));
        } else {
            authRepDetails.put('SSN', contactRecord.genesis__SSN__c);
        }
        authRepDetails.put('Phone', validatePhoneNumber(contactRecord.Phone));
        authRepDetails.put('DriverLicenseNumber', contactRecord.ints__Driver_License__c);
        authRepDetails.put('DriverLicenseState', null);
        authRepDetails.put('Email', contactRecord.Email);

        return authRepDetails;
    }

    public Map<String, String> prepareAddress(Contact contactObj) {
        Map<String, String> addressDetails = new Map<String, String>();
        String line1 = contactObj.MailingBuildingNumber__c != null ? contactObj.MailingBuildingNumber__c + ' ': '';
        line1 += contactObj.MailingAddress != null && contactObj.MailingAddress.getStreet() != null ?
            contactObj.MailingAddress.getStreet().replaceAll(',', '') : null;
        addressDetails.put('line1', line1);
        addressDetails.put('city', contactObj.MailingAddress != null && contactObj.MailingAddress.getCity() != null ?
                                contactObj.MailingAddress.getCity() : null);
        addressDetails.put('state', contactObj.MailingAddress != null && contactObj.MailingAddress.getState() != null ?
                                contactObj.MailingAddress.getState() : null);
        addressDetails.put('zipCode', contactObj.MailingAddress != null && contactObj.MailingAddress.getPostalCode() != null ?
                                contactObj.MailingAddress.getPostalCode() : null);

        return addressDetails;
    }

    public Map<String, String> addressDetails(String streetAddress, String city, String state, String zipCode) {
        Map<String, String> address = new Map<String, String>();
        address.put('StreetNumber', null);
        address.put('StreetPreDirection', null);
        address.put('StreetName', null);
        address.put('StreetSuffix', null);
        address.put('StreetPostDirection', null);
        address.put('UnitDesignation', null);
        address.put('UnitNumber', null);
        address.put('StreetAddress1', streetAddress);
        address.put('StreetAddress2', null);
        address.put('City', city);
        address.put('State', state);
        address.put('Zip5', zipCode);
        address.put('Zip4', null);
        address.put('County', null);
        address.put('PostalCode', null);
        address.put('StateCityZip', null);
        address.put('Latitude', null);
        address.put('Longitude', null);

        return address;
    }

    public Map<String, Integer> prepareBusinessIds() {
        Map<String, Integer> businessIds = new Map<String, Integer>();
        businessIds.put('DotID', 0);
        businessIds.put('EmpID', 0);
        businessIds.put('POWID', 0);
        businessIds.put('ProxID', 0);
        businessIds.put('SeleID', 0);
        businessIds.put('OrgID', 0);
        businessIds.put('UltID', 0);

        return businessIds;
    }

    public Map<String,String> nameDetails(Contact contact) {
        Map<String,String> name = new Map<String,String>();
        name.put('Full', null);
        name.put('First', contact.FirstName);
        name.put('Middle', null);
        name.put('Last', contact.LastName);
        name.put('Suffix', null);
        name.put('Prefix', null);

        return name;
    }

    public Map<String, Integer> prepareDateField(Date inputDateField) {
        Map<String, Integer> dateField = new Map<String, Integer>();
        Integer yearInput = 0;
        Integer monthInput = 0;
        Integer dateInput = 0;
        if(inputDateField != null) {
            yearInput = inputDateField.year();
            monthInput = inputDateField.month();
            dateInput = inputDateField.day();
        }
        dateField.put('Year', yearInput);
        dateField.put('Month', monthInput);
        dateField.put('Day', dateInput);

        return dateField;
    }

    public String validatePhoneNumber(String phoneNumber) {
        if(!String.isBlank(phoneNumber)) {
            String nonDigits = '[^0-9]';
            return phoneNumber.replaceAll(nonDigits, '');
        }
        return null;
    }

    public Map<String,Object> businessInstantIdResponseParse(HttpResponse response) {
        String responseBody = response.getBody();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        Map<String, Object> businessIdResponse = checkMapContains(responseMap, 'BIID20ResponseEx');
        Map<String, Object> responseForResult = checkMapContains(businessIdResponse, 'response');
        Map<String, Object> result = checkMapContains(responseForResult, 'Result');
        Map<String, Object> companyResults = checkMapContains(result, 'CompanyResults');
        Map<String, Object> businessToAuthorizedRepLinkIndexes = checkMapContains(companyResults, 'BusinessToAuthorizedRepLinkIndexes');
        Map<String, Object> authorizedRepresentativeResults = checkMapContains(result, 'AuthorizedRepresentativeResults');

        Map<String, Object> resultMap = new Map<String, Object>();
        if(companyResults.get('BusinessVerification') != null) {
            resultMap.put('BusinessVerification', companyResults.get('BusinessVerification'));
        }
        if(businessToAuthorizedRepLinkIndexes.get('BusinessToAuthorizedRepLinkIndex') != null) {
            resultMap.put('BusinessToAuthorizedRepLinkIndex', businessToAuthorizedRepLinkIndexes.get('BusinessToAuthorizedRepLinkIndex'));
        }
        if(companyResults.get('Compliance') != null) {
            resultMap.put('Compliance', companyResults.get('Compliance'));
        }
        if(authorizedRepresentativeResults.get('AuthorizedRepresentativeResult') != null) {
            resultMap.put('AuthorizedRepresentativeResults', authorizedRepresentativeResults.get('AuthorizedRepresentativeResult'));
        }
        resultMap.put('CompanyResults', companyResults);

        return resultMap;
    }

    public Map<String, Object> fraudPointResponseParse(HttpResponse response) {
        String responseBody = response.getBody();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        Map<String, Object> fraudPointAnalyticsMap = checkMapContains(responseMap, 'SmallBusinessAnalyticsResponseEx');
        Map<String, Object> fraudPointResponseMap = checkMapContains(fraudPointAnalyticsMap, 'response');
        Map<String, Object> fraudPointResultMap = checkMapContains(fraudPointResponseMap, 'Result');
        Map<String, Object> fraudPointModelsMap = checkMapContains(fraudPointResultMap, 'Models');
        Map<String, Object> fraudScoreModel = new Map<String, Object>();

        if(fraudPointModelsMap.get('Model') != null) {
            fraudScoreModel.put('FraudModel', fraudPointModelsMap.get('Model'));
        }

        return fraudScoreModel;
    }

    public Map<String, Object> checkMapContains(Map<String, Object> mapOfObjects, String key) {
        if(mapOfObjects.get(key) != null) {
            return (Map<String, Object>) mapOfObjects.get(key);
        }
        return new Map<String, Object>();
    }
}