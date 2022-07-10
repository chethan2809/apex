@isTest(isParallel=true)
private class FinCenRecordMatchTests {
    @isTest
    private static void runFinCenReportForAccountMatches() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        List<Object> fieldNameToAccountList = new List<Object>();
        Map<String, String> fieldValueToFields = new Map<String, String>();
        fieldValueToFields.put('business_name', 'SURGERY CENTER');
        fieldValueToFields.put('dba_name', 'SURGERY CENTER');
        fieldValueToFields.put('street', '663 BRYANT BLVD');
        fieldValueToFields.put('city', 'Rock Hill');
        fieldValueToFields.put('state', 'NC');
        fieldValueToFields.put('zip', '29732');
        fieldValueToFields.put('number', '783960579');
        fieldValueToFields.put('number_type', 'EIN');
        fieldNameToAccountList.add(fieldValueToFields);

        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountRecord.Merchant_ID__c = '23432423';
        accountRecord.BillingBuildingNumber__c = '340';
        accountRecord.BillingStreet = '663 BRYANT BLVD';
        accountRecord.BillingCity = 'Rock Hill';
        accountRecord.BillingState = 'NC';
        accountRecord.BillingPostalCode = '29732';
        accountRecord.Doing_Business_As_Name__c = 'SURGERY CENTER';
        accountRecord.Legal_Name__c = 'SURGERY CENTER';
        accountRecord.Business_Name__c = 'SURGERY CENTER';
        accountRecord.Business_Tax_ID__c = '783960579';
        Set<String> accountIds = new Set<String>();
        accountIds.add(accountRecord.Id);
        Map<String, Object> matchedAccountDetailsByAccountId = new Map<String, Object>();

        CAN_General_Settings__c generalSetting = new CAN_General_Settings__c();
        generalSetting.Id = TestUtility.getFakeId(CAN_General_Settings__c.getSObjectType());
        generalSetting.FinCen_Threshold_Value__c = 85;
        CustomSettingsHelper.generalSettings = generalSetting;

        Test.startTest();
            FinCenRecordMatch.runFinCenReportForAccountMatches(accountRecord, fieldNameToAccountList, matchedAccountDetailsByAccountId);
        Test.stopTest();

        Map<String, Object> matchedAccount = (Map<String, Object>) matchedAccountDetailsByAccountId.get(String.valueOf(accountRecord.Id) + '_0');

        System.assertEquals(accountRecord.Business_Name__c, matchedAccount.get('businessName'));
    }

    @isTest
    private static void runFinCenReportForContactMatches() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        List<Object> fieldNameToContactList = new List<Object>();
        Map<String, String> fieldValueToFields = new Map<String, String>();
        fieldValueToFields.put('first_name', 'Andy');
        fieldValueToFields.put('last_name', 'Troiano');
        fieldValueToFields.put('street', '340 Westover Drive');
        fieldValueToFields.put('city', 'Woodstock');
        fieldValueToFields.put('state', 'GA');
        fieldValueToFields.put('zip', '30188');
        fieldValueToFields.put('number', '123121234');
        fieldValueToFields.put('number_type', 'SSN/ITIN');
        fieldNameToContactList.add(fieldValueToFields);

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.LastName = 'Troiano';
        contactRecord.FirstName = 'Andy';
        contactRecord.MailingBuildingNumber__c = '540';
        contactRecord.MailingStreet = '340 Westover Drive';
        contactRecord.MailingCity = 'Woodstock';
        contactRecord.MailingState = 'GA';
        contactRecord.MailingPostalCode = '30188';
        contactRecord.genesis__SSN__c = '123121234';

        AccountContactRelation contactRelation = new AccountContactRelation();
        contactRelation.Id = TestUtility.getFakeId(AccountContactRelation.getSObjectType());
        contactRelation.Contact = contactRecord;

        Map<String, Object> matchedContactDetailsByContactId = new Map<String, Object>();
        Set<String> contactIds = new Set<String>();
        contactIds.add(contactRecord.Id);

        CAN_General_Settings__c generalSetting = new CAN_General_Settings__c();
        generalSetting.Id = TestUtility.getFakeId(CAN_General_Settings__c.getSObjectType());
        generalSetting.FinCen_Threshold_Value__c = 85;
        CustomSettingsHelper.generalSettings = generalSetting;

        Test.startTest();
            FinCenRecordMatch.runFinCenReportForContactMatches(contactRelation, fieldNameToContactList, matchedContactDetailsByContactId);
        Test.stopTest();

        Map<String, Object> matchedContact = (Map<String, Object>) matchedContactDetailsByContactId.get(String.valueOf(contactRecord.Id) + '_0');
        System.assertEquals(contactRelation.Contact.FirstName, matchedContact.get('guarantorFirstName'));
    }

    @isTest
    private static void runFinCenReportForException() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        List<Object> fieldNameToContactList = new List<Object>();
        Map<String, String> fieldValueToFields = new Map<String, String>();
        fieldValueToFields.put('first_name', 'Leven');
        fieldValueToFields.put('last_name', 'Troiano');
        fieldValueToFields.put('street', '340 Westover Drive');
        fieldValueToFields.put('city', 'Woodstock');
        fieldValueToFields.put('state', 'GA');
        fieldValueToFields.put('zip', '30188');
        fieldValueToFields.put('number', '123121234');
        fieldValueToFields.put('number_type', 'SSN/ITIN');
        fieldNameToContactList.add(fieldValueToFields);

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.LastName = 'Michael';
        contactRecord.FirstName = 'Andy';
        contactRecord.MailingBuildingNumber__c = '540';
        contactRecord.MailingStreet = '340 Westover Drive';
        contactRecord.MailingCity = 'Woodstock';
        contactRecord.MailingState = 'GA';
        contactRecord.MailingPostalCode = '30188';
        contactRecord.genesis__SSN__c = '123121234';

        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());

        AccountContactRelation contactRelation = new AccountContactRelation();
        contactRelation.Id = TestUtility.getFakeId(AccountContactRelation.getSObjectType());
        contactRelation.Account = accountRecord;
        contactRelation.Contact = contactRecord;

        Map<String, Object> matchedContactDetailsByContactId = new Map<String, Object>();
        Set<String> contactIds = new Set<String>();
        contactIds.add(contactRecord.Id);

        CAN_General_Settings__c generalSetting = new CAN_General_Settings__c();
        generalSetting.Id = TestUtility.getFakeId(CAN_General_Settings__c.getSObjectType());
        generalSetting.FinCen_Threshold_Value__c = 85;
        CustomSettingsHelper.generalSettings = generalSetting;

        Test.startTest();
            FinCenRecordMatch.runFinCenReportForContactMatches(contactRelation, fieldNameToContactList, matchedContactDetailsByContactId);
        Test.stopTest();

        Map<String, Object> matchedContact = (Map<String, Object>) matchedContactDetailsByContactId.get(String.valueOf(contactRecord.Id) + '_0');
        System.assertEquals(contactRelation.Contact.FirstName, matchedContact.get('guarantorFirstName'));
    }

    @isTest
    private static void buildFinCenReport() {
        Map<String, Object> recordMap = new Map<String, Object>();
        recordMap.put('batchNumber', '');
        recordMap.put('runDate', '');
        recordMap.put('recordCount', '');
        recordMap.put('totalSearched', '');
        recordMap.put('totalMatched', '');
        recordMap.put('sourceFile', '');
        recordMap.put('threshold', '');
        recordMap.put('lastName', '');
        recordMap.put('firstName', '');
        recordMap.put('middleName', '');
        recordMap.put('suffix', '');
        recordMap.put('aliasLastName', '');
        recordMap.put('aliasFirstName', '');
        recordMap.put('aliasMiddleName', '');
        recordMap.put('aliasSuffix', '');
        recordMap.put('contactNumber', '');
        recordMap.put('contactNumberType', '');
        recordMap.put('contactDOB', '');
        recordMap.put('contactStreet', '');
        recordMap.put('contactCity', '');
        recordMap.put('contactState', '');
        recordMap.put('contactZip', '');
        recordMap.put('contactCountry', '');
        recordMap.put('contactPhone', '');
        recordMap.put('businessName', '');
        recordMap.put('dbaName', '');
        recordMap.put('businessNumber', '');
        recordMap.put('businessNumberType', '');
        recordMap.put('incorporated', '');
        recordMap.put('businessStreet', '');
        recordMap.put('businessCity', '');
        recordMap.put('businessState', '');
        recordMap.put('businessZip', '');
        recordMap.put('businessCountry', '');
        recordMap.put('businessPhone', '');
        recordMap.put('possibleMatches', '');
        recordMap.put('matchingCriteria', '');
        recordMap.put('borrowerName', '');
        recordMap.put('merchantId', '');
        recordMap.put('legalName', '');
        recordMap.put('legalStreet', '');
        recordMap.put('legalCity', '');
        recordMap.put('legalState', '');
        recordMap.put('legalZip', '');
        recordMap.put('legalCountry', '');
        recordMap.put('legalComment', '');
        recordMap.put('guarantorFirstName', 'Andy');
        recordMap.put('guarantorLastName', 'Mathew');
        recordMap.put('guarantorStreet', '');
        recordMap.put('guarantorCity', '');
        recordMap.put('guarantorState', '');
        recordMap.put('guarantorZip', '');
        recordMap.put('guarantorCountry', '');
        recordMap.put('guarantorDOB', '');
        recordMap.put('guarantorComment', null);

        List<String> csvIndividualRowValues;
        Map<String, String> documentParameters = new Map<String, String> ();
        documentParameters.put('fileName', 'FinCenReportCheck');
        documentParameters.put('recordCount', '25');
        documentParameters.put('totalSearches', '100');
        documentParameters.put('batchNumber', '2353453453');

        Test.startTest();
            csvIndividualRowValues = FinCenRecordMatch.buildFinCenReport('FR-00000001', recordMap, documentParameters);
        Test.stopTest();
        System.assertEquals(57, csvIndividualRowValues.size());
    }

    @isTest
    private static void createFinCenResult() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Map<String, String> documentParameters = new Map<String, String>();
        documentParameters.put('recordCount', '25');
        documentParameters.put('fileName', 'FinCenReportCheck');
        documentParameters.put('totalSearches', '100');

        CAN_General_Settings__c generalSetting = new CAN_General_Settings__c();
        generalSetting.Id = TestUtility.getFakeId(CAN_General_Settings__c.getSObjectType());
        generalSetting.FinCen_Threshold_Value__c = 85;
        CustomSettingsHelper.generalSettings = generalSetting;
        FinCen_Result__c finCenResult;
        Test.startTest();
            finCenResult = FinCenRecordMatch.createFinCenResult(documentParameters);
        Test.stopTest();

        System.assertEquals(GeneralHelper.currentSystemDate, finCenResult.Run_Date__c);
    }

    @isTest
    private static void createFinCenSearchForAccount() {
        Id recordId = TestUtility.getFakeId(Account.getSObjectType());
        FinCen_Search__c finCenSearch;
        String type = 'FinCen Account';
        FinCen_Result__c finCenResult = (FinCen_Result__c) JSON.deserialize (
            '{"Name" : "FR-0000001"}', FinCen_Result__c.class
        );
        finCenResult.Id = TestUtility.getFakeId(FinCen_Result__c.getSObjectType());

        Map<String, Object> recordMap = new Map<String, Object> ();
        recordMap.put('matchingCriteria', 'Name');
        recordMap.put('totalMatched', '1');
        recordMap.put('batchNumber', '305061');
        recordMap.put('businessName', 'SURGERY CENTER');
        recordMap.put('dbaName', 'SURGERY CENTER');
        recordMap.put('incorporated', '');
        recordMap.put('businessStreet', '663 Bryant Boulevard');
        recordMap.put('businessCity', 'Rock Hill');
        recordMap.put('businessState', 'NC');
        recordMap.put('businessZip', '29732');
        recordMap.put('businessCountry', 'US');
        recordMap.put('businessPhone', '');
        recordMap.put('businessNumber', '783960579');
        recordMap.put('businessNumberType', 'EIN');

        Test.startTest();
            finCenSearch = FinCenRecordMatch.createFinCenSearch(finCenResult, String.valueOf(recordId), recordMap, type);
        Test.stopTest();

        System.assertEquals('29732', finCenSearch.Address_Zip__c);
    }

    @isTest
    private static void createFinCenSearchForContact() {
        Id recordId = TestUtility.getFakeId(Account.getSObjectType());
        FinCen_Search__c finCenSearch;
        String type = 'FinCen Contact';
        FinCen_Result__c finCenResult = (FinCen_Result__c) JSON.deserialize (
            '{"Name" : "FR-0000001"}', FinCen_Result__c.class
        );
        finCenResult.Id = TestUtility.getFakeId(FinCen_Result__c.getSObjectType());

        Map<String, Object> recordMap = new Map<String, Object> ();
        recordMap.put('matchingCriteria', 'Name');
        recordMap.put('totalMatched', '1');
        recordMap.put('batchNumber', '305061');
        recordMap.put('suffix', '');
        recordMap.put('firstName', 'Doe');
        recordMap.put('middleName', '');
        recordMap.put('lastName', 'Nathan');
        recordMap.put('aliasFirstName', 'Zuny');
        recordMap.put('aliasLastName', 'Hernandez');
        recordMap.put('aliasMiddleName', '');
        recordMap.put('aliasSuffix', '');
        recordMap.put('contactDOB', '01/01/1962');
        recordMap.put('contactStreet', '8652 MAIN ST');
        recordMap.put('contactCity', 'Holton');
        recordMap.put('contactState', 'MI');
        recordMap.put('contactZip', '494259616');
        recordMap.put('contactCountry', 'US');
        recordMap.put('contactPhone', '');
        recordMap.put('contactNumber', '666183903');
        recordMap.put('contactNumberType', 'SSN/ITIN');

        Test.startTest();
            finCenSearch = FinCenRecordMatch.createFinCenSearch(finCenResult, String.valueOf(recordId), recordMap, type);
        Test.stopTest();

        System.assertEquals('494259616', finCenSearch.Address_Zip__c);
    }
}