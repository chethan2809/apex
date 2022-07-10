public class ExperianCalloutParser {

    Contact contactObj;
    Account accountObj;
    String binValueResponse;
    String instanceName;
    String subscriberCode;

    public ExperianCalloutParser(Contact contactObj, Account accountObj) {
        this.contactObj = contactObj;
        this.accountObj = accountObj;
    }

    public ExperianCalloutParser(Contact contactObj, Account accountObj, API_Detail__mdt apiDetails) {
        this.contactObj = contactObj;
        this.accountObj = accountObj;
        this.subscriberCode = apiDetails.Subscriber_Code__c;
        if(apiDetails.Endpoint_URL__c.contains('uat-us')) {
            this.instanceName = 'uat';
        } else {
            this.instanceName = 'prod';
        }
    }

    public Map<String,Object> consumerRequestBody() {
        Map<String,Object> paramBody = new Map<String,Object>();

        paramBody.put('consumerPii', preparePrimaryApplicant());
        paramBody.put('requestor', prepareRequestor());
        paramBody.put('addOns', prepareAddOns());
        paramBody.put('permissiblePurpose', getPermissiblePurpose());
        paramBody.put('solutionId', 'XEDE');
        paramBody.put('verifyId', 'Y2/DM/RM');
        paramBody.put('infoId1', prepareInfoId());

        return paramBody;
    }

    public Map<String,Object> preparePrimaryApplicant() {
        Map<String,Object> primaryApplicant = new Map<String,Object>();
        primaryApplicant.put('primaryApplicant',prepareApplicantDetails());

        return primaryApplicant;
    }

    public Map<String,Object> prepareApplicantDetails() {
        Map<String, Object> applicantDetails = new Map<String, Object>();
        applicantDetails.put('name', prepareName());
        applicantDetails.put('ssn', prepareSsn());
        applicantDetails.put('currentAddress', prepareAddress());

        return applicantDetails;
    }

    public Map<String,Object> getPermissiblePurpose() {
        Map<String, Object> permissiblePurpose = new Map<String, Object>();
        permissiblePurpose.put('type', '5J');

        return permissiblePurpose;
    }

    public Map<String, Object> prepareName() {
        Map<String, Object> name = new Map<String, Object>();
        name.put('lastName',  GeneralHelper.cleanSpecialCharacters(contactObj.LastName));
        name.put('firstName', GeneralHelper.cleanSpecialCharacters(contactObj.FirstName));

        return name;
    }

    public Map<String, Object> prepareSsn() {
        Map<String, Object> ssn = new Map<String, Object>();
        ssn.put('ssn', GeneralHelper.cleanSpecialCharacters(contactObj.genesis__SSN__c));

        return ssn;
    }

    public Map<String, Object> prepareAddress() {
        Map<String, Object> addressDetails = new Map<String, Object>();
        String line1 = contactObj.MailingBuildingNumber__c != null ? contactObj.MailingBuildingNumber__c + ' ' : '';
        line1 += contactObj.MailingAddress != null && contactObj.MailingAddress.getStreet() != null ?
            contactObj.MailingAddress.getStreet() : null;
        addressDetails.put('line1', GeneralHelper.cleanSpecialCharacters(line1));
        addressDetails.put('line2', '');
        addressDetails.put('city', contactObj.MailingAddress != null && contactObj.MailingAddress.getCity() != null ?
                                GeneralHelper.cleanSpecialCharacters(contactObj.MailingAddress.getCity()) : null);
        addressDetails.put('state', contactObj.MailingAddress != null && contactObj.MailingAddress.getState() != null ?
                                GeneralHelper.cleanSpecialCharacters(contactObj.MailingAddress.getState()) : null);
        addressDetails.put('zipCode', contactObj.MailingAddress != null && contactObj.MailingAddress.getPostalCode() != null ?
                                GeneralHelper.cleanSpecialCharacters(contactObj.MailingAddress.getPostalCode()) : null);

        return addressDetails;
    }

    public Map<String,Object> prepareRequestor() {
        Map<String,Object> requestor = new Map<String,Object>();
        requestor.put('subscriberCode', subscriberCode);

        return requestor;
    }

    public Map<String,Object> prepareAddOns() {
        Map<String,Object> addOns = new Map<String,Object>();
        addOns.put('riskModels', prepareRiskModels());
        addOns.put('fraudShield', 'Y');
        addOns.put('outputType', 'COMBO1');

        return addOns;
    }

    public Map<String,Object> prepareRiskModels() {
        Map<String,Object> riskModels = new Map<String,Object>();
        riskModels.put('modelIndicator', prepareModelIndicator());
        riskModels.put('scorePercentile', 'N');

        return riskModels;
    }

    public List<String> prepareModelIndicator() {
        List<String> modelIndicator = new List<String>();
        modelIndicator.add('FB');
        modelIndicator.add('AF');

        return modelIndicator;
    }

    public Map<String,Object> prepareInfoId() {
        Map<String,Object> infoId = new Map<String,Object>();
        List<String> infoItem = new List<String>();

        infoItem.add('SOLID:CANCAPDE');
        infoItem.add('DS:EC');
        infoItem.add('BOTH');
        infoItem.add('PROD:EXPPA1_2');

        infoId.put('item', infoItem);

        return infoId;
    }

    public Map<String,Object> responseParse(HttpResponse response) {

        String responseBody = response.getBody();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        List<Object> responseList = (List<Object>) responseMap.get('creditProfile');

        Map<String, Object> creditReqMap = fetchCreditRequestPull(responseList);

        formulateTTY(responseMap, creditReqMap);

        return creditReqMap;
    }

    public Map<String,Object> fetchCreditRequestPull(List<Object> resList) {
        List<Object>resProcessList = new List<Object>();
        Map<String,Object> processMap = new Map<String,Object>();
        List<Object> riskModelList;
        List<Object> tradeLineList;
        List<Object> premierAttributes;
        List<Object> infoMessage;
        List<Object> personalAddress;
        Map<String, Object> personalInformation;
        List<Object> ssnInformation;
        List<Object> summaries;
        List<Object>  publicRecord;
        List<Object> statement;

        for (Object dataObj : resList) {
            Map<String, Object> dataMap = (Map<String, Object>) dataObj;
            riskModelList = checkContainsList(dataMap, 'riskModel');
            tradeLineList = checkContainsList(dataMap, 'tradeline');
            premierAttributes = checkContainsList(dataMap, 'premierAttributes');
            infoMessage = checkContainsList(dataMap, 'informationalMessage');
            personalAddress = checkContainsList(dataMap, 'addressInformation');
            personalInformation = checkContainsMap(dataMap, 'consumerIdentity');
            ssnInformation = checkContainsList(dataMap, 'ssn');
            summaries = checkContainsList(dataMap, 'summaries');
            publicRecord = checkContainsList(dataMap, 'publicRecord');
            statement = checkContainsList(dataMap, 'statement');
        }

        formulateRiskModel(riskModelList, processMap);
        formulateTradeLineList(tradeLineList, processMap);
        formulatePremierAttributes(premierAttributes, processMap);
        formulateInfoMessage(infoMessage, processMap);
        formulatePersonalAddress(personalAddress, processMap);
        formulatePersonalInformation(personalInformation, processMap);
        formulateSsnInformation(ssnInformation, processMap);
        formulateSummary(summaries, processMap);
        formulatePublicRecord(publicRecord, processMap);
        formulateStatement(statement, processMap);

        return processMap;
    }

    public Map<String, Object> formulateRiskModel(List<Object> riskModelList, Map<String, Object> processMap) {
        if(riskModelList != null && !riskModelList.isEmpty()) {
            for(Object riskObj:riskModelList) {
                Map<String, Object> riskModelMap = (Map<String, Object>) riskObj;
                if(riskModelMap.get('modelIndicator')=='AF') {
                    if(riskModelMap.get('score') != null) {
                        processMap.put('FICOScore', riskModelMap.get('score') );
                    } else {
                        processMap.put('FICOScore', '0');
                    }
                    processMap.put('FICOScoreFactors', riskModelMap);
                }
                else {
                    if(riskModelMap.get('score') != null) {
                        processMap.put('BKScore', riskModelMap.get('score'));
                    }
                    else {
                        processMap.put('BKScore', '0');
                    }
                    processMap.put('BKScoreFactors', riskModelMap);
                }
            }
        }
        return processMap;
    }

    public Map<String, Object> formulateTradeLineList(List<Object> tradeLineList, Map<String, Object> processMap) {
        Integer openTradeCount = 0;
        if(tradeLineList != null && !tradeLineList.isEmpty()) {
            for(Object tradeObj:tradeLineList) {
                Map<String, Object> tradeLineMap = (Map<String, Object>) tradeObj;
                if(tradeLineMap.get('openOrClosedText') == 'Closed') {
                    openTradeCount++;
                }
            }
            processMap.put('openTrade',String.valueOf(openTradeCount));
            processMap.put('totalLateMortgage', tradeLineList);
        }
        return processMap;
    }

    public Map<String, Object> formulatePremierAttributes(List<Object> premierAttributes, Map<String, Object> processMap) {
        if(premierAttributes != null && !premierAttributes.isEmpty()) {
            for(Object premierObj:premierAttributes) {
                Map<String, Object> premierMap = (Map<String, Object>) premierObj;
                if(premierMap.get('id') == 'ALL7170') {
                    processMap.put('OverallAmounttoBalanceRatio',String.valueOf(premierMap.get('value')));
                }
                if(premierMap.get('id') == 'IQT9426') {
                    processMap.put('TotalNbrCreditInquiriesLast6months',String.valueOf(premierMap.get('value')));
                }
                if(premierMap.get('id') == 'REV3423') {
                    processMap.put('OpenRevolvingTradesCreditAmtRatio>100',String.valueOf(premierMap.get('value')));
                }
                if(premierMap.get('id') == 'REV0416') {
                    processMap.put('OpenRevolvingTradesinlast6months',String.valueOf(premierMap.get('value')));
                }
                if(premierMap.get('id') == 'MTA2387') {
                    processMap.put('MortgageTrades>90daysDlqin12months',String.valueOf(premierMap.get('value')));
                }
                if(premierMap.get('id') == 'MTA0317') {
                    processMap.put('MortgageTradesin12months',String.valueOf(premierMap.get('value')));
                }
                if(premierMap.get('id') == 'IQF9410') {
                    processMap.put('Totalnoofcreditpersonalfinanceinquiries',String.valueOf(premierMap.get('value')));
                }
                if(premierMap.get('id') == 'ALL8320') {
                    processMap.put('AvgmonthsTradesOpnExcludeCollections',String.valueOf(premierMap.get('value')));
                }
            }
        }
        return processMap;
    }

    public Map<String, Object> formulatePersonalInformation(Map<String, Object> personalInformation, Map<String, Object> processMap) {
        if(personalInformation != null && !personalInformation.isEmpty()) {
            List<Object> nameList = personalInformation.containsKey('name') ? (List<Object>) personalInformation.get('name') : null;
            Map<String, Object> dob = personalInformation.containsKey('dob') ? (Map<String, Object>) personalInformation.get('dob') : null;
            if(checkDateFieldExists(dob)) {
                processMap.put('dobYear', dob.get('year'));
                processMap.put('dobMonth', dob.get('month'));
                processMap.put('dobDate', dob.get('date'));
            }
            for(Object nameObj:nameList) {
                Map<String, Object> nameMap = (Map<String, Object>) nameObj;
                processMap.put('firstName',nameMap.get('firstName'));
                processMap.put('lastName',nameMap.get('surname'));
            }
        }
        return processMap;
    }

    public Boolean checkDateFieldExists(Map<String, Object> dob) {
        if(dob != null && dob.containsKey('year') &&  dob.containsKey('month') && dob.containsKey('date')
            && dob.get('year') != null && dob.get('month') != null && dob.get('date') != null
        ) {
            return true;
        }
        return false;
    }

    public Map<String, Object> checkContainsMap(Map<String, Object> mapOfObjects, String key) {
        if(mapOfObjects.containsKey(key)) {
            return (Map<String, Object>) mapOfObjects.get(key);
        }
        return null;
    }

    public List<Object> checkContainsList(Map<String, Object> mapOfObjects, String key) {
        if(mapOfObjects.containsKey(key)) {
            return (List<Object>) mapOfObjects.get(key);
        }
        return null;
    }

    public Map<String, Object> formulateSsnInformation(List<Object> ssnInformation, Map<String, Object> processMap) {
        if(ssnInformation  != null && !ssnInformation.isEmpty()) {
            Map<String, Object> ssnInformationMap = (Map<String, Object>) ssnInformation.get(0);
            processMap.put('ssnNumber',ssnInformationMap.get('number'));
        }
        return processMap;
    }

    public Map<String, Object> formulateInfoMessage(List<Object> infoMessage, Map<String, Object> processMap) {
        if(infoMessage != null && !infoMessage.isEmpty()) {
            for(Object infoMessageObj:infoMessage) {
                Map<String, Object> infoMessageMap = (Map<String, Object>) infoMessageObj;
                if(infoMessageMap.get('messageNumber') == '07') {
                    processMap.put('message',String.valueOf(infoMessageMap.get('messageText')));
                }
            }
        }
        return processMap;
    }

    public Map<String, Object> formulatePersonalAddress(List<Object> personalAddress, Map<String, Object> processMap) {
        if(personalAddress != null && !personalAddress.isEmpty()) {
            for(Object personalAddressObj:personalAddress) {
                Map<String, Object> personalAddressMap = (Map<String, Object>) personalAddressObj;
                processMap.put('address', personalAddressMap.get('streetPrefix') + ', ' + personalAddressMap.get('streetName') +  ', ' +
                    personalAddressMap.get('streetSuffix') +  ' ' + personalAddressMap.get('city') + ' ' +
                    personalAddressMap.get('state') + ', ' + personalAddressMap.get('zipCode'));
            }
        }
        return processMap;
    }

    public Map<String, Object> formulateSummary(List<Object> summaries, Map<String, Object> processMap) {
        if(summaries != null && !summaries.isEmpty()) {
            processMap.put('totalTradeItems', summaries);
        }
        return processMap;
    }

    public Map<String, Object> formulatePublicRecord(List<Object> publicRecord, Map<String, Object> processMap) {
        if(publicRecord != null && !publicRecord.isEmpty()) {
            processMap.put('publicRecord', publicRecord);
        }
        return processMap;
    }

    public Map<String, Object> formulateStatement(List<Object> statement, Map<String, Object> processMap) {
        if(statement != null && !statement.isEmpty()) {
            processMap.put('statement', statement);
        }
        return processMap;
    }

    public void formulateTTY(Map<String, Object> ttyResponse, Map<String, Object> processMap) {
        if(ttyResponse.get('tty') != null) {
            Map<String, Object> ttyMessage = (Map<String, Object>) ttyResponse.get('tty');
            if(ttyMessage != null && !ttyMessage.isEmpty()) {
                processMap.put('ttyResponse', ttyMessage.get('ttyResponse'));
            }
        }
    }

    public Map<String,Object> businessRequestBody() {
        String buildingNumber = accountObj.BillingBuildingNumber__c != null ? accountObj.BillingBuildingNumber__c + ' ' : '';
        Map<String,Object> paramBody = new Map<String,Object>();
        paramBody.put('name', GeneralHelper.cleanSpecialCharacters(accountObj.Legal_Name__c));
        paramBody.put('city', GeneralHelper.cleanSpecialCharacters(accountObj.BillingCity));
        paramBody.put('state', GeneralHelper.cleanSpecialCharacters(accountObj.BillingState));
        paramBody.put('subcode', subscriberCode);
        paramBody.put('street', GeneralHelper.cleanSpecialCharacters(buildingNumber + accountObj.BillingStreet));
        paramBody.put('zip', GeneralHelper.cleanSpecialCharacters(accountObj.BillingPostalCode));
        paramBody.put('phone', GeneralHelper.cleanSpecialCharacters(accountObj.Phone));
        paramBody.put('taxId', GeneralHelper.cleanSpecialCharacters(accountObj.Business_Tax_ID__c));
        paramBody.put('geo', true);
        paramBody.put('comments', instanceName);

        return paramBody;
    }

    public Map<String,Object> businessResponseBody(HttpResponse response) {
        String responseBody = response.getBody();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        Map<String, Object> resultMap = new Map<String, Object>();

        if(responseMap.containsKey('responseMessage')) {
            resultMap.put('responseMessage', responseMap.get('responseMessage'));
        }

        Integer maxReliabilityCode = 0;
        for(Object obj : (List<Object>) responseMap.get('results')) {
            Map<String, Object> binResponseMap = (Map<String, Object>) obj;
            Integer currentReliabilityCode = Integer.valueOf(binResponseMap.get('reliabilityCode'));
            if(currentReliabilityCode > 85 && currentReliabilityCode > maxReliabilityCode) {
                maxReliabilityCode = currentReliabilityCode;
                resultMap.put('bin', binResponseMap.get('bin'));
                resultMap.put('reliabilityCode', maxReliabilityCode);
            }
        }

        return resultMap;
     }

    public Map<String, Object> businessPremierProfilesRequestBody(Map<String, Object> accountCreditPremierProfile) {
        String binValue = String.ValueOf(accountCreditPremierProfile.get('bin'));
        Map<String, Object> paramBody = new Map<String, Object>();
        paramBody.put('bin', binValue);
        paramBody.put('subcode', subscriberCode);
        paramBody.put('modelCode', '000224');
        paramBody.put('comments', instanceName);
        return paramBody;
    }

   public Map<String,Object> businessPremierProfilesResponseBody(HttpResponse response) {
        String responseBody = response.getBody();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        Map<String, Object> resultMap = new Map<String, Object>();
        resultMap.put('requestId', responseMap.get('requestId') != null? String.valueOf(responseMap.get('requestId')) : null);

        if(responseMap.containsKey('results')) {
            Map<String,Object> resultsResponseMap = (Map<String,Object>) responseMap.get('results');
            Map<String,Object> businessFactsMap = (Map<String,Object>) resultsResponseMap.get('businessFacts');
            Map<String,Object> businessHeader = (Map<String,Object>) resultsResponseMap.get('businessHeader');
            Map<String,Object> tradeLineCountMap = (Map<String,Object>) resultsResponseMap.get('expandedCreditSummary');
            Map<String, String> documentAndDateValMap = new Map<String, String>();

            resultMap.putAll(resultsResponseMap);

            if(businessFactsMap.containsKey('fileEstablishedDate') && businessFactsMap.get('fileEstablishedDate') != null) {
                String extractedDate = String.ValueOf(businessFactsMap.get('fileEstablishedDate'));
                Date fileEstablishedDate = GeneralHelper.getDateFromUntypedString(extractedDate, 0, 1, 2, '-');
                resultMap.put('fileEstablishedDate', fileEstablishedDate);
            }
            if(businessFactsMap.containsKey('businessType')) {
                resultMap.put('businessType', businessFactsMap.get('businessType'));
            }
            if(businessHeader.containsKey('legalBusinessName')) {
                resultMap.put('legalBusinessName', businessHeader.get('legalBusinessName'));
            }
            if(businessHeader.containsKey('taxId')) {
                resultMap.put('taxId', businessHeader.get('taxId'));
            }
            if(businessHeader.containsKey('address')) {
                Map<String,Object> businessAddressMap=(Map<String,Object>) businessHeader.get('address');
                if(businessAddressMap.containsKey('street')) {
                    resultMap.put('street',businessAddressMap.get('street'));
                }
                if(businessAddressMap.containsKey('city')) {
                    resultMap.put('city',businessAddressMap.get('city'));
                }
                if(businessAddressMap.containsKey('state')) {
                    resultMap.put('state',businessAddressMap.get('state'));
                }
                if(businessAddressMap.containsKey('zip')) {
                    resultMap.put('zip',businessAddressMap.get('zip'));
                }
                if(businessAddressMap.containsKey('zipExtension')) {
                    resultMap.put('zipExtension',businessAddressMap.get('zipExtension'));
                }
            }
            if(tradeLineCountMap.containsKey('allTradelineCount')) {
                resultMap.put('allTradelineCount', tradeLineCountMap.get('allTradelineCount'));
            }

        }

        return resultMap;
    }

    public Map<String,Object> businessPremierProfilesPDFRequestBody(Map<String, Object> accountCreditPremierProfilePdf) {
        String binValue = String.ValueOf(accountCreditPremierProfilePdf.get('bin'));
        Map<String,Object> paramBody = new Map<String,Object>();
        paramBody.put('bin', binValue);
        paramBody.put('subcode', subscriberCode);
        paramBody.put('modelCode', '000224');
        paramBody.put('comments', instanceName);

        return paramBody;
    }

    public string businessPremierProfilesPDFResponseBody(HttpResponse response) {
        String responseBody = response.getBody();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        String resultsString = String.valueOf(responseMap.get('results'));
        return resultsString;
    }

    public Map<String,Object> businessAggregatesRequestBody(Map<String, Object> accountCreditAggregates) {
        String binValue = String.ValueOf(accountCreditAggregates.get('bin'));
        Map<String,Object> paramBody = new Map<String,Object>();
        paramBody.put('bin', binValue);
        paramBody.put('subcode', subscriberCode);
        paramBody.put('extraAggs', true);

        return paramBody;
    }

    public Map<String,Object> businessAggregatesResponseBody(HttpResponse response) {
        String responseBody = response.getBody();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        return (Map<String,Object>) responseMap.get('results');
    }

}