@isTest
private class FinCenRecordMatchManagerTests {
    @isTest
    private static void processAccountRecordMatchedWithFinCen() {
        List<Account> accountList = new List<Account> ();
        Map<String, Object> matchedAccountDetailsByAccountId = new Map<String, Object> ();
        List<Object> fieldNameToAccountList = new List<Object>();
        Map<String, String> fieldValueToFields = new Map<String, String>();
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        GeneralHelper.currentSystemDateTime = DateTime.newInstance(GeneralHelper.currentSystemDate, DateTime.Now().Time());

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
        accountList.add(accountRecord);

        fieldValueToFields.put('business_name', 'SURGERY CENTER');
        fieldValueToFields.put('dba_name', 'SURGERY CENTER');
        fieldValueToFields.put('street', '663 BRYANT BLVD');
        fieldValueToFields.put('city', 'Rock Hill');
        fieldValueToFields.put('state', 'NC');
        fieldValueToFields.put('zip', '29732');
        fieldValueToFields.put('number', '783960579');
        fieldNameToAccountList.add(fieldValueToFields);

        CAN_General_Settings__c generalSetting = new CAN_General_Settings__c();
        generalSetting.Id = TestUtility.getFakeId(CAN_General_Settings__c.getSObjectType());
        generalSetting.FinCen_Threshold_Value__c = 85;
        CustomSettingsHelper.generalSettings = generalSetting;

        Test.startTest();
            FinCenRecordMatchManager.processAccountRecordMatchedWithFinCen(accountList, fieldNameToAccountList, matchedAccountDetailsByAccountId);
        Test.stopTest();

        Map<String, Object> matchedAccount = (Map<String, Object>) matchedAccountDetailsByAccountId.get(String.valueOf(accountRecord.Id) + '_0');

        System.assertEquals(accountRecord.Business_Name__c, matchedAccount.get('legalName'));
    }

    @isTest
    private static void processContactRecordMatchedWithFinCen() {
        List<AccountContactRelation> accountContactList = new List<AccountContactRelation>();
        Map<String, String> fieldValueToFields = new Map<String, String>();
        List<Object> fieldNameToContactList = new List<Object>();
        Map<String, Object> matchedContactDetailsByContactId = new Map<String, Object>();
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        GeneralHelper.currentSystemDateTime = DateTime.newInstance(GeneralHelper.currentSystemDate, DateTime.Now().Time());

        fieldValueToFields.put('first_name', 'Andy');
        fieldValueToFields.put('last_name', 'Troiano');
        fieldValueToFields.put('street', '340 Westover Drive');
        fieldValueToFields.put('city', 'Woodstock');
        fieldValueToFields.put('state', 'GA');
        fieldValueToFields.put('zip', '30188');
        fieldValueToFields.put('number', '123121234');
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

        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());

        AccountContactRelation contactRelation = new AccountContactRelation();
        contactRelation.Id = TestUtility.getFakeId(AccountContactRelation.getSObjectType());
        contactRelation.Contact = contactRecord;
        contactRelation.Account = accountRecord;
        accountContactList.add(contactRelation);

        CAN_General_Settings__c generalSetting = new CAN_General_Settings__c();
        generalSetting.Id = TestUtility.getFakeId(CAN_General_Settings__c.getSObjectType());
        generalSetting.FinCen_Threshold_Value__c = 85;
        CustomSettingsHelper.generalSettings = generalSetting;

        Test.startTest();
            FinCenRecordMatchManager.processContactRecordMatchedWithFinCen(accountContactList, fieldNameToContactList, matchedContactDetailsByContactId);
        Test.stopTest();

        Map<String, Object> matchedContact = (Map<String, Object>) matchedContactDetailsByContactId.get(String.valueOf(contactRecord.Id) + '_0');
        System.assertEquals(contactRecord.FirstName, matchedContact.get('guarantorFirstName'));
    }

    @isTest
    private static void finCenReportForForContactAfterExecution() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        GeneralHelper.currentSystemDateTime = DateTime.newInstance(GeneralHelper.currentSystemDate, DateTime.Now().Time());

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());

        Map<String, Object> matchedAccountDetailsByAccountId = new Map<String, Object> ();
        Map<String, Object> matchedContactDetailsByContactId = new Map<String, Object> ();

        Map<String, Object> recordDetailsByField = new Map<String, Object>();
        recordDetailsByField.put('batchNumber', '2342352');
        recordDetailsByField.put('runDate', String.valueOf(GeneralHelper.currentSystemDate));
        recordDetailsByField.put('recordCount', 300);
        recordDetailsByField.put('totalSearched', 900);
        recordDetailsByField.put('totalMatched', 1);
        recordDetailsByField.put('sourceFile', '');
        recordDetailsByField.put('threshold', '90');
        recordDetailsByField.put('lastName', 'Marlene');
        recordDetailsByField.put('firstName', 'Andy');
        recordDetailsByField.put('middleName', '');
        recordDetailsByField.put('suffix', '');
        recordDetailsByField.put('aliasLastName', '');
        recordDetailsByField.put('aliasFirstName', '');
        recordDetailsByField.put('aliasMiddleName', '');
        recordDetailsByField.put('aliasSuffix', '');
        recordDetailsByField.put('contactNumber', '54635654');
        recordDetailsByField.put('contactNumberType', 'SSN');
        recordDetailsByField.put('contactDOB', '10/29/1986');
        recordDetailsByField.put('contactStreet', '340 Westover Drive');
        recordDetailsByField.put('contactCity', 'Woodstock');
        recordDetailsByField.put('contactState', 'GA');
        recordDetailsByField.put('contactZip', '30188');
        recordDetailsByField.put('contactCountry', 'US');
        recordDetailsByField.put('contactPhone', '');

        recordDetailsByField.put('businessName', '');
        recordDetailsByField.put('dbaName', '');
        recordDetailsByField.put('businessNumber', '');
        recordDetailsByField.put('businessNumberType','');
        recordDetailsByField.put('incorporated', '');
        recordDetailsByField.put('businessStreet', '');
        recordDetailsByField.put('businessCity', '');
        recordDetailsByField.put('businessState', '');
        recordDetailsByField.put('businessZip', '');
        recordDetailsByField.put('businessCountry', '');
        recordDetailsByField.put('businessPhone', '');
        recordDetailsByField.put('possibleMatches', 1);
        recordDetailsByField.put('matchingCriteria', 'Address');

        recordDetailsByField.put('borrowerName', '');
        recordDetailsByField.put('merchantId', '');
        recordDetailsByField.put('legalName', '');
        recordDetailsByField.put('legalStreet', '');
        recordDetailsByField.put('legalCity', '');
        recordDetailsByField.put('legalState', '');
        recordDetailsByField.put('legalZip', '');
        recordDetailsByField.put('legalCountry', '');
        recordDetailsByField.put('legalComment', '');
        recordDetailsByField.put('guarantorFirstName', 'Andy');
        recordDetailsByField.put('guarantorLastName', 'Marlene');
        recordDetailsByField.put('guarantorStreet', '340 Westover Drive');
        recordDetailsByField.put('guarantorCity', 'Woodstock');
        recordDetailsByField.put('guarantorState', 'GA');
        recordDetailsByField.put('guarantorZip', '30188');
        recordDetailsByField.put('guarantorCountry', 'US');
        recordDetailsByField.put('guarantorDOB', '');
        recordDetailsByField.put('guarantorComment', '');

        FinCen_Result__c finCenResult = (FinCen_Result__c) JSON.deserialize (
            '{"Name" : "FR-0000001"}', FinCen_Result__c.class
        );
        finCenResult.Id = TestUtility.getFakeId(FinCen_Result__c.getSObjectType());

        Map<String, String> documentParameters = new Map<String, String> ();
        documentParameters.put('fileName', 'FinCenReportCheck');
        documentParameters.put('recordCount', '25');
        documentParameters.put('totalSearches', '100');
        documentParameters.put('batchNumber', '2353453453');

        matchedContactDetailsByContactId.put(String.valueOf(contactRecord.Id), recordDetailsByField);

        CAN_General_Settings__c generalSetting = new CAN_General_Settings__c();
        generalSetting.Id = TestUtility.getFakeId(CAN_General_Settings__c.getSObjectType());
        generalSetting.FinCen_Threshold_Value__c = 85;
        CustomSettingsHelper.generalSettings = generalSetting;

        DBManagerTestsStub documentDBStubInstance = new DBManagerTestsStub();
        FinCenRecordMatchManager.documentDBInstance = (DocumentDB) Test.createStub(DocumentDB.class, documentDBStubInstance);

        DBManagerTestsStub finCenResultDBStubInstance = new DBManagerTestsStub();
        finCenResultDBStubInstance.genericReturnObject = new List<FinCen_Result__c> {finCenResult};
        FinCenRecordMatchManager.finCenResultDBInstance = (FinCenResultDB) Test.createStub(FinCenResultDB.class, finCenResultDBStubInstance);

        DBManagerTestsStub finCenSearchDBStubInstance = new DBManagerTestsStub();
        FinCenRecordMatchManager.finCenSearchDBInstance = (FinCenSearchDB) Test.createStub(FinCenSearchDB.class, finCenSearchDBStubInstance);

        Test.startTest();
            FinCenRecordMatchManager.finCenReportAfterExecution(matchedAccountDetailsByAccountId, matchedContactDetailsByContactId, documentParameters);
        Test.stopTest();

        System.assertEquals(1, documentDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void finCenReportForAccountAfterExecution() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        GeneralHelper.currentSystemDateTime = DateTime.newInstance(GeneralHelper.currentSystemDate, DateTime.Now().Time());
        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());

        Map<String, Object> matchedAccountDetailsByAccountId = new Map<String, Object> ();
        Map<String, Object> matchedContactDetailsByContactId = new Map<String, Object> ();

        Map<String, Object> recordDetailsByField = new Map<String, Object>();
        recordDetailsByField.put('batchNumber', '2342352');
        recordDetailsByField.put('runDate', String.valueOf(GeneralHelper.currentSystemDate));
        recordDetailsByField.put('recordCount', 300);
        recordDetailsByField.put('totalSearched', 900);
        recordDetailsByField.put('totalMatched', 1);
        recordDetailsByField.put('sourceFile', '');
        recordDetailsByField.put('threshold', '90');
        recordDetailsByField.put('lastName', '');
        recordDetailsByField.put('firstName', '');
        recordDetailsByField.put('middleName', '');
        recordDetailsByField.put('suffix', '');
        recordDetailsByField.put('aliasLastName', '');
        recordDetailsByField.put('aliasFirstName', '');
        recordDetailsByField.put('aliasMiddleName', '');
        recordDetailsByField.put('aliasSuffix', '');
        recordDetailsByField.put('contactNumber', '');
        recordDetailsByField.put('contactNumberType', '');
        recordDetailsByField.put('contactDOB', '');
        recordDetailsByField.put('contactStreet', '');
        recordDetailsByField.put('contactCity', '');
        recordDetailsByField.put('contactState', '');
        recordDetailsByField.put('contactZip', '');
        recordDetailsByField.put('contactCountry', '');
        recordDetailsByField.put('contactPhone', '');

        recordDetailsByField.put('businessName', 'SURGERY CENTER');
        recordDetailsByField.put('dbaName', 'SURGERY CENTER');
        recordDetailsByField.put('businessNumber', '783960579');
        recordDetailsByField.put('businessNumberType','TIN');
        recordDetailsByField.put('incorporated', '');
        recordDetailsByField.put('businessStreet', '663 BRYANT BLVD');
        recordDetailsByField.put('businessCity', 'Rock Hill');
        recordDetailsByField.put('businessState', 'NC');
        recordDetailsByField.put('businessZip', '29732');
        recordDetailsByField.put('businessCountry', 'US');
        recordDetailsByField.put('businessPhone', '');
        recordDetailsByField.put('possibleMatches', 1);
        recordDetailsByField.put('matchingCriteria', 'Address');

        recordDetailsByField.put('borrowerName', 'SURGERY CENTER');
        recordDetailsByField.put('merchantId', '3635345');
        recordDetailsByField.put('legalName', 'SURGERY CENTER');
        recordDetailsByField.put('legalStreet', '663 BRYANT BLVD');
        recordDetailsByField.put('legalCity', 'Rock Hill');
        recordDetailsByField.put('legalState', 'NC');
        recordDetailsByField.put('legalZip', '29732');
        recordDetailsByField.put('legalCountry', 'US');
        recordDetailsByField.put('legalComment', '');
        recordDetailsByField.put('guarantorFirstName', '');
        recordDetailsByField.put('guarantorLastName', '');
        recordDetailsByField.put('guarantorStreet', '');
        recordDetailsByField.put('guarantorCity', '');
        recordDetailsByField.put('guarantorState', '');
        recordDetailsByField.put('guarantorZip', '');
        recordDetailsByField.put('guarantorCountry', '');
        recordDetailsByField.put('guarantorDOB', '');
        recordDetailsByField.put('guarantorComment', '');

        CAN_General_Settings__c generalSetting = new CAN_General_Settings__c();
        generalSetting.Id = TestUtility.getFakeId(CAN_General_Settings__c.getSObjectType());
        generalSetting.FinCen_Threshold_Value__c = 85;
        CustomSettingsHelper.generalSettings = generalSetting;

        Folder folderDetail = new Folder();
        folderDetail.Name = GeneralConstants.FOLDER_FINCEN_REPORT;
        folderDetail.Id = TestUtility.getFakeId(Folder.getSObjectType());

        Map<String, Folder> folderByFolderName = new Map<String, Folder>();
        folderByFolderName.put(folderDetail.Name, folderDetail);
        GeneralHelper.folderByFolderName = folderByFolderName;

        FinCen_Result__c finCenResult = (FinCen_Result__c) JSON.deserialize (
            '{"Name" : "FR-0000001"}', FinCen_Result__c.class
        );
        finCenResult.Id = TestUtility.getFakeId(FinCen_Result__c.getSObjectType());

        Document documentFinCenReport = new Document();
        documentFinCenReport.Id = TestUtility.getFakeId(Document.getSObjectType());
        documentFinCenReport.Name = 'FINCEN_REPORT_12';
        documentFinCenReport.DeveloperName = 'FINCEN_REPORT_12';

        Map<String, String> documentParameters = new Map<String, String> ();
        documentParameters.put('fileName', 'FinCenReportCheck');
        documentParameters.put('recordCount', '25');
        documentParameters.put('totalSearches', '100');
        documentParameters.put('batchNumber', '2353453453');

        matchedAccountDetailsByAccountId.put(String.valueOf(accountRecord.Id), recordDetailsByField);

        DBManagerTestsStub documentDBStubInstance = new DBManagerTestsStub();
        documentDBStubInstance.genericReturnObject = new List<Document> {documentFinCenReport};
        FinCenRecordMatchManager.documentDBInstance = (DocumentDB) Test.createStub(DocumentDB.class, documentDBStubInstance);

        DBManagerTestsStub finCenResultDBStubInstance = new DBManagerTestsStub();
        finCenResultDBStubInstance.genericReturnObject = new List<FinCen_Result__c> {finCenResult};
        FinCenRecordMatchManager.finCenResultDBInstance = (FinCenResultDB) Test.createStub(FinCenResultDB.class, finCenResultDBStubInstance);

        DBManagerTestsStub finCenSearchDBStubInstance = new DBManagerTestsStub();
        FinCenRecordMatchManager.finCenSearchDBInstance = (FinCenSearchDB) Test.createStub(FinCenSearchDB.class, finCenSearchDBStubInstance);

        Test.startTest();
            FinCenRecordMatchManager.finCenReportAfterExecution(matchedAccountDetailsByAccountId, matchedContactDetailsByContactId, documentParameters);
        Test.stopTest();

        System.assertEquals(1, documentDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void finCenReportForNoRecordAfterExecution() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        GeneralHelper.currentSystemDateTime = DateTime.newInstance(GeneralHelper.currentSystemDate, DateTime.Now().Time());
        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());

        Map<String, Object> matchedAccountDetailsByAccountId = new Map<String, Object> ();
        Map<String, Object> matchedContactDetailsByContactId = new Map<String, Object> ();

        Map<String, Object> recordDetailsByField = new Map<String, Object>();

        Folder folderDetail = new Folder();
        folderDetail.Name = GeneralConstants.FOLDER_FINCEN_REPORT;
        folderDetail.Id = TestUtility.getFakeId(Folder.getSObjectType());

        Map<String, Folder> folderByFolderName = new Map<String, Folder>();
        folderByFolderName.put(folderDetail.Name, folderDetail);
        GeneralHelper.folderByFolderName = folderByFolderName;

        Document documentFinCenReport = new Document();
        documentFinCenReport.Id = TestUtility.getFakeId(Document.getSObjectType());
        documentFinCenReport.Name = 'FINCEN_REPORT_12';
        documentFinCenReport.DeveloperName = 'FINCEN_REPORT_12';

        Map<String, String> documentParameters = new Map<String, String> ();
        documentParameters.put('fileName', 'FinCenReportCheck');
        documentParameters.put('recordCount', '25');
        documentParameters.put('totalSearches', '100');
        documentParameters.put('batchNumber', '2353453453');

        DBManagerTestsStub documentDBStubInstance = new DBManagerTestsStub();
        documentDBStubInstance.genericReturnObject = new List<Document> {documentFinCenReport};
        FinCenRecordMatchManager.documentDBInstance = (DocumentDB) Test.createStub(DocumentDB.class, documentDBStubInstance);

        CAN_General_Settings__c generalSetting = new CAN_General_Settings__c();
        generalSetting.Id = TestUtility.getFakeId(CAN_General_Settings__c.getSObjectType());
        generalSetting.FinCen_Threshold_Value__c = 85;
        CustomSettingsHelper.generalSettings = generalSetting;

        Test.startTest();
            FinCenRecordMatchManager.finCenReportAfterExecution(matchedAccountDetailsByAccountId, matchedContactDetailsByContactId, documentParameters);
        Test.stopTest();

        System.assertEquals(1, documentDBStubInstance.forInsertSObjects.size());
    }
}