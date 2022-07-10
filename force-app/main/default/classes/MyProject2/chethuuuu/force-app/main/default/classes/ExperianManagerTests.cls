@isTest
private class ExperianManagerTests {

    @isTest
    private static void requestBusinessCreditCheck() {

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Origination_Fee_Amount__c" : "299"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        application.Opportunity__c = TestUtility.getFakeId(Opportunity.getSObjectType());
        application.Industry_Rating__c = 'A+ Medical';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 1413777;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 1;
        application.genesis__Payment_Frequency__c = 'DAILY';

        Account accountRecord = new Account();
        accountRecord.Id = application.genesis__Account__c;
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
        businessCreditReport.Account__c = application.genesis__Account__c;
        businessCreditReport.Tax_Liens__c = 53423;
        businessCreditReport.Judgement_Liens__c = 24324;
        businessCreditReport.Is_Recent_Bankruptcy__c = false;
        businessCreditReport.Is_Open_Bankruptcy__c = false;
        businessCreditReport.Competitor_Judgement__c = false;
        businessCreditReport.Type__c = 'Experian Business';

        clcommon__Document_Definition__c documentDefinition = new clcommon__Document_Definition__c();
        documentDefinition.Id = TestUtility.getFakeId(clcommon__Document_Definition__c.getSObjectType());
        documentDefinition.Name = 'Experian Business Credit Report';
        documentDefinition.clcommon__Show_In_Portal__c = 'DELIVERED';
        documentDefinition.clcommon__Active__c = true;

        clcommon__Document_Category__c documentCategory = new clcommon__Document_Category__c();
        documentCategory.Id = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());
        documentCategory.clcommon__Category_Name__c = documentDefinition.Name;
        documentCategory.clcommon__Show_In_Portal__c = documentDefinition.clcommon__Show_In_Portal__c;
        documentCategory.clcommon__Document_Definition__c = documentDefinition.Id;
        documentCategory.genesis__Application__c = application.Id;
        documentCategory.clcommon__Account__c = application.genesis__Account__c;

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        ExperianManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub accountDBInstance = new DBManagerTestsStub();
        accountDBInstance.genericReturnObject = new List<Account> {accountRecord};
        ExperianManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBInstance);

        DBManagerTestsStub errorLogDBInstance = new DBManagerTestsStub();
        ExperianManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBInstance);

        DBManagerTestsStub creditReportDetailDBInstance = new DBManagerTestsStub();
        ExperianManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBInstance);

        DBManagerTestsStub attachmentDBInstance = new DBManagerTestsStub();
        ExperianManager.attachmentDBInstance = (AttachmentDB) Test.createStub(AttachmentDB.class, attachmentDBInstance);

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
            ExperianManager.requestBusinessCreditCheck(new List<genesis__Applications__c> {application});
        Test.stopTest();

        System.assertEquals(1, applicationDBStubInstance.forUpdateSObjects.size());
        System.assertEquals(1, creditReportDetailDBInstance.forUpsertSObjects.size());
    }

    @isTest
    private static void requestBusinessCreditCheckExistingReport() {

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Origination_Fee_Amount__c" : "299"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        application.Opportunity__c = TestUtility.getFakeId(Opportunity.getSObjectType());
        application.Industry_Rating__c = 'A+ Medical';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 1413777;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 1;
        application.genesis__Payment_Frequency__c = 'DAILY';

        Account accountRecord = new Account();
        accountRecord.Id = application.genesis__Account__c;
        accountRecord.Name = 'DELTA FRESH, L.L.C';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Last_Business_Credit_Pull__c = TestUtility.currentSystemDate.addDays(-10);
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);

        Credit_Report_Detail__c businessCreditReport = new Credit_Report_Detail__c();
        businessCreditReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        businessCreditReport.Account__c = application.genesis__Account__c;
        businessCreditReport.Tax_Liens__c = 53423;
        businessCreditReport.Judgement_Liens__c = 24324;
        businessCreditReport.Is_Recent_Bankruptcy__c = false;
        businessCreditReport.Is_Open_Bankruptcy__c = false;
        businessCreditReport.Competitor_Judgement__c = false;
        businessCreditReport.Type__c = 'Experian Business';

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        ExperianManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub accountDBInstance = new DBManagerTestsStub();
        accountDBInstance.genericReturnObject = new List<Account> {accountRecord};
        ExperianManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBInstance);

        DBManagerTestsStub errorLogDBInstance = new DBManagerTestsStub();
        ExperianManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBInstance);

        DBManagerTestsStub creditReportDetailDBInstance = new DBManagerTestsStub();
        creditReportDetailDBInstance.genericReturnObject = new List<Credit_Report_Detail__c> {businessCreditReport};
        ExperianManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBInstance);

        DBManagerTestsStub busRuleCreditReportDetailDBInstance = new DBManagerTestsStub();
        busRuleCreditReportDetailDBInstance.genericReturnObject = new List<Credit_Report_Detail__c> {businessCreditReport};
        BusinessRuleManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, busRuleCreditReportDetailDBInstance);

        Test.setMock(HttpCalloutMock.class, new ExperianCalloutMock.ExperianBusinessSuccessResponse());
        Test.startTest();
            ExperianManager.requestBusinessCreditCheck(new List<genesis__Applications__c> {application});
        Test.stopTest();

        System.assertEquals(1, applicationDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void requestBusinessCreditCheckException() {

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Origination_Fee_Amount__c" : "299"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        application.Opportunity__c = TestUtility.getFakeId(Opportunity.getSObjectType());
        application.Industry_Rating__c = 'A+ Medical';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 1413777;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 1;
        application.genesis__Payment_Frequency__c = 'DAILY';

        Account accountRecord = new Account();
        accountRecord.Id = application.genesis__Account__c;
        accountRecord.Name = 'DELTA FRESH, L.L.C';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);

        Credit_Report_Detail__c businessCreditReport = new Credit_Report_Detail__c();
        businessCreditReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        businessCreditReport.Account__c = application.genesis__Account__c;
        businessCreditReport.Tax_Liens__c = 53423;
        businessCreditReport.Judgement_Liens__c = 24324;
        businessCreditReport.Is_Recent_Bankruptcy__c = false;
        businessCreditReport.Is_Open_Bankruptcy__c = false;
        businessCreditReport.Competitor_Judgement__c = false;
        businessCreditReport.Type__c = 'Experian Business';

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        ExperianManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub accountDBInstance = new DBManagerTestsStub();
        accountDBInstance.genericReturnObject = new List<Account> {accountRecord};
        ExperianManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBInstance);

        DBManagerTestsStub errorLogDBInstance = new DBManagerTestsStub();
        ExperianManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBInstance);

        DBManagerTestsStub creditReportDetailDBInstance = new DBManagerTestsStub();
        creditReportDetailDBInstance.genericReturnObject = new List<Credit_Report_Detail__c> {businessCreditReport};
        ExperianManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBInstance);

        DBManagerTestsStub busRuleCreditReportDetailDBInstance = new DBManagerTestsStub();
        busRuleCreditReportDetailDBInstance.genericReturnObject = new List<Credit_Report_Detail__c> {businessCreditReport};
        BusinessRuleManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, busRuleCreditReportDetailDBInstance);

        Test.startTest();
            ExperianManager.requestBusinessCreditCheck(new List<genesis__Applications__c> {application});
        Test.stopTest();

        System.assertEquals(1, errorLogDBInstance.forInsertSObjects.size());
    }

    @isTest
    private static void requestConsumerCreditCheck() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        application.Primary_Guarantor__c = TestUtility.getFakeId(Contact.getSObjectType());
        application.Opportunity__c = TestUtility.getFakeId(Opportunity.getSObjectType());
        application.Industry_Rating__c = 'A+ Medical';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 1413777;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 1;
        application.genesis__Payment_Frequency__c = 'DAILY';

        Account accountRecord = new Account();
        accountRecord.Id = application.genesis__Account__c;
        accountRecord.Name = 'DELTA FRESH, L.L.C';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);

        Contact contactRecord = new Contact();
        contactRecord.Id = application.Primary_Guarantor__c;
        contactRecord.FirstName = 'John';
        contactRecord.LastName = 'Boos';
        contactRecord.genesis__SSN__c = '1234567!#%$';

        Credit_Report_Detail__c consumerCreditReport = new Credit_Report_Detail__c();
        consumerCreditReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        consumerCreditReport.Contact__c = application.Primary_Guarantor__c;
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

        clcommon__Party__c partyRecord = new clcommon__Party__c();
        partyRecord.Id =TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        partyRecord.clcommon__Type__c = partyType.Id;
        partyRecord.clcommon__Type__r = partyType;
        partyRecord.clcommon__isPrimary__c = true;
        partyRecord.genesis__Application__c = application.Id;
        partyRecord.clcommon__Account__c = application.genesis__Account__c;
        partyRecord.clcommon__Contact__c = application.Primary_Guarantor__c;

        clcommon__Document_Definition__c documentDefinition = new clcommon__Document_Definition__c();
        documentDefinition.Id = TestUtility.getFakeId(clcommon__Document_Definition__c.getSObjectType());
        documentDefinition.Name = 'Experian Consumer Credit Report';
        documentDefinition.clcommon__Show_In_Portal__c = 'DELIVERED';
        documentDefinition.clcommon__Active__c = true;

        clcommon__Document_Category__c documentCategory = new clcommon__Document_Category__c();
        documentCategory.Id = TestUtility.getFakeId(clcommon__Document_Category__c.getSObjectType());
        documentCategory.clcommon__Category_Name__c = documentDefinition.Name;
        documentCategory.clcommon__Show_In_Portal__c = documentDefinition.clcommon__Show_In_Portal__c;
        documentCategory.clcommon__Document_Definition__c = documentDefinition.Id;
        documentCategory.genesis__Application__c = application.Id;
        documentCategory.clcommon__Account__c = application.genesis__Account__c;

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        ExperianManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub accountDBInstance = new DBManagerTestsStub();
        accountDBInstance.genericReturnObject = new List<Account> {accountRecord};
        ExperianManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBInstance);

        DBManagerTestsStub contactDBInstance = new DBManagerTestsStub();
        contactDBInstance.genericReturnObject = new List<Contact> {contactRecord};
        ExperianManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBInstance);

        DBManagerTestsStub partyDBInstance = new DBManagerTestsStub();
        partyDBInstance.genericReturnObject = new List<clcommon__Party__c> {partyRecord};
        ExperianManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBInstance);

        DBManagerTestsStub errorLogDBInstance = new DBManagerTestsStub();
        ExperianManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBInstance);

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
            ExperianManager.requestConsumerCreditCheck(new List<genesis__Applications__c> {application});
        Test.stopTest();

        System.assertEquals(1, creditReportDetailDBInstance.forUpsertSObjects.size());
    }

    @isTest
    private static void requestConsumerCreditCheckFrozenReport() {
        User salesRep = new User();
        salesRep.Id = TestUtility.getFakeId(User.getSObjectType());
        salesRep.Email = 'test1@yopmail.com';

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        newOpportunity.Offer_Notification_To_Guarantor__c = true;
        newOpportunity.Offer_Notification_To_Broker__c = true;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        application.Primary_Guarantor__c = TestUtility.getFakeId(Contact.getSObjectType());
        application.Opportunity__c = TestUtility.getFakeId(Opportunity.getSObjectType());
        application.Industry_Rating__c = 'A+ Medical';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 1413777;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 1;
        application.genesis__Payment_Frequency__c = 'DAILY';
        application.Opportunity__c = newOpportunity.Id;
        application.Opportunity__r = newOpportunity;
        application.Sales_Rep__c = salesRep.Id;
        application.Sales_Rep__r = salesRep;

        Account accountRecord = new Account();
        accountRecord.Id = application.genesis__Account__c;
        accountRecord.Name = 'DELTA FRESH, L.L.C';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);

        Contact contactRecord = new Contact();
        contactRecord.Id = application.Primary_Guarantor__c;
        contactRecord.FirstName = 'John';
        contactRecord.LastName = 'Boos';
        contactRecord.Email = 'test@gmail.com';
        contactRecord.genesis__SSN__c = '1234567!#%$';

        Credit_Report_Detail__c consumerCreditReport = new Credit_Report_Detail__c();
        consumerCreditReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        consumerCreditReport.Contact__c = application.Primary_Guarantor__c;
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

        clcommon__Party__c partyRecord = new clcommon__Party__c();
        partyRecord.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        partyRecord.clcommon__Type__c = partyType.Id;
        partyRecord.clcommon__Type__r = partyType;
        partyRecord.clcommon__isPrimary__c = true;
        partyRecord.genesis__Application__c = application.Id;
        partyRecord.clcommon__Account__c = application.genesis__Account__c;
        partyRecord.clcommon__Contact__c = application.Primary_Guarantor__c;

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        ExperianManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub accountDBInstance = new DBManagerTestsStub();
        accountDBInstance.genericReturnObject = new List<Account> {accountRecord};
        ExperianManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBInstance);

        DBManagerTestsStub contactDBInstance = new DBManagerTestsStub();
        contactDBInstance.genericReturnObject = new List<Contact> {contactRecord};
        ExperianManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBInstance);

        DBManagerTestsStub partyDBInstance = new DBManagerTestsStub();
        partyDBInstance.genericReturnObject = new List<clcommon__Party__c> {partyRecord};
        ExperianManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBInstance);

        DBManagerTestsStub errorLogDBInstance = new DBManagerTestsStub();
        ExperianManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBInstance);

        DBManagerTestsStub creditReportDetailDBInstance = new DBManagerTestsStub();
        ExperianManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBInstance);

        DBManagerTestsStub cusRuleCreditReportDetailDBInstance = new DBManagerTestsStub();
        cusRuleCreditReportDetailDBInstance.genericReturnObject = new List<Credit_Report_Detail__c> {consumerCreditReport};
        BusinessRuleManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, cusRuleCreditReportDetailDBInstance);

        Test.setMock(HttpCalloutMock.class, new ExperianCalloutMock.ExperianConsumerFrozenResponse());
        Test.startTest();
            ExperianManager.requestConsumerCreditCheck(new List<genesis__Applications__c> {application});
        Test.stopTest();

        System.assertEquals(1, contactDBInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void requestConsumerCreditCheckException() {
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        application.Primary_Guarantor__c = TestUtility.getFakeId(Contact.getSObjectType());
        application.Opportunity__c = TestUtility.getFakeId(Opportunity.getSObjectType());
        application.Industry_Rating__c = 'A+ Medical';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 1413777;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 1;
        application.genesis__Payment_Frequency__c = 'DAILY';

        Account accountRecord = new Account();
        accountRecord.Id = application.genesis__Account__c;
        accountRecord.Name = 'DELTA FRESH, L.L.C';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);

        Contact contactRecord = new Contact();
        contactRecord.Id = application.Primary_Guarantor__c;
        contactRecord.FirstName = 'John';
        contactRecord.LastName = 'Boos';
        contactRecord.Email = 'test@gmail.com';

        Credit_Report_Detail__c consumerCreditReport = new Credit_Report_Detail__c();
        consumerCreditReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        consumerCreditReport.Contact__c = application.Primary_Guarantor__c;
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

        clcommon__Party__c partyRecord = new clcommon__Party__c();
        partyRecord.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        partyRecord.clcommon__Type__c = partyType.Id;
        partyRecord.clcommon__Type__r = partyType;
        partyRecord.clcommon__isPrimary__c = true;
        partyRecord.genesis__Application__c = application.Id;
        partyRecord.clcommon__Account__c = application.genesis__Account__c;
        partyRecord.clcommon__Contact__c = application.Primary_Guarantor__c;

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        ExperianManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub accountDBInstance = new DBManagerTestsStub();
        accountDBInstance.genericReturnObject = new List<Account> {accountRecord};
        ExperianManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBInstance);

        DBManagerTestsStub contactDBInstance = new DBManagerTestsStub();
        contactDBInstance.genericReturnObject = new List<Contact> {contactRecord};
        ExperianManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBInstance);

        DBManagerTestsStub partyDBInstance = new DBManagerTestsStub();
        partyDBInstance.genericReturnObject = new List<clcommon__Party__c> {partyRecord};
        ExperianManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBInstance);

        DBManagerTestsStub errorLogDBInstance = new DBManagerTestsStub();
        ExperianManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBInstance);

        DBManagerTestsStub creditReportDetailDBInstance = new DBManagerTestsStub();
        ExperianManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBInstance);

        DBManagerTestsStub cusRuleCreditReportDetailDBInstance = new DBManagerTestsStub();
        cusRuleCreditReportDetailDBInstance.genericReturnObject = new List<Credit_Report_Detail__c> {consumerCreditReport};
        BusinessRuleManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, cusRuleCreditReportDetailDBInstance);

        Test.startTest();
            ExperianManager.requestConsumerCreditCheck(new List<genesis__Applications__c> {application});
        Test.stopTest();

        System.assertEquals(1, errorLogDBInstance.forInsertSObjects.size());
    }

    @isTest
    private static void sendCreditFreezeNotification() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        User salesRep = new User();
        salesRep.Id = TestUtility.getFakeId(User.getSObjectType());
        salesRep.Email = 'test2@yopmail.com';

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        newOpportunity.Offer_Notification_To_Guarantor__c = true;
        newOpportunity.Offer_Notification_To_Broker__c = true;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        application.Primary_Guarantor__c = TestUtility.getFakeId(Contact.getSObjectType());
        application.Opportunity__c = TestUtility.getFakeId(Opportunity.getSObjectType());
        application.Industry_Rating__c = 'A+ Medical';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 1413777;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 1;
        application.genesis__Payment_Frequency__c = 'DAILY';
        application.Last_Status_Update_Date__c = TestUtility.currentSystemDate.addDays(-10);
        application.Opportunity__c = newOpportunity.Id;
        application.Opportunity__r = newOpportunity;
        application.Sales_Rep__c = salesRep.Id;
        application.Sales_Rep__r = salesRep;

        Account accountRecord = new Account();
        accountRecord.Id = application.genesis__Account__c;
        accountRecord.Name = 'DELTA FRESH, L.L.C';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);

        Contact contactRecord = new Contact();
        contactRecord.Id = application.Primary_Guarantor__c;
        contactRecord.FirstName = 'John';
        contactRecord.LastName = 'Boos';
        contactRecord.Email = 'test@gmail.com';
        contactRecord.Credit_Report_Message__c = 'FILE FROZEN';
        contactRecord.Last_Consumer_Credit_Pull__c = GeneralHelper.currentSystemDateTime;
        contactRecord.Last_Date_of_Inquiry__c = GeneralHelper.currentSystemDateTime;

        clcommon__Party_Type__c partyType = new clcommon__Party_Type__c();
        partyType.Name = 'GUARANTOR';
        partyType.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());

        Map<String, Id> partyTypeToId = new Map<String, Id>();
        partyTypeToId.put(partyType.Name, partyType.Id);
        OriginationHelper.partyTypeToId = partyTypeToId;

        clcommon__Party__c partyRecord = new clcommon__Party__c();
        partyRecord.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        partyRecord.clcommon__Type__c = partyType.Id;
        partyRecord.clcommon__Type__r = partyType;
        partyRecord.clcommon__isPrimary__c = true;
        partyRecord.genesis__Application__c = application.Id;
        partyRecord.clcommon__Account__c = application.genesis__Account__c;
        partyRecord.clcommon__Contact__c = application.Primary_Guarantor__c;
        partyRecord.clcommon__Contact__r = contactRecord;
        partyRecord.Credit_Report_Message__c = 'FILE FROZEN';
        partyRecord.Last_Date_of_Inquiry__c = GeneralHelper.currentSystemDateTime;

        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        DBManagerTestsStub partyDBInstance = new DBManagerTestsStub();
        partyDBInstance.genericReturnObject = new List<clcommon__Party__c> {partyRecord};
        ExperianManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        ExperianManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub accountDBInstance = new DBManagerTestsStub();
        accountDBInstance.genericReturnObject = new List<Account> {accountRecord};
        ExperianManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBInstance);

        DBManagerTestsStub contactDBInstance = new DBManagerTestsStub();
        contactDBInstance.genericReturnObject = new List<Contact> {contactRecord};
        ExperianManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBInstance);

        Test.startTest();
            ExperianManager.sendCreditFreezeNotification(new List<genesis__Applications__c> {application});
        Test.stopTest();
        System.assertEquals(1, applicationDBStubInstance.forUpdateSObjects.size());
    }

}