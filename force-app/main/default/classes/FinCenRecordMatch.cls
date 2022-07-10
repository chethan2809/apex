public class FinCenRecordMatch {

    public static final String RECORD_TYPE_ACCOUNT = 'FinCen Account';
    public static final String RECORD_TYPE_CONTACT = 'FinCen Contact';
    public static final String RECORD_TYPE_ID_ACCOUNT = 'Fincen Report Account';
    public static final String RECORD_TYPE_ID_CONTACT = 'Fincen Report Contact';

    public static void runFinCenReportForAccountMatches(Account accountRecord, List<Object> fieldNameToAccountList,
        Map<String, Object> matchedAccountDetailsByAccountId
    ) {
        for (Integer i = 0; i < fieldNameToAccountList.size(); i++) {
            Map<String, String> fieldValueMap = (Map<String, String>) fieldNameToAccountList.get(i);
            Map<String, Object> criteriaValues = new Map<String, Object>();
            criteriaValues.put('recordCount', fieldNameToAccountList.size());
            criteriaValues.put('indexValue', i);

            checkToCallStringForMatch(fieldValueMap.get('business_name'),
                accountRecord.Legal_Name__c, criteriaValues, matchedAccountDetailsByAccountId,
                fieldValueMap, accountRecord, null, 'Business Name - Legal Name'
            );

            checkToCallStringForMatch(fieldValueMap.get('business_name'),
                accountRecord.Business_Name__c, criteriaValues, matchedAccountDetailsByAccountId,
                fieldValueMap, accountRecord, null, 'Business Name - Business Name'
            );

            checkToCallStringForMatch(fieldValueMap.get('business_name'),
                accountRecord.Doing_Business_As_Name__c, criteriaValues, matchedAccountDetailsByAccountId,
                fieldValueMap, accountRecord, null, 'Business Name - Doing Business Name'
            );

            checkToCallStringForMatch(fieldValueMap.get('dba_name'),
                accountRecord.Legal_Name__c, criteriaValues, matchedAccountDetailsByAccountId,
                fieldValueMap, accountRecord, null, 'dba Name - Legal Name'
            );

            checkToCallStringForMatch(fieldValueMap.get('dba_name'),
                accountRecord.Business_Name__c, criteriaValues, matchedAccountDetailsByAccountId,
                fieldValueMap, accountRecord, null, 'dba Name - Business Name'
            );

            checkToCallStringForMatch(fieldValueMap.get('dba_name'),
                accountRecord.Doing_Business_As_Name__c, criteriaValues, matchedAccountDetailsByAccountId,
                fieldValueMap, accountRecord, null, 'dba Name - Doing Business Name'
            );

            checkToCallStringForMatch(
                fieldValueMap.get('street') + fieldValueMap.get('city')
                        + fieldValueMap.get('state') + fieldValueMap.get('zip'),
                    accountRecord.BillingBuildingNumber__c + accountRecord.BillingStreet + accountRecord.BillingCity + accountRecord.BillingState
                        + accountRecord.BillingPostalCode, criteriaValues, matchedAccountDetailsByAccountId,
                    fieldValueMap, accountRecord, null, 'Address'
            );

            if(fieldValueMap.get('number') == accountRecord.Business_Tax_ID__c && fieldValueMap.get('number_type') == 'EIN') {
                criteriaValues.put('matchingCriteria', 'Business Tax ID');
                criteriaValues.put('threshold', '100.00');
                prepareMatchedAccountDetails(matchedAccountDetailsByAccountId, fieldValueMap, accountRecord, null, criteriaValues);
            }
        }
    }

    public static void runFinCenReportForContactMatches(AccountContactRelation contactRecord, List<Object> fieldNameToContactList,
        Map<String, Object> matchedAccountDetailsByContactId
    ) {
        for (Integer i = 0; i < fieldNameToContactList.size(); i++) {
            Map<String, String> fieldValueMap = (Map<String, String>) fieldNameToContactList.get(i);
            Map<String, Object> criteriaValues = new Map<String, Object>();
            criteriaValues.put('recordCount', fieldNameToContactList.size());
            criteriaValues.put('indexValue', i);

            checkToCallStringForMatch(fieldValueMap.get('first_name') + fieldValueMap.get('last_name'),
                contactRecord.Contact.FirstName + contactRecord.Contact.LastName, criteriaValues, matchedAccountDetailsByContactId,
                fieldValueMap, null, contactRecord, 'Name'
            );

            checkToCallStringForMatch(fieldValueMap.get('last_name') + fieldValueMap.get('first_name'),
                contactRecord.Contact.FirstName + contactRecord.Contact.LastName, criteriaValues, matchedAccountDetailsByContactId,
                fieldValueMap, null, contactRecord, 'Name'
            );

            checkToCallStringForMatch(fieldValueMap.get('alias_first_name') + fieldValueMap.get('alias_last_name'),
                contactRecord.Contact.FirstName + contactRecord.Contact.LastName, criteriaValues, matchedAccountDetailsByContactId,
                fieldValueMap, null, contactRecord, 'Alias Name'
            );

            checkToCallStringForMatch(fieldValueMap.get('alias_last_name') + fieldValueMap.get('alias_first_name'),
                contactRecord.Contact.FirstName + contactRecord.Contact.LastName, criteriaValues, matchedAccountDetailsByContactId,
                fieldValueMap, null, contactRecord, 'Alias Name'
            );

            checkToCallStringForMatch(
                fieldValueMap.get('street') + fieldValueMap.get('city') + fieldValueMap.get('state') + fieldValueMap.get('zip'),
                contactRecord.Contact.MailingBuildingNumber__c + contactRecord.Contact.MailingStreet + contactRecord.Contact.MailingCity
                    + contactRecord.Contact.MailingState + contactRecord.Contact.MailingPostalCode, criteriaValues, matchedAccountDetailsByContactId,
                    fieldValueMap, null, contactRecord, 'Address'
            );
            if (fieldValueMap.get('number') == contactRecord.Contact.genesis__SSN__c && fieldValueMap.get('number_type') == 'SSN/ITIN') {
                criteriaValues.put('matchingCriteria', 'SSN');
                criteriaValues.put('threshold', '100.00');
                prepareMatchedAccountDetails(matchedAccountDetailsByContactId, fieldValueMap, null, contactRecord, criteriaValues);
            }
        }
    }

    public static void checkToCallStringForMatch(String finCenFieldValue, String fieldValue,
        Map<String, Object> criteriaValues, Map<String, Object> matchedRecordDetailsByRecordId, Map<String, String> fieldValueMap,
        Account accountRecord, AccountContactRelation contactRecord, String matchingCriteria
    ) {
        Decimal threshold = compareStringForMatch(finCenFieldValue, fieldValue);
        if(CustomSettingsHelper.generalSettings != null && CustomSettingsHelper.generalSettings.FinCen_Threshold_Value__c != null
            && Integer.valueOf(threshold) >= CustomSettingsHelper.generalSettings.FinCen_Threshold_Value__c
        ) {
            criteriaValues.put('threshold', threshold);
            criteriaValues.put('matchingCriteria', matchingCriteria);
            prepareMatchedAccountDetails(matchedRecordDetailsByRecordId, fieldValueMap, accountRecord, contactRecord, criteriaValues);
        }
    }

    public static Decimal compareStringForMatch(String finCenFieldValue, String fieldValue) {
        Decimal threshold = 0;
        if(finCenFieldValue == null || fieldValue == null) {
            return threshold;
        }

        if(finCenFieldValue.length() > fieldValue.length()) {
            threshold = calculateLevenshteinDistanceAndThreshold(finCenFieldValue.toUpperCase(), fieldValue.toUpperCase());
        } else {
            threshold = calculateLevenshteinDistanceAndThreshold(fieldValue.toUpperCase(), finCenFieldValue.toUpperCase());
        }

        return threshold;
    }

    public static Decimal calculateLevenshteinDistanceAndThreshold(String sourceString, String targetString) {
        Decimal levenshteinDistance = sourceString.getLevenshteinDistance(targetString, 80);
        Decimal threshold = levenshteinDistance >= 0 ? ((1 - (levenshteinDistance / sourceString.length())) * 100) : 0;

        return threshold.setScale(2);
    }

    public static void prepareMatchedAccountDetails(Map<String, Object> matchedAccountDetailsByRecordId, Map<String, String> valuesFromDocument,
        Account accountRecord, AccountContactRelation contactRecord, Map<String, Object> criteriaValues
    ) {
        Map<String, Object> recordDetailsByField;
        String recordId = accountRecord != null ? String.valueOf(accountRecord.Id)  + '_' + String.valueOf(criteriaValues.get('indexValue'))
            : (contactRecord != null ? String.valueOf(contactRecord.Contact.Id)  + '_' + String.valueOf(criteriaValues.get('indexValue'))
                : ''
            );
        if(matchedAccountDetailsByRecordId.containsKey(recordId)) {
            recordDetailsByField = (Map<String, Object>) matchedAccountDetailsByRecordId.get(recordId);
            Integer matchesFound = Integer.valueOf(recordDetailsByField.get('totalMatched')) + 1;
            recordDetailsByField.put('totalMatched', matchesFound);
            recordDetailsByField.put('possibleMatches', matchesFound);
            String matchingCriteria = String.valueOf(recordDetailsByField.get('matchingCriteria'));
            recordDetailsByField.put('matchingCriteria', matchingCriteria + ',' + String.valueOf(criteriaValues.get('matchingCriteria')));
            String thresholdValue = String.valueOf(recordDetailsByField.get('threshold'));
            recordDetailsByField.put('thresholdValue', thresholdValue + ',' + String.valueOf(criteriaValues.get('threshold')));
        } else {
            recordDetailsByField = new Map<String, Object>();
            recordDetailsByField.put('batchNumber', valuesFromDocument.containsKey('tracking_number') ? valuesFromDocument.get('tracking_number') : '');
            recordDetailsByField.put('runDate', String.valueOf(GeneralHelper.currentSystemDate));
            recordDetailsByField.put('recordCount', Integer.valueOf(criteriaValues.get('recordCount')));
            recordDetailsByField.put('totalSearched',
                valuesFromDocument.containsKey('totalSearches') ? String.valueOf(valuesFromDocument.get('totalSearches')) : ''
            );
            recordDetailsByField.put('totalMatched', 1);
            recordDetailsByField.put('sourceFile', '');
            recordDetailsByField.put('threshold', String.valueOf(CustomSettingsHelper.generalSettings.FinCen_Threshold_Value__c.setScale(0)));
            recordDetailsByField.put('thresholdValue', String.valueOf(criteriaValues.get('threshold')));
            recordDetailsByField.put('lastName', valuesFromDocument.containsKey('last_name') ? valuesFromDocument.get('last_name') : '');
            recordDetailsByField.put('firstName', valuesFromDocument.containsKey('first_name') ? valuesFromDocument.get('first_name') : '');
            recordDetailsByField.put('middleName', valuesFromDocument.containsKey('middle_name') ? valuesFromDocument.get('middle_name') : '');
            recordDetailsByField.put('suffix', valuesFromDocument.containsKey('suffix') ? valuesFromDocument.get('suffix') : '');
            recordDetailsByField.put('aliasLastName', valuesFromDocument.containsKey('alias_last_name') ? valuesFromDocument.get('alias_last_name') : '');
            recordDetailsByField.put('aliasFirstName', valuesFromDocument.containsKey('alias_first_name') ? valuesFromDocument.get('alias_first_name') : '');
            recordDetailsByField.put('aliasMiddleName', valuesFromDocument.containsKey('alias_middle_name') ? valuesFromDocument.get('alias_middle_name') : '');
            recordDetailsByField.put('aliasSuffix', valuesFromDocument.containsKey('alias_suffix') ? valuesFromDocument.get('alias_suffix') : '');
            recordDetailsByField.put('contactNumber', contactRecord != null && valuesFromDocument.containsKey('number') ? valuesFromDocument.get('number') : '');
            recordDetailsByField.put('contactNumberType', contactRecord != null && valuesFromDocument.containsKey('number_type') ? valuesFromDocument.get('number_type') : '');
            recordDetailsByField.put('contactDOB', valuesFromDocument.containsKey('dob') ? valuesFromDocument.get('dob') : '');
            recordDetailsByField.put('contactStreet', contactRecord != null && valuesFromDocument.containsKey('street') ? valuesFromDocument.get('street') : '');
            recordDetailsByField.put('contactCity', contactRecord != null && valuesFromDocument.containsKey('city') ? valuesFromDocument.get('city') : '');
            recordDetailsByField.put('contactState', contactRecord != null && valuesFromDocument.containsKey('state') ? valuesFromDocument.get('state') : '');
            recordDetailsByField.put('contactZip', contactRecord != null && valuesFromDocument.containsKey('zip') ? valuesFromDocument.get('zip') : '');
            recordDetailsByField.put('contactCountry', contactRecord != null && valuesFromDocument.containsKey('country') ? valuesFromDocument.get('country') : '');
            recordDetailsByField.put('contactPhone', contactRecord != null && valuesFromDocument.containsKey('phone') ? valuesFromDocument.get('phone') : '');

            recordDetailsByField.put('businessName', valuesFromDocument.containsKey('business_name') ? valuesFromDocument.get('business_name') : '');
            recordDetailsByField.put('dbaName', valuesFromDocument.containsKey('dba_name') ? valuesFromDocument.get('dba_name') : '');
            recordDetailsByField.put('businessNumber', accountRecord != null && valuesFromDocument.containsKey('number') ? valuesFromDocument.get('number') : '');
            recordDetailsByField.put('businessNumberType', accountRecord != null && valuesFromDocument.containsKey('number_type') ? valuesFromDocument.get('number_type') : '');
            recordDetailsByField.put('incorporated', valuesFromDocument.containsKey('incorporated') ? valuesFromDocument.get('incorporated') : '');
            recordDetailsByField.put('businessStreet', accountRecord != null && valuesFromDocument.containsKey('street') ? valuesFromDocument.get('street') : '');
            recordDetailsByField.put('businessCity', accountRecord != null && valuesFromDocument.containsKey('city') ? valuesFromDocument.get('city') : '');
            recordDetailsByField.put('businessState', accountRecord != null && valuesFromDocument.containsKey('state') ? valuesFromDocument.get('state') : '');
            recordDetailsByField.put('businessZip', accountRecord != null && valuesFromDocument.containsKey('zip') ? valuesFromDocument.get('zip') : '');
            recordDetailsByField.put('businessCountry', accountRecord != null && valuesFromDocument.containsKey('country') ? valuesFromDocument.get('country') : '');
            recordDetailsByField.put('businessPhone', accountRecord != null && valuesFromDocument.containsKey('phone') ? valuesFromDocument.get('phone') : '');
            recordDetailsByField.put('possibleMatches', 1);
            recordDetailsByField.put('matchingCriteria', String.valueOf(criteriaValues.get('matchingCriteria')));

            recordDetailsByField.put('borrowerName', accountRecord != null ? accountRecord.Name : '');
            recordDetailsByField.put('merchantId', accountRecord != null ? accountRecord.Merchant_ID__c : '');
            recordDetailsByField.put('legalName', accountRecord != null ? accountRecord.Legal_Name__c : '');
            recordDetailsByField.put('legalStreet', accountRecord != null ? accountRecord.BillingStreet : '');
            recordDetailsByField.put('legalCity', accountRecord != null ? accountRecord.BillingCity : '');
            recordDetailsByField.put('legalState', accountRecord != null ? accountRecord.BillingState : '');
            recordDetailsByField.put('legalZip', accountRecord != null ? accountRecord.BillingPostalCode : '');
            recordDetailsByField.put('legalCountry', accountRecord != null ? accountRecord.BillingCountry : '');
            recordDetailsByField.put('legalComment', '');
            recordDetailsByField.put('legalNumber', accountRecord != null ? accountRecord.Business_Tax_ID__c :
                (contactRecord != null ? contactRecord.Contact.genesis__SSN__c : ''));
            recordDetailsByField.put('legalNumberType', accountRecord != null ? 'EIN' : (contactRecord != null ? 'SSN' : ''));
            recordDetailsByField.put('guarantorFirstName', contactRecord != null ? contactRecord.Contact.FirstName : '');
            recordDetailsByField.put('guarantorLastName', contactRecord != null ? contactRecord.Contact.LastName : '');
            recordDetailsByField.put('guarantorStreet', contactRecord != null ? contactRecord.Contact.MailingStreet : '');
            recordDetailsByField.put('guarantorCity', contactRecord != null ? contactRecord.Contact.MailingCity : '');
            recordDetailsByField.put('guarantorState', contactRecord != null ? contactRecord.Contact.MailingState : '');
            recordDetailsByField.put('guarantorZip', contactRecord != null ? contactRecord.Contact.MailingPostalCode : '');
            recordDetailsByField.put('guarantorCountry', contactRecord != null ? contactRecord.Contact.MailingCountry : '');
            recordDetailsByField.put('guarantorDOB', contactRecord != null ? String.valueOf(contactRecord.Contact.Birthdate) : '');
            recordDetailsByField.put('guarantorComment', '');

            matchedAccountDetailsByRecordId.put(String.valueOf(recordId), recordDetailsByField);
        }
    }

    public static List<String> buildFinCenReport(String finCenResultName, Map<String, Object> recordMap, Map<String, String> documentParameters) {
        List<String> csvIndividualRowValues = new List<String>{
            validateStringValue(finCenResultName),
            validateStringValue(String.valueOf(recordMap.get('runDate'))),
            validateStringValue(String.valueOf(documentParameters.get('recordCount'))),
            validateStringValue(String.valueOf(documentParameters.get('totalSearches'))),
            validateStringValue(String.valueOf(recordMap.get('totalMatched'))),
            validateStringValue(String.valueOf(documentParameters.get('fileName'))),
            validateStringValue(String.valueOf(recordMap.get('threshold'))),
            validateStringValue(String.valueOf(recordMap.get('lastName'))),
            validateStringValue(String.valueOf(recordMap.get('firstName'))),
            validateStringValue(String.valueOf(recordMap.get('middleName'))),
            validateStringValue(String.valueOf(recordMap.get('suffix'))),
            validateStringValue(String.valueOf(recordMap.get('aliasLastName'))),
            validateStringValue(String.valueOf(recordMap.get('aliasFirstName'))),
            validateStringValue(String.valueOf(recordMap.get('aliasMiddleName'))),
            validateStringValue(String.valueOf(recordMap.get('aliasSuffix'))),
            validateStringValue(String.valueOf(recordMap.get('contactNumber'))),
            validateStringValue(String.valueOf(recordMap.get('contactNumberType'))),
            validateStringValue(String.valueOf(recordMap.get('contactDOB'))),
            validateStringValue(String.valueOf(recordMap.get('contactStreet'))),
            validateStringValue(String.valueOf(recordMap.get('contactCity'))),
            validateStringValue(String.valueOf(recordMap.get('contactState'))),
            validateStringValue(String.valueOf(recordMap.get('contactZip'))),
            validateStringValue(String.valueOf(recordMap.get('contactCountry'))),
            validateStringValue(String.valueOf(recordMap.get('contactPhone'))),
            validateStringValue(String.valueOf(recordMap.get('businessName'))),
            validateStringValue(String.valueOf(recordMap.get('dbaName'))),
            validateStringValue(String.valueOf(recordMap.get('businessNumber'))),
            validateStringValue(String.valueOf(recordMap.get('businessNumberType'))),
            validateStringValue(String.valueOf(recordMap.get('incorporated'))),
            validateStringValue(String.valueOf(recordMap.get('businessStreet'))),
            validateStringValue(String.valueOf(recordMap.get('businessCity'))),
            validateStringValue(String.valueOf(recordMap.get('businessState'))),
            validateStringValue(String.valueOf(recordMap.get('businessZip'))),
            validateStringValue(String.valueOf(recordMap.get('businessCountry'))),
            validateStringValue(String.valueOf(recordMap.get('businessPhone'))),
            validateStringValue(String.valueOf(recordMap.get('possibleMatches'))),
            validateStringValue(String.valueOf(recordMap.get('matchingCriteria'))),
            validateStringValue(String.valueOf(recordMap.get('borrowerName'))),
            validateStringValue(String.valueOf(recordMap.get('merchantId'))),
            validateStringValue(String.valueOf(recordMap.get('legalName'))),
            validateStringValue(String.valueOf(recordMap.get('legalStreet'))),
            validateStringValue(String.valueOf(recordMap.get('legalCity'))),
            validateStringValue(String.valueOf(recordMap.get('legalState'))),
            validateStringValue(String.valueOf(recordMap.get('legalZip'))),
            validateStringValue(String.valueOf(recordMap.get('legalCountry'))),
            validateStringValue(String.valueOf(recordMap.get('legalComment'))),
            validateStringValue(String.valueOf(recordMap.get('legalNumber'))),
            validateStringValue(String.valueOf(recordMap.get('legalNumberType'))),
            validateStringValue(String.valueOf(recordMap.get('guarantorFirstName'))),
            validateStringValue(String.valueOf(recordMap.get('guarantorLastName'))),
            validateStringValue(String.valueOf(recordMap.get('guarantorStreet'))),
            validateStringValue(String.valueOf(recordMap.get('guarantorCity'))),
            validateStringValue(String.valueOf(recordMap.get('guarantorState'))),
            validateStringValue(String.valueOf(recordMap.get('guarantorZip'))),
            validateStringValue(String.valueOf(recordMap.get('guarantorCountry'))),
            validateStringValue(String.valueOf(recordMap.get('guarantorDOB'))),
            validateStringValue(String.valueOf(recordMap.get('guarantorComment')))
        };
        return csvIndividualRowValues;
    }

    private static String validateStringValue(String value) {
        String stringValue = (String)value;
        if (stringValue == null) {
            return null;
        }
        return stringValue.replaceAll('\n','').replaceAll('\r','').escapeCSV();
    }

    public static FinCen_Result__c createFinCenResult(Map<String, String> documentParameters) {
        FinCen_Result__c finCenResult = new FinCen_Result__c();
        finCenResult.Record_Count__c = documentParameters != null && documentParameters.containsKey('recordCount') ?
            Integer.valueOf(documentParameters.get('recordCount')) : null;
        finCenResult.Run_Date__c = GeneralHelper.currentSystemDate;
        finCenResult.Source_File__c = documentParameters != null && documentParameters.containsKey('fileName') ?
            String.valueOf(documentParameters.get('fileName')) : null;
        finCenResult.Threshold__c = Integer.valueOf(CustomSettingsHelper.generalSettings.FinCen_Threshold_Value__c.setScale(0));
        finCenResult.Total_Searched__c = documentParameters != null && documentParameters.containsKey('totalSearches') ?
            Integer.valueOf(documentParameters.get('totalSearches')) : null;

        return finCenResult;
    }

    public static FinCen_Search__c createFinCenSearch(FinCen_Result__c finCenResult, String recordId, Map<String, Object> recordMap, String type) {
        FinCen_Search__c finCenSearch = new FinCen_Search__c();
        finCenSearch.Type__c = type;
        if(type == RECORD_TYPE_ACCOUNT) {
            finCenSearch.RecordTypeId = Schema.SObjectType.FinCen_Search__c.getRecordTypeInfosByName().get(RECORD_TYPE_ID_ACCOUNT).getRecordTypeId();
        } else {
            finCenSearch.RecordTypeId = Schema.SObjectType.FinCen_Search__c.getRecordTypeInfosByName().get(RECORD_TYPE_ID_CONTACT).getRecordTypeId();
        }
        finCenSearch.FinCen_Result__c = finCenResult.Id;
        finCenSearch.Matching_Criteria__c = validateString(recordMap, 'matchingCriteria');
        finCenSearch.Total_Matched__c = validateInteger(recordMap, 'totalMatched');
        finCenSearch.Tracking_Number__c = validateString(recordMap, 'batchNumber');

        generateFinCenSearch(recordId, type, finCenSearch, recordMap);
        generateFinCenAddress(type, finCenSearch, recordMap);
        generateFinCenIdentity(type, finCenSearch, recordMap);

        return finCenSearch;
    }

    public static void generateFinCenSearch(String recordId, String type, FinCen_Search__c finCenSearch,  Map<String, Object> recordMap) {
        if(type == RECORD_TYPE_ACCOUNT) {
            finCenSearch.Account__c = Id.valueOf(recordId);
            finCenSearch.Business_Name__c = validateString(recordMap, 'businessName');
            finCenSearch.Doing_Business_As_Name__c = validateString(recordMap, 'dbaName');
            finCenSearch.Incorporated__c = validateString(recordMap, 'incorporated');
        } else {
            finCenSearch.Contact__c = Id.valueOf(recordId);
            finCenSearch.Suffix__c = validateString(recordMap, 'suffix');
            finCenSearch.First_Name__c = validateString(recordMap, 'firstName');
            finCenSearch.Middle_Name__c = validateString(recordMap, 'middleName');
            finCenSearch.Last_Name__c = validateString(recordMap, 'lastName');
            finCenSearch.Alias_First_Name__c = validateString(recordMap, 'aliasFirstName');
            finCenSearch.Alias_Last_Name__c = validateString(recordMap, 'aliasLastName');
            finCenSearch.Alias_Middle_Name__c = validateString(recordMap, 'aliasMiddleName');
            finCenSearch.Alias_Suffix__c = validateString(recordMap, 'aliasSuffix');
            List<String> dateOfBirth = validateString(recordMap, 'contactDOB') != '' ?
                String.valueOf(recordMap.get('contactDOB')).split('/') : new List<String> ();
            if(!dateOfBirth.isEmpty()) {
                finCenSearch.Date_Of_Birth__c = Date.newInstance(
                    Integer.valueOf(dateOfBirth.get(2)), Integer.valueOf(dateOfBirth.get(0)), Integer.valueOf(dateOfBirth.get(1))
                );
            }
        }
    }

    public static void generateFinCenAddress(String type, FinCen_Search__c finCenSearch,  Map<String, Object> recordMap) {
        if(type == RECORD_TYPE_ACCOUNT) {
            finCenSearch.Address_Street__c = validateString(recordMap, 'businessStreet');
            finCenSearch.Address_City__c = validateString(recordMap, 'businessCity');
            finCenSearch.Address_State__c = validateString(recordMap, 'businessState');
            finCenSearch.Address_Zip__c = validateString(recordMap, 'businessZip');
            finCenSearch.Address_Country__c = validateString(recordMap, 'businessCountry');
        } else {
            finCenSearch.Address_Street__c = validateString(recordMap, 'contactStreet');
            finCenSearch.Address_City__c = validateString(recordMap, 'contactCity');
            finCenSearch.Address_State__c = validateString(recordMap, 'contactState');
            finCenSearch.Address_Zip__c = validateString(recordMap, 'contactZip');
            finCenSearch.Address_Country__c = validateString(recordMap, 'contactCountry');
        }
    }

    public static void generateFinCenIdentity(String type, FinCen_Search__c finCenSearch,  Map<String, Object> recordMap) {
        if(type == RECORD_TYPE_ACCOUNT) {
            finCenSearch.Phone__c = validateString(recordMap, 'businessPhone');
            finCenSearch.Identity_Number__c = validateString(recordMap, 'businessNumber');
            finCenSearch.Identity_Number_Type__c = validateString(recordMap, 'businessNumberType');
        } else {
            finCenSearch.Phone__c = validateString(recordMap, 'contactPhone');
            finCenSearch.Identity_Number__c = validateString(recordMap, 'contactNumber');
            finCenSearch.Identity_Number_Type__c = validateString(recordMap, 'contactNumberType');
        }
    }

    private static String validateString(Map<String, Object> valueMap, String valueString) {
        if(valueMap != null && !valueMap.isEmpty() && valueMap.containsKey(valueString)) {
            return String.valueOf(valueMap.get(valueString));
        }
        return '';
    }

    private static Integer validateInteger(Map<String, Object> valueMap, String valueInteger) {
        if(valueMap != null && !valueMap.isEmpty() && valueMap.containsKey(valueInteger)) {
            return Integer.valueOf(valueMap.get(valueInteger));
        }
        return null;
    }
}