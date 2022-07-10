@isTest(isParallel=true)

    private class UCCFilingsTests {

        @isTest
        private static void createUCCRecord() {
            Account accountRecord = new Account();
            accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());
            accountRecord.UCC_Order_Number__c = '99999';

            Test.startTest();
            UCC_Filing_Detail__c uccFiling = UCCFilings.createUCCRecord(accountRecord);
            Test.stopTest();

            System.assertEquals(accountRecord.Id, uccFiling.Account__c);
        }

        @isTest
        private static void createUCCValidationLog() {
            UCC_Filing_Detail__c uccFilingDetail = new UCC_Filing_Detail__c();
            uccFilingDetail.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
            String validationMessage = 'DummyValidationMessage';

            Test.startTest();
            UCC_Validation_Log__c validationLog = UCCFilings.createUCCValidationLog(uccFilingDetail, validationMessage);
            Test.stopTest();

            System.assertEquals(uccFilingDetail.Id, validationLog.UCC_Filing_Detail__c);
        }

        @isTest
        private static void validateDateString() {
            String stringDate = '0001-10-10T14:48:00.000+09:00';

            Test.startTest();
            String validateStringDate = UCCFilings.validateStringValue(stringDate);
            Test.stopTest();

            System.assert(validateStringDate != null);
        }

        @isTest
        private static void isTerminateChanged() {
            UCC_Filing_Detail__c newUCCFilingDetail = new UCC_Filing_Detail__c();
            newUCCFilingDetail.Is_Terminated__c = true;

            UCC_Filing_Detail__c oldUccFilingDetail = new UCC_Filing_Detail__c();
            oldUccFilingDetail.Is_Terminated__c = false;

            Test.startTest();
            Boolean isTerminateChangedRecord = UCCFilings.isTerminateChanged(newUCCFilingDetail, oldUccFilingDetail);
            Test.stopTest();

            System.assert(isTerminateChangedRecord);
        }

        @isTest
        private static void setAccountAndUCCValues() {
            UCC_Filing_Detail__c uccFilingDetail = new UCC_Filing_Detail__c();
            Account accountRecord = new Account();

            Map<String, String> uccFilingResponseMap = new Map<String, String>();
            uccFilingResponseMap.put('FilerNamesOrganizationName0', 'ON');
            uccFilingResponseMap.put('FilerNamesMailAddress0', 'MA');
            uccFilingResponseMap.put('FilerNamesCity0', 'C');
            uccFilingResponseMap.put('FilerNamesState0', 'S');
            uccFilingResponseMap.put('FilerNamesPostalCode0', 'PostalCodes');
            uccFilingResponseMap.put('FilerClientAccountNum0', 'CAN');
            uccFilingResponseMap.put('FilerContactName0', 'CN');
            uccFilingResponseMap.put('FilerContactPhone0', 'CP');
            uccFilingResponseMap.put('FilerContactEmail0', 'CE');
            uccFilingResponseMap.put('FilerContactFax0', 'CF');
            uccFilingResponseMap.put('OrderInfoOrderID0', '1234567');
            uccFilingResponseMap.put('OrderInfoCreateDate0', '0001-10-10T14:48:00.000+09:00');
            uccFilingResponseMap.put('OrderInfoParentOrderID0', '1234567');
            uccFilingResponseMap.put('OrderInfoAccountID0', 'AID');
            uccFilingResponseMap.put('OrderInfoOrderStatus0', 'OS');
            uccFilingResponseMap.put('OrderInfoFilingNumber0', 'FUN');
            uccFilingResponseMap.put('OrderInfoFilingDate0', '0001-10-10T14:48:00.000+09:00');
            uccFilingResponseMap.put('OrderInfoExpirationDate0', '0001-10-10T14:48:00.000+09:00');
            uccFilingResponseMap.put('OrderInfoOriginalFilingNumber0', 'OFN');
            uccFilingResponseMap.put('OrderInfoOriginalFilingDate0', '0001-10-10T14:48:00.000+09:00');
            uccFilingResponseMap.put('OrderInfoApproveDate0', '0001-10-10T14:48:00.000+09:00');
            uccFilingResponseMap.put('OrderInfoCompleteDate0', '0001-10-10T14:48:00.000+09:00');
            uccFilingResponseMap.put('DebtorNameNamesOrganizationName0', 'OrgaNa');
            uccFilingResponseMap.put('DebtorNameNamesMailAddress0', 'Mad');
            uccFilingResponseMap.put('DebtorNameNamesCity0', 'Ci');
            uccFilingResponseMap.put('DebtorNameNamesState0', 'St');
            uccFilingResponseMap.put('DebtorNameNamesPostalCode0', 'PostalCodes');
            uccFilingResponseMap.put('DebtorNameNamesCountry0', 'Cou');
            uccFilingResponseMap.put('IndividualNameLastName0', 'LN');
            uccFilingResponseMap.put('IndividualNameFirstName0', 'FiN');
            uccFilingResponseMap.put('IndividualNameMiddleName0', 'MN');
            uccFilingResponseMap.put('IndividualNameSuffix0', 'Suf');
            uccFilingResponseMap.put('DebtorNameNamesMailAddress1', 'MailAdd');
            uccFilingResponseMap.put('DebtorNameNamesCity1', 'Cit');
            uccFilingResponseMap.put('DebtorNameNamesState1', 'Sta');
            uccFilingResponseMap.put('DebtorNameNamesCountry1', 'Coutr');
            uccFilingResponseMap.put('DebtorNameNamesPostalCode1', 'PostalCode');
            uccFilingResponseMap.put('SecuredNameNamesOrganizationName0', 'Organiz');
            uccFilingResponseMap.put('SecuredNameNamesMailAddress0', 'MailAd');
            uccFilingResponseMap.put('SecuredNameNamesCity0', 'Cityy');
            uccFilingResponseMap.put('SecuredNameNamesState0', 'States');
            uccFilingResponseMap.put('SecuredNameNamesPostalCode0', 'PostalCodes');
            uccFilingResponseMap.put('SecuredNameNamesCountry0', 'Countryy');

            Test.startTest();
            UCCFilings.setAccountAndUCCValues(uccFilingDetail, accountRecord, uccFilingResponseMap);
            Test.stopTest();

            System.assertEquals(accountRecord.Id, uccFilingDetail.Account__c);
        }

        @isTest
        private static void setAccountAndUCCValuesFilingDate() {
            UCC_Filing_Detail__c uccFilingDetail = new UCC_Filing_Detail__c();
            Account accountRecord = new Account();

            Map<String, String> uccFilingResponseMap = new Map<String, String>();
            uccFilingResponseMap.put('OrderInfoFilingDate0', '0001-10-10T14:48:00.000+09:00');

            Test.startTest();
            UCCFilings.setAccountAndUCCValues(uccFilingDetail, accountRecord, uccFilingResponseMap);
            Test.stopTest();

            System.assertEquals(accountRecord.Id, uccFilingDetail.Account__c);
        }

        @isTest
        private static void setAccountAndUCCValuesExpirationDate() {
            UCC_Filing_Detail__c uccFilingDetail = new UCC_Filing_Detail__c();
            Account accountRecord = new Account();

            Map<String, String> uccFilingResponseMap = new Map<String, String>();
            uccFilingResponseMap.put('OrderInfoExpirationDate0', '0001-10-10T14:48:00.000+09:00');

            Test.startTest();
            UCCFilings.setAccountAndUCCValues(uccFilingDetail, accountRecord, uccFilingResponseMap);
            Test.stopTest();

            System.assertEquals(accountRecord.Id, uccFilingDetail.Account__c);
        }

        @isTest
        private static void setAccountAndUCCValuesOriginalFilingDate() {
            UCC_Filing_Detail__c uccFilingDetail = new UCC_Filing_Detail__c();
            Account accountRecord = new Account();

            Map<String, String> uccFilingResponseMap = new Map<String, String>();
            uccFilingResponseMap.put('OrderInfoOriginalFilingDate0', '0001-10-10T14:48:00.000+09:00');

            Test.startTest();
            UCCFilings.setAccountAndUCCValues(uccFilingDetail, accountRecord, uccFilingResponseMap);
            Test.stopTest();

            System.assertEquals(accountRecord.Id, uccFilingDetail.Account__c);
        }

        @isTest
        private static void setAccountAndUCCValuesApproveDate() {
            UCC_Filing_Detail__c uccFilingDetail = new UCC_Filing_Detail__c();
            Account accountRecord= new Account();

            Map<String, String> uccFilingResponseMap = new Map<String, String>();
            uccFilingResponseMap.put('OrderInfoApproveDate0', '0001-10-10T14:48:00.000+09:00');

            Test.startTest();
            UCCFilings.setAccountAndUCCValues(uccFilingDetail, accountRecord, uccFilingResponseMap);
            Test.stopTest();

            System.assertEquals(accountRecord.Id, uccFilingDetail.Account__c);
        }

        @isTest
        private static void setAccountAndUCCValuesCompleteDate() {
            UCC_Filing_Detail__c uccFilingDetail = new UCC_Filing_Detail__c();
            Account accountRecord = new Account();

            Map<String, String> uccFilingResponseMap = new Map<String, String>();
            uccFilingResponseMap.put('OrderInfoCompleteDate0', '0001-10-10T14:48:00.000+09:00');

            Test.startTest();
            UCCFilings.setAccountAndUCCValues(uccFilingDetail, accountRecord, uccFilingResponseMap);
            Test.stopTest();

            System.assertEquals(accountRecord.Id, uccFilingDetail.Account__c);
        }

        @isTest
        private static void prepareUCCFilingIdToModelValueResponseMap() {
            UCC_Filing_Detail__c uccFilingDetail = new UCC_Filing_Detail__c();
            uccFilingDetail.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());

            List<String> responseValueList = new List<String>();
            responseValueList.add('FilerNamesOrganizationName');
            responseValueList.add('FilerNamesState');
            responseValueList.add('IndividualNameLastName');

            Map<String, List<String>> ModelToResponseValueListMap = new Map<String, List<String>>();
            ModelToResponseValueListMap.put('FilerNamesOrganizationName0', responseValueList);
            ModelToResponseValueListMap.put('FilerNamesState0', responseValueList);
            ModelToResponseValueListMap.put('IndividualNameLastName0', responseValueList);

            Map<Id, Map<String, List<String>>> uCCFilingIdToModelValueResponseMap = new Map<Id, Map<String, List<String>>>();
            uCCFilingIdToModelValueResponseMap.put(uccFilingDetail.Id, ModelToResponseValueListMap);

            Map<Id, Map<String, String>> prepareUCCFilingIdToModelValueResponse = new Map<Id, Map<String, String>>();

            Test.startTest();
            	prepareUCCFilingIdToModelValueResponse = UCCFilings.prepareUCCFilingIdToModelValueResponseMap(uCCFilingIdToModelValueResponseMap);
            Test.stopTest();

            System.assert(!prepareUCCFilingIdToModelValueResponse.isEmpty());
        }

        @isTest
        private static void validateStringValue() {
            Test.startTest();
            String newValues = UCCFilings.validateStringValue(null);
            Test.stopTest();

            System.assertEquals(null, newValues);
        }

        @isTest
        private static void validateStringValue1() {
            Test.startTest();
            String newValues = UCCFilings.validateStringValue('DUM'+''+'MMY');
            Test.stopTest();

            System.assertEquals('DUMMMY', newValues);
        }

        @isTest
        private static void setContinuationFields() {
            UCC_Filing_Detail__c uccFilingDetail = new UCC_Filing_Detail__c();
            uccFilingDetail.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());

            Map<String,String> uccFilingResponseMapTest = new Map<String,String>();
            uccFilingResponseMapTest.put('OrderID0', '1234567');

            Test.startTest();
            UCCFilings.setContinuationFields(uccFilingDetail, uccFilingResponseMapTest);
            Test.stopTest();

            System.assertEquals('1234567', uccFilingDetail.Order_ID__c);
        }

        @isTest
        private static void prepareModelValueResponseMap() {
            String uccFilingModelTest = 'DummyString';

            List<String> uccFilingModelValues = new List<String>();
            uccFilingModelValues.add('Dummy0');

            Map<String, String> uccFilingMap = new Map<String, String>();

            Map<String, String> uccFilingResponse = new Map<String, String>();
            uccFilingResponse.put(uccFilingModelTest+0, 'Dummy0');

            Test.startTest();
            	Map<String, String> uccFilingResponseMap = UCCFilings.prepareModelValueResponseMap(uccFilingModelTest, uccFilingModelValues, uccFilingMap);
            Test.stopTest();

            System.assertEquals(uccFilingResponse, uccFilingResponseMap);
        }

        @isTest
        private static void createNotes() {

            UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
            uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());

            UCC_Notes__c uccNotesTest = new UCC_Notes__c();
            uccNotesTest.Id = TestUtility.getFakeId(UCC_Notes__c.getSObjectType());
            String notesDescriptionMap = 'NoteDescription';
            String notesCreatedDateMap = 'NoteCreateDate';
            String testDate = '0001-10-10T14:48:00.000+09:00';

            Map<String, String> uccFilingResponseMap = new Map<String, String>();
            uccFilingResponseMap.put(notesDescriptionMap, testDate);
            uccFilingResponseMap.put(notesCreatedDateMap, testDate);

            List<String> existingUCCNoteDescriptions = new List<String>();
            existingUCCNoteDescriptions.add('NoteDescription');

            List<UCC_Notes__c> uccNotes = new List<UCC_Notes__c>();

            Test.startTest();
            	uccNotes = UCCFilings.createNotes(uccFiling.Id, uccFilingResponseMap, existingUCCNoteDescriptions);
            Test.stopTest();

            System.assert(uccNotes != null);
        }

        @isTest
        private static void createUCCRecords() {
            String jurisdictionID = '1234567';

            String jurisdictionName = 'Dummy';

            Map<Id, Id> contractIdToAccountIdMap = new Map<Id,Id>();
            Map<Id, Account> accountMap = new Map<Id, Account>();

            clcommon__Legal_Entity__c legalEntity = new clcommon__Legal_Entity__c();
            legalEntity.Id = TestUtility.getFakeId(clcommon__Legal_Entity__c.getSObjectType());

            Account account = new Account();
            account.Id = TestUtility.getFakeId(Account.getSObjectType());
            account.clcommon__Legal_Entity_Type__c = legalEntity.Id;
            account.Legal_Name__c = 'Sole Proprietorship';
            account.BillingState = 'GA';
            account.BillingStreet = 'DS';
            account.BillingCity = 'Dc';
            account.BillingPostalCode = '123456';
            account.BillingCountry = 'USA';

            loan__Loan_Account__c contract = new loan__Loan_Account__c();
            contract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

            JurisdictionID_To_Name_Mapping__mdt jurisdictionIDToNameMappingTest = new JurisdictionID_To_Name_Mapping__mdt();
            jurisdictionIDToNameMappingTest.Jurisdiction_ID__c = '1234567';
            jurisdictionIDToNameMappingTest.DeveloperName = 'DummyName';
            jurisdictionIDToNameMappingTest.State__c = 'GA';

            accountMap.put(account.Id, account);
            contractIdToAccountIdMap.put(contract.Id, account.Id);

            Map<String, JurisdictionID_To_Name_Mapping__mdt> jurisdictionIDToNameMapping = new Map<String, JurisdictionID_To_Name_Mapping__mdt>();
            jurisdictionIDToNameMapping.put('GA', jurisdictionIDToNameMappingTest);

            UCC_Setting__mdt uccDetails = new UCC_Setting__mdt();
            uccDetails.Filer_State__c = 'DummyString';
            uccDetails.Secured_Organization_Name__c = 'Org';
            uccDetails.Secured_MailAddress__c = 'MA';
            uccDetails.Secured_City__c = 'SC';
            uccDetails.Secured_Country__c = 'SCO';
            uccDetails.Secured_State__c = 'CA';
            uccDetails.Secured_postalCode__c = '123456';
            uccDetails.Filer_Contact_Fax__c = '123456';
            uccDetails.Filer_Contact_Name__c = 'DummyName';
            uccDetails.Filer_Contact_Phone__c = '1234567890';
            uccDetails.Filer_Mail_Address__c = 'FM';
            uccDetails.Filer_Organization_Name__c = 'org';
            uccDetails.Filer_PostalCode__c = '098765';
            uccDetails.Filer_City__c = 'DummyCity';

            DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
            accountDBStubInstance.genericReturnObject = new List<Account> {account};
            UCCFilingManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

            DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
            clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{contract};
            UCCFilingManager.contractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

            Test.startTest();
            	UCC_Filing_Detail__c uCCFilingDetail = UCCFilings.createUCCRecords(contractIdToAccountIdMap, contract, accountMap, uccDetails, jurisdictionIDToNameMapping, jurisdictionID, jurisdictionName);
            Test.stopTest();

            System.assertEquals(uccDetails.Secured_postalCode__c, uCCFilingDetail.Secured_postalCode__c);
        }

        @isTest
        private static void forStateFlorida() {
            Map<Id, Id> contractIdToAccountIdMap = new Map<Id,Id>();
            Map<Id, Account> accountMap = new Map<Id, Account>();

            clcommon__Legal_Entity__c legalEntity = new clcommon__Legal_Entity__c();
            legalEntity.Id = TestUtility.getFakeId(clcommon__Legal_Entity__c.getSObjectType());
            legalEntity.clcommon__Legal_Entity_Type__c = 'Sole Proprietorship';
            legalEntity.Name = 'Sole Proprietorship';

            Account account = new Account();
            account.Id = TestUtility.getFakeId(Account.getSObjectType());
            account.clcommon__Legal_Entity_Type__c = legalEntity.Id;
            account.Legal_Name__c = 'Sole Proprietorship';
            account.BillingState = 'FL';
            account.BillingStreet = 'DS';
            account.BillingCity = 'Dc';
            account.BillingPostalCode = '123456';
            account.BillingCountry = 'USA';

            Map<String, JurisdictionID_To_Name_Mapping__mdt> jurisdictionIDToNameMapping = new Map<String, JurisdictionID_To_Name_Mapping__mdt>();
            JurisdictionID_To_Name_Mapping__mdt jurisdictionIDToNameMappingTest = new JurisdictionID_To_Name_Mapping__mdt();
            jurisdictionIDToNameMappingTest.Jurisdiction_ID__c = '1234567';
            jurisdictionIDToNameMappingTest.DeveloperName = 'DummyName';
            jurisdictionIDToNameMappingTest.State__c = 'AndhraPradesh';
            jurisdictionIDToNameMapping.put('FL', jurisdictionIDToNameMappingTest);

            loan__Loan_Account__c contract = new loan__Loan_Account__c();
            contract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

            accountMap.put(account.Id, account);
            contractIdToAccountIdMap.put( contract.Id, account.Id);

            UCC_Setting__mdt uccDetails = new UCC_Setting__mdt();
            uccDetails.Filer_State__c = 'DummyString';
            uccDetails.Secured_Organization_Name__c = 'Org';
            uccDetails.Secured_MailAddress__c = 'MA';
            uccDetails.Secured_City__c = 'SC';
            uccDetails.Secured_Country__c = 'SCO';
            uccDetails.Secured_State__c = 'CA';
            uccDetails.Secured_postalCode__c = '123456';
            uccDetails.Filer_Contact_Fax__c = '123456';
            uccDetails.Filer_Contact_Name__c = 'DummyName';
            uccDetails.Filer_Contact_Phone__c = '1234567890';
            uccDetails.Filer_Mail_Address__c = 'FM';
            uccDetails.Filer_Organization_Name__c = 'org';
            uccDetails.Filer_PostalCode__c = '098765';
            uccDetails.Filer_City__c = 'DummyCity';

            DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
            accountDBStubInstance.genericReturnObject = new List<Account> {account};
            UCCFilingManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

            DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
            clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{contract};
            UCCFilingManager.contractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

            Test.startTest();
            	UCC_Filing_Detail__c uCCFilingDetailTest = UCCFilings.createUCCRecords(contractIdToAccountIdMap, contract, accountMap, uccDetails, jurisdictionIDToNameMapping, '1234567', 'Dummy');
            Test.stopTest();

            System.assertEquals(uccDetails.Secured_Organization_Name__c, uCCFilingDetailTest.Secured_Organization_Name__c);
        }

        @isTest
        private static void forStateNewJersey() {
            Map<Id, Id> contractIdToAccountIdMap = new Map<Id,Id>();
            Map<Id, Account> accountMap = new Map<Id, Account>();

            clcommon__Legal_Entity__c legalEntity = new clcommon__Legal_Entity__c();
            legalEntity.Id = TestUtility.getFakeId(clcommon__Legal_Entity__c.getSObjectType());
            legalEntity.clcommon__Legal_Entity_Type__c = 'Sole Proprietorship';
            legalEntity.Name = 'Sole Proprietorship';

            Account account = new Account();
            account.Id = TestUtility.getFakeId(Account.getSObjectType());
            account.clcommon__Legal_Entity_Type__c = legalEntity.Id;
            account.Legal_Name__c = 'Sole Proprietorship';
            account.BillingState = 'NJ';
            account.BillingStreet = 'DS';
            account.BillingCity = 'Dc';
            account.BillingPostalCode = '123456';
            account.BillingCountry = 'USA';

            genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
                '{ "Business_Type__c" : "Sole Proprietorship"}' , genesis__Applications__c.class
            );
            application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

            Map<String, JurisdictionID_To_Name_Mapping__mdt> jurisdictionIDToNameMapping = new Map<String, JurisdictionID_To_Name_Mapping__mdt>();
            JurisdictionID_To_Name_Mapping__mdt jurisdictionIDToNameMappingTest = new JurisdictionID_To_Name_Mapping__mdt();
            jurisdictionIDToNameMappingTest.Jurisdiction_ID__c = '1234567';
            jurisdictionIDToNameMappingTest.DeveloperName = 'DummyName';
            jurisdictionIDToNameMappingTest.State__c = 'AndhraPradesh';
            jurisdictionIDToNameMapping.put('NJ', jurisdictionIDToNameMappingTest);

            loan__Loan_Account__c contract = new loan__Loan_Account__c();
            contract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
            contract.Application__c = application.Id;

            accountMap.put(account.Id, account);
            contractIdToAccountIdMap.put( contract.Id, account.Id);

            UCC_Setting__mdt uccDetails = new UCC_Setting__mdt();
            uccDetails.Filer_State__c = 'DummyString';
            uccDetails.Secured_Organization_Name__c = 'Org';
            uccDetails.Secured_MailAddress__c = 'MA';
            uccDetails.Secured_City__c = 'SC';
            uccDetails.Secured_Country__c = 'SCO';
            uccDetails.Secured_State__c = 'CA';
            uccDetails.Secured_postalCode__c = '123456';
            uccDetails.Filer_Contact_Fax__c = '123456';
            uccDetails.Filer_Contact_Name__c = 'DummyName';
            uccDetails.Filer_Contact_Phone__c = '1234567890';
            uccDetails.Filer_Mail_Address__c = 'FM';
            uccDetails.Filer_Organization_Name__c = 'org';
            uccDetails.Filer_PostalCode__c = '098765';
            uccDetails.Filer_City__c = 'DummyCity';

            DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
            accountDBStubInstance.genericReturnObject = new List<Account> {account};
            UCCFilingManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

            DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
            clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{contract};
            UCCFilingManager.contractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

            Test.startTest();
            	UCC_Filing_Detail__c uCCFilingDetailTest = UCCFilings.createUCCRecords(contractIdToAccountIdMap, contract, accountMap, uccDetails, jurisdictionIDToNameMapping, '1234567', 'Dummy');
            Test.stopTest();

            System.assertEquals(uccDetails.Secured_Organization_Name__c, uCCFilingDetailTest.Secured_Organization_Name__c);
        }

        @isTest
        private static void isUCCContinued() {
            UCC_Filing_Detail__c newUCCFilingDetail = new UCC_Filing_Detail__c();
            newUCCFilingDetail.Is_UCC_Continued__c = true;

            UCC_Filing_Detail__c oldUccFilingDetail = new UCC_Filing_Detail__c();
            oldUccFilingDetail.Is_UCC_Continued__c = false;

            Test.startTest();
            	Boolean isUCCContinuedRecord = UCCFilings.isUCCContinued(newUCCFilingDetail, oldUccFilingDetail);
            Test.stopTest();

            System.assert(isUCCContinuedRecord);
        }

        @isTest
        private static void getUCCAttachmentIDs() {
            UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();

            UCC_Setting__mdt uccDetails = new UCC_Setting__mdt();
            uccDetails.Filer_State__c = 'DummyString';

            Map<String, String> uccFilingResponseMap = new Map<String, String>();
            uccFilingResponseMap.put('OrderInfoOrderStatus0', 'OS');

            Test.startTest();
            	UCCFilings.getUCCAttachmentIDs(uccFiling, uccFilingResponseMap);
            Test.stopTest();

            System.assertEquals(uccDetails.Secured_Organization_Name__c, uccFiling.Secured_Organization_Name__c);
        }

        @isTest
        private static void setUCCAttachmentLinks() {
            UCC_Filing_Attachment__c uccFilingAttachment = new UCC_Filing_Attachment__c();
            uccFilingAttachment.Id = TestUtility.getFakeId(UCC_Filing_Attachment__c.getSObjectType());

            Map<String, String> uccFilingResponseMap = new Map<String, String>();
            uccFilingResponseMap.put('AttachmentURL0', 'AU');

            String setUCCAttachmentLinks;

            Test.startTest();
            	setUCCAttachmentLinks = UCCFilings.setUCCAttachmentLinks(uccFilingAttachment, uccFilingResponseMap);
            Test.stopTest();

            System.assert(setUCCAttachmentLinks != null);
        }

        @isTest
        private static void getUCCAttachments() {
            UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();

            Set<String> uccAttachmentIDs = new Set<String>{'80659412', '80659837'};
            Map<String, String> uccFilingResponseMap = new Map<String, String>();
            uccFilingResponseMap.put('AttachmentAttachmentID', 'AttachmentDescription');

            List<UCC_Filing_Attachment__c> uccFilingAttachment = new List<UCC_Filing_Attachment__c>();

            Test.startTest();
                uccFilingAttachment = UCCFilings.getUCCAttachments(uccFiling, uccFilingResponseMap, uccAttachmentIDs);
            Test.stopTest();

            System.assert(uccFilingAttachment != null);
        }

        @isTest
        private static void getUCCAttachmentsNull() {
            UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();

            Set<String> uccAttachmentIDs = new Set<String>{'80659412', '80659837'};
            Map<String, String> uccFilingResponseMap = new Map<String, String>();
            uccFilingResponseMap.put('AttachmentDescription', null);

            List<UCC_Filing_Attachment__c> uccFilingAttachment = new List<UCC_Filing_Attachment__c>();

            Test.startTest();
                uccFilingAttachment = UCCFilings.getUCCAttachments(uccFiling, uccFilingResponseMap, uccAttachmentIDs);
            Test.stopTest();

            System.assert(uccFilingAttachment != null);
        }

        @isTest
        private static void getExistingUCCNotes() {
            List<UCC_Notes__c> existingUCCNotes = new List<UCC_Notes__c>();

            UCC_Notes__c uccNotes = new UCC_Notes__c();
            uccNotes.Id = TestUtility.getFakeId(UCC_Notes__c.getSObjectType());

            List<String> DescriptionList = new List<String>();
            DescriptionList.add('DummyDescription');

            UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
            uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());

            Map<Id, List<String>> uccFilingIdToDescriptionList = new  Map<Id, List<String>>();
            uccFilingIdToDescriptionList.put(uccFiling.Id, DescriptionList);

            Map<Id, List<String>> existingUCCNote = new Map<Id, List<String>>();

            Test.startTest();
            	existingUCCNote = UCCFilings.getExistingUCCNotes(existingUCCNotes);
            Test.stopTest();

            System.assert(existingUCCNote != null);
        }
    }