@isTest
private class CollectionsCreditPullTests {

    @TestSetup
    static void makeData() {
        TestUtility.runSetupData();
        loan__Loan_Account__c clContract = TestUtility.createContract();

        updateUser();

        Collection_Case__c collectionCase = new Collection_Case__c();
        collectionCase.Contract_Number__c = clContract.Name;
        collectionCase.CL_Contract_Id__c = clContract.Id;
        collectionCase.Supervisor__c = UserInfo.getUserId();
        collectionCase.OwnerId = UserInfo.getUserId();
        collectionCase.Account__c = clContract.loan__Account__c;
        insert collectionCase;
    }

    private static void updateUser() {
        User user = new User(Id = UserInfo.getUserId());
        user.Supervisor__c = true;
        update user;
    }

    @isTest
    private static void consumerCreditPullTest() {

        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];
        Id contactId = TestUtility.getFakeId(Contact.getSObjectType());

        Account accountRecord = new Account();
        accountRecord.Id = collectionCase.Account__c;
        accountRecord.Name = 'DELTA FRESH, L.L.C';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);

        Contact contactRecord = TestUtility.createContact();
        contactRecord.FirstName = 'John';
        contactRecord.LastName = 'Boos';
        contactRecord.genesis__SSN__c = '1234567!#%$';

        Credit_Report_Detail__c consumerCreditReport = new Credit_Report_Detail__c();
        consumerCreditReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        consumerCreditReport.Contact__c = contactId;
        consumerCreditReport.Personal_FICO_Score__c = 700;
        consumerCreditReport.No_Of_Open_Trades__c = 4;
        consumerCreditReport.Total_No_Trades_Count__c = 8;
        consumerCreditReport.Bankruptcy_Risk_Score__c = 650;
        consumerCreditReport.Total_No_Late_Mortgage_Count__c = 1;
        consumerCreditReport.Is_Recent_Bankruptcy__c = false;
        consumerCreditReport.Is_Open_Bankruptcy__c = false;
        consumerCreditReport.Type__c = 'Experian Consumer';

        clcommon__Party_Type__c partyType = new clcommon__Party_Type__c();
        partyType.Name = 'GUARANTOR';
        partyType.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());

        Map<String, Id> partyTypeToId = new Map<String, Id>();
        partyTypeToId.put(partyType.Name, partyType.Id);
        OriginationHelper.partyTypeToId = partyTypeToId;

        clcommon__Document_Definition__c documentDefinition = new clcommon__Document_Definition__c();
        documentDefinition.Id = TestUtility.getFakeId(clcommon__Document_Definition__c.getSObjectType());
        documentDefinition.Name = 'Collections Consumer Credit';
        documentDefinition.clcommon__Show_In_Portal__c = 'DELIVERED';
        documentDefinition.clcommon__Active__c = true;

        clcommon__Document_Category__c documentCategory = new clcommon__Document_Category__c();
        documentCategory.Id = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());
        documentCategory.clcommon__Category_Name__c = documentDefinition.Name;
        documentCategory.clcommon__Show_In_Portal__c = documentDefinition.clcommon__Show_In_Portal__c;
        documentCategory.clcommon__Document_Definition__c = documentDefinition.Id;
        documentCategory.Collection_Case__c = collectionCase.Id;
        documentCategory.clcommon__Account__c = collectionCase.Account__c;

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        DBManagerTestsStub accountDBInstance = new DBManagerTestsStub();
        accountDBInstance.genericReturnObject = new List<Account> {accountRecord};
        ExperianManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBInstance);

        DBManagerTestsStub contactDBInstance = new DBManagerTestsStub();
        contactDBInstance.genericReturnObject = new List<Contact> {contactRecord};
        ExperianManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBInstance);

        DBManagerTestsStub creditReportDetailDBInstance = new DBManagerTestsStub();
        ExperianManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBInstance);

        DBManagerTestsStub cusRuleCreditReportDetailDBInstance = new DBManagerTestsStub();
        cusRuleCreditReportDetailDBInstance.genericReturnObject = new List<Credit_Report_Detail__c> {consumerCreditReport};
        BusinessRuleManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, cusRuleCreditReportDetailDBInstance);

        DBManagerTestsStub attachmentDBInstance = new DBManagerTestsStub();
        ExperianManager.attachmentDBInstance = (AttachmentDB) Test.createStub(AttachmentDB.class, attachmentDBInstance);

        DBManagerTestsStub documentCategoryDBInstance = new DBManagerTestsStub();
        documentCategoryDBInstance.genericReturnObject = new List<clcommon__Document_Category__c> {documentCategory};
        CategoryAttachAssnManager.documentCategoryDBInstance = (DocumentCategoryDB) Test.createStub(DocumentCategoryDB.class, documentCategoryDBInstance);

        DBManagerTestsStub categoryAttachmentAssociationDBInstance = new DBManagerTestsStub();
        CategoryAttachAssnManager.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, categoryAttachmentAssociationDBInstance);

        DBManagerTestsStub documentDefinitionDBStubInstance = new DBManagerTestsStub();
        documentDefinitionDBStubInstance.genericReturnObject = new List<clcommon__Document_Definition__c> {documentDefinition};
        OriginationHelper.documentDefinitionDBInstance = (DocumentDefinitionDB) Test.createStub(DocumentDefinitionDB.class, documentDefinitionDBStubInstance);

        Test.setMock(HttpCalloutMock.class, new ExperianCalloutMock.ExperianConsumerSuccessResponse());
        Test.startTest();
            CollectionsCreditPull.consumerCreditPull(contactRecord.Id, collectionCase.Id);
        Test.stopTest();

        System.assert(collectionCase.Id != null);
    }

    @isTest
    private static void businessCreditPullTest() {

        Collection_Case__c collectionCase = [
            SELECT Id,Name, Contract_Number__c, CL_Contract_Id__c,
            Supervisor__c, OwnerId, Account__c FROM Collection_Case__c LIMIT 1
        ];
        Id contactId = TestUtility.getFakeId(Contact.getSObjectType());

        Account accountRecord = new Account();
        accountRecord.Id = collectionCase.Account__c;
        accountRecord.Name = 'DELTA FRESH, L.L.C';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024!#%$';
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);
        accountRecord.BillingCity = 'Ohio!#%$';
        accountRecord.BillingState = 'NH!#%$';
        accountRecord.BillingStreet = '17 Charles Street!#%$';
        accountRecord.BillingPostalCode = '12345!#%$';
        accountRecord.Phone = '12345678!#%$';

        Credit_Report_Detail__c businessCreditReport = new Credit_Report_Detail__c();
        businessCreditReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        businessCreditReport.Account__c = collectionCase.Account__c;
        businessCreditReport.Tax_Liens__c = 53423;
        businessCreditReport.Judgement_Liens__c = 24324;
        businessCreditReport.Is_Recent_Bankruptcy__c = false;
        businessCreditReport.Is_Open_Bankruptcy__c = false;
        businessCreditReport.Competitor_Judgement__c = false;
        businessCreditReport.Type__c = 'Experian Business';

        clcommon__Document_Definition__c documentDefinition = new clcommon__Document_Definition__c();
        documentDefinition.Id = TestUtility.getFakeId(clcommon__Document_Definition__c.getSObjectType());
        documentDefinition.Name = 'Collections Business Credit';
        documentDefinition.clcommon__Show_In_Portal__c = 'DELIVERED';
        documentDefinition.clcommon__Active__c = true;

        clcommon__Document_Category__c documentCategory = new clcommon__Document_Category__c();
        documentCategory.Id = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());
        documentCategory.clcommon__Category_Name__c = documentDefinition.Name;
        documentCategory.clcommon__Show_In_Portal__c = documentDefinition.clcommon__Show_In_Portal__c;
        documentCategory.clcommon__Document_Definition__c = documentDefinition.Id;
        documentCategory.Collection_Case__c = collectionCase.Id;
        documentCategory.clcommon__Account__c = collectionCase.Account__c;

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        DBManagerTestsStub accountDBInstance = new DBManagerTestsStub();
        accountDBInstance.genericReturnObject = new List<Account> {accountRecord};
        CollectionsCreditPull.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBInstance);

        DBManagerTestsStub creditReportDetailDBInstance = new DBManagerTestsStub();
        CollectionsCreditPull.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBInstance);

        DBManagerTestsStub attachmentDBInstance = new DBManagerTestsStub();
        CollectionsCreditPull.attachmentDBInstance = (AttachmentDB) Test.createStub(AttachmentDB.class, attachmentDBInstance);

        DBManagerTestsStub busRuleCreditReportDetailDBInstance = new DBManagerTestsStub();
        busRuleCreditReportDetailDBInstance.genericReturnObject = new List<Credit_Report_Detail__c> {businessCreditReport};
        BusinessRuleManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, busRuleCreditReportDetailDBInstance);

        DBManagerTestsStub documentCategoryDBInstance = new DBManagerTestsStub();
        documentCategoryDBInstance.genericReturnObject = new List<clcommon__Document_Category__c> {documentCategory};
        CategoryAttachAssnManager.documentCategoryDBInstance = (DocumentCategoryDB) Test.createStub(DocumentCategoryDB.class, documentCategoryDBInstance);

        DBManagerTestsStub categoryAttachmentAssociationDBInstance = new DBManagerTestsStub();
        CategoryAttachAssnManager.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, categoryAttachmentAssociationDBInstance);

        DBManagerTestsStub documentDefinitionDBStubInstance = new DBManagerTestsStub();
        documentDefinitionDBStubInstance.genericReturnObject = new List<clcommon__Document_Definition__c> {documentDefinition};
        OriginationHelper.documentDefinitionDBInstance = (DocumentDefinitionDB) Test.createStub(DocumentDefinitionDB.class, documentDefinitionDBStubInstance);

        Test.setMock(HttpCalloutMock.class, new ExperianCalloutMock.ExperianBusinessSuccessResponse());
        Test.startTest();
            CollectionsCreditPull.businessCreditPull(accountRecord.Id, collectionCase.Id);
        Test.stopTest();

        System.assert(collectionCase.Id != null);
    }

    @isTest
    private static void getBusinessCreditReportByAccountIdTest() {
        Id account = TestUtility.getFakeId(Account.getSObjectType());
        Test.startTest();
            List<Credit_Report_Detail__c> creditReport = CollectionsCreditPull.getBusinessCreditReportByAccountId(account, false);
        Test.stopTest();

        System.assert(creditReport.isEmpty());
    }

    @isTest
    private static void getConsumerCreditReportByContactIdTest() {
        Id contact = TestUtility.getFakeId(Contact.getSObjectType());
        Test.startTest();
            List<Credit_Report_Detail__c> creditReport = CollectionsCreditPull.getConsumerCreditReportByContactId(contact, false);
        Test.stopTest();

        System.assert(creditReport.isEmpty());
    }

    @isTest
    private static void createExperianBusinessCreditReportDocumentTest(){
        Id collectionCase = TestUtility.getFakeId(Collection_Case__c.getSObjectType());
        Map<Id, String> accountIdToCreditProfilePdf = new Map<Id, String>();
        clcommon__Document_Definition__c documentDefinition = new clcommon__Document_Definition__c();
        documentDefinition.Id = TestUtility.getFakeId(clcommon__Document_Definition__c.getSObjectType());
        documentDefinition.Name = GeneralConstants.DOCUMENT_TYPE_COLLECTIONS_BUSINESS_CREDIT;
        Map<String, clcommon__Document_Definition__c> documentDefinitionMap = new Map<String, clcommon__Document_Definition__c>();
        documentDefinitionMap.put(documentDefinition.Name,documentDefinition);
        OriginationHelper.documentDefinitionByName = documentDefinitionMap;

        DBManagerTestsStub documentCategoryDBInstance = new DBManagerTestsStub();
        CategoryAttachAssnManager.documentCategoryDBInstance = (DocumentCategoryDB) Test.createStub(DocumentCategoryDB.class, documentCategoryDBInstance);

        DBManagerTestsStub attachmentDBStubInstance = new DBManagerTestsStub();
        CollectionsCreditPull.attachmentDBInstance = (AttachmentDB) Test.createStub(AttachmentDB.class, attachmentDBStubInstance);

        DBManagerTestsStub categoryAttachmentAssociationDBInstance = new DBManagerTestsStub();
        CategoryAttachAssnManager.categoryAttachmentAssociationDBInstance = (CategoryAttachmentAssociationDB) Test.createStub(CategoryAttachmentAssociationDB.class, categoryAttachmentAssociationDBInstance);

        accountIdToCreditProfilePdf.put(collectionCase, 'TestAttachment');

        Test.startTest();
            CollectionsCreditPull.createExperianBusinessCreditReportDocument(accountIdToCreditProfilePdf, collectionCase);
        Test.stopTest();

        System.assertEquals(1, attachmentDBStubInstance.forInsertSObjects.size());
    }
}