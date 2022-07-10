@isTest
private class UCCFilingManagerTests {
    @isTest
    private static void getContractIdForUCCTests() {

        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountRecord.UCC_Status__c = 'None';
        accountRecord.UCC_Opt_Out__c = False;
        accountRecord.Current_Active_Contract_Number__c = 'LAI-0001';
        accountRecord.BillingState = UCCFilings.STATE_GEORGIA;

        loan__Loan_Account__c contract = (loan__Loan_Account__c) JSON.deserialize(
            '{"Name" : "LAI-0001"}' , loan__Loan_Account__c.class
        );
        contract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        contract.loan__Disbursed_Amount__c = 20000;
        contract.loan__Account__c = accountRecord.Id;
        contract.loan__Account__r = accountRecord;

        CAN_General_Settings__c canGeneralSettings = new CAN_General_Settings__c();
        canGeneralSettings.Id = TestUtility.getFakeId(CAN_General_Settings__c.getSObjectType());
        canGeneralSettings.UCC_Filing_Eligible_Amount__c = 30;
        CustomSettingsHelper.generalSettings = canGeneralSettings;

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {accountRecord};
        UCCFilingManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub contractDBStubInstance = new DBManagerTestsStub();
        contractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c> {contract};
        UCCFilingManager.contractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, contractDBStubInstance);

        System.Test.setMock(HttpCalloutMock.class, new UCCCalloutMock.UCCCalloutMockGetPlaceID());

        Map<String, JurisdictionID_To_Name_Mapping__mdt> jurisdictionIDToNameMapping= new Map<String, JurisdictionID_To_Name_Mapping__mdt>();
        JurisdictionID_To_Name_Mapping__mdt jurisdictionIDToName = new JurisdictionID_To_Name_Mapping__mdt();
        //jurisdictionIDToNameMapping.Jurisdiction_ID__c = null;
        //jurisdictionIDToNameMapping.DeveloperName = null;
        jurisdictionIDToNameMapping.put('Name', jurisdictionIDToName);
        CustomMetaDataHelper.jurisdictionIDToNameMapping = jurisdictionIDToNameMapping;

        Test.startTest();
            UCCFilingManager.getContractIdForUCC(accountRecord.Id);
        Test.stopTest();

        System.assertEquals(0, accountDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void createFilingTests(){

        Set<Id> contractIds = new Set<Id>();

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        loan__Loan_Account__c loanAccount = (loan__Loan_Account__c) JSON.deserialize(
            '{"BilingState" : "GA"}' , loan__Loan_Account__c.class
        );
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccount.loan__Account__c = account.Id;
        contractIds.add(loanAccount.Id);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {account};
        UCCFilingManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub contractDBStubInstance = new DBManagerTestsStub();
        contractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c> {loanAccount};
        UCCFilingManager.contractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, contractDBStubInstance);

        DBManagerTestsStub errorDBStubInstance = new DBManagerTestsStub();
        UCCFilingManager.ErrorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, ErrorDBStubInstance);

        DBManagerTestsStub uccFilingDBStubInstance = new DBManagerTestsStub();
        UCCFilingManager.UCCFilingDBInstance = (UCCFilingDB) Test.createStub(UCCFilingDB.class, UCCFilingDBStubInstance);

        System.Test.setMock(HttpCalloutMock.class, new UCCCalloutMock.UCCCallOutMockCreateFiling());

        Test.startTest();
            UCCFilingManager.createUCCFiling(contractIds);
        Test.stopTest();

        System.assertEquals(1, errorDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void getOrderInformationOnClickTests(){

        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());

        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        uccFiling.Account__c = accountRecord.Id;
        uccFiling.Order_ID__c = '153405863';

        DBManagerTestsStub uCCFilingDBStubInstance = new DBManagerTestsStub();
        uCCFilingDBStubInstance.genericReturnObject = new List<UCC_Filing_Detail__c> {uccFiling};
        UCCFilingManager.UCCFilingDBInstance = (UCCFilingDB) Test.createStub(UCCFilingDB.class, UCCFilingDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {accountRecord};
        UCCFilingManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        System.Test.setMock(HttpCalloutMock.class, new UCCCalloutMock.UCCCalloutMockGetOrderInformationByUCCFilingDetail());

        Test.startTest();
            UCCFilingManager.getOrderInformationOnClick(accountRecord.Id);
        Test.stopTest();

        System.assertEquals(1, uCCFilingDBStubInstance.forUpdateSObjects.size());
        System.assertEquals(1, accountDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void getOrderInformationTests(){
        Set<Id> accountIds = new Set<Id>();

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        uccFiling.Account__c = account.Id;
        accountIds.add(account.Id);

        DBManagerTestsStub uCCFilingDBStubInstance = new DBManagerTestsStub();
        uCCFilingDBStubInstance.genericReturnObject = new List<UCC_Filing_Detail__c> {uccFiling};
        UCCFilingManager.UCCFilingDBInstance = (UCCFilingDB) Test.createStub(UCCFilingDB.class, UCCFilingDBStubInstance);

        DBManagerTestsStub errorDBStubInstance = new DBManagerTestsStub();
        UCCFilingManager.ErrorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, ErrorDBStubInstance);

        Test.startTest();
            UCCFilingManager.getOrderInformation(accountIds);
        Test.stopTest();

        System.assertEquals(1, errorDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void setOrderInformationTests(){

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        uccFiling.Order_ID__c = '98879765';
        uccFiling.Account__c = account.Id;
        List<UCC_Filing_Detail__c> uccFilingList = new List<UCC_Filing_Detail__c>();
        uccFilingList.add(uccFiling);

        List<String> responseValueList = new List<String>();
        responseValueList.add('FilerNamesOrganizationName');
        responseValueList.add('FilerNamesState');
        responseValueList.add('IndividualNameLastName');

        Map<String, List<String>> modelToResponseValueListMap = new Map<String, List<String>>();
        ModelToResponseValueListMap.put('FilerNamesOrganizationName0', responseValueList);
        ModelToResponseValueListMap.put('FilerNamesState0', responseValueList);
        ModelToResponseValueListMap.put('IndividualNameLastName0', responseValueList);

        Map<Id, Map<String, List<String>>> uCCFilingIdToModelValueResponseMap = new Map<Id, Map<String, List<String>>>();
        uCCFilingIdToModelValueResponseMap.put(uccFiling.Id, ModelToResponseValueListMap);

        DBManagerTestsStub errorDBStubInstance = new DBManagerTestsStub();
        UCCFilingManager.ErrorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, ErrorDBStubInstance);

        DBManagerTestsStub uCCFilingDBStubInstance = new DBManagerTestsStub();
        uCCFilingDBStubInstance.genericReturnObject = new List<UCC_Filing_Detail__c> {uccFiling};
        UCCFilingManager.UCCFilingDBInstance = (UCCFilingDB) Test.createStub(UCCFilingDB.class, UCCFilingDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {account};
        UCCFilingManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub UCCNoteDBStubInstance = new DBManagerTestsStub();
        UCCFilingManager.UCCNoteDBInstance = (UCCNoteDB) Test.createStub(UCCNoteDB.class, UCCNoteDBStubInstance);

        Test.startTest();
            UCCFilingManager.setOrderInformation(uCCFilingIdToModelValueResponseMap, uccFilingList);
        Test.stopTest();

        System.assertEquals(1, uCCFilingDBStubInstance.forUpdateSObjects.size());
        System.assertEquals(1, accountDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void setOrderInformationExceptionTests(){
        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        uccFiling.Order_ID__c = '98879765';
        uccFiling.Account__c = account.Id;
        List<UCC_Filing_Detail__c> uccFilingList = new List<UCC_Filing_Detail__c>();
        uccFilingList.add(uccFiling);

        List<String> responseValueList = new List<String>();
        responseValueList.add('FilerNamesOrganizationName');
        responseValueList.add('FilerNamesState');
        responseValueList.add('IndividualNameLastName');

        Map<String, List<String>> modelToResponseValueListMap = new Map<String, List<String>>();
        ModelToResponseValueListMap.put('FilerNamesOrganizationName0', responseValueList);
        ModelToResponseValueListMap.put('FilerNamesState0', responseValueList);
        ModelToResponseValueListMap.put('IndividualNameLastName0', responseValueList);

        Map<Id, Map<String, List<String>>> uCCFilingIdToModelValueResponseMap = new Map<Id, Map<String, List<String>>>();
        uCCFilingIdToModelValueResponseMap.put(uccFiling.Id, ModelToResponseValueListMap);

        DBManagerTestsStub errorDBStubInstance = new DBManagerTestsStub();
        UCCFilingManager.ErrorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, ErrorDBStubInstance);

        Test.startTest();
            UCCFilingManager.setOrderInformation(uCCFilingIdToModelValueResponseMap, uccFilingList);
        Test.stopTest();

        System.assertEquals(1, errorDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void uccFilingContinuationTests(){

        Set<Id> accountIds = new Set<Id>();

        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountRecord.Override_UCC_status__c = 'None';

        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        uccFiling.Order_ID__c = '153405863';
        uccFiling.Order_Status__c = 'C';
        uccFiling.Account__c = accountRecord.Id;
        accountIds.add(accountRecord.Id);

        DBManagerTestsStub uCCFilingDBStubInstance = new DBManagerTestsStub();
        uCCFilingDBStubInstance.genericReturnObject = new List<UCC_Filing_Detail__c> {uccFiling};
        UCCFilingManager.UCCFilingDBInstance = (UCCFilingDB) Test.createStub(UCCFilingDB.class, UCCFilingDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {accountRecord};
        UCCFilingManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        System.Test.setMock(HttpCalloutMock.class, new UCCCalloutMock.UCCCalloutMockUccFilingContinuation());

        Test.startTest();
            UCCFilingManager.uccFilingContinuation(accountIds);
        Test.stopTest();

        System.assertEquals(0, accountDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void uccFilingContinuationForExceptionTests(){

        Set<Id> accountIds = new Set<Id>();

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        account.Override_UCC_status__c = 'None';

        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        uccFiling.Order_ID__c = null;
        uccFiling.Account__c = account.Id;
        accountIds.add(account.Id);

        DBManagerTestsStub uCCFilingDBStubInstance = new DBManagerTestsStub();
        uCCFilingDBStubInstance.genericReturnObject = new List<UCC_Filing_Detail__c> {uccFiling};
        UCCFilingManager.UCCFilingDBInstance = (UCCFilingDB) Test.createStub(UCCFilingDB.class, UCCFilingDBStubInstance);

        DBManagerTestsStub errorDBStubInstance = new DBManagerTestsStub();
        UCCFilingManager.ErrorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, ErrorDBStubInstance);

        Test.startTest();
            UCCFilingManager.uccFilingContinuation(accountIds);
        Test.stopTest();

        System.assertEquals(1, errorDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void uccValidateApproveFilingTests(){
        List<UCC_Filing_Detail__c> uccFilingList = new List<UCC_Filing_Detail__c>();

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        uccFiling.Order_ID__c = '153395790';
        uccFiling.Account__c = account.Id;
        uccFilingList.add(uccFiling);

        DBManagerTestsStub uCCFilingDBStubInstance = new DBManagerTestsStub();
        uCCFilingDBStubInstance.genericReturnObject = new List<UCC_Filing_Detail__c> {uccFiling};
        UCCFilingManager.UCCFilingDBInstance = (UCCFilingDB) Test.createStub(UCCFilingDB.class, UCCFilingDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {account};
        UCCFilingManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub errorDBStubInstance = new DBManagerTestsStub();
        UCCFilingManager.ErrorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, ErrorDBStubInstance);

        DBManagerTestsStub UCCValidationLogDBStubInstance = new DBManagerTestsStub();
        UCCFilingManager.UCCValidationLogDBInstance = (UCCValidationLogDB) Test.createStub(UCCValidationLogDB.class, UCCValidationLogDBStubInstance);

        System.Test.setMock(HttpCalloutMock.class, new UCCCalloutMock.UCCCallOutMockCreateFiling());

        Test.startTest();
            UCCFilingManager.uccValidateApproveFiling(uccFilingList);
        Test.stopTest();

        System.assertEquals(1, uCCFilingDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void setAccountFieldsForUCCTests(){

        List<UCC_Filing_Detail__c> uccList = new List<UCC_Filing_Detail__c>();

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        uccFiling.Order_ID__c = '153395797';
        uccFiling.Is_Terminated__c = true;
        uccFiling.Account__c = account.Id;
        uccList.add(uccFiling);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {account};
        UCCFilingManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Test.startTest();
            UCCFilingManager.setAccountFieldsFromUCC(uccList);
        Test.stopTest();

        System.assertEquals('153395797', account.UCC_Order_Number__c);
    }

    @isTest
    private static void terminateUCCFilingTests(){

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        uccFiling.Order_ID__c = '153395797';
        uccFiling.Is_Terminated__c = true;
        uccFiling.Account__c = account.Id;

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {account};
        UCCFilingManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub uCCFilingDBStubInstance = new DBManagerTestsStub();
        uCCFilingDBStubInstance.genericReturnObject = new List<UCC_Filing_Detail__c> {uccFiling};
        UCCFilingManager.UCCFilingDBInstance = (UCCFilingDB) Test.createStub(UCCFilingDB.class, UCCFilingDBStubInstance);

        DBManagerTestsStub errorDBStubInstance = new DBManagerTestsStub();
        UCCFilingManager.ErrorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, ErrorDBStubInstance);

        System.Test.setMock(HttpCalloutMock.class, new UCCCalloutMock.UCCCallOutMockCreateFiling());

        Test.startTest();
            UCCFilingManager.terminateUCCFiling(account.Id);
        Test.stopTest();

        System.assertEquals(1, errorDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void terminateUCCFilingForExceptionTests(){

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        uccFiling.Order_ID__c = null;
        uccFiling.Is_Terminated__c = true;
        uccFiling.Account__c = account.Id;

        DBManagerTestsStub uCCFilingDBStubInstance = new DBManagerTestsStub();
        uCCFilingDBStubInstance.genericReturnObject = new List<UCC_Filing_Detail__c> {uccFiling};
        UCCFilingManager.UCCFilingDBInstance = (UCCFilingDB) Test.createStub(UCCFilingDB.class, UCCFilingDBStubInstance);

        Test.startTest();
            UCCFilingManager.terminateUCCFiling(account.Id);
        Test.stopTest();

        System.assertEquals(0, uCCFilingDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void updateUCCFilingTestsForNull(){

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        uccFiling.Order_ID__c = null;
        uccFiling.Account__c = account.Id;

        DBManagerTestsStub uCCFilingDBStubInstance = new DBManagerTestsStub();
        uCCFilingDBStubInstance.genericReturnObject = new List<UCC_Filing_Detail__c> {uccFiling};
        UCCFilingManager.UCCFilingDBInstance = (UCCFilingDB) Test.createStub(UCCFilingDB.class, UCCFilingDBStubInstance);

        Test.startTest();
            UCCFilingManager.updateUCCFiling(account.Id);
        Test.stopTest();
    }

    @isTest
    private static void setContinuationInformationTests(){

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        uccFiling.Order_ID__c = '98879765';
        uccFiling.Account__c = account.Id;
        List<UCC_Filing_Detail__c> uccFilingList = new List<UCC_Filing_Detail__c>();
        uccFilingList.add(uccFiling);

        List<String> responseValueList = new List<String>();
        responseValueList.add('FilerNamesOrganizationName');
        responseValueList.add('FilerNamesState');
        responseValueList.add('IndividualNameLastName');

        Map<String, List<String>> ModelToResponseValueListMap = new Map<String, List<String>>();
        ModelToResponseValueListMap.put('FilerNamesOrganizationName0', responseValueList);
        ModelToResponseValueListMap.put('FilerNamesState0', responseValueList);
        ModelToResponseValueListMap.put('IndividualNameLastName0', responseValueList);

        Map<Id, Map<String, List<String>>> uCCFilingIdToModelValueResponseMap = new Map<Id, Map<String, List<String>>>();
        uCCFilingIdToModelValueResponseMap.put(uccFiling.Id, ModelToResponseValueListMap);

        DBManagerTestsStub uCCFilingDBStubInstance = new DBManagerTestsStub();
        uCCFilingDBStubInstance.genericReturnObject = new List<UCC_Filing_Detail__c> {uccFiling};
        UCCFilingManager.UCCFilingDBInstance = (UCCFilingDB) Test.createStub(UCCFilingDB.class, UCCFilingDBStubInstance);

        Test.startTest();
            UCCFilingManager.setContinuationInformation(uCCFilingIdToModelValueResponseMap, uccFilingList);
        Test.stopTest();
    }

    @isTest
    private static void getUCCOrderStatusTests(){

        List<UCC_Filing_Detail__c> uccList = new List<UCC_Filing_Detail__c>();

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        uccFiling.Order_ID__c = '153395797';
        uccFiling.Is_Terminated__c = true;
        uccFiling.Account__c = account.Id;
        uccList.add(uccFiling);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {account};
        UCCFilingManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Test.startTest();
            UCCFilingManager.getUCCOrderStatus(uccList);
        Test.stopTest();

    }

    @isTest
    private static void getUCCReportsTests(){

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        uccFiling.Order_ID__c = '98879765';
        uccFiling.Account__c = account.Id;
        uccFiling.Order_Status__c = 'C';
        List<UCC_Filing_Detail__c> uccFilingList = new List<UCC_Filing_Detail__c>();
        uccFilingList.add(uccFiling);

        List<String> responseValueList = new List<String>();
        responseValueList.add('FilerNamesOrganizationName');
        responseValueList.add('FilerNamesState');
        responseValueList.add('IndividualNameLastName');

        Map<String, List<String>> modelToResponseValueListMap = new Map<String, List<String>>();
        ModelToResponseValueListMap.put('FilerNamesOrganizationName0', responseValueList);
        ModelToResponseValueListMap.put('FilerNamesState0', responseValueList);
        ModelToResponseValueListMap.put('IndividualNameLastName0', responseValueList);

        Map<Id, Map<String, List<String>>> uCCFilingIdToModelValueResponseMap = new Map<Id, Map<String, List<String>>>();
        uCCFilingIdToModelValueResponseMap.put(uccFiling.Id, ModelToResponseValueListMap);

        DBManagerTestsStub errorDBStubInstance = new DBManagerTestsStub();
        UCCFilingManager.ErrorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, ErrorDBStubInstance);

        DBManagerTestsStub uCCFilingDBStubInstance = new DBManagerTestsStub();
        uCCFilingDBStubInstance.genericReturnObject = new List<UCC_Filing_Detail__c> {uccFiling};
        UCCFilingManager.UCCFilingDBInstance = (UCCFilingDB) Test.createStub(UCCFilingDB.class, UCCFilingDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {account};
        UCCFilingManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub UCCNoteDBStubInstance = new DBManagerTestsStub();
        UCCFilingManager.UCCNoteDBInstance = (UCCNoteDB) Test.createStub(UCCNoteDB.class, UCCNoteDBStubInstance);

        Test.startTest();
            UCCFilingManager.getUCCReports(uCCFilingIdToModelValueResponseMap);
        Test.stopTest();

        System.assertEquals(0, errorDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void getUCCReportsExceptionTests(){
        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        uccFiling.Order_ID__c = '98879765';
        uccFiling.Account__c = account.Id;
        uccFiling.Order_Status__c = 'C';
        List<UCC_Filing_Detail__c> uccFilingList = new List<UCC_Filing_Detail__c>();
        uccFilingList.add(uccFiling);

        List<String> responseValueList = new List<String>();
        responseValueList.add('FilerNamesOrganizationName');
        responseValueList.add('FilerNamesState');
        responseValueList.add('IndividualNameLastName');

        Map<String, List<String>> modelToResponseValueListMap = new Map<String, List<String>>();
        ModelToResponseValueListMap.put('FilerNamesOrganizationName0', responseValueList);
        ModelToResponseValueListMap.put('FilerNamesState0', responseValueList);
        ModelToResponseValueListMap.put('IndividualNameLastName0', responseValueList);

        Map<Id, Map<String, List<String>>> uCCFilingIdToModelValueResponseMap = new Map<Id, Map<String, List<String>>>();
        uCCFilingIdToModelValueResponseMap.put(uccFiling.Id, ModelToResponseValueListMap);

        Test.startTest();
            UCCFilingManager.getUCCReports(uCCFilingIdToModelValueResponseMap);
        Test.stopTest();
    }

    @isTest
    private static void getUCCAttachmentReportsTests(){

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        uccFiling.Order_ID__c = '98879765';
        uccFiling.Account__c = account.Id;
        uccFiling.Order_Status__c = 'C';
        List<UCC_Filing_Detail__c> uccFilingList = new List<UCC_Filing_Detail__c>();
        uccFilingList.add(uccFiling);

        UCC_Filing_Attachment__c uccAttachment = new UCC_Filing_Attachment__c();
        uccAttachment.Id = TestUtility.getFakeId(UCC_Filing_Attachment__c.getSObjectType());
        uccAttachment.Account__c = account.Id;

        Test.startTest();
            UCCFilingManager.getUCCAttachmentReports(uccFilingList);
        Test.stopTest();
    }

    @isTest
    private static void setUCCAttachmentsTests(){

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        uccFiling.Order_ID__c = '98879765';
        uccFiling.Account__c = account.Id;
        uccFiling.Order_Status__c = 'C';
        List<UCC_Filing_Detail__c> uccFilingList = new List<UCC_Filing_Detail__c>();
        uccFilingList.add(uccFiling);

        UCC_Filing_Attachment__c uccAttachment = new UCC_Filing_Attachment__c();
        uccAttachment.Id = TestUtility.getFakeId(UCC_Filing_Attachment__c.getSObjectType());
        uccAttachment.Account__c = account.Id;

        List<String> responseValueList = new List<String>();
        responseValueList.add('FilerNamesOrganizationName');
        responseValueList.add('FilerNamesState');
        responseValueList.add('IndividualNameLastName');

        Map<String, List<String>> modelToResponseValueListMap = new Map<String, List<String>>();
        ModelToResponseValueListMap.put('FilerNamesOrganizationName0', responseValueList);
        ModelToResponseValueListMap.put('FilerNamesState0', responseValueList);
        ModelToResponseValueListMap.put('IndividualNameLastName0', responseValueList);

        Map<Id, Map<String, List<String>>> uCCFilingIdToModelValueResponseMap = new Map<Id, Map<String, List<String>>>();
        uCCFilingIdToModelValueResponseMap.put(uccAttachment.Id, ModelToResponseValueListMap);

        DBManagerTestsStub errorDBStubInstance = new DBManagerTestsStub();
        UCCFilingManager.ErrorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, ErrorDBStubInstance);

        DBManagerTestsStub uCCFilingDBStubInstance = new DBManagerTestsStub();
        uCCFilingDBStubInstance.genericReturnObject = new List<UCC_Filing_Detail__c> {uccFiling};
        UCCFilingManager.UCCFilingDBInstance = (UCCFilingDB) Test.createStub(UCCFilingDB.class, UCCFilingDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {account};
        UCCFilingManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub uccNoteDBStubInstance = new DBManagerTestsStub();
        UCCFilingManager.uccNoteDBInstance = (UCCNoteDB) Test.createStub(UCCNoteDB.class, uccNoteDBStubInstance);

        DBManagerTestsStub uccFilingAttachmentDBStubInstance = new DBManagerTestsStub();
        uccFilingAttachmentDBStubInstance.genericReturnObject = new List<UCC_Filing_Attachment__c> {uccAttachment};
        UCCFilingManager.uccFilingAttachmentDBInstance = (UCCFilingAttachmentDB) Test.createStub(UCCFilingAttachmentDB.class, uccFilingAttachmentDBStubInstance);

        Exception ex;

        Test.startTest();
            try {
                UCCFilingManager.setUCCAttachments(uCCFilingIdToModelValueResponseMap);
            } catch(Exception e) {
                ex = e;
            }
        Test.stopTest();

        System.assertEquals('UCC Attachment Link is null', ex.getMessage());
    }

	@isTest
    private static void setUCCExpiredFieldsTests(){
        List<Account> accountList = new List<Account>();
        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountList.add(account);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {account};
        UCCFilingManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Test.startTest();
            UCCFilingManager.setUCCExpiredFields(accountList);
        Test.stopTest();
    }

    @isTest
    private static void setUCCExpiredFieldsExceptionTests(){
        List<Account> accountList = new List<Account>();
        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountList.add(account);

        Test.startTest();
            UCCFilingManager.setUCCExpiredFields(accountList);
        Test.stopTest();
    }

    @isTest
    private static void getUCCReportsClick(){

        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());

        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        uccFiling.Account__c = accountRecord.Id;
        uccFiling.Order_ID__c = '153405863';

        DBManagerTestsStub uCCFilingDBStubInstance = new DBManagerTestsStub();
        uCCFilingDBStubInstance.genericReturnObject = new List<UCC_Filing_Detail__c> {uccFiling};
        UCCFilingManager.UCCFilingDBInstance = (UCCFilingDB) Test.createStub(UCCFilingDB.class, UCCFilingDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {accountRecord};
        UCCFilingManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        System.Test.setMock(HttpCalloutMock.class, new UCCCalloutMock.UCCCalloutMockGetOrderInformationByUCCFilingDetail());

        Test.startTest();
            UCCFilingManager.getUCCReportsOnClick(accountRecord.Id);
        Test.stopTest();

        System.assertEquals(1, uCCFilingDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void uccValidateApproveFilingTestsForTerminate(){
        List<UCC_Filing_Detail__c> uccFilingList = new List<UCC_Filing_Detail__c>();

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        uccFiling.Order_ID__c = '153395790';
        uccFiling.Is_Terminated__c = true;
        uccFiling.Account__c = account.Id;
        uccFilingList.add(uccFiling);

        DBManagerTestsStub uCCFilingDBStubInstance = new DBManagerTestsStub();
        uCCFilingDBStubInstance.genericReturnObject = new List<UCC_Filing_Detail__c> {uccFiling};
        UCCFilingManager.UCCFilingDBInstance = (UCCFilingDB) Test.createStub(UCCFilingDB.class, UCCFilingDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {account};
        UCCFilingManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub errorDBStubInstance = new DBManagerTestsStub();
        UCCFilingManager.ErrorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, ErrorDBStubInstance);

        DBManagerTestsStub UCCValidationLogDBStubInstance = new DBManagerTestsStub();
        UCCFilingManager.UCCValidationLogDBInstance = (UCCValidationLogDB) Test.createStub(UCCValidationLogDB.class, UCCValidationLogDBStubInstance);

        System.Test.setMock(HttpCalloutMock.class, new UCCCalloutMock.UCCCallOutMockCreateFiling());

        Test.startTest();
            UCCFilingManager.uccValidateApproveFiling(uccFilingList);
        Test.stopTest();

        System.assertEquals(1, uCCFilingDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void uccValidateApproveFilingTestsForUCCContinued(){
        List<UCC_Filing_Detail__c> uccFilingList = new List<UCC_Filing_Detail__c>();

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        UCC_Filing_Detail__c uccFiling = new UCC_Filing_Detail__c();
        uccFiling.Id = TestUtility.getFakeId(UCC_Filing_Detail__c.getSObjectType());
        uccFiling.Order_ID__c = '153395790';
        uccFiling.Is_UCC_Continued__c = true;
        uccFiling.Account__c = account.Id;
        uccFilingList.add(uccFiling);

        DBManagerTestsStub uCCFilingDBStubInstance = new DBManagerTestsStub();
        uCCFilingDBStubInstance.genericReturnObject = new List<UCC_Filing_Detail__c> {uccFiling};
        UCCFilingManager.UCCFilingDBInstance = (UCCFilingDB) Test.createStub(UCCFilingDB.class, UCCFilingDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {account};
        UCCFilingManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub errorDBStubInstance = new DBManagerTestsStub();
        UCCFilingManager.ErrorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, ErrorDBStubInstance);

        DBManagerTestsStub UCCValidationLogDBStubInstance = new DBManagerTestsStub();
        UCCFilingManager.UCCValidationLogDBInstance = (UCCValidationLogDB) Test.createStub(UCCValidationLogDB.class, UCCValidationLogDBStubInstance);

        System.Test.setMock(HttpCalloutMock.class, new UCCCalloutMock.UCCCallOutMockCreateFiling());

        Test.startTest();
            UCCFilingManager.uccValidateApproveFiling(uccFilingList);
        Test.stopTest();

        System.assertEquals(1, uCCFilingDBStubInstance.forUpdateSObjects.size());
    }
}