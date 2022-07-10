@IsTest
private class AccountsTests
{
    @IsTest
    private static void createAccountTests()
    {
        Map<String, String> leadMap = TestUtility.getLeadMap();
        leadMap.put('Biz_Structure__c','Partnership');
        leadMap.put('loan__SICCode__c','073');
        leadMap.put('SIC_Description__c','Business Services');
        leadMap.put('Biz_Phone__c','9876786543');

        String jsonString = JSON.serialize(leadMap);
        Lead leadRecord = (Lead) JSON.deserialize(jsonString, Lead.class);

        clcommon__Legal_Entity__c legalEntity = new clcommon__Legal_Entity__c();
        legalEntity.Id = TestUtility.getFakeId(clcommon__Legal_Entity__c.getSObjectType());
        OriginationHelper.legalNameToId.put('Partnership', legalEntity.Id);
        Id legalEntityTypeBusiness = OriginationHelper.legalNameToId.get('Partnership');
        OriginationHelper.legalNameToId.put(Leads.LEGAL_INDIVIDUAL_ENTITY_TYPE, legalEntity.Id);
        Id legalEntityTypeIndividual = OriginationHelper.legalNameToId.get(Leads.LEGAL_INDIVIDUAL_ENTITY_TYPE);

        Test.startTest();
            Account borrowerAccount = Accounts.createBorrowerAccount(leadRecord, legalEntityTypeBusiness);
            Account guarantorAccount = Accounts.createGuarantorAccount(leadRecord, legalEntityTypeIndividual);
            Account brokerAccount = Accounts.createBrokerAccount(leadRecord);
        Test.stopTest();

        System.assert(borrowerAccount != null);
        System.assertEquals(borrowerAccount.Phone, leadRecord.Biz_Phone__c);
    }

    @IsTest
    private static void createAccountSicTwoDigitTests()
    {
        Map<String, String> leadMap = TestUtility.getLeadMap();
        leadMap.put('Biz_Structure__c','Partnership');
        leadMap.put('loan__SICCode__c','73');
        leadMap.put('SIC_Description__c','Business Services');
        String jsonString = JSON.serialize(leadMap);
        Lead leadRecord = (Lead) JSON.deserialize(jsonString, Lead.class);
        clcommon__Legal_Entity__c legalEntity = new clcommon__Legal_Entity__c();
        legalEntity.Id = TestUtility.getFakeId(clcommon__Legal_Entity__c.getSObjectType());
        OriginationHelper.legalNameToId.put('Partnership', legalEntity.Id);
        Id legalEntityTypeBusiness = OriginationHelper.legalNameToId.get('Partnership');
        OriginationHelper.legalNameToId.put(Leads.LEGAL_INDIVIDUAL_ENTITY_TYPE, legalEntity.Id);
        Id legalEntityTypeIndividual = OriginationHelper.legalNameToId.get(Leads.LEGAL_INDIVIDUAL_ENTITY_TYPE);

        Test.startTest();
            Account borrowerAccount = Accounts.createBorrowerAccount(leadRecord, legalEntityTypeBusiness);
            Account guarantorAccount = Accounts.createGuarantorAccount(leadRecord, legalEntityTypeIndividual);
        Accounts.createBrokerAccount(leadRecord);
        Test.stopTest();

        System.assert(guarantorAccount.Type.equals(Leads.GUARANTOR));
    }

    @IsTest
    private static void testAccountsMethodsTests()
    {
        TestUtility.runSetupData();
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 1, 1);
        Id brokerContactId = TestUtility.getFakeId(Contact.getSObjectType());
        Id brokerAccountId = TestUtility.getFakeId(Account.getSObjectType());

        Test.startTest();
            Accounts.setContractApprovedRelatedFields(TestUtility.createAccount(), brokerContactId, brokerAccountId);
            Account accountRecord = Accounts.setSICCodeFromApplication(TestUtility.createApplication());
        Test.stopTest();

        System.assertEquals('073', accountRecord.Sic);
    }

    @IsTest
    private static void setCanceledContractRelatedFields()
    {
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Account borrowerAccountRecord = new Account();
        borrowerAccountRecord.Type =  Accounts.BORROWER;
        borrowerAccountRecord.Id = accountId;
        borrowerAccountRecord.Legacy_Number_of_Contracts__c = 1;

        Test.startTest();
            Accounts.setCanceledContractRelatedFields(borrowerAccountRecord);
        Test.stopTest();

        System.assertEquals(0, borrowerAccountRecord.Legacy_Number_of_Contracts__c);
    }

    @isTest
    private static void testSetContractApprovedRelatedFields()
    {
        loan__Loan_Account__c clContract = new loan__Loan_Account__c();
        clContract.loan__Loan_Amount__c = 100;

        Test.startTest();
            Account accountRecord = Accounts.setContractApprovedRelatedFields(clContract);
        Test.stopTest();

        System.assertEquals(100, accountRecord.Original_Max_Funding_Amount__c);
        System.assert(accountRecord.Zero_Balance_Date__c == null);
    }

    @IsTest
    private static void setClosedContractRelatedFields() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        loan__Loan_Account__c clContract = new loan__Loan_Account__c();
        clContract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        clContract.loan__Closed_Date__c = TestUtility.currentSystemDate;
        clContract.loan__Loan_Status__c = CLContracts.LOAN_STATUS_CLOSED_OBLIGATION_MET;

        Test.startTest();
            Account accountRecord = Accounts.setClosedContractRelatedFields(clContract);
        Test.stopTest();

        System.assertEquals(TestUtility.currentSystemDate, accountRecord.Zero_Balance_Date__c);
    }

    @isTest
    private static void isCANNegativeHistory() {

        Account oldAccount = new Account();
        oldAccount.Legacy_Negative_CAN_History__c = false;
        Account newAccount = new Account();
        newAccount.Legacy_Negative_CAN_History__c = true;
        Test.startTest();
            Boolean accountRecord = Accounts.isCANNegativeHistory(newAccount, oldAccount);
        Test.stopTest();

        System.assertEquals(accountRecord, true);
    }

    @isTest
    private static void setNegativeHistoryAccountFields() {

        Account oldAccount = new Account();
        oldAccount.Legacy_Negative_CAN_History__c = false;
        Account newAccount = new Account();
        newAccount.Legacy_Negative_CAN_History__c = true;
        newAccount.ParentId = TestUtility.getFakeId(Account.getSObjectType());
        newAccount.Negative_CAN_History_Reason__c = 'Written Off Contract';
        Test.startTest();
            Account accountRecord = Accounts.setNegativeHistoryAccountFields(newAccount, oldAccount);
        Test.stopTest();

        System.assert(accountRecord != null);
    }

    @isTest
    private static void setAccountFieldsOnBeforeInsert() {
        Account account = new Account();
        account.Id = TestUtility.getFakeId(account.getSObjectType());
        account.Name = 'Account Before Insert';
        account.Legacy_Percent_Paid__c = 80;
        account.Type = Accounts.BROKER;

        Test.startTest();
            Accounts.setAccountFieldsOnBeforeInsert(account);
        Test.stopTest();

        System.assertEquals(account.Legacy_Percent_Paid_High_Indicator__c, true);
        System.assertEquals(account.renewal_funding_notice__c, true);
    }

    @isTest
    private static void setAccountFieldsOnBeforeUpdate() {

        clcommon__Document_Definition__c documentDefinition = new clcommon__Document_Definition__c();
        documentDefinition.Name = GeneralConstants.DOCUMENT_TYPE_EXPERIAN_BUSINESS_REPORT;
        documentDefinition.Document_Category__c = 'Account';

        DBManagerTestsStub ddDBStubInstance = new DBManagerTestsStub();
        ddDBStubInstance.genericReturnObject = new List<clcommon__Document_Definition__c>{documentDefinition};
        OriginationHelper.documentDefinitionDBInstance = (DocumentDefinitionDB) Test.createStub(DocumentDefinitionDB.class, ddDBStubInstance);

        CAN_Industry_Rating_Profile__c irp = new CAN_Industry_Rating_Profile__c();
        irp.Description__c = 'BUSINESS SERVICES';
        irp.Digit_Code__c = '73';
        irp.Industry_Rating__c = 'B';

        DBManagerTestsStub irpDBStubInstance = new DBManagerTestsStub();
        irpDBStubInstance.genericReturnObject = new List<CAN_Industry_Rating_Profile__c>{irp};
        OriginationHelper.industryRatingProfileDBInstance = (IndustryRatingProfileDB) Test.createStub(IndustryRatingProfileDB.class, irpDBStubInstance);

        Account oldAccount = new Account();
        oldAccount.Sic = '083';
        oldAccount.Name = 'old Acc';
        oldAccount.Industry = 'REAL ESTATE AGENTS AND MANAGERS';
        oldAccount.BillingState = 'New York';
        oldAccount.Id = TestUtility.getFakeId(account.getSObjectType());
        oldAccount.Name = 'Account Before Insert';
        oldAccount.Legacy_Negative_CAN_History__c = false;

        Account newAccount = new Account();
        newAccount.Sic = '073';
        newAccount.Id = oldAccount.Id;
        newAccount.Industry = 'BUSINESS SERVICES';
        newAccount.Legacy_Percent_Paid__c = 65.00;
        newAccount.BillingState = 'Ohio';
        newAccount.Name = 'Account Before Update';
        newAccount.Legacy_Negative_CAN_History__c = true;

        Test.startTest();
            Accounts.setAccountFieldsOnBeforeUpdate(newAccount, oldAccount);
        Test.stopTest();

        System.assertEquals(newAccount.Do_Not_Sync_With_SFMC__c, true);
    }

    @isTest
    private static void setAccountFieldsFromParty() {
        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());

        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        party.clcommon__Account__c = accountRecord.Id;
        party.genesis__Application__c = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        party.Doing_Business_As__c = 'Test';
        party.State_of_Incorporation_Organization__c = 'AL';
        party.Biz_Phone__c = '15487963';
        party.Biz_Structure__c = 'Company';
        party.Industry__c = 'AGRICULTURAL SERVICES';
        party.Biz_Building__c = '1254 NC';
        party.BizBillingPostalCode__c = '9878987';
        party.Biz_City__c = 'NewYork';
        party.Biz_Country__c = 'US';
        party.Website__c = 'google.com';
        party.Biz_Street__c = '124 high';
        party.Biz_State__c = 'NY';

        Test.startTest();
            Account borrowerAccount = Accounts.setAccountFieldsFromParty(party);
        Test.stopTest();

        System.assert(borrowerAccount != null);
        System.assertEquals(borrowerAccount.Business_Name__c, party.Business_Name__c);
    }

    @isTest
    private static void setAccountFieldsFromCollectionsAfterInsertTest() {

        Collection_Case__c collectionCase = new Collection_Case__c();
        collectionCase.Deceased_owner__c = true;

        Test.startTest();
            Account borrowerAccount = Accounts.setAccountFieldsFromCollectionsAfterInsert(collectionCase, true);
        Test.stopTest();

        System.assertEquals(borrowerAccount.Deceased__c, true);
    }

    @isTest
    private static void setAccountFieldsFromCollectionsAfterUpdateTest() {

        Collection_Case__c OldCollectionCase = new Collection_Case__c();
        OldCollectionCase.Deceased_owner__c = false;
        OldCollectionCase.Confirmed_fraud__c = false;
        OldCollectionCase.Cease_and_Desist__c = false;
        OldCollectionCase.SCRA__c = false;

        Collection_Case__c collectionCase = new Collection_Case__c();
        collectionCase.Deceased_owner__c = true;
        collectionCase.Confirmed_fraud__c = true;
        collectionCase.Cease_and_Desist__c = true;
        collectionCase.SCRA__c = true;

        Test.startTest();
            Account borrowerAccount = Accounts.setAccountFieldsFromCollectionsAfterUpdate(collectionCase, OldCollectionCase);
        Test.stopTest();

        System.assertEquals(borrowerAccount.SCRA__c, true);
    }

    @isTest
    private static void setAccountFieldsFromApplicationTest() {

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        application.Is_EIS_Renewal__c = true;
        application.Auto_Renewed__c = true;
        application.Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;

        Test.startTest();
            Account account = Accounts.setAccountFieldsFromApplication(application);
        Test.stopTest();

        System.assert(account.Legacy_Renewal_Application_Created_Date__c != null);
    }
}