@isTest(isParallel=true)
private class ApplicationManagerTests {

    private static EmailDB emailDBInstance = new EmailDB();

    @isTest
    private static void createApplicationAndParties() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Decimal loanAmount = 5000;
        Id opportunityId = TestUtility.getFakeId(Opportunity.getSObjectType());
        Id guarantorContactId = TestUtility.getFakeId(Contact.getSObjectType());

        List<clcommon__Party_Type__c> partyTypeList = new List<clcommon__Party_Type__c> ();

        clcommon__Party_Type__c partyTypeGuarantor = new clcommon__Party_Type__c();
        partyTypeGuarantor.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());
        partyTypeGuarantor.Name = 'GUARANTOR';
        partyTypeList.add(partyTypeGuarantor);

        clcommon__Party_Type__c partyTypeBorrower = new clcommon__Party_Type__c();
        partyTypeGuarantor.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());
        partyTypeBorrower.Name = 'BORROWER';
        partyTypeList.add(partyTypeBorrower);

        loan__Loan_Product__c loanProduct = new loan__Loan_Product__c();
        loanProduct.Id = TestUtility.getFakeId(loan__Loan_Product__c.getSObjectType());
        loanProduct.loan__Default_Number_of_Installments__c = 6;
        loanProduct.loan__Frequency_of_Loan_Payment__c = GeneralConstants.FREQUENCY_DAILY;

        clcommon__CL_Product__c clProduct = new clcommon__CL_Product__c();
        clProduct.Id = TestUtility.getFakeId(clcommon__CL_Product__c.getSObjectType());
        clProduct.loan__Lending_Product__c = loanProduct.Id;
        clProduct.clcommon__Product_Name__c = 'Test';
        clProduct.clcommon__Class__c = 'Commercial';
        clProduct.loan__Lending_Product__r = loanProduct;

        clcommon__Company__c clCompany = new clcommon__Company__c();
        clCompany.Id = TestUtility.getFakeId(clcommon__Company__c.getSObjectType());
        clCompany.clcommon__Company_Name__c = TestUtility.COMPANY_NAME;
        clCompany.clcommon__Branch_Date__c = TestUtility.currentSystemDate;

        genesis__Company__c company = genesis.TestHelper.createCompany();
        company.Id = TestUtility.getFakeId(genesis__Company__c.getSObjectType());
        company.genesis__Short_Name__c = '1';
        company.Name = GeneralConstants.COMPANY_NAME;

        Account brokerAccount = new Account();
        brokerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        brokerAccount.Name = 'Lead Broker';
        brokerAccount.Type = Leads.BROKER;

        Contact brokerContact = new Contact();
        brokerContact.Id = TestUtility.getFakeId(Contact.getSObjectType());
        brokerContact.FirstName = 'Broker';
        brokerContact.LastName = 'Test Broker';
        brokerContact.AccountId = brokerAccount.Id;
        brokerContact.loan__Contact_Type__c = Leads.BROKER;

        User brokerUserRecord = (User) JSON.deserialize('{"AccountId" : "' + brokerAccount.Id + '"}', User.class);
        brokerUserRecord.Id = TestUtility.getFakeId(User.getSObjectType());
        brokerUserRecord.ContactId = guarantorContactId;

        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountRecord.Name = 'Maher Industries LLC';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);
        accountRecord.Type = 'Borrower';

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {accountRecord};
        ApplicationManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        PartyManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub partyTypeDBStubInstance = new DBManagerTestsStub();
        partyTypeDBStubInstance.genericReturnObject = partyTypeList;
        OriginationHelper.partyTypeDBInstance = (PartyTypeDB) Test.createStub(PartyTypeDB.class, partyTypeDBStubInstance);

        DBManagerTestsStub clProductDBStubInstance = new DBManagerTestsStub();
        clProductDBStubInstance.genericReturnObject = new List<clcommon__CL_Product__c> {clProduct};
        OriginationHelper.clProductDBInstance = (CLProductDB) Test.createStub(CLProductDB.class, clProductDBStubInstance);

        DBManagerTestsStub clCompanyDBStubInstance = new DBManagerTestsStub();
        clCompanyDBStubInstance.genericReturnObject = new List<clcommon__Company__c> {clCompany};
        OriginationHelper.clCompanyDBInstance = (CLCompanyDB) Test.createStub(CLCompanyDB.class, clCompanyDBStubInstance);

        DBManagerTestsStub companyDBStubInstance = new DBManagerTestsStub();
        companyDBStubInstance.genericReturnObject = new List<genesis__Company__c> {company};
        OriginationHelper.companyDBInstance = (CompanyDB) Test.createStub(CompanyDB.class, companyDBStubInstance);

        Test.startTest();

            genesis__Applications__c application = ApplicationManager.createApplicationAndParties(
                opportunityId, loanAmount, accountRecord.Id, accountRecord.Id,
                guarantorContactId, brokerUserRecord, 'New'
            );

        Test.stopTest();

        System.assertEquals(1, applicationDBStubInstance.forInsertSObjects.size());
        System.assertEquals('Calculate Term', application.genesis__Calculation_Action__c);
        System.assertEquals(brokerAccount.Id, application.Broker_Account__c);

    }

    @isTest
    private static void handleBeforeStatusChange() {

        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.AnnualRevenue = 2000000;

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-00000102", "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship"}' ,
            genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Origination_Fee_Percentage__c = 12;
        application.genesis__Collateral_Value__c = 6700;
        application.genesis__Customer_Cash_Available__c = 1500;
        application.genesis__Days_Convention__c = '30/360';
        application.genesis__Estimated_Selling_Price__c = 6700;
        application.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        application.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        application.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        application.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        application.genesis__Fees_Amount__c = 0;
        application.genesis__Financed_Amount__c = 10000;
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Landing_Sequence__c = 3;
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__Other_Financed_fees__c = 0;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.genesis__Product_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
        application.genesis__Sales_Division__c = 'DIRECT';
        application.genesis__Tax_Amount__c = 0;
        application.genesis__Term__c = 12;
        application.genesis__Warranty_Amount__c = 0;
        application.SIC_Code__c = '073';
        application.Primary_Guarantor__c = TestUtility.getFakeId(Contact.getSObjectType());
        application.genesis__Account__c = borrowerAccount.Id;
        application.Maximum_Funding_Amount__c = 12000;
        application.Industry_Rating__c = 'Prohibited';
        application.SC4_Tier__c = 'TIER 1';
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.genesis__Account__r = borrowerAccount;
        application.Decline_Reasons__c = null;
        application.Annual_Volume__c = 123000;
        application.genesis__Status__c = Applications.STATUS_INDUSTRY_CHECK;
        application.Partner_Pricing_Secure_Link__c = 'www.example.com';

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        IndustryRatingProfileManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Map<String, List<genesis__Applications__c>> applicationListByStatus = new Map<String, List<genesis__Applications__c>>();
        applicationListByStatus.put(Applications.STATUS_INDUSTRY_CHECK, new List<genesis__Applications__c> {application});
        Test.startTest();

            ApplicationManager.handleBeforeStatusChange(applicationListByStatus);

        Test.stopTest();
        System.assertEquals('TIER 1', application.SC4_Tier__c);
    }

    @isTest
    private static void handleBeforeStatusChangeToReadyToFund() {

        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.AnnualRevenue = 2000000;

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-00000102", "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship"}' ,
            genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Origination_Fee_Percentage__c = 12;
        application.genesis__Collateral_Value__c = 6700;
        application.genesis__Customer_Cash_Available__c = 1500;
        application.genesis__Days_Convention__c = '30/360';
        application.genesis__Estimated_Selling_Price__c = 6700;
        application.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        application.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        application.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        application.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        application.genesis__Fees_Amount__c = 0;
        application.genesis__Financed_Amount__c = 10000;
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Landing_Sequence__c = 3;
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__Other_Financed_fees__c = 0;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.genesis__Product_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
        application.genesis__Sales_Division__c = 'DIRECT';
        application.genesis__Tax_Amount__c = 0;
        application.genesis__Term__c = 12;
        application.genesis__Warranty_Amount__c = 0;
        application.SIC_Code__c = '073';
        application.Primary_Guarantor__c = TestUtility.getFakeId(Contact.getSObjectType());
        application.genesis__Account__c = borrowerAccount.Id;
        application.Maximum_Funding_Amount__c = 12000;
        application.Industry_Rating__c = 'Prohibited';
        application.SC4_Tier__c = 'TIER 1';
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.genesis__Account__r = borrowerAccount;
        application.Decline_Reasons__c = null;
        application.Annual_Volume__c = 123000;
        application.genesis__Status__c = Applications.STATUS_READY_TO_FUND;
        application.Partner_Pricing_Secure_Link__c = 'www.example.com';

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        IndustryRatingProfileManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Map<String, List<genesis__Applications__c>> applicationListByStatus = new Map<String, List<genesis__Applications__c>>();
        applicationListByStatus.put(Applications.STATUS_READY_TO_FUND, new List<genesis__Applications__c> {application});

        Test.startTest();
            ApplicationManager.handleBeforeStatusChange(applicationListByStatus);
        Test.stopTest();

        System.assertEquals(Applications.STATUS_READY_TO_FUND, application.genesis__Status__c);
    }

    @isTest
    private static void handleAfterStatusChangeConsumerCredit() {
        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.AnnualRevenue = 2000000;

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-00000102", "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship"}' ,
            genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Origination_Fee_Percentage__c = 12;
        application.genesis__Collateral_Value__c = 6700;
        application.genesis__Customer_Cash_Available__c = 1500;
        application.genesis__Days_Convention__c = '30/360';
        application.genesis__Estimated_Selling_Price__c = 6700;
        application.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        application.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        application.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        application.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        application.genesis__Fees_Amount__c = 0;
        application.genesis__Financed_Amount__c = 10000;
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Landing_Sequence__c = 3;
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__Other_Financed_fees__c = 0;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.genesis__Product_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
        application.genesis__Sales_Division__c = 'DIRECT';
        application.genesis__Tax_Amount__c = 0;
        application.genesis__Term__c = 12;
        application.genesis__Warranty_Amount__c = 0;
        application.SIC_Code__c = '073';
        application.Primary_Guarantor__c = TestUtility.getFakeId(Contact.getSObjectType());
        application.genesis__Account__c = borrowerAccount.Id;
        application.Maximum_Funding_Amount__c = 12000;
        application.Industry_Rating__c = 'Prohibited';
        application.SC4_Tier__c = 'TIER 1';
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.genesis__Account__r = borrowerAccount;
        application.Decline_Reasons__c = null;
        application.Annual_Volume__c = 123000;
        application.genesis__Status__c = Applications.STATUS_GUARANTOR_CREDIT_CHECK;

        Map<String, List<genesis__Applications__c>> applicationListByStatus = new Map<String, List<genesis__Applications__c>>();
        applicationListByStatus.put(Applications.STATUS_GUARANTOR_CREDIT_CHECK, new List<genesis__Applications__c> {application});
        Test.startTest();

            ApplicationManager.handleAfterStatusChange(applicationListByStatus);

        Test.stopTest();
        System.assertEquals('TIER 1', application.SC4_Tier__c);
    }

    @isTest
    private static void handleAfterStatusChangeBusinessCredit() {
        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.AnnualRevenue = 2000000;
        borrowerAccount.Last_Business_Credit_Pull__c = null;

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-00000102", "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship"}' ,
            genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Origination_Fee_Percentage__c = 12;
        application.genesis__Collateral_Value__c = 6700;
        application.genesis__Customer_Cash_Available__c = 1500;
        application.genesis__Days_Convention__c = '30/360';
        application.genesis__Estimated_Selling_Price__c = 6700;
        application.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        application.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        application.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        application.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        application.genesis__Fees_Amount__c = 0;
        application.genesis__Financed_Amount__c = 10000;
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Landing_Sequence__c = 3;
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__Other_Financed_fees__c = 0;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.genesis__Product_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
        application.genesis__Sales_Division__c = 'DIRECT';
        application.genesis__Tax_Amount__c = 0;
        application.genesis__Term__c = 12;
        application.genesis__Warranty_Amount__c = 0;
        application.SIC_Code__c = '073';
        application.Primary_Guarantor__c = TestUtility.getFakeId(Contact.getSObjectType());
        application.genesis__Account__c = borrowerAccount.Id;
        application.Maximum_Funding_Amount__c = 12000;
        application.Industry_Rating__c = 'Prohibited';
        application.SC4_Tier__c = 'TIER 1';
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.genesis__Account__r = borrowerAccount;
        application.Decline_Reasons__c = null;
        application.Annual_Volume__c = 123000;
        application.genesis__Status__c = Applications.STATUS_BUSINESS_CREDIT_CHECK;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        ExperianManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {borrowerAccount};
        ExperianManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub creditReportDetailDBStubInstance = new DBManagerTestsStub();
        ExperianManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        ExperianManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);


        Map<String, List<genesis__Applications__c>> applicationListByStatus = new Map<String, List<genesis__Applications__c>>();
        applicationListByStatus.put(Applications.STATUS_BUSINESS_CREDIT_CHECK, new List<genesis__Applications__c> {application});
        Test.startTest();

            ApplicationManager.handleAfterStatusChange(applicationListByStatus);

        Test.stopTest();
        System.assertEquals(Applications.STATUS_BUSINESS_CREDIT_CHECK, application.genesis__Status__c);
    }

    @isTest
    private static void handleAfterStatusChangeCanScoring() {
        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.AnnualRevenue = 2000000;

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-00000102", "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship"}' ,
            genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Origination_Fee_Percentage__c = 12;
        application.genesis__Collateral_Value__c = 6700;
        application.genesis__Customer_Cash_Available__c = 1500;
        application.genesis__Days_Convention__c = '30/360';
        application.genesis__Estimated_Selling_Price__c = 6700;
        application.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        application.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        application.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        application.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        application.genesis__Fees_Amount__c = 0;
        application.genesis__Financed_Amount__c = 10000;
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Landing_Sequence__c = 3;
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__Other_Financed_fees__c = 0;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.genesis__Product_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
        application.genesis__Sales_Division__c = 'DIRECT';
        application.genesis__Tax_Amount__c = 0;
        application.genesis__Term__c = 12;
        application.genesis__Warranty_Amount__c = 0;
        application.SIC_Code__c = '073';
        application.Primary_Guarantor__c = TestUtility.getFakeId(Contact.getSObjectType());
        application.genesis__Account__c = borrowerAccount.Id;
        application.Maximum_Funding_Amount__c = 12000;
        application.Industry_Rating__c = 'Prohibited';
        application.SC4_Tier__c = 'TIER 1';
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.genesis__Account__r = borrowerAccount;
        application.Decline_Reasons__c = null;
        application.Annual_Volume__c = 123000;
        application.genesis__Status__c = Applications.STATUS_CAN_SCORING;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        CANScoringManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub creditReportDetailDBStubInstance = new DBManagerTestsStub();
        CANScoringManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CANScoringManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Map<String, List<genesis__Applications__c>> applicationListByStatus = new Map<String, List<genesis__Applications__c>>();
        applicationListByStatus.put(Applications.STATUS_CAN_SCORING, new List<genesis__Applications__c> {application});

        Test.startTest();

            ApplicationManager.handleAfterStatusChange(applicationListByStatus);

        Test.stopTest();
        System.assertEquals(Applications.STATUS_CAN_SCORING, application.genesis__Status__c);
    }

    @isTest
    private static void handleAfterStatusChangeLexisNexisCheck() {
        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.AnnualRevenue = 2000000;

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'JOHN';
        contactRecord.LastName = 'BOSS';

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-00000102", "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship"}' ,
            genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Origination_Fee_Percentage__c = 12;
        application.genesis__Collateral_Value__c = 6700;
        application.genesis__Customer_Cash_Available__c = 1500;
        application.genesis__Days_Convention__c = '30/360';
        application.genesis__Estimated_Selling_Price__c = 6700;
        application.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        application.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        application.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        application.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        application.genesis__Fees_Amount__c = 0;
        application.genesis__Financed_Amount__c = 10000;
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Landing_Sequence__c = 3;
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__Other_Financed_fees__c = 0;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.genesis__Product_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
        application.genesis__Sales_Division__c = 'DIRECT';
        application.genesis__Tax_Amount__c = 0;
        application.genesis__Term__c = 12;
        application.genesis__Warranty_Amount__c = 0;
        application.SIC_Code__c = '073';
        application.Primary_Guarantor__c = contactRecord.Id;
        application.genesis__Account__c = borrowerAccount.Id;
        application.Maximum_Funding_Amount__c = 12000;
        application.Industry_Rating__c = 'Prohibited';
        application.SC4_Tier__c = 'TIER 1';
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.genesis__Account__r = borrowerAccount;
        application.Decline_Reasons__c = null;
        application.Annual_Volume__c = 123000;
        application.genesis__Status__c = Applications.STATUS_LEXISNEXIS_CHECK;

        List<clcommon__Party__c> partyList = new List<clcommon__Party__c> ();
        List<clcommon__Party_Type__c> partyTypeList = new List<clcommon__Party_Type__c> ();

        clcommon__Party_Type__c partyTypeGuarantor = new clcommon__Party_Type__c();
        partyTypeGuarantor.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());
        partyTypeGuarantor.Name = 'GUARANTOR';
        partyTypeList.add(partyTypeGuarantor);

        clcommon__Party_Type__c partyTypeBorrower = new clcommon__Party_Type__c();
        partyTypeGuarantor.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());
        partyTypeBorrower.Name = 'BORROWER';
        partyTypeList.add(partyTypeBorrower);

        clcommon__Party__c partyBorrower = new clcommon__Party__c();
        partyBorrower.clcommon__Account__c = application.genesis__Account__c;
        partyBorrower.genesis__Application__c = application.Id;
        partyBorrower.clcommon__Type__c = partyTypeBorrower.Id;
        partyBorrower.clcommon__isPrimary__c = false;
        partyBorrower.genesis__Application__r = application;
        partyList.add(partyBorrower);

        clcommon__Party__c partyGuarantor = new clcommon__Party__c();
        partyGuarantor.clcommon__Account__c = application.genesis__Account__c;
        partyGuarantor.genesis__Application__c = application.Id;
        partyGuarantor.clcommon__Type__c = partyTypeGuarantor.Id;
        partyGuarantor.clcommon__isPrimary__c = true;
        partyGuarantor.clcommon__Contact__c = application.Primary_Guarantor__c;
        partyGuarantor.genesis__Application__r = application;
        partyList.add(partyGuarantor);

        List<UnderWriter_Task__c> uwList = new List<UnderWriter_Task__c>();
        UnderWriter_Task__c uwProofOfOwnership = new UnderWriter_Task__c();
        uwProofOfOwnership.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        uwProofOfOwnership.Task_Name__c = LexisNexiss.TASK_TYPE_PROOF_OF_OWNERSHIP;
        uwProofOfOwnership.Application__c = application.Id;
        uwList.add(uwProofOfOwnership);

        UnderWriter_Task__c uwLegalName = new UnderWriter_Task__c();
        uwLegalName.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        uwLegalName.Task_Name__c = LexisNexiss.TASK_TYPE_LEGAL_NAME;
        uwLegalName.Application__c = application.Id;
        uwList.add(uwLegalName);

        UnderWriter_Task__c uwLegalAddress = new UnderWriter_Task__c();
        uwLegalAddress.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        uwLegalAddress.Task_Name__c = LexisNexiss.TASK_TYPE_LEGAL_ADDRESS;
        uwLegalAddress.Application__c = application.Id;
        uwList.add(uwLegalAddress);

        UnderWriter_Task__c uwCANHistory = new UnderWriter_Task__c();
        uwCANHistory.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        uwCANHistory.Task_Name__c = LexisNexiss.TASK_TYPE_PRIOR_CAN_HISTORY;
        uwCANHistory.Application__c = application.Id;
        uwList.add(uwCANHistory);

        UnderWriter_Task__c uwBusinessPhone = new UnderWriter_Task__c();
        uwBusinessPhone.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        uwBusinessPhone.Task_Name__c = LexisNexiss.TASK_TYPE_BUSINESS_PHONE;
        uwBusinessPhone.Application__c = application.Id;
        uwList.add(uwBusinessPhone);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        LexisNexisManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        LexisNexisManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        DBManagerTestsStub creditReportDetailDBStubInstance = new DBManagerTestsStub();
        LexisNexisManager.creditReportDetailDBInstance =
            (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBStubInstance);

        DBManagerTestsStub underWriterTaskDBStubInstance = new DBManagerTestsStub();
        underWriterTaskDBStubInstance.genericReturnObject = uwList;
        LexisNexisManager.underWriterTaskDBInstance = (UnderWriterTaskDB) Test.createStub(UnderWriterTaskDB.class, underWriterTaskDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {borrowerAccount};
        LexisNexisManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact> {contactRecord};
        LexisNexisManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = partyList;
        LexisNexisManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        DBManagerTestsStub partyTypeDBStubInstance = new DBManagerTestsStub();
        partyTypeDBStubInstance.genericReturnObject = partyTypeList;
        OriginationHelper.partyTypeDBInstance = (PartyTypeDB) Test.createStub(PartyTypeDB.class, partyTypeDBStubInstance);

        Map<String, List<genesis__Applications__c>> applicationListByStatus = new Map<String, List<genesis__Applications__c>>();
        applicationListByStatus.put(Applications.STATUS_LEXISNEXIS_CHECK, new List<genesis__Applications__c> {application});

        Test.startTest();

            ApplicationManager.handleAfterStatusChange(applicationListByStatus);

        Test.stopTest();
        System.assertEquals(Applications.STATUS_LEXISNEXIS_CHECK, application.genesis__Status__c);
    }

    @isTest
    private static void handleAfterStatusChangeBankUpload() {
        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.AnnualRevenue = 2000000;

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'JOHN';
        contactRecord.LastName = 'BOSS';

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-00000102", "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship"}' ,
            genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Origination_Fee_Percentage__c = 12;
        application.genesis__Collateral_Value__c = 6700;
        application.genesis__Customer_Cash_Available__c = 1500;
        application.genesis__Days_Convention__c = '30/360';
        application.genesis__Estimated_Selling_Price__c = 6700;
        application.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        application.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        application.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        application.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        application.genesis__Fees_Amount__c = 0;
        application.genesis__Financed_Amount__c = 10000;
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Landing_Sequence__c = 3;
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__Other_Financed_fees__c = 0;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.genesis__Product_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
        application.genesis__Sales_Division__c = 'DIRECT';
        application.genesis__Tax_Amount__c = 0;
        application.genesis__Term__c = 12;
        application.genesis__Warranty_Amount__c = 0;
        application.SIC_Code__c = '073';
        application.Primary_Guarantor__c = contactRecord.Id;
        application.genesis__Account__c = borrowerAccount.Id;
        application.Maximum_Funding_Amount__c = 12000;
        application.Industry_Rating__c = 'Prohibited';
        application.SC4_Tier__c = 'TIER 1';
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.genesis__Account__r = borrowerAccount;
        application.Decline_Reasons__c = null;
        application.Annual_Volume__c = 123000;
        application.genesis__Status__c = Applications.STATUS_BANK_STATEMENT_UPLOAD;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.ocrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        Map<String, List<genesis__Applications__c>> applicationListByStatus = new Map<String, List<genesis__Applications__c>>();
        applicationListByStatus.put(Applications.STATUS_BANK_STATEMENT_UPLOAD, new List<genesis__Applications__c> {application});
        Test.startTest();

            ApplicationManager.handleAfterStatusChange(applicationListByStatus);

        Test.stopTest();
        System.assertEquals(Applications.STATUS_BANK_STATEMENT_UPLOAD, application.genesis__Status__c);
    }

    @isTest
    private static void handleAfterStatusChangePricingGeneration() {
        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.AnnualRevenue = 2000000;

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'JOHN';
        contactRecord.LastName = 'BOSS';

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-00000102", "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship"}' ,
            genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Origination_Fee_Percentage__c = 12;
        application.genesis__Collateral_Value__c = 6700;
        application.genesis__Customer_Cash_Available__c = 1500;
        application.genesis__Days_Convention__c = '30/360';
        application.genesis__Estimated_Selling_Price__c = 6700;
        application.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        application.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        application.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        application.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        application.genesis__Fees_Amount__c = 0;
        application.genesis__Financed_Amount__c = 10000;
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Landing_Sequence__c = 3;
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__Other_Financed_fees__c = 0;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.genesis__Product_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
        application.genesis__Sales_Division__c = 'DIRECT';
        application.genesis__Tax_Amount__c = 0;
        application.genesis__Term__c = 12;
        application.genesis__Warranty_Amount__c = 0;
        application.SIC_Code__c = '073';
        application.Primary_Guarantor__c = contactRecord.Id;
        application.genesis__Account__c = borrowerAccount.Id;
        application.Maximum_Funding_Amount__c = 12000;
        application.Industry_Rating__c = 'Prohibited';
        application.SC4_Tier__c = 'TIER 1';
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.genesis__Account__r = borrowerAccount;
        application.Decline_Reasons__c = null;
        application.Annual_Volume__c = 123000;
        application.genesis__Status__c = Applications.STATUS_PRICING_GENERATION;

        Map<String, List<genesis__Applications__c>> applicationListByStatus = new Map<String, List<genesis__Applications__c>>();
        applicationListByStatus.put(Applications.STATUS_PRICING_GENERATION, new List<genesis__Applications__c> {application});
        Test.startTest();

            ApplicationManager.handleAfterStatusChange(applicationListByStatus);

        Test.stopTest();
        System.assertEquals(Applications.STATUS_PRICING_GENERATION, application.genesis__Status__c);
    }

    @isTest
    private static void handleAfterStatusChangeDocsIn() {
        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.AnnualRevenue = 2000000;

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'JOHN';
        contactRecord.LastName = 'BOSS';

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-00000102", "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship"}' ,
            genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Origination_Fee_Percentage__c = 12;
        application.genesis__Collateral_Value__c = 6700;
        application.genesis__Customer_Cash_Available__c = 1500;
        application.genesis__Days_Convention__c = '30/360';
        application.genesis__Estimated_Selling_Price__c = 6700;
        application.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        application.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        application.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        application.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        application.genesis__Fees_Amount__c = 0;
        application.genesis__Financed_Amount__c = 10000;
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Landing_Sequence__c = 3;
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__Other_Financed_fees__c = 0;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.genesis__Product_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
        application.genesis__Sales_Division__c = 'DIRECT';
        application.genesis__Tax_Amount__c = 0;
        application.genesis__Term__c = 12;
        application.genesis__Warranty_Amount__c = 0;
        application.SIC_Code__c = '073';
        application.Primary_Guarantor__c = contactRecord.Id;
        application.genesis__Account__c = borrowerAccount.Id;
        application.Maximum_Funding_Amount__c = 12000;
        application.Industry_Rating__c = 'Prohibited';
        application.SC4_Tier__c = 'TIER 1';
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.genesis__Account__r = borrowerAccount;
        application.Decline_Reasons__c = null;
        application.Annual_Volume__c = 123000;
        application.genesis__Status__c = Applications.STATUS_DOCS_IN;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        CaseManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub caseDBStubInstance = new DBManagerTestsStub();
        caseDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        CaseManager.CaseDBInstance = (CaseDB) Test.createStub(CaseDB.class, caseDBStubInstance);

        Map<String, List<genesis__Applications__c>> applicationListByStatus = new Map<String, List<genesis__Applications__c>>();
        applicationListByStatus.put(Applications.STATUS_DOCS_IN, new List<genesis__Applications__c> {application});
        Test.startTest();

            ApplicationManager.handleAfterStatusChange(applicationListByStatus);

        Test.stopTest();
        System.assertEquals(Applications.STATUS_DOCS_IN, application.genesis__Status__c);
    }

    @isTest
    private static void handleAfterStatusChangeOfferAcceptedException() {
        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.AnnualRevenue = 2000000;

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'JOHN';
        contactRecord.LastName = 'BOSS';

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-00000102", "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship"}' ,
            genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Origination_Fee_Percentage__c = 12;
        application.genesis__Collateral_Value__c = 6700;
        application.genesis__Customer_Cash_Available__c = 1500;
        application.genesis__Days_Convention__c = '30/360';
        application.genesis__Estimated_Selling_Price__c = 6700;
        application.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        application.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        application.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        application.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        application.genesis__Fees_Amount__c = 0;
        application.genesis__Financed_Amount__c = 10000;
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Landing_Sequence__c = 3;
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__Other_Financed_fees__c = 0;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.genesis__Product_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
        application.genesis__Sales_Division__c = 'DIRECT';
        application.genesis__Tax_Amount__c = 0;
        application.genesis__Term__c = 12;
        application.genesis__Warranty_Amount__c = 0;
        application.SIC_Code__c = '073';
        application.Primary_Guarantor__c = contactRecord.Id;
        application.genesis__Account__c = borrowerAccount.Id;
        application.Maximum_Funding_Amount__c = 12000;
        application.Industry_Rating__c = 'Prohibited';
        application.SC4_Tier__c = 'TIER 1';
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.genesis__Account__r = borrowerAccount;
        application.Decline_Reasons__c = null;
        application.Annual_Volume__c = 123000;
        application.Pricing_Factor__c = 1.2;
        application.genesis__Status__c = Applications.STATUS_OFFER_ACCEPTED;

        Map<String, List<genesis__Applications__c>> applicationListByStatus = new Map<String, List<genesis__Applications__c>>();
        applicationListByStatus.put(Applications.STATUS_OFFER_ACCEPTED, new List<genesis__Applications__c> {application});
        Test.startTest();
            try {
                ApplicationManager.handleAfterStatusChange(applicationListByStatus);
            } catch (Exception e) {
            }

        Test.stopTest();
        System.assertEquals(Applications.STATUS_OFFER_ACCEPTED, application.genesis__Status__c);
    }

    @isTest
    private static void handleAfterStatusChangeOfferAccepted() {
        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.AnnualRevenue = 2000000;

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'JOHN';
        contactRecord.LastName = 'BOSS';

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-00000102", "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship"}' ,
            genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Origination_Fee_Percentage__c = 12;
        application.genesis__Collateral_Value__c = 6700;
        application.genesis__Customer_Cash_Available__c = 1500;
        application.genesis__Days_Convention__c = '30/360';
        application.genesis__Estimated_Selling_Price__c = 6700;
        application.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        application.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        application.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        application.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        application.genesis__Fees_Amount__c = 0;
        application.genesis__Financed_Amount__c = 10000;
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Landing_Sequence__c = 3;
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__Other_Financed_fees__c = 0;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.genesis__Product_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
        application.genesis__Sales_Division__c = 'DIRECT';
        application.genesis__Tax_Amount__c = 0;
        application.genesis__Term__c = 12;
        application.genesis__Warranty_Amount__c = 0;
        application.SIC_Code__c = '073';
        application.Primary_Guarantor__c = contactRecord.Id;
        application.genesis__Account__c = borrowerAccount.Id;
        application.Maximum_Funding_Amount__c = 12000;
        application.Industry_Rating__c = 'Prohibited';
        application.SC4_Tier__c = 'TIER 1';
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.genesis__Account__r = borrowerAccount;
        application.Decline_Reasons__c = null;
        application.Annual_Volume__c = 123000;
        application.Pricing_Factor__c = 1.2;
        application.genesis__Status__c = Applications.STATUS_OFFER_ACCEPTED;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        Map<String, List<genesis__Applications__c>> applicationListByStatus = new Map<String, List<genesis__Applications__c>>();
        applicationListByStatus.put(Applications.STATUS_OFFER_ACCEPTED, new List<genesis__Applications__c> {application});
        Test.startTest();

            ApplicationManager.handleAfterStatusChange(applicationListByStatus);

        Test.stopTest();
        System.assertEquals(Applications.STATUS_OFFER_ACCEPTED, application.genesis__Status__c);
    }

    @isTest
    private static void setAcceptedPricingDetailsToApplication() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.AnnualRevenue = 2000000;

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'JOHN';
        contactRecord.LastName = 'BOSS';

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-00000102", "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship"}' ,
            genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Origination_Fee_Percentage__c = 12;
        application.genesis__Collateral_Value__c = 6700;
        application.genesis__Customer_Cash_Available__c = 1500;
        application.genesis__Days_Convention__c = '30/360';
        application.genesis__Estimated_Selling_Price__c = 6700;
        application.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        application.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        application.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        application.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        application.genesis__Fees_Amount__c = 0;
        application.genesis__Financed_Amount__c = 10000;
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Landing_Sequence__c = 3;
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__Other_Financed_fees__c = 0;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.genesis__Product_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
        application.genesis__Sales_Division__c = 'DIRECT';
        application.genesis__Tax_Amount__c = 0;
        application.genesis__Term__c = 12;
        application.genesis__Warranty_Amount__c = 0;
        application.SIC_Code__c = '073';
        application.Primary_Guarantor__c = contactRecord.Id;
        application.genesis__Account__c = borrowerAccount.Id;
        application.Maximum_Funding_Amount__c = 88110.07;
        application.Industry_Rating__c = 'Prohibited';
        application.SC4_Tier__c = 'TIER 1';
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.genesis__Account__r = borrowerAccount;
        application.Decline_Reasons__c = null;
        application.Annual_Volume__c = 123000;
        application.Pricing_Factor__c = 1;

        loan__Loan_Account__c clContract = (loan__Loan_Account__c) JSON.deserialize(
            '{ "Concurrent_Eligible_Amount__c" : "2000"}' , loan__Loan_Account__c.class
        );
        clContract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        application.Renewal_Concurrent_LoanAccount__r = clContract;

        CAN_Pricing_Detail__c pricingDetail =  new CAN_Pricing_Detail__c();
        pricingDetail.Id = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());
        pricingDetail.Application__c = application.Id;
        pricingDetail.Account__c = application.genesis__Account__c;
        pricingDetail.Opportunity__c = application.Opportunity__c;
        pricingDetail.Industry_Rating__c = application.Industry_Rating__c;
        pricingDetail.SC4_Tier__c = application.SC4_Tier__c;
        pricingDetail.Annual_Volume__c = application.Annual_Volume__c;
        pricingDetail.Loan_Type__c = application.Type__c;
        pricingDetail.Origination_Fee_Percentage__c = application.Origination_Fee_Percentage__c;
        pricingDetail.Origination_Fee_Amount__c = application.Origination_Fee_Amount__c;
        pricingDetail.Payment_Frequency__c = application.genesis__Payment_Frequency__c;
        pricingDetail.Status__c = 'Accepted';
        pricingDetail.Ocrolus_Max_Daily_Payment__c = 132462;
        pricingDetail.Maximum_Exception_Amount__c = 132462;
        pricingDetail.Selected_Amount__c = 5000;
        pricingDetail.Maximum_Amount__c = 10000;
        pricingDetail.Term__c = 6;
        pricingDetail.Maximum_Term__c = 6;
        pricingDetail.Standard_Commission__c = 100;
        pricingDetail.Buy_Rate__c = 1.2;
        pricingDetail.Pricing_Factor__c = 1.2;

        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>();
        applicationMap.put(application.Id, application);

        DBManagerTestsStub pricingDetailDBStubInstance = new DBManagerTestsStub();
        pricingDetailDBStubInstance.genericReturnObject = new List<CAN_Pricing_Detail__c> {pricingDetail};
        ApplicationManager.canPricingDetailDBInstance = (CANPricingDetailDB) Test.createStub(CANPricingDetailDB.class, pricingDetailDBStubInstance);

        LoanCalculatorManagerTestStub loanCalculatorManagerTestStubInstance = new LoanCalculatorManagerTestStub();
        Applications.loanCalculatorManagerInstance = (LoanCalculatorManager) Test.createStub(
            LoanCalculatorManager.class, loanCalculatorManagerTestStubInstance
        );

        Test.startTest();
            ApplicationManager.setAcceptedPricingDetailsToApplication(applicationMap);
        Test.stopTest();

        System.assertEquals(pricingDetail.Pricing_Factor__c, application.Pricing_Factor__c);
    }

    @isTest
    private static void sendSTIPsIncompleteNotification() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.AnnualRevenue = 2000000;
        borrowerAccount.Name = 'Magar Industries LLC';
        borrowerAccount.Merchant_ID__c = '3123123';

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'JOHN';
        contactRecord.LastName = 'BOSS';

        STIPS_Checklist__c stipsCheckList = new STIPS_Checklist__c();
        stipsCheckList.Id = TestUtility.getFakeId(STIPS_Checklist__c.getSObjectType());
        stipsCheckList.Additional_Banks__c = false;
        stipsCheckList.Bank_Verification_Call__c = true;
        stipsCheckList.Borrower_Interview__c = true;
        stipsCheckList.Competitors__c = false;
        stipsCheckList.Federal_Tax_ID__c = true;
        stipsCheckList.Identification__c = false;
        stipsCheckList.Month_to_Date_Bank_Statement__c = false;
        stipsCheckList.Proof_of_Ownership__c = true;
        stipsCheckList.Verification_Call__c = true;
        stipsCheckList.Voided_Check__c = false;
        stipsCheckList.Last_Four_Bank_Account_Number__c = null;
        stipsCheckList.Guarantors_Whose_Identity_Not_Verified__c = null;
        stipsCheckList.Competitor_Names__c = null;

        List<STIPS_Checklist__c> stipsCheckListsList = new List<STIPS_Checklist__c>{stipsCheckList};
        String jsonStipsCheckList = '{"totalSize" : 1, "done" : true, "records" : ' + JSON.serialize(stipsCheckListsList, false) + '}';

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Id = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());
        pricingDetail.Maximum_Amount__c = 5000;
        pricingDetail.Industry_Rating__c = 'A+ Medical';
        pricingDetail.SC4_Tier__c = 'TIER 1';
        pricingDetail.Annual_Volume__c = 1231232;
        pricingDetail.Loan_Type__c = 'New';
        pricingDetail.Origination_Fee_Percentage__c = 14;
        pricingDetail.Origination_Fee_Amount__c = 299;
        pricingDetail.Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        pricingDetail.Status__c = 'Sent To Customer';
        pricingDetail.Ocrolus_Max_Daily_Payment__c = 132462;
        pricingDetail.Term__c = 6;
        pricingDetail.Maximum_Term__c = 6;
        pricingDetail.Buy_Rate__c = 6;
        pricingDetail.Maximum_Exception_Amount__c = 6000;

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        newOpportunity.Offer_Notification_To_Guarantor__c = true;
        newOpportunity.Offer_Notification_To_Broker__c = true;

        List<CAN_Pricing_Detail__c> pricingDetailList = new List<CAN_Pricing_Detail__c>{pricingDetail};
        String jsonPricingDetailList = '{"totalSize" : 1, "done" : true, "records" :' + JSON.serialize(pricingDetailList, false) + '}';

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{"Name" : "APP-00000102", "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship", ' +
                '"Time_In_Business__c" : "1", "Sales_Rep__r.Email" : "sales@youtest.com", "Max_Broker_Commission__c" : "120", ' +
            	'"STIPS_Checklists__r" : ' + jsonStipsCheckList + ', "CAN_Pricing_Details__r" : ' + jsonPricingDetailList +
            '}' , genesis__Applications__c.class
        );

        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Origination_Fee_Percentage__c = 12;
        application.genesis__Collateral_Value__c = 6700;
        application.genesis__Customer_Cash_Available__c = 1500;
        application.genesis__Days_Convention__c = '30/360';
        application.genesis__Estimated_Selling_Price__c = 6700;
        application.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        application.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        application.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        application.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        application.genesis__Fees_Amount__c = 0;
        application.genesis__Financed_Amount__c = 10000;
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Landing_Sequence__c = 3;
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__Other_Financed_fees__c = 0;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.genesis__Product_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
        application.genesis__Sales_Division__c = 'DIRECT';
        application.genesis__Tax_Amount__c = 0;
        application.genesis__Term__c = 12;
        application.genesis__Warranty_Amount__c = 0;
        application.SIC_Code__c = '073';
        application.Primary_Guarantor__c = contactRecord.Id;
        application.genesis__Account__c = borrowerAccount.Id;
        application.Maximum_Funding_Amount__c = 12000;
        application.Industry_Rating__c = 'Prohibited';
        application.SC4_Tier__c = 'TIER 1';
        application.Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;
        application.genesis__Account__r = borrowerAccount;
        application.Decline_Reasons__c = null;
        application.Annual_Volume__c = 123000;
        application.Pricing_Factor__c = 1.2;
        application.Max_Term__c =6;
        application.Buy_Rate__c = 1.2;
        application.genesis__Requested_Loan_Amount__c = 1009;
        application.Opportunity__c = newOpportunity.Id;
        application.Opportunity__r = newOpportunity;

        stipsCheckList.Application__c = application.Id;

        loan__Loan_Account__c clContract = (loan__Loan_Account__c) JSON.deserialize(
            '{ "Concurrent_Eligible_Amount__c" : "2000"}' , loan__Loan_Account__c.class
        );
        clContract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        application.Renewal_Concurrent_LoanAccount__r = clContract;

        Account accountRecord = new Account();
        accountRecord.Id = application.genesis__Account__c;
        accountRecord.Name = 'Business Account';
        accountRecord.Commision_Based_On__c = Brokers.COMMISSION_CALC_METHOD_FLAT;
        accountRecord.Is_Flat_Renewal__c = true;
        accountRecord.New_Max_Broker_Commission__c = 500;
        accountRecord.Renewal_Amount_Commission__c = Brokers.COMMISSION_CALC_METHOD_FLAT;

        Contact brokerContact = new Contact();
        brokerContact.Id = TestUtility.getFakeId(Contact.getSObjectType());
        brokerContact.Email = 'test@yopmail.com';
        brokerContact.Account = accountRecord;

        User salesRep = new User();
        salesRep.Id = TestUtility.getFakeId(User.getSObjectType());
        salesRep.Email = 'test1@yopmail.com';

        //application.Broker_Contact__c = brokerContact.Id;
        //application.Broker_Contact__r = brokerContact;
        application.Sales_Rep__c = salesRep.Id;
        application.Sales_Rep__r = salesRep;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Max_Daily_Payment__c = 1000;

        CAN_Max_Amount_And_Max_Term_Mapping__c canMaxAmountMaxTerm = new CAN_Max_Amount_And_Max_Term_Mapping__c();
        canMaxAmountMaxTerm.Id = TestUtility.getFakeId(CAN_Max_Amount_And_Max_Term_Mapping__c.getSObjectType());
        canMaxAmountMaxTerm.Loan_Type__c = application.Type__c;
        canMaxAmountMaxTerm.Industry_Rating__c = application.Industry_Rating__c;
        canMaxAmountMaxTerm.SC4_Tier__c = application.SC4_Tier__c;
        canMaxAmountMaxTerm.Maximum_Term__c = 6;
        canMaxAmountMaxTerm.Maximum_Amount_Single_Location__c = 2000;

        CAN_Pricing_Matrix_Detail__c canPricingMatrixDetail = new CAN_Pricing_Matrix_Detail__c();
        canPricingMatrixDetail.Id = TestUtility.getFakeId(CAN_Pricing_Matrix_Detail__c.getSObjectType());
        canPricingMatrixDetail.Term__c = 6;
        canPricingMatrixDetail.Loan_Type__c = GeneralConstants.LOAN_TYPE_NEW;
        canPricingMatrixDetail.SC4_Tier__c = application.SC4_Tier__c;
        canPricingMatrixDetail.Industry_Rating__c = application.Industry_Rating__c;
        canPricingMatrixDetail.Pricing_Rate__c = 2.2;

        CAN_GAV_Matrix_Detail__c canGavMatrix = new CAN_GAV_Matrix_Detail__c();
        canGavMatrix.Id = TestUtility.getFakeId(CAN_GAV_Matrix_Detail__c.getSObjectType());
        canGavMatrix.Term__c = 6;
        canGavMatrix.SC4_Tier__c = application.SC4_Tier__c;
        canGavMatrix.Industry_Rating__c = application.Industry_Rating__c;
        canGavMatrix.GAV__c = 3;

        Document canLogo = new Document();
        canLogo.Id = TestUtility.getFakeId(Document.getSObjectType());
        canLogo.Name = 'CAN_CAPITAL_IMAGE_PURPLE_BG';
        canLogo.DeveloperName = 'CAN_CAPITAL_IMAGE_PURPLE_BG';

        GeneralHelper.domainUrl = 'https://www.test.com--main/domain';

        Site siteDetails = (Site) JSON.deserialize(
            '{ "Name" : "instanceSite", "Subdomain" : "subdomain/name", "UrlPathPrefix" : "path/prefix" }' , Site.class
        );

        EmailTemplate emailTemplate = new EmailTemplate();
        emailTemplate.Id = TestUtility.getFakeId(EmailTemplate.getSObjectType());
        emailTemplate.Name = 'Broker_Credit_Incomplete';
        emailTemplate.Subject = 'STIPS Incomplete {{LEGAL_ENTITY_NAME}} {{BROKER_COMPANY_NAME}} {{MERCHANT_ID}}';
        emailTemplate.Body = 'Stips is not completed{{APPLICATION_NAME}} {{MAX_FUNDING_AMOUNT}}' +
            '{{MAX_TERM}} {{BUY_RATE}} {{MAX_COMMISSION}} {{ORIGINATION_FEE_PERCENTAGE}} {{PAYMENT_FREQUENCY}} {{IMAGE__LOGO}}'+
            '{{BROKER_PORTAL_LINK}} {{OFFER_APPROVED_STANDARD_START}} {{OFFER_APPROVED_STANDARD_END}} {{OFFER_APPROVED_COUNTER_OFFER_START}}' +
            '{{OFFER_APPROVED_COUNTER_OFFER_END}} {{STANDARD_START}} {{STANDARD_END}} {{COUNTER_OFFER_START}} {{COUNTER_OFFER_END}}';
        emailTemplate.HtmlValue = 'Stips is not completed {{APPLICATION_NAME}} {{MAX_FUNDING_AMOUNT}}' +
            '{{MAX_TERM}} {{BUY_RATE}} {{MAX_COMMISSION}} {{ORIGINATION_FEE_PERCENTAGE}} {{PAYMENT_FREQUENCY}} {{IMAGE__LOGO}}'+
            '{{BROKER_PORTAL_LINK}} {{OFFER_APPROVED_STANDARD_START}} {{OFFER_APPROVED_STANDARD_END}} {{OFFER_APPROVED_COUNTER_OFFER_START}}' +
            '{{OFFER_APPROVED_COUNTER_OFFER_END}} {{STANDARD_START}} {{STANDARD_END}} {{COUNTER_OFFER_START}} {{COUNTER_OFFER_END}}';
        emailTemplate.DeveloperName = 'Broker_Credit_Incomplete';

        List<UnderWriter_Task__c> uwList = new List<UnderWriter_Task__c>();
        List<Credit_Report_Detail__c> creditReportList = new List<Credit_Report_Detail__c>();

        UnderWriter_Task__c uwFraudAlert = new UnderWriter_Task__c();
        uwFraudAlert.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        uwFraudAlert.Task_Name__c = 'OCR Fraud Alert';
        uwFraudAlert.Application__c = application.Id;
        uwList.add(uwFraudAlert);

        UnderWriter_Task__c uwExperianFraud = new UnderWriter_Task__c();
        uwExperianFraud.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        uwExperianFraud.Task_Name__c = 'Experian Fraud Alert';
        uwExperianFraud.Application__c = application.Id;
        uwList.add(uwExperianFraud);

        Credit_Report_Detail__c creditReportConsumer = new Credit_Report_Detail__c();
        creditReportConsumer.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        creditReportConsumer.Type__c = 'Experian Consumer';
        creditReportConsumer.Contact__c = application.Primary_Guarantor__c;
        creditReportList.add(creditReportConsumer);

        Credit_Report_Detail__c creditReportBusiness = new Credit_Report_Detail__c();
        creditReportBusiness.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        creditReportBusiness.Type__c = 'Experian Business';
        creditReportBusiness.Account__c = application.genesis__Account__c;
        creditReportList.add(creditReportBusiness);

        Credit_Report_Detail__c creditReportLexisNexis = new Credit_Report_Detail__c();
        creditReportLexisNexis.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        creditReportLexisNexis.Application__c = application.Id;
        creditReportLexisNexis.Type__c = 'Lexis Nexis';
        creditReportList.add(creditReportLexisNexis);

        clcommon__Party_Type__c partyTypeGuarantor = new clcommon__Party_Type__c();
        partyTypeGuarantor.Name = GeneralConstants.PARTY_TYPE_GUARANTOR;
        partyTypeGuarantor.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());

        Map<String, Id> partyTypeToId = new Map<String, Id>();
        partyTypeToId.put(partyTypeGuarantor.Name, partyTypeGuarantor.Id);
        OriginationHelper.partyTypeToId = partyTypeToId;

        List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();
        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        party.clcommon__Account__c = application.genesis__Account__c;
        party.genesis__Application__c = application.Id;
        party.clcommon__isPrimary__c = false;
        party.clcommon__Type__c = partyTypeGuarantor.Id;
        party.clcommon__Contact__c = contactRecord.Id;
        partyList.add(party);

        DBManagerTestsStub canOcrolusReportDBStubInstance = new DBManagerTestsStub();
        canOcrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c> {ocrolusReport};
        CANPricingDetailManager.canOcrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, canOcrolusReportDBStubInstance);

        DBManagerTestsStub applicationDBBStubInstance = new DBManagerTestsStub();
        applicationDBBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        CANPricingDetailManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBBStubInstance);

        DBManagerTestsStub applicationDBBusinessStubInstance = new DBManagerTestsStub();
        BusinessRuleManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBBusinessStubInstance);

        DBManagerTestsStub stipsDBStubInstance = new DBManagerTestsStub();
        stipsDBStubInstance.genericReturnObject = new List<STIPS_Checklist__c> {stipsCheckList};
        BusinessRuleManager.stipsDBInstance = (STIPSChecklistDB) Test.createStub(STIPSChecklistDB.class, stipsDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {accountRecord};
        BusinessRuleManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact> {contactRecord};
        ApplicationManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = new List<clcommon__Party__c> {party};
        ApplicationManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        DBManagerTestsStub underWriterTaskDBStubInstance = new DBManagerTestsStub();
        underWriterTaskDBStubInstance.genericReturnObject = uwList;
        BusinessRuleManager.underWriterTaskDBInstance = (UnderWriterTaskDB) Test.createStub(UnderWriterTaskDB.class, underWriterTaskDBStubInstance);

        DBManagerTestsStub creditReportDetailDBStubInstance = new DBManagerTestsStub();
        creditReportDetailDBStubInstance.genericReturnObject = creditReportList;
        BusinessRuleManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBStubInstance);

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        ocrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c> {ocrolusReport};
        BusinessRuleManager.ocrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        DBManagerTestsStub documentDBStubInstance = new DBManagerTestsStub();
        documentDBStubInstance.genericReturnObject = new List<Document> {canLogo};
        ApplicationManager.documentDBInstance = (DocumentDB) Test.createStub(DocumentDB.class, documentDBStubInstance);

        DBManagerTestsStub emailTemplateDBStubInstance = new DBManagerTestsStub();
        emailTemplateDBStubInstance.genericReturnObject = new List<EmailTemplate> {emailTemplate};
        GeneralHelper.emailTemplateDBInstance = (EmailTemplateDB) Test.createStub(EmailTemplateDB.class, emailTemplateDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        ApplicationManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        DBManagerTestsStub siteDBStubInstance = new DBManagerTestsStub();
        siteDBStubInstance.genericReturnObject = new List<Site> {siteDetails};
        GeneralHelper.siteDBInstance = (SiteDB) Test.createStub(SiteDB.class, siteDBStubInstance);

        DBManagerTestsStub pricingMatrixDetailDBStubInstance = new DBManagerTestsStub();
        pricingMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_Pricing_Matrix_Detail__c> {canPricingMatrixDetail};
        OriginationHelper.pricingMatrixDetailDBInstance = (PricingMatrixDetailDB) Test.createStub(PricingMatrixDetailDB.class, pricingMatrixDetailDBStubInstance);

        DBManagerTestsStub gavMatrixDetailDBStubInstance = new DBManagerTestsStub();
        gavMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_GAV_Matrix_Detail__c> {canGavMatrix};
        OriginationHelper.gavMatrixDetailDBInstance = (GAVMatrixDetailDB) Test.createStub(GAVMatrixDetailDB.class, gavMatrixDetailDBStubInstance);

        DBManagerTestsStub maxAmountAndMaxTermMappingDBStubInstance = new DBManagerTestsStub();
        maxAmountAndMaxTermMappingDBStubInstance.genericReturnObject = new List<CAN_Max_Amount_And_Max_Term_Mapping__c> {canMaxAmountMaxTerm};
        OriginationHelper.maxAmountAndMaxTermMappingDBInstance = (MaxAmountAndMaxTermMappingDB) Test.createStub(MaxAmountAndMaxTermMappingDB.class, maxAmountAndMaxTermMappingDBStubInstance);

        Map<String, List<genesis__Applications__c>> applicationByStatus = new Map<String, List<genesis__Applications__c>>();
        applicationByStatus.put(Applications.STATUS_OFFER_SENT, new List<genesis__Applications__c> {application});

        Test.startTest();

            ApplicationManager.handleAfterStatusChange(applicationByStatus);

        Test.stopTest();
        System.assertEquals(1, stipsDBStubInstance.forUpdateSObjects.size());

    }

    @isTest
    private static void sendSTIPsIncompleteNotificationToBroker() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.AnnualRevenue = 2000000;
        borrowerAccount.Name = 'Magar Industries LLC';
        borrowerAccount.Merchant_ID__c = '3123123';

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'JOHN';
        contactRecord.LastName = 'BOSS';

        STIPS_Checklist__c stipsCheckList = new STIPS_Checklist__c();
        stipsCheckList.Id = TestUtility.getFakeId(STIPS_Checklist__c.getSObjectType());
        stipsCheckList.Additional_Banks__c = false;
        stipsCheckList.Bank_Verification_Call__c = true;
        stipsCheckList.Borrower_Interview__c = true;
        stipsCheckList.Competitors__c = false;
        stipsCheckList.Federal_Tax_ID__c = true;
        stipsCheckList.Identification__c = false;
        stipsCheckList.Month_to_Date_Bank_Statement__c = false;
        stipsCheckList.Proof_of_Ownership__c = true;
        stipsCheckList.Verification_Call__c = true;
        stipsCheckList.Voided_Check__c = false;
        stipsCheckList.Last_Four_Bank_Account_Number__c = null;
        stipsCheckList.Guarantors_Whose_Identity_Not_Verified__c = null;
        stipsCheckList.Competitor_Names__c = null;

        List<STIPS_Checklist__c> stipsCheckListsList = new List<STIPS_Checklist__c>{stipsCheckList};
        String jsonStipsCheckList = '{"totalSize" : 1, "done" : true, "records" : ' + JSON.serialize(stipsCheckListsList, false) + '}';

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Id = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());
        pricingDetail.Maximum_Amount__c = 5000;
        pricingDetail.Industry_Rating__c = 'A+ Medical';
        pricingDetail.SC4_Tier__c = 'TIER 1';
        pricingDetail.Annual_Volume__c = 1231232;
        pricingDetail.Loan_Type__c = 'New';
        pricingDetail.Origination_Fee_Percentage__c = 14;
        pricingDetail.Origination_Fee_Amount__c = 299;
        pricingDetail.Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        pricingDetail.Status__c = 'Sent To Customer';
        pricingDetail.Ocrolus_Max_Daily_Payment__c = 132462;
        pricingDetail.Term__c = 6;
        pricingDetail.Maximum_Term__c = 6;
        pricingDetail.Buy_Rate__c = 6;
        pricingDetail.Maximum_Exception_Amount__c = 6000;

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        newOpportunity.Offer_Notification_To_Guarantor__c = true;
        newOpportunity.Offer_Notification_To_Broker__c = true;

        List<CAN_Pricing_Detail__c> pricingDetailList = new List<CAN_Pricing_Detail__c>{pricingDetail};
        String jsonPricingDetailList = '{"totalSize" : 1, "done" : true, "records" :' + JSON.serialize(pricingDetailList, false) + '}';

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{"Name" : "APP-00000102", "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship", ' +
                '"Time_In_Business__c" : "1", "Sales_Rep__r.Email" : "sales@youtest.com", "Max_Broker_Commission__c" : "120", ' +
            	'"STIPS_Checklists__r" : ' + jsonStipsCheckList + ', "CAN_Pricing_Details__r" : ' + jsonPricingDetailList +
            '}' , genesis__Applications__c.class
        );

        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Origination_Fee_Percentage__c = 12;
        application.genesis__Collateral_Value__c = 6700;
        application.genesis__Customer_Cash_Available__c = 1500;
        application.genesis__Days_Convention__c = '30/360';
        application.genesis__Estimated_Selling_Price__c = 6700;
        application.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        application.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        application.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        application.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        application.genesis__Fees_Amount__c = 0;
        application.genesis__Financed_Amount__c = 10000;
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Landing_Sequence__c = 3;
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__Other_Financed_fees__c = 0;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.genesis__Product_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
        application.genesis__Sales_Division__c = 'DIRECT';
        application.genesis__Tax_Amount__c = 0;
        application.genesis__Term__c = 12;
        application.genesis__Warranty_Amount__c = 0;
        application.SIC_Code__c = '073';
        application.Primary_Guarantor__c = contactRecord.Id;
        application.genesis__Account__c = borrowerAccount.Id;
        application.Maximum_Funding_Amount__c = 12000;
        application.Industry_Rating__c = 'Prohibited';
        application.SC4_Tier__c = 'TIER 1';
        application.Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;
        application.genesis__Account__r = borrowerAccount;
        application.Decline_Reasons__c = null;
        application.Annual_Volume__c = 123000;
        application.Pricing_Factor__c = 1.2;
        application.Max_Term__c =6;
        application.Buy_Rate__c = 1.2;
        application.genesis__Requested_Loan_Amount__c = 9000;
        application.Opportunity__c = newOpportunity.Id;
        application.Opportunity__r = newOpportunity;

        stipsCheckList.Application__c = application.Id;

        loan__Loan_Account__c clContract = (loan__Loan_Account__c) JSON.deserialize(
            '{ "Concurrent_Eligible_Amount__c" : "2000"}' , loan__Loan_Account__c.class
        );
        clContract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        application.Renewal_Concurrent_LoanAccount__r = clContract;

        Account accountRecord = new Account();
        accountRecord.Id = application.genesis__Account__c;
        accountRecord.Name = 'Business Account';
        accountRecord.Commision_Based_On__c = Brokers.COMMISSION_CALC_METHOD_FLAT;
        accountRecord.Is_Flat_Renewal__c = true;
        accountRecord.New_Max_Broker_Commission__c = 500;
        accountRecord.Renewal_Amount_Commission__c = Brokers.COMMISSION_CALC_METHOD_FLAT;
        accountRecord.Email_cc__c = 'test@yopmail.com, test@mailnator.com';

        Contact brokerContact = new Contact();
        brokerContact.Id = TestUtility.getFakeId(Contact.getSObjectType());
        brokerContact.Email = 'test@yopmail.com';
        brokerContact.Account = accountRecord;

        User salesRep = new User();
        salesRep.Id = TestUtility.getFakeId(User.getSObjectType());
        salesRep.Email = 'test1@yopmail.com';

        application.Broker_Contact__c = brokerContact.Id;
        application.Broker_Contact__r = brokerContact;
        application.Sales_Rep__c = salesRep.Id;
        application.Sales_Rep__r = salesRep;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Max_Daily_Payment__c = 1000;

        CAN_Max_Amount_And_Max_Term_Mapping__c canMaxAmountMaxTerm = new CAN_Max_Amount_And_Max_Term_Mapping__c();
        canMaxAmountMaxTerm.Id = TestUtility.getFakeId(CAN_Max_Amount_And_Max_Term_Mapping__c.getSObjectType());
        canMaxAmountMaxTerm.Loan_Type__c = application.Type__c;
        canMaxAmountMaxTerm.Industry_Rating__c = application.Industry_Rating__c;
        canMaxAmountMaxTerm.SC4_Tier__c = application.SC4_Tier__c;
        canMaxAmountMaxTerm.Maximum_Term__c = 6;
        canMaxAmountMaxTerm.Maximum_Amount_Single_Location__c = 2000;

        CAN_Pricing_Matrix_Detail__c canPricingMatrixDetail = new CAN_Pricing_Matrix_Detail__c();
        canPricingMatrixDetail.Id = TestUtility.getFakeId(CAN_Pricing_Matrix_Detail__c.getSObjectType());
        canPricingMatrixDetail.Term__c = 6;
        canPricingMatrixDetail.Loan_Type__c = GeneralConstants.LOAN_TYPE_NEW;
        canPricingMatrixDetail.SC4_Tier__c = application.SC4_Tier__c;
        canPricingMatrixDetail.Industry_Rating__c = application.Industry_Rating__c;
        canPricingMatrixDetail.Pricing_Rate__c = 2.2;

        CAN_GAV_Matrix_Detail__c canGavMatrix = new CAN_GAV_Matrix_Detail__c();
        canGavMatrix.Id = TestUtility.getFakeId(CAN_GAV_Matrix_Detail__c.getSObjectType());
        canGavMatrix.Term__c = 6;
        canGavMatrix.SC4_Tier__c = application.SC4_Tier__c;
        canGavMatrix.Industry_Rating__c = application.Industry_Rating__c;
        canGavMatrix.GAV__c = 3;

        Document canLogo = new Document();
        canLogo.Id = TestUtility.getFakeId(Document.getSObjectType());
        canLogo.Name = 'CAN_CAPITAL_IMAGE_PURPLE_BG';
        canLogo.DeveloperName = 'CAN_CAPITAL_IMAGE_PURPLE_BG';

        GeneralHelper.domainUrl = 'https://www.test.com--main/domain';

        Site siteDetails = (Site) JSON.deserialize(
            '{ "Name" : "instanceSite", "Subdomain" : "subdomain/name", "UrlPathPrefix" : "path/prefix" }' , Site.class
        );

        EmailTemplate emailTemplate = new EmailTemplate();
        emailTemplate.Id = TestUtility.getFakeId(EmailTemplate.getSObjectType());
        emailTemplate.Name = 'Broker_Credit_Incomplete';
        emailTemplate.Subject = 'STIPS Incomplete {{LEGAL_ENTITY_NAME}} {{BROKER_COMPANY_NAME}} {{MERCHANT_ID}}';
        emailTemplate.Body = 'Stips is not completed{{APPLICATION_NAME}} {{MAX_FUNDING_AMOUNT}}' +
            '{{MAX_TERM}} {{BUY_RATE}} {{MAX_COMMISSION}} {{ORIGINATION_FEE_PERCENTAGE}} {{PAYMENT_FREQUENCY}} {{IMAGE__LOGO}}'+
            '{{BROKER_PORTAL_LINK}} {{OFFER_APPROVED_STANDARD_START}} {{OFFER_APPROVED_STANDARD_END}} {{OFFER_APPROVED_COUNTER_OFFER_START}}' +
            '{{OFFER_APPROVED_COUNTER_OFFER_END}} {{STANDARD_START}} {{STANDARD_END}} {{COUNTER_OFFER_START}} {{COUNTER_OFFER_END}}';
        emailTemplate.HtmlValue = 'Stips is not completed {{APPLICATION_NAME}} {{MAX_FUNDING_AMOUNT}}' +
            '{{MAX_TERM}} {{BUY_RATE}} {{MAX_COMMISSION}} {{ORIGINATION_FEE_PERCENTAGE}} {{PAYMENT_FREQUENCY}} {{IMAGE__LOGO}}'+
            '{{BROKER_PORTAL_LINK}} {{OFFER_APPROVED_STANDARD_START}} {{OFFER_APPROVED_STANDARD_END}} {{OFFER_APPROVED_COUNTER_OFFER_START}}' +
            '{{OFFER_APPROVED_COUNTER_OFFER_END}} {{STANDARD_START}} {{STANDARD_END}} {{COUNTER_OFFER_START}} {{COUNTER_OFFER_END}}';
        emailTemplate.DeveloperName = 'Broker_Credit_Incomplete';

        List<UnderWriter_Task__c> uwList = new List<UnderWriter_Task__c>();
        List<Credit_Report_Detail__c> creditReportList = new List<Credit_Report_Detail__c>();

        UnderWriter_Task__c uwFraudAlert = new UnderWriter_Task__c();
        uwFraudAlert.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        uwFraudAlert.Task_Name__c = 'OCR Fraud Alert';
        uwFraudAlert.Application__c = application.Id;
        uwList.add(uwFraudAlert);

        UnderWriter_Task__c uwExperianFraud = new UnderWriter_Task__c();
        uwExperianFraud.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        uwExperianFraud.Task_Name__c = 'Experian Fraud Alert';
        uwExperianFraud.Application__c = application.Id;
        uwList.add(uwExperianFraud);

        Credit_Report_Detail__c creditReportConsumer = new Credit_Report_Detail__c();
        creditReportConsumer.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        creditReportConsumer.Type__c = 'Experian Consumer';
        creditReportConsumer.Contact__c = application.Primary_Guarantor__c;
        creditReportList.add(creditReportConsumer);

        Credit_Report_Detail__c creditReportBusiness = new Credit_Report_Detail__c();
        creditReportBusiness.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        creditReportBusiness.Type__c = 'Experian Business';
        creditReportBusiness.Account__c = application.genesis__Account__c;
        creditReportList.add(creditReportBusiness);

        Credit_Report_Detail__c creditReportLexisNexis = new Credit_Report_Detail__c();
        creditReportLexisNexis.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        creditReportLexisNexis.Application__c = application.Id;
        creditReportLexisNexis.Type__c = 'Lexis Nexis';
        creditReportList.add(creditReportLexisNexis);

        clcommon__Party_Type__c partyTypeGuarantor = new clcommon__Party_Type__c();
        partyTypeGuarantor.Name = GeneralConstants.PARTY_TYPE_GUARANTOR;
        partyTypeGuarantor.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());

        Map<String, Id> partyTypeToId = new Map<String, Id>();
        partyTypeToId.put(partyTypeGuarantor.Name, partyTypeGuarantor.Id);
        OriginationHelper.partyTypeToId = partyTypeToId;

        List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();
        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        party.clcommon__Account__c = application.genesis__Account__c;
        party.genesis__Application__c = application.Id;
        party.clcommon__isPrimary__c = false;
        party.clcommon__Type__c = partyTypeGuarantor.Id;
        party.clcommon__Contact__c = contactRecord.Id;
        partyList.add(party);

        DBManagerTestsStub canOcrolusReportDBStubInstance = new DBManagerTestsStub();
        canOcrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c> {ocrolusReport};
        CANPricingDetailManager.canOcrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, canOcrolusReportDBStubInstance);

        DBManagerTestsStub applicationDBBStubInstance = new DBManagerTestsStub();
        applicationDBBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        CANPricingDetailManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBBStubInstance);

        DBManagerTestsStub applicationDBBusinessStubInstance = new DBManagerTestsStub();
        BusinessRuleManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBBusinessStubInstance);

        DBManagerTestsStub stipsDBStubInstance = new DBManagerTestsStub();
        stipsDBStubInstance.genericReturnObject = new List<STIPS_Checklist__c> {stipsCheckList};
        BusinessRuleManager.stipsDBInstance = (STIPSChecklistDB) Test.createStub(STIPSChecklistDB.class, stipsDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {accountRecord};
        BusinessRuleManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact> {contactRecord};
        ApplicationManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = new List<clcommon__Party__c> {party};
        ApplicationManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        DBManagerTestsStub underWriterTaskDBStubInstance = new DBManagerTestsStub();
        underWriterTaskDBStubInstance.genericReturnObject = uwList;
        BusinessRuleManager.underWriterTaskDBInstance = (UnderWriterTaskDB) Test.createStub(UnderWriterTaskDB.class, underWriterTaskDBStubInstance);

        DBManagerTestsStub creditReportDetailDBStubInstance = new DBManagerTestsStub();
        creditReportDetailDBStubInstance.genericReturnObject = creditReportList;
        BusinessRuleManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBStubInstance);

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        ocrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c> {ocrolusReport};
        BusinessRuleManager.ocrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        DBManagerTestsStub documentDBStubInstance = new DBManagerTestsStub();
        documentDBStubInstance.genericReturnObject = new List<Document> {canLogo};
        ApplicationManager.documentDBInstance = (DocumentDB) Test.createStub(DocumentDB.class, documentDBStubInstance);

        DBManagerTestsStub emailTemplateDBStubInstance = new DBManagerTestsStub();
        emailTemplateDBStubInstance.genericReturnObject = new List<EmailTemplate> {emailTemplate};
        GeneralHelper.emailTemplateDBInstance = (EmailTemplateDB) Test.createStub(EmailTemplateDB.class, emailTemplateDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        ApplicationManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        DBManagerTestsStub siteDBStubInstance = new DBManagerTestsStub();
        siteDBStubInstance.genericReturnObject = new List<Site> {siteDetails};
        GeneralHelper.siteDBInstance = (SiteDB) Test.createStub(SiteDB.class, siteDBStubInstance);

        DBManagerTestsStub pricingMatrixDetailDBStubInstance = new DBManagerTestsStub();
        pricingMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_Pricing_Matrix_Detail__c> {canPricingMatrixDetail};
        OriginationHelper.pricingMatrixDetailDBInstance = (PricingMatrixDetailDB) Test.createStub(PricingMatrixDetailDB.class, pricingMatrixDetailDBStubInstance);

        DBManagerTestsStub gavMatrixDetailDBStubInstance = new DBManagerTestsStub();
        gavMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_GAV_Matrix_Detail__c> {canGavMatrix};
        OriginationHelper.gavMatrixDetailDBInstance = (GAVMatrixDetailDB) Test.createStub(GAVMatrixDetailDB.class, gavMatrixDetailDBStubInstance);

        DBManagerTestsStub maxAmountAndMaxTermMappingDBStubInstance = new DBManagerTestsStub();
        maxAmountAndMaxTermMappingDBStubInstance.genericReturnObject = new List<CAN_Max_Amount_And_Max_Term_Mapping__c> {canMaxAmountMaxTerm};
        OriginationHelper.maxAmountAndMaxTermMappingDBInstance = (MaxAmountAndMaxTermMappingDB) Test.createStub(MaxAmountAndMaxTermMappingDB.class, maxAmountAndMaxTermMappingDBStubInstance);

        Map<String, List<genesis__Applications__c>> applicationByStatus = new Map<String, List<genesis__Applications__c>>();
        applicationByStatus.put(Applications.STATUS_OFFER_SENT, new List<genesis__Applications__c> {application});

        Test.startTest();
            ApplicationManager.handleAfterStatusChange(applicationByStatus);
        Test.stopTest();
        System.assertEquals(1, stipsDBStubInstance.forUpdateSObjects.size());

    }

    @isTest
    private static void sendSTIPsIncompleteNotificationException() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.AnnualRevenue = 2000000;
        borrowerAccount.Name = 'Magar Industries LLC';
        borrowerAccount.Merchant_ID__c = '3123123';

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'JOHN';
        contactRecord.LastName = 'BOSS';

        STIPS_Checklist__c stipsCheckList = new STIPS_Checklist__c();
        stipsCheckList.Id = TestUtility.getFakeId(STIPS_Checklist__c.getSObjectType());
        stipsCheckList.Additional_Banks__c = false;
        stipsCheckList.Bank_Verification_Call__c = true;
        stipsCheckList.Borrower_Interview__c = true;
        stipsCheckList.Competitors__c = false;
        stipsCheckList.Federal_Tax_ID__c = true;
        stipsCheckList.Identification__c = false;
        stipsCheckList.Month_to_Date_Bank_Statement__c = false;
        stipsCheckList.Proof_of_Ownership__c = true;
        stipsCheckList.Verification_Call__c = true;
        stipsCheckList.Voided_Check__c = false;
        stipsCheckList.Last_Four_Bank_Account_Number__c = null;
        stipsCheckList.Guarantors_Whose_Identity_Not_Verified__c = null;
        stipsCheckList.Competitor_Names__c = null;

        List<STIPS_Checklist__c> stipsCheckListsList = new List<STIPS_Checklist__c>{stipsCheckList};
        String jsonStipsCheckList = '{"totalSize" : 1, "done" : true, "records" : ' + JSON.serialize(stipsCheckListsList, false) + '}';

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Id = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());
        pricingDetail.Maximum_Amount__c = 5000;
        pricingDetail.Industry_Rating__c = 'A+ Medical';
        pricingDetail.SC4_Tier__c = 'TIER 1';
        pricingDetail.Annual_Volume__c = 1231232;
        pricingDetail.Loan_Type__c = 'New';
        pricingDetail.Origination_Fee_Percentage__c = 14;
        pricingDetail.Origination_Fee_Amount__c = 299;
        pricingDetail.Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        pricingDetail.Status__c = 'Sent To Customer';
        pricingDetail.Ocrolus_Max_Daily_Payment__c = 132462;
        pricingDetail.Term__c = 6;
        pricingDetail.Maximum_Term__c = 6;
        pricingDetail.Buy_Rate__c = 6;
        pricingDetail.Maximum_Exception_Amount__c = 6000;

        List<CAN_Pricing_Detail__c> pricingDetailList = new List<CAN_Pricing_Detail__c>{pricingDetail};
        String jsonPricingDetailList = '{"totalSize" : 1, "done" : true, "records" :' + JSON.serialize(pricingDetailList, false) + '}';

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{"Name" : "APP-00000102", "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship", ' +
                '"Time_In_Business__c" : "1", "Sales_Rep__r.Email" : "sales@youtest.com", "Max_Broker_Commission__c" : "120", ' +
            	'"STIPS_Checklists__r" : ' + jsonStipsCheckList + ', "CAN_Pricing_Details__r" : ' + jsonPricingDetailList +
            '}' , genesis__Applications__c.class
        );

        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Origination_Fee_Percentage__c = 12;
        application.genesis__Collateral_Value__c = 6700;
        application.genesis__Customer_Cash_Available__c = 1500;
        application.genesis__Days_Convention__c = '30/360';
        application.genesis__Estimated_Selling_Price__c = 6700;
        application.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        application.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        application.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        application.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        application.genesis__Fees_Amount__c = 0;
        application.genesis__Financed_Amount__c = 10000;
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Landing_Sequence__c = 3;
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__Other_Financed_fees__c = 0;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.genesis__Product_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
        application.genesis__Sales_Division__c = 'DIRECT';
        application.genesis__Tax_Amount__c = 0;
        application.genesis__Term__c = 12;
        application.genesis__Warranty_Amount__c = 0;
        application.SIC_Code__c = '073';
        application.Primary_Guarantor__c = contactRecord.Id;
        application.genesis__Account__c = borrowerAccount.Id;
        application.Maximum_Funding_Amount__c = 12000;
        application.Industry_Rating__c = 'Prohibited';
        application.SC4_Tier__c = 'TIER 1';
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.genesis__Account__r = borrowerAccount;
        application.Decline_Reasons__c = null;
        application.Annual_Volume__c = 123000;
        application.Pricing_Factor__c = 1.2;
        application.Max_Term__c =6;
        application.Buy_Rate__c = 1.2;
        application.genesis__Requested_Loan_Amount__c = 1009;

        stipsCheckList.Application__c = application.Id;

        loan__Loan_Account__c clContract = (loan__Loan_Account__c) JSON.deserialize(
            '{ "Concurrent_Eligible_Amount__c" : "2000"}' , loan__Loan_Account__c.class
        );
        clContract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        application.Renewal_Concurrent_LoanAccount__r = clContract;

        Account accountRecord = new Account();
        accountRecord.Id = application.genesis__Account__c;
        accountRecord.Name = 'Business Account';
        accountRecord.Commision_Based_On__c = Brokers.COMMISSION_CALC_METHOD_FLAT;
        accountRecord.Is_Flat_Renewal__c = true;
        accountRecord.New_Max_Broker_Commission__c = 500;
        accountRecord.Renewal_Amount_Commission__c = Brokers.COMMISSION_CALC_METHOD_FLAT;

        Contact brokerContact = new Contact();
        brokerContact.Id = TestUtility.getFakeId(Contact.getSObjectType());
        brokerContact.Email = 'test@yopmail.com';
        brokerContact.Account = accountRecord;

        application.Broker_Contact__c = brokerContact.Id;
        application.Broker_Contact__r = brokerContact;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Max_Daily_Payment__c = 1000;

        CAN_Max_Amount_And_Max_Term_Mapping__c canMaxAmountMaxTerm = new CAN_Max_Amount_And_Max_Term_Mapping__c();
        canMaxAmountMaxTerm.Id = TestUtility.getFakeId(CAN_Max_Amount_And_Max_Term_Mapping__c.getSObjectType());
        canMaxAmountMaxTerm.Loan_Type__c = application.Type__c;
        canMaxAmountMaxTerm.Industry_Rating__c = application.Industry_Rating__c;
        canMaxAmountMaxTerm.SC4_Tier__c = application.SC4_Tier__c;
        canMaxAmountMaxTerm.Maximum_Term__c = 6;
        canMaxAmountMaxTerm.Maximum_Amount_Single_Location__c = 2000;

        CAN_Pricing_Matrix_Detail__c canPricingMatrixDetail = new CAN_Pricing_Matrix_Detail__c();
        canPricingMatrixDetail.Id = TestUtility.getFakeId(CAN_Pricing_Matrix_Detail__c.getSObjectType());
        canPricingMatrixDetail.Term__c = 6;
        canPricingMatrixDetail.Loan_Type__c = GeneralConstants.LOAN_TYPE_NEW;
        canPricingMatrixDetail.SC4_Tier__c = application.SC4_Tier__c;
        canPricingMatrixDetail.Industry_Rating__c = application.Industry_Rating__c;
        canPricingMatrixDetail.Pricing_Rate__c = 2.2;

        CAN_GAV_Matrix_Detail__c canGavMatrix = new CAN_GAV_Matrix_Detail__c();
        canGavMatrix.Id = TestUtility.getFakeId(CAN_GAV_Matrix_Detail__c.getSObjectType());
        canGavMatrix.Term__c = 6;
        canGavMatrix.SC4_Tier__c = application.SC4_Tier__c;
        canGavMatrix.Industry_Rating__c = application.Industry_Rating__c;
        canGavMatrix.GAV__c = 3;

        Document canLogo = new Document();
        canLogo.Id = TestUtility.getFakeId(Document.getSObjectType());
        canLogo.Name = 'CAN_CAPITAL_IMAGE_PURPLE_BG';
        canLogo.DeveloperName = 'CAN_CAPITAL_IMAGE_PURPLE_BG';

        GeneralHelper.domainUrl = 'https://www.test.com--main/domain';

        Site siteDetails = (Site) JSON.deserialize(
            '{ "Name" : "instanceSite", "Subdomain" : "subdomain/name", "UrlPathPrefix" : "path/prefix" }' , Site.class
        );

        List<UnderWriter_Task__c> uwList = new List<UnderWriter_Task__c>();
        List<Credit_Report_Detail__c> creditReportList = new List<Credit_Report_Detail__c>();

        UnderWriter_Task__c uwFraudAlert = new UnderWriter_Task__c();
        uwFraudAlert.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        uwFraudAlert.Task_Name__c = 'OCR Fraud Alert';
        uwFraudAlert.Application__c = application.Id;
        uwList.add(uwFraudAlert);

        UnderWriter_Task__c uwExperianFraud = new UnderWriter_Task__c();
        uwExperianFraud.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        uwExperianFraud.Task_Name__c = 'Experian Fraud Alert';
        uwExperianFraud.Application__c = application.Id;
        uwList.add(uwExperianFraud);

        Credit_Report_Detail__c creditReportConsumer = new Credit_Report_Detail__c();
        creditReportConsumer.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        creditReportConsumer.Type__c = 'Experian Consumer';
        creditReportConsumer.Contact__c = application.Primary_Guarantor__c;
        creditReportList.add(creditReportConsumer);

        Credit_Report_Detail__c creditReportBusiness = new Credit_Report_Detail__c();
        creditReportBusiness.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        creditReportBusiness.Type__c = 'Experian Business';
        creditReportBusiness.Account__c = application.genesis__Account__c;
        creditReportList.add(creditReportBusiness);

        Credit_Report_Detail__c creditReportLexisNexis = new Credit_Report_Detail__c();
        creditReportLexisNexis.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        creditReportLexisNexis.Application__c = application.Id;
        creditReportLexisNexis.Type__c = 'Lexis Nexis';
        creditReportList.add(creditReportLexisNexis);

        DBManagerTestsStub canOcrolusReportDBStubInstance = new DBManagerTestsStub();
        canOcrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c> {ocrolusReport};
        CANPricingDetailManager.canOcrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, canOcrolusReportDBStubInstance);

        DBManagerTestsStub applicationDBBStubInstance = new DBManagerTestsStub();
        applicationDBBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        CANPricingDetailManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBBStubInstance);

        DBManagerTestsStub applicationDBBusinessStubInstance = new DBManagerTestsStub();
        BusinessRuleManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBBusinessStubInstance);

        DBManagerTestsStub stipsDBStubInstance = new DBManagerTestsStub();
        stipsDBStubInstance.genericReturnObject = new List<STIPS_Checklist__c> {stipsCheckList};
        BusinessRuleManager.stipsDBInstance = (STIPSChecklistDB) Test.createStub(STIPSChecklistDB.class, stipsDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {accountRecord};
        BusinessRuleManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub underWriterTaskDBStubInstance = new DBManagerTestsStub();
        underWriterTaskDBStubInstance.genericReturnObject = uwList;
        BusinessRuleManager.underWriterTaskDBInstance = (UnderWriterTaskDB) Test.createStub(UnderWriterTaskDB.class, underWriterTaskDBStubInstance);

        DBManagerTestsStub creditReportDetailDBStubInstance = new DBManagerTestsStub();
        creditReportDetailDBStubInstance.genericReturnObject = creditReportList;
        BusinessRuleManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBStubInstance);

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        ocrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c> {ocrolusReport};
        BusinessRuleManager.ocrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        DBManagerTestsStub documentDBStubInstance = new DBManagerTestsStub();
        documentDBStubInstance.genericReturnObject = new List<Document> {canLogo};
        ApplicationManager.documentDBInstance = (DocumentDB) Test.createStub(DocumentDB.class, documentDBStubInstance);

        DBManagerTestsStub emailTemplateDBStubInstance = new DBManagerTestsStub();
        emailTemplateDBStubInstance.genericReturnObject = new List<EmailTemplate>();
        GeneralHelper.emailTemplateDBInstance = (EmailTemplateDB) Test.createStub(EmailTemplateDB.class, emailTemplateDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        ApplicationManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        DBManagerTestsStub siteDBStubInstance = new DBManagerTestsStub();
        siteDBStubInstance.genericReturnObject = new List<Site> {siteDetails};
        GeneralHelper.siteDBInstance = (SiteDB) Test.createStub(SiteDB.class, siteDBStubInstance);

        DBManagerTestsStub pricingMatrixDetailDBStubInstance = new DBManagerTestsStub();
        pricingMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_Pricing_Matrix_Detail__c> {canPricingMatrixDetail};
        OriginationHelper.pricingMatrixDetailDBInstance = (PricingMatrixDetailDB) Test.createStub(PricingMatrixDetailDB.class, pricingMatrixDetailDBStubInstance);

        DBManagerTestsStub gavMatrixDetailDBStubInstance = new DBManagerTestsStub();
        gavMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_GAV_Matrix_Detail__c> {canGavMatrix};
        OriginationHelper.gavMatrixDetailDBInstance = (GAVMatrixDetailDB) Test.createStub(GAVMatrixDetailDB.class, gavMatrixDetailDBStubInstance);

        DBManagerTestsStub maxAmountAndMaxTermMappingDBStubInstance = new DBManagerTestsStub();
        maxAmountAndMaxTermMappingDBStubInstance.genericReturnObject = new List<CAN_Max_Amount_And_Max_Term_Mapping__c> {canMaxAmountMaxTerm};
        OriginationHelper.maxAmountAndMaxTermMappingDBInstance = (MaxAmountAndMaxTermMappingDB) Test.createStub(MaxAmountAndMaxTermMappingDB.class, maxAmountAndMaxTermMappingDBStubInstance);

        Map<String, List<genesis__Applications__c>> applicationByStatus = new Map<String, List<genesis__Applications__c>>();
        applicationByStatus.put(Applications.STATUS_OFFER_SENT, new List<genesis__Applications__c> {application});

        Test.startTest();

            ApplicationManager.handleAfterStatusChange(applicationByStatus);

        Test.stopTest();
        System.assertEquals(1, stipsDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void handleAfterIndustryCheck() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.AnnualRevenue = 2000000;
        borrowerAccount.Name = 'Magar Industries LLC';
        borrowerAccount.Merchant_ID__c = '3123123';

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'JOHN';
        contactRecord.LastName = 'BOSS';

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{"Name" : "APP-00000102", "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship", ' +
                '"Time_In_Business__c" : "1"}' , genesis__Applications__c.class
        );

        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Origination_Fee_Percentage__c = 12;
        application.genesis__Collateral_Value__c = 6700;
        application.genesis__Customer_Cash_Available__c = 1500;
        application.genesis__Days_Convention__c = '30/360';
        application.genesis__Estimated_Selling_Price__c = 6700;
        application.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        application.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        application.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        application.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        application.genesis__Fees_Amount__c = 0;
        application.genesis__Financed_Amount__c = 10000;
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Landing_Sequence__c = 3;
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__Other_Financed_fees__c = 0;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.genesis__Product_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
        application.genesis__Sales_Division__c = 'DIRECT';
        application.genesis__Tax_Amount__c = 0;
        application.genesis__Term__c = 12;
        application.genesis__Warranty_Amount__c = 0;
        application.SIC_Code__c = '073';
        application.Primary_Guarantor__c = contactRecord.Id;
        application.genesis__Account__c = borrowerAccount.Id;
        application.Maximum_Funding_Amount__c = 12000;
        application.Industry_Rating__c = 'Prohibited';
        application.SC4_Tier__c = 'TIER 1';
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.genesis__Account__r = borrowerAccount;
        application.Decline_Reasons__c = null;
        application.Annual_Volume__c = 123000;
        application.Pricing_Factor__c = 1.2;
        application.Max_Term__c =6;
        application.Buy_Rate__c = 1.2;
        application.genesis__Requested_Loan_Amount__c = 1009;
        application.Industry_Rating__c = 'Prohibited';

        List<clcommon__Party_Type__c> partyTypeList = new List<clcommon__Party_Type__c> ();
        List<clcommon__Party__c> partyList = new List<clcommon__Party__c> ();

        clcommon__Party_Type__c partyTypeGuarantor = new clcommon__Party_Type__c();
        partyTypeGuarantor.Name = GeneralConstants.PARTY_TYPE_GUARANTOR;
        partyTypeGuarantor.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());
        partyTypeList.add(partyTypeGuarantor);

        clcommon__Party_Type__c partyTypeBorrower = new clcommon__Party_Type__c();
        partyTypeBorrower.Name = GeneralConstants.PARTY_TYPE_BORROWER;
        partyTypeBorrower.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());
        partyTypeList.add(partyTypeBorrower);

        clcommon__Party__c partyBorrower = new clcommon__Party__c();
        partyBorrower.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        partyBorrower.clcommon__Account__c = application.genesis__Account__c;
        partyBorrower.genesis__Application__c = application.Id;
        partyBorrower.clcommon__Type__c = partyTypeBorrower.Id;
        partyBorrower.clcommon__isPrimary__c = false;
        partyList.add(partyBorrower);

        clcommon__Party__c partyGuarantor = new clcommon__Party__c();
        partyGuarantor.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        partyGuarantor.clcommon__Account__c = application.genesis__Account__c;
        partyGuarantor.genesis__Application__c = application.Id;
        partyGuarantor.clcommon__Type__c = partyTypeGuarantor.Id;
        partyGuarantor.clcommon__isPrimary__c = false;
        partyList.add(partyGuarantor);

        Account accountRecord = new Account();
        accountRecord.Id = application.genesis__Account__c;

        Map<String, List<genesis__Applications__c>> applicationByStatus = new Map<String, List<genesis__Applications__c>>();
        applicationByStatus.put(Applications.STATUS_INDUSTRY_CHECK, new List<genesis__Applications__c> {application});

        DBManagerTestsStub applicationDBApplicationStubInstance = new DBManagerTestsStub();
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBApplicationStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        ApplicationManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {accountRecord};
        LexisNexisManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = partyList;
        LexisNexisManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        DBManagerTestsStub partyTypeDBStubInstance = new DBManagerTestsStub();
        partyTypeDBStubInstance.genericReturnObject = partyTypeList;
        OriginationHelper.partyTypeDBInstance = (PartyTypeDB) Test.createStub(PartyTypeDB.class, partyTypeDBStubInstance);

        Test.startTest();

            ApplicationManager.handleAfterStatusChange(applicationByStatus);

        Test.stopTest();

        System.assertEquals(1, applicationDBApplicationStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void handleAfterIndustryCheckToBankUpload() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.AnnualRevenue = 2000000;
        borrowerAccount.Name = 'Magar Industries LLC';
        borrowerAccount.Merchant_ID__c = '3123123';

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'JOHN';
        contactRecord.LastName = 'BOSS';

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{"Name" : "APP-00000102", "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship", ' +
                '"Time_In_Business__c" : "10"}' , genesis__Applications__c.class
        );

        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Origination_Fee_Percentage__c = 12;
        application.genesis__Collateral_Value__c = 6700;
        application.genesis__Customer_Cash_Available__c = 1500;
        application.genesis__Days_Convention__c = '30/360';
        application.genesis__Estimated_Selling_Price__c = 6700;
        application.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        application.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        application.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        application.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        application.genesis__Fees_Amount__c = 0;
        application.genesis__Financed_Amount__c = 10000;
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Landing_Sequence__c = 3;
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__Other_Financed_fees__c = 0;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.genesis__Product_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
        application.genesis__Sales_Division__c = 'DIRECT';
        application.genesis__Tax_Amount__c = 0;
        application.genesis__Term__c = 12;
        application.genesis__Warranty_Amount__c = 0;
        application.SIC_Code__c = '073';
        application.Primary_Guarantor__c = contactRecord.Id;
        application.genesis__Account__c = borrowerAccount.Id;
        application.Maximum_Funding_Amount__c = 12000;
        application.Industry_Rating__c = 'A+ Medial';
        application.SC4_Tier__c = 'TIER 1';
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.genesis__Account__r = borrowerAccount;
        application.Decline_Reasons__c = null;
        application.Annual_Volume__c = 123000;
        application.Pricing_Factor__c = 1.2;
        application.Max_Term__c =6;
        application.Buy_Rate__c = 1.2;
        application.genesis__Requested_Loan_Amount__c = 1009;
        application.Industry_Rating__c = 'Prohibited';

        List<clcommon__Party_Type__c> partyTypeList = new List<clcommon__Party_Type__c> ();
        List<clcommon__Party__c> partyList = new List<clcommon__Party__c> ();

        clcommon__Party_Type__c partyTypeGuarantor = new clcommon__Party_Type__c();
        partyTypeGuarantor.Name = GeneralConstants.PARTY_TYPE_GUARANTOR;
        partyTypeGuarantor.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());
        partyTypeList.add(partyTypeGuarantor);

        clcommon__Party_Type__c partyTypeBorrower = new clcommon__Party_Type__c();
        partyTypeBorrower.Name = GeneralConstants.PARTY_TYPE_BORROWER;
        partyTypeBorrower.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());
        partyTypeList.add(partyTypeBorrower);

        clcommon__Party__c partyBorrower = new clcommon__Party__c();
        partyBorrower.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        partyBorrower.clcommon__Account__c = application.genesis__Account__c;
        partyBorrower.genesis__Application__c = application.Id;
        partyBorrower.clcommon__Type__c = partyTypeBorrower.Id;
        partyBorrower.clcommon__isPrimary__c = false;
        partyList.add(partyBorrower);

        clcommon__Party__c partyGuarantor = new clcommon__Party__c();
        partyGuarantor.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        partyGuarantor.clcommon__Account__c = application.genesis__Account__c;
        partyGuarantor.genesis__Application__c = application.Id;
        partyGuarantor.clcommon__Type__c = partyTypeGuarantor.Id;
        partyGuarantor.clcommon__isPrimary__c = false;
        partyList.add(partyGuarantor);

        Account accountRecord = new Account();
        accountRecord.Id = application.genesis__Account__c;

        Map<String, List<genesis__Applications__c>> applicationByStatus = new Map<String, List<genesis__Applications__c>>();
        applicationByStatus.put(Applications.STATUS_INDUSTRY_CHECK, new List<genesis__Applications__c> {application});

        DBManagerTestsStub applicationDBApplicationStubInstance = new DBManagerTestsStub();
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBApplicationStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        ApplicationManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {accountRecord};
        LexisNexisManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = partyList;
        LexisNexisManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        DBManagerTestsStub partyTypeDBStubInstance = new DBManagerTestsStub();
        partyTypeDBStubInstance.genericReturnObject = partyTypeList;
        OriginationHelper.partyTypeDBInstance = (PartyTypeDB) Test.createStub(PartyTypeDB.class, partyTypeDBStubInstance);

        Test.startTest();

            ApplicationManager.handleAfterStatusChange(applicationByStatus);

        Test.stopTest();

        System.assertEquals(1, applicationDBApplicationStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void handleRenewalAndConcurrentApplicationsBeforeUpdate() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.AnnualRevenue = 2000000;
        borrowerAccount.Name = 'Magar Industries LLC';
        borrowerAccount.Merchant_ID__c = '3123123';

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'JOHN';
        contactRecord.LastName = 'BOSS';

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{"Name" : "APP-00000102", "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship", ' +
                '"Time_In_Business__c" : "1"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Origination_Fee_Percentage__c = 12;
        application.genesis__Collateral_Value__c = 6700;
        application.genesis__Customer_Cash_Available__c = 1500;
        application.genesis__Days_Convention__c = '30/360';
        application.genesis__Estimated_Selling_Price__c = 6700;
        application.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        application.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        application.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        application.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        application.genesis__Fees_Amount__c = 0;
        application.genesis__Financed_Amount__c = 10000;
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Landing_Sequence__c = 3;
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__Other_Financed_fees__c = 0;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.genesis__Product_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
        application.genesis__Sales_Division__c = 'DIRECT';
        application.genesis__Tax_Amount__c = 0;
        application.genesis__Term__c = 12;
        application.genesis__Warranty_Amount__c = 0;
        application.SIC_Code__c = '073';
        application.Primary_Guarantor__c = contactRecord.Id;
        application.genesis__Account__c = borrowerAccount.Id;
        application.Maximum_Funding_Amount__c = 12000;
        application.Industry_Rating__c = 'Prohibited';
        application.SC4_Tier__c = 'TIER 1';
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.genesis__Account__r = borrowerAccount;
        application.Decline_Reasons__c = null;
        application.Annual_Volume__c = 123000;
        application.Pricing_Factor__c = 1.2;
        application.Max_Term__c =6;
        application.Buy_Rate__c = 1.2;
        application.genesis__Requested_Loan_Amount__c = 1009;

        loan__Bank_Account__c bankAccount = new loan__Bank_Account__c();
        bankAccount.Id = TestUtility.getFakeId(loan__Bank_Account__c.getSObjectType());
        bankAccount.loan__Account__c = application.genesis__Account__c;
        bankAccount.loan__Account_Type__c = 'Saving';
        bankAccount.loan__Bank_Account_Number__c = '1234567890';
        bankAccount.loan__Bank_Name__c = 'CAN Capital';
        bankAccount.loan__Contact__c = application.Primary_Guarantor__c;

        loan__Loan_Product__c loanProduct = new loan__Loan_Product__c();
        loanProduct.Id = TestUtility.getFakeId(loan__Loan_Product__c.getSObjectType());
        loanProduct.loan__Default_Number_of_Installments__c = 6;
        loanProduct.Name = TestUtility.COMPANY_NAME;
        loanProduct.loan__Frequency_of_Loan_Payment__c = GeneralConstants.FREQUENCY_DAILY;
        loanProduct.loan__Min_Interest_Rate__c = 2;
        loanProduct.loan__Max_Interest_Rate__c = 33;
        loanProduct.loan__Funding_in_Tranches__c = true;

        Id recordTypeId = Schema.SObjectType.loan__Loan_Account__c.getRecordTypeInfosByName().get('Loan').getRecordTypeId();
        loan__Loan_Account__c contract = new loan__Loan_Account__c();
        contract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        contract.RecordTypeId = recordTypeId;
        contract.loan__Loan_Product_Name__c = loanProduct.Id;
        contract.loan__Account__c = application.genesis__Account__c;
        contract.Application__c = application.Id;
        contract.loan__Loan_Amount__c = 10000;
        contract.loan__Principal_Remaining__c = 10000;
        contract.loan__Payment_Amount__c = 860.52;
        contract.loan__Pmt_Amt_Cur__c = 860.52;
        contract.loan__Loan_Status__c = 'Approved';
        contract.loan__First_Installment_Date__c = TestUtility.currentSystemDate.addMonths(1);
        contract.loan__Expected_Repayment_Start_Date__c = TestUtility.currentSystemDate.addMonths(1);
        contract.loan__Expected_Disbursal_Date__c = TestUtility.currentSystemDate;
        contract.loan__Last_Accrual_Date__c = TestUtility.currentSystemDate;
        contract.loan__Accrue_Past_Maturity__c = true;
        contract.loan__Contractual_Interest_Rate__c = 6;
        contract.loan__Disbursal_Amount__c = 10000;
        contract.loan__Interest_estimated__c = 326.26;
        contract.loan__Interest_Only_Period__c = 0;
        contract.loan__Interest_Rate__c = 6;
        contract.loan__Last_Installment_Date__c = TestUtility.currentSystemDate.addYears(1);
        contract.loan__Maturity_Date_Current__c = TestUtility.currentSystemDate.addYears(1);
        contract.loan__Next_Installment_Date__c = TestUtility.currentSystemDate.addMonths(1);
        contract.loan__Number_of_Installments__c = 12;
        contract.loan__Oldest_Due_Date__c = TestUtility.currentSystemDate.addMonths(1);
        contract.loan__Overdue_Interest_Rate__c = 12;
        contract.loan__Term_Cur__c = 12;
        contract.Bank_Account__c = bankAccount.Id;
        contract.loan__Disbursal_Date__c = TestUtility.currentSystemDate;

        application.Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;
        application.Renewal_Concurrent_LoanAccount__c = contract.Id;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Max_Daily_Payment__c = 1000;

        clcommon__Party_Type__c partyTypeGuarantor = new clcommon__Party_Type__c();
        partyTypeGuarantor.Name = GeneralConstants.PARTY_TYPE_GUARANTOR;
        partyTypeGuarantor.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());

        List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();
        clcommon__Party__c partyGuarantor = new clcommon__Party__c();
        partyGuarantor.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        partyGuarantor.clcommon__Account__c = application.genesis__Account__c;
        partyGuarantor.genesis__Application__c = application.Id;
        partyGuarantor.clcommon__Type__c = partyTypeGuarantor.Id;
        partyGuarantor.clcommon__isPrimary__c = false;
        partyList.add(partyGuarantor);

        clcommon__Party__c partyPrimaryGuarantor = new clcommon__Party__c();
        partyPrimaryGuarantor.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        partyPrimaryGuarantor.clcommon__Account__c = application.genesis__Account__c;
        partyPrimaryGuarantor.genesis__Application__c = application.Id;
        partyPrimaryGuarantor.clcommon__Type__c = partyTypeGuarantor.Id;
        partyPrimaryGuarantor.clcommon__isPrimary__c = false;
        partyList.add(partyPrimaryGuarantor);

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{contract};
        ApplicationManager.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = partyList;
        ApplicationManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        DBManagerTestsStub partyTypeDBStubInstance = new DBManagerTestsStub();
        partyTypeDBStubInstance.genericReturnObject = new List<clcommon__Party_Type__c> {partyTypeGuarantor};
        OriginationHelper.partyTypeDBInstance = (PartyTypeDB) Test.createStub(PartyTypeDB.class, partyTypeDBStubInstance);

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        ocrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c> {ocrolusReport};
        ApplicationManager.ocrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        Map<Id, genesis__Applications__c> renewalAndConcurrentContractIdToApplication = new Map<Id, genesis__Applications__c>();
        renewalAndConcurrentContractIdToApplication.put(application.Id, application);

        Test.startTest();

            ApplicationManager.handleRenewalAndConcurrentApplicationsBeforeUpdate(renewalAndConcurrentContractIdToApplication);

        Test.stopTest();
        System.assertEquals(1, ocrolusReportDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void recalculateConcurrentRelatedFields() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{"Max_Broker_Commission__c" : 10, "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship", ' +
                '"Time_In_Business__c" : "1"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.genesis__Product_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
        application.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        application.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        application.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        application.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        application.genesis__Term__c = 12;
        application.SIC_Code__c = '073';
        application.Maximum_Funding_Amount__c = 12000;
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.Total_Repayment_Amount__c = 12500;
        application.genesis__Requested_Loan_Amount__c = 1009;
        application.Pricing_Factor__c = 1.33;

        loan__Loan_Account__c contract = (loan__Loan_Account__c) JSON.deserialize(
            '{"Remaining_Number_of_Payments__c" : 10}' , loan__Loan_Account__c.class
        );
        contract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        contract.loan__Disbursed_Amount__c = 1000;
        contract.loan__Interest_Rate__c = 33;
        contract.Application__c = application.Id;
        contract.Application__r = application;
        contract.loan__Loan_Amount__c = 10000;
        contract.loan__Payment_Amount__c = 860.52;
        application.Renewal_Concurrent_LoanAccount__c = contract.Id;

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{contract};
        ApplicationManager.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        LoanCalculatorManagerTestStub loanCalculatorManagerTestStubInstance = new LoanCalculatorManagerTestStub();
        Applications.loanCalculatorManagerInstance = (LoanCalculatorManager) Test.createStub(
            LoanCalculatorManager.class, loanCalculatorManagerTestStubInstance
        );

        Map<Id, genesis__Applications__c> concurrentContractIdToApplication = new Map<Id, genesis__Applications__c>();
        concurrentContractIdToApplication.put(contract.Id, application);

        Test.startTest();
            ApplicationManager.recalculateConcurrentRelatedFields(concurrentContractIdToApplication);
        Test.stopTest();

        System.assertEquals(application.Broker_Standard_Commission__c, application.Max_Broker_Commission__c);
    }

    @isTest
    private static void handleAfterApproved() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.AnnualRevenue = 2000000;
        borrowerAccount.Name = 'Magar Industries LLC';
        borrowerAccount.Merchant_ID__c = '3123123';

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'JOHN';
        contactRecord.LastName = 'BOSS';

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{"Name" : "APP-00000102", "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship", ' +
                '"Time_In_Business__c" : "1"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Origination_Fee_Percentage__c = 12;
        application.genesis__Collateral_Value__c = 6700;
        application.genesis__Customer_Cash_Available__c = 1500;
        application.genesis__Days_Convention__c = '30/360';
        application.genesis__Estimated_Selling_Price__c = 6700;
        application.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        application.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        application.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        application.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        application.genesis__Fees_Amount__c = 0;
        application.genesis__Financed_Amount__c = 10000;
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Landing_Sequence__c = 3;
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__Other_Financed_fees__c = 0;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.genesis__Product_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
        application.genesis__Sales_Division__c = 'DIRECT';
        application.genesis__Tax_Amount__c = 0;
        application.genesis__Term__c = 12;
        application.genesis__Warranty_Amount__c = 0;
        application.SIC_Code__c = '073';
        application.Primary_Guarantor__c = contactRecord.Id;
        application.genesis__Account__c = borrowerAccount.Id;
        application.Maximum_Funding_Amount__c = 12000;
        application.Industry_Rating__c = 'Prohibited';
        application.SC4_Tier__c = 'TIER 1';
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.genesis__Account__r = borrowerAccount;
        application.Decline_Reasons__c = null;
        application.Annual_Volume__c = 123000;
        application.Pricing_Factor__c = 1.2;
        application.Max_Term__c =6;
        application.Buy_Rate__c = 1.2;
        application.genesis__Requested_Loan_Amount__c = 1009;

        Contact brokerContactRecord = new Contact();
        brokerContactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        brokerContactRecord.FirstName = 'JOHN';
        brokerContactRecord.LastName = 'DARK';
        brokerContactRecord.Broker_Account__c = TestUtility.getFakeId(Account.getSObjectType());
        brokerContactRecord.Broker_Contact__c = TestUtility.getFakeId(Contact.getSObjectType());

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> { application };
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> { borrowerAccount };
        ApplicationManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact> { brokerContactRecord };
        ApplicationManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        Map<String, List<genesis__Applications__c>> applicationByStatus = new Map<String, List<genesis__Applications__c>>();
        applicationByStatus.put(Applications.STATUS_APPROVED, new List<genesis__Applications__c> {application});

        Test.startTest();

            ApplicationManager.handleAfterStatusChange(applicationByStatus);

        Test.stopTest();
        System.assertEquals(1, applicationDBStubInstance.forUpdateSObjects.size());

    }

    @isTest
    private static void sendDeclineNotificationToBroker() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.AnnualRevenue = 2000000;
        borrowerAccount.Name = 'Magar Industries LLC';
        borrowerAccount.Merchant_ID__c = '3123123';
        borrowerAccount.Email_cc__c = 'test@yopmail.com, test@mailnator.com';

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'JOHN';
        contactRecord.LastName = 'BOSS';
        contactRecord.Email = 'Test@Cancapital.com';
        contactRecord.Account = borrowerAccount;

        User salesRep = new User();
        salesRep.Id = TestUtility.getFakeId(User.getSObjectType());
        salesRep.Email = 'test1@yopmail.com';

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        newOpportunity.Offer_Notification_To_Guarantor__c = true;
        newOpportunity.Offer_Notification_To_Broker__c = true;

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{"Name" : "APP-00000102", "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship", ' +
                '"Time_In_Business__c" : "1"}' , genesis__Applications__c.class
        );

        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Primary_Guarantor__c = contactRecord.Id;
        application.genesis__Account__c = borrowerAccount.Id;
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.genesis__Account__r = borrowerAccount;
        application.Broker_Contact__c = contactRecord.Id;
        application.Broker_Contact__r = contactRecord;
        application.Decline_Reasons__c = 'Time in Business;Negative History with CAN';
        application.Opportunity__c = newOpportunity.Id;
        application.Opportunity__r = newOpportunity;
        application.Sales_Rep__c = salesRep.Id;
        application.Sales_Rep__r = salesRep;

        EmailTemplate emailTemplate = new EmailTemplate();
        emailTemplate.Id = TestUtility.getFakeId(EmailTemplate.getSObjectType());
        emailTemplate.Name = 'Broker_Decline_Notification';
        emailTemplate.Subject = '{{MERCHANT_ID}}';
        emailTemplate.Body = '{{MERCHANT_ID}}';
        emailTemplate.HtmlValue = '{{MERCHANT_ID}}';
        emailTemplate.DeveloperName = 'Broker_Decline_Notification';

        String fromAddress = 'test1@example.com';
        String subject = 'Dummy Subject';
        String htmlTextBody = '<b>Dummy Html Text Body</b><br/>';
        List<String> toAddress = new List<String>{'test@example.com'};

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = Emails.getEmailMessageSetup(
            toAddress, null, fromAddress, subject, htmlTextBody, true,
            new Map<String, Blob>{'a' => Blob.valueOf('a')}, null
        );
        emailList.add(email);

        List<Messaging.SendEmailResult> sendEmailResult = emailDbInstance.sendEmail(email);

        Map<String, List<genesis__Applications__c>> applicationByStatus = new Map<String, List<genesis__Applications__c>>();
        applicationByStatus.put(Applications.STATUS_DECLINED, new List<genesis__Applications__c> {application});

        DBManagerTestsStub applicationDBApplicationStubInstance = new DBManagerTestsStub();
        applicationDBApplicationStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBApplicationStubInstance);

        DBManagerTestsStub emailTemplateDBStubInstance = new DBManagerTestsStub();
        emailTemplateDBStubInstance.genericReturnObject = new List<EmailTemplate> {emailTemplate};
        GeneralHelper.emailTemplateDBInstance = (EmailTemplateDB) Test.createStub(EmailTemplateDB.class, emailTemplateDBStubInstance);

        DBManagerTestsStub emailDBStubInstance = new DBManagerTestsStub();
        ApplicationManager.emailDBInstance = (EmailDB) Test.createStub(EmailDB.class, emailDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        ApplicationManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Test.startTest();

            ApplicationManager.handleAfterStatusChange(applicationByStatus);

        Test.stopTest();
        System.assertEquals(true, sendEmailResult.get(0).isSuccess());
    }

    @isTest
    private static void sendReadyToFundNotification() {

        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.Name = 'Magar Industries LLC';
        borrowerAccount.Merchant_ID__c = '3123123';
        borrowerAccount.Email_cc__c = 'test@yopmail.com, test@mailnator.com';

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'JOHN';
        contactRecord.LastName = 'BOSS';
        contactRecord.Email = 'Test@Cancapital.com';
        contactRecord.Account = borrowerAccount;

        User salesRep = new User();
        salesRep.Id = TestUtility.getFakeId(User.getSObjectType());
        salesRep.Email = 'test1@yopmail.com';

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        newOpportunity.Offer_Notification_To_Broker__c = true;

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{"Name" : "APP-00000102", "Broker_Commission_Amount__c" : "1200"}' , genesis__Applications__c.class
        );

        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.genesis__Account__c = borrowerAccount.Id;
        application.genesis__Account__r = borrowerAccount;
        application.Broker_Contact__c = contactRecord.Id;
        application.Broker_Contact__r = contactRecord;
        application.Opportunity__c = newOpportunity.Id;
        application.Opportunity__r = newOpportunity;
        application.Sales_Rep__c = salesRep.Id;
        application.Sales_Rep__r = salesRep;
        application.genesis__Loan_Amount__c = 12000;

        EmailTemplate emailTemplate = new EmailTemplate();
        emailTemplate.Id = TestUtility.getFakeId(EmailTemplate.getSObjectType());
        emailTemplate.Name = 'Broker_Decline_Notification';
        emailTemplate.Subject = '{{MERCHANT_ID}}';
        emailTemplate.Body = '{{MERCHANT_ID}}';
        emailTemplate.HtmlValue = '{{MERCHANT_ID}}';
        emailTemplate.DeveloperName = 'Broker_Decline_Notification';

        String fromAddress = 'test1@example.com';
        String subject = 'Dummy Subject';
        String htmlTextBody = '<b>Dummy Html Text Body</b><br/>';
        List<String> toAddress = new List<String>{'test@example.com'};

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = Emails.getEmailMessageSetup(
            toAddress, null, fromAddress, subject, htmlTextBody, true,
            new Map<String, Blob>{'a' => Blob.valueOf('a')}, null
        );
        emailList.add(email);

        List<Messaging.SendEmailResult> sendEmailResult = emailDbInstance.sendEmail(email);

        Map<String, List<genesis__Applications__c>> applicationByStatus = new Map<String, List<genesis__Applications__c>>();
        applicationByStatus.put(Applications.STATUS_READY_TO_FUND, new List<genesis__Applications__c> {application});

        DBManagerTestsStub applicationDBApplicationStubInstance = new DBManagerTestsStub();
        applicationDBApplicationStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBApplicationStubInstance);

        DBManagerTestsStub emailTemplateDBStubInstance = new DBManagerTestsStub();
        emailTemplateDBStubInstance.genericReturnObject = new List<EmailTemplate> {emailTemplate};
        GeneralHelper.emailTemplateDBInstance = (EmailTemplateDB) Test.createStub(EmailTemplateDB.class, emailTemplateDBStubInstance);

        DBManagerTestsStub emailDBStubInstance = new DBManagerTestsStub();
        ApplicationManager.emailDBInstance = (EmailDB) Test.createStub(EmailDB.class, emailDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        ApplicationManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Test.startTest();
            ApplicationManager.handleAfterStatusChange(applicationByStatus);
        Test.stopTest();
        System.assertEquals(true, sendEmailResult.get(0).isSuccess());
    }

    @isTest
    private static void sendReadyToFundNotificationWhenRenewal() {

        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.Name = 'Magar Industries LLC';
        borrowerAccount.Merchant_ID__c = '3123123';
        borrowerAccount.Email_cc__c = 'test@yopmail.com, test@mailnator.com';

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'JOHN';
        contactRecord.LastName = 'BOSS';
        contactRecord.Email = 'Test@Cancapital.com';
        contactRecord.Account = borrowerAccount;

        User salesRep = new User();
        salesRep.Id = TestUtility.getFakeId(User.getSObjectType());
        salesRep.Email = 'test1@yopmail.com';

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        newOpportunity.Offer_Notification_To_Broker__c = true;

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{"Name" : "APP-00000102", "Broker_Commission_Amount__c" : "1200"}' , genesis__Applications__c.class
        );

        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;
        application.genesis__Account__c = borrowerAccount.Id;
        application.genesis__Account__r = borrowerAccount;
        application.Broker_Contact__c = contactRecord.Id;
        application.Broker_Contact__r = contactRecord;
        application.Opportunity__c = newOpportunity.Id;
        application.Opportunity__r = newOpportunity;
        application.Sales_Rep__c = salesRep.Id;
        application.Sales_Rep__r = salesRep;
        application.genesis__Loan_Amount__c = 12000;
        application.Broker_Contact__r.Account.renewal_funding_notice__c = true;

        EmailTemplate emailTemplate = new EmailTemplate();
        emailTemplate.Id = TestUtility.getFakeId(EmailTemplate.getSObjectType());
        emailTemplate.Name = 'Broker_Decline_Notification';
        emailTemplate.Subject = '{{MERCHANT_ID}}';
        emailTemplate.Body = '{{MERCHANT_ID}}';
        emailTemplate.HtmlValue = '{{MERCHANT_ID}}';
        emailTemplate.DeveloperName = 'Broker_Decline_Notification';

        String fromAddress = 'test1@example.com';
        String subject = 'Dummy Subject';
        String htmlTextBody = '<b>Dummy Html Text Body</b><br/>';
        List<String> toAddress = new List<String>{'test@example.com'};

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = Emails.getEmailMessageSetup(
            toAddress, null, fromAddress, subject, htmlTextBody, true,
            new Map<String, Blob>{'a' => Blob.valueOf('a')}, null
        );
        emailList.add(email);

        List<Messaging.SendEmailResult> sendEmailResult = emailDbInstance.sendEmail(email);

        Map<String, List<genesis__Applications__c>> applicationByStatus = new Map<String, List<genesis__Applications__c>>();
        applicationByStatus.put(Applications.STATUS_READY_TO_FUND, new List<genesis__Applications__c> {application});

        DBManagerTestsStub applicationDBApplicationStubInstance = new DBManagerTestsStub();
        applicationDBApplicationStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBApplicationStubInstance);

        DBManagerTestsStub emailTemplateDBStubInstance = new DBManagerTestsStub();
        emailTemplateDBStubInstance.genericReturnObject = new List<EmailTemplate> {emailTemplate};
        GeneralHelper.emailTemplateDBInstance = (EmailTemplateDB) Test.createStub(EmailTemplateDB.class, emailTemplateDBStubInstance);

        DBManagerTestsStub emailDBStubInstance = new DBManagerTestsStub();
        ApplicationManager.emailDBInstance = (EmailDB) Test.createStub(EmailDB.class, emailDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        ApplicationManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Test.startTest();
            ApplicationManager.handleAfterStatusChange(applicationByStatus);
        Test.stopTest();
        System.assertEquals(true, sendEmailResult.get(0).isSuccess());
    }



    @isTest
    private static void handleAfterStatusChangeBankStatementProcessFailed() {

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Industry_Rating__c = 'B';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 1413777;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 1;
        application.genesis__Payment_Frequency__c = 'DAILY';
        application.Auto_Renewed__c = true;
        application.Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;
        application.genesis__Status__c = Applications.STATUS_BANK_STATEMENT_PROCESSING;

        DBManagerTestsStub ocrolusAppDBStubInstance = new DBManagerTestsStub();
        ocrolusAppDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        OcrolusManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, ocrolusAppDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        OcrolusManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Map<String, List<genesis__Applications__c>> applicationByStatus = new Map<String, List<genesis__Applications__c>>();
        applicationByStatus.put(Applications.STATUS_BANK_STATEMENT_PROCESSING_FAILED, new List<genesis__Applications__c> {application});

        Test.startTest();
            ApplicationManager.handleAfterStatusChange(applicationByStatus);
        Test.stopTest();

        System.assertEquals(1, ErrorLogDBStubInstance.forInsertSObjects.size());
    }

    @isTest
    private static void handleAfterDecline() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;
        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{"Name" : "APP-00000102", "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship", ' +
                '"Time_In_Business__c" : "1"}' , genesis__Applications__c.class
        );

        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Primary_Guarantor__c = TestUtility.getFakeId(Contact.getSObjectType());
        application.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        application.Renewal_Concurrent_LoanAccount__c = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        application.Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;
        application.Auto_Renewed__c = true;
        application.Decline_Reasons__c = BusinessRules.DENIAL_REASON_ACTIVE_APPLICATION_OR_CONTRACT;

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        ApplicationManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        ApplicationManager.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        DBManagerTestsStub applicationDBApplicationStubInstance = new DBManagerTestsStub();
        applicationDBApplicationStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBApplicationStubInstance);

        Test.startTest();
            ApplicationManager.handleAfterDecline(new List<genesis__Applications__c> {application} );
        Test.stopTest();

        System.assertEquals(1, accountDBStubInstance.forUpdateSObjects.size());
        System.assertEquals(1, clContractDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void handleFraudFlagChangesWhenChecked() {

        Id accountId = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        ApplicationManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Id contactId = TestUtility.getFakeId(Contact.getSObjectType());

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        ApplicationManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Confirmed_Fraud_Flag__c = true;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        Set<Id> applicationIds = new Set<Id> ();
        applicationIds.add(application.Id);

        clcommon__Party_Type__c guarantorPartyType = new clcommon__Party_Type__c();
        guarantorPartyType.Name = 'GUARANTOR';
        guarantorPartyType.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());

        clcommon__Party_Type__c borrowerPartyType = new clcommon__Party_Type__c();
        borrowerPartyType.Name = 'BORROWER';
        borrowerPartyType.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());

        Map<String, Id> partyTypeToId = new Map<String, Id>();
        partyTypeToId.put(guarantorPartyType.Name, guarantorPartyType.Id);
        partyTypeToId.put(borrowerPartyType.Name, borrowerPartyType.Id);
        OriginationHelper.partyTypeToId = partyTypeToId;

        List<clcommon__Party__c> partyList = new List<clcommon__Party__c> ();

        clcommon__Party__c partyBorrower = new clcommon__Party__c();
        partyBorrower.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        partyBorrower.genesis__Application__c = application.Id;
        partyBorrower.genesis__Application__r = application;
        partyBorrower.clcommon__Type__c = OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BORROWER);
        partyBorrower.clcommon__Account__c = accountId;
        partyList.add(partyBorrower);

        clcommon__Party__c partyGuarantor = new clcommon__Party__c();
        partyGuarantor.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        partyGuarantor.genesis__Application__c = application.Id;
        partyGuarantor.genesis__Application__r = application;
        partyGuarantor.clcommon__Type__c = OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_GUARANTOR);
        partyGuarantor.clcommon__Account__c = accountId;
        partyGuarantor.clcommon__Contact__c = contactId;
        partyList.add(partyGuarantor);

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = partyList;
        ApplicationManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        Test.startTest();
            ApplicationManager.handleFraudFlagChanges(applicationIds);
        Test.stopTest();

        System.assertEquals(1, accountDBStubInstance.forUpdateSObjects.size());
        Account actualAccount = (Account) accountDBStubInstance.forUpdateSObjects.get(0);
        System.assert(actualAccount.Confirmed_Fraud_Flag__c);

        System.assertEquals(1, contactDBStubInstance.forUpdateSObjects.size());
        Contact actualContact = (Contact) contactDBStubInstance.forUpdateSObjects.get(0);
        System.assert(actualContact.Confirmed_Fraud_Flag__c);
    }

    @isTest
    private static void handleFraudFlagChangesWhenUnCheckedForSamePartiesMappedWithOtherApps() {

        Id accountId = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        ApplicationManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Id contactId = TestUtility.getFakeId(Contact.getSObjectType());

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        ApplicationManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Confirmed_Fraud_Flag__c = false;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        Set<Id> applicationIds = new Set<Id> ();
        applicationIds.add(application.Id);

        clcommon__Party_Type__c guarantorPartyType = new clcommon__Party_Type__c();
        guarantorPartyType.Name = 'GUARANTOR';
        guarantorPartyType.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());

        clcommon__Party_Type__c borrowerPartyType = new clcommon__Party_Type__c();
        borrowerPartyType.Name = 'BORROWER';
        borrowerPartyType.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());

        Map<String, Id> partyTypeToId = new Map<String, Id>();
        partyTypeToId.put(guarantorPartyType.Name, guarantorPartyType.Id);
        partyTypeToId.put(borrowerPartyType.Name, borrowerPartyType.Id);
        OriginationHelper.partyTypeToId = partyTypeToId;

        List<clcommon__Party__c> partyList = new List<clcommon__Party__c> ();

        clcommon__Party__c partyBorrower = new clcommon__Party__c();
        partyBorrower.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        partyBorrower.genesis__Application__c = application.Id;
        partyBorrower.genesis__Application__r = application;
        partyBorrower.clcommon__Type__c = OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BORROWER);
        partyBorrower.clcommon__Account__c = accountId;
        partyList.add(partyBorrower);

        clcommon__Party__c partyGuarantor = new clcommon__Party__c();
        partyGuarantor.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        partyGuarantor.genesis__Application__c = application.Id;
        partyGuarantor.genesis__Application__r = application;
        partyGuarantor.clcommon__Type__c = OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_GUARANTOR);
        partyGuarantor.clcommon__Account__c = accountId;
        partyGuarantor.clcommon__Contact__c = contactId;
        partyList.add(partyGuarantor);

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = partyList;
        ApplicationManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        List<clcommon__Party__c> samePartiesForOtherApplication = new List<clcommon__Party__c> ();

        clcommon__Party__c fraudPartyBorrower = new clcommon__Party__c();
        fraudPartyBorrower.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        fraudPartyBorrower.genesis__Application__c = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        fraudPartyBorrower.clcommon__Type__c = OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BORROWER);
        fraudPartyBorrower.clcommon__Account__c = accountId;
        samePartiesForOtherApplication.add(fraudPartyBorrower);

        clcommon__Party__c fraudPartyGuarantor = new clcommon__Party__c();
        fraudPartyGuarantor.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        fraudPartyGuarantor.genesis__Application__c = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        fraudPartyGuarantor.clcommon__Type__c = OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_GUARANTOR);
        fraudPartyGuarantor.clcommon__Account__c = accountId;
        fraudPartyGuarantor.clcommon__Contact__c = contactId;
        samePartiesForOtherApplication.add(fraudPartyGuarantor);

        DBManagerTestsStub fraudPartyDBStubInstance = new DBManagerTestsStub();
        fraudPartyDBStubInstance.genericReturnObject = samePartiesForOtherApplication;
        ApplicationManager.fraudPartyDBInstance = (PartyDB) Test.createStub(PartyDB.class, fraudPartyDBStubInstance);

        Test.startTest();
            ApplicationManager.handleFraudFlagChanges(applicationIds);
        Test.stopTest();

        System.assertEquals(0, accountDBStubInstance.forUpdateSObjects.size());
        System.assertEquals(0, contactDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    private static void handleFraudFlagChangesWhenUnCheckedForNoPartiesMappedWithOtherApps() {

        Id accountId = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        ApplicationManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Id contactId = TestUtility.getFakeId(Contact.getSObjectType());

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        ApplicationManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Confirmed_Fraud_Flag__c = false;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        Set<Id> applicationIds = new Set<Id> ();
        applicationIds.add(application.Id);

        clcommon__Party_Type__c guarantorPartyType = new clcommon__Party_Type__c();
        guarantorPartyType.Name = 'GUARANTOR';
        guarantorPartyType.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());

        clcommon__Party_Type__c borrowerPartyType = new clcommon__Party_Type__c();
        borrowerPartyType.Name = 'BORROWER';
        borrowerPartyType.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());

        Map<String, Id> partyTypeToId = new Map<String, Id>();
        partyTypeToId.put(guarantorPartyType.Name, guarantorPartyType.Id);
        partyTypeToId.put(borrowerPartyType.Name, borrowerPartyType.Id);
        OriginationHelper.partyTypeToId = partyTypeToId;

        List<clcommon__Party__c> partyList = new List<clcommon__Party__c> ();

        clcommon__Party__c partyBorrower = new clcommon__Party__c();
        partyBorrower.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        partyBorrower.genesis__Application__c = application.Id;
        partyBorrower.genesis__Application__r = application;
        partyBorrower.clcommon__Type__c = OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BORROWER);
        partyBorrower.clcommon__Account__c = accountId;
        partyList.add(partyBorrower);

        clcommon__Party__c partyGuarantor = new clcommon__Party__c();
        partyGuarantor.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        partyGuarantor.genesis__Application__c = application.Id;
        partyGuarantor.genesis__Application__r = application;
        partyGuarantor.clcommon__Type__c = OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_GUARANTOR);
        partyGuarantor.clcommon__Account__c = accountId;
        partyGuarantor.clcommon__Contact__c = contactId;
        partyList.add(partyGuarantor);

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = partyList;
        ApplicationManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        DBManagerTestsStub fraudPartyDBStubInstance = new DBManagerTestsStub();
        fraudPartyDBStubInstance.genericReturnObject =  new List<clcommon__Party__c> ();
        ApplicationManager.fraudPartyDBInstance = (PartyDB) Test.createStub(PartyDB.class, fraudPartyDBStubInstance);

        Test.startTest();
            ApplicationManager.handleFraudFlagChanges(applicationIds);
        Test.stopTest();

        System.assertEquals(1, accountDBStubInstance.forUpdateSObjects.size());
        Account actualAccount = (Account) accountDBStubInstance.forUpdateSObjects.get(0);
        System.assert(!actualAccount.Confirmed_Fraud_Flag__c);

        System.assertEquals(1, contactDBStubInstance.forUpdateSObjects.size());
        Contact actualContact = (Contact) contactDBStubInstance.forUpdateSObjects.get(0);
        System.assert(!actualContact.Confirmed_Fraud_Flag__c);
    }

    @isTest
    private static void runApplicationConversionRuleTermAuditAndPricingAccepted() {

        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Id pricingDetailId = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Application__c = applicationId;
        pricingDetail.Id = pricingDetailId;
        pricingDetail.Status__c = CANPricingDetails.STATUS_ACCEPTED;
        pricingDetail.term_audit_complete__c = true;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = applicationId;
        application.Confirmed_Fraud_Flag__c = false;
        application.Pricing_Factor__c = 1.20;
        application.Origination_Fee_Percentage__c = 2.00;
        application.SC4_Tier__c = 'TIER 2';
        application.genesis__Term__c = 12;

        CAN_Min_And_Max_Pricing_Detail__c canMAxAndMinPricing = new CAN_Min_And_Max_Pricing_Detail__c();
        canMAxAndMinPricing.sc4_tier__c ='TIER 2';
        canMAxAndMinPricing.term__c = 12;
        canMAxAndMinPricing.min_price__c = 1.08;
        canMAxAndMinPricing.max_price__c = 1.46;

        DBManagerTestsStub canPricingDBStubInstance = new DBManagerTestsStub();
        canPricingDBStubInstance.genericReturnObject = new List<CAN_Pricing_Detail__c>{pricingDetail};
        ApplicationManager.canPricingDetailDBInstance = (CANPricingDetailDB) Test.createStub(CANPricingDetailDB.class, canPricingDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub minAndMaxPricingMappingDBStubInstance = new DBManagerTestsStub();
        minAndMaxPricingMappingDBStubInstance.genericReturnObject = new List<CAN_Min_And_Max_Pricing_Detail__c> {canMAxAndMinPricing};
        OriginationHelper.minAndMaxPricingDBInstance = (CANMinAndMaxPricingDetailDB) Test.createStub(CANMinAndMaxPricingDetailDB.class, minAndMaxPricingMappingDBStubInstance);

        Test.startTest();
            String result = ApplicationManager.runApplicationConversionRule(applicationId);
        Test.stopTest();

        System.assertEquals('SUCCESS', result);
    }

    @isTest
    private static void runApplicationConversionRuleTermAuditButNotPricingAccepted() {

        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Id pricingDetailId = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Application__c = applicationId;
        pricingDetail.Id = pricingDetailId;
        pricingDetail.Status__c = 'Sent To Customer';
        pricingDetail.term_audit_complete__c = true;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = applicationId;
        application.Confirmed_Fraud_Flag__c = false;
        application.Pricing_Factor__c = 1.20;
        application.Origination_Fee_Percentage__c = 2.00;
        application.SC4_Tier__c = 'TIER 2';
        application.genesis__Term__c = 12;

        CAN_Min_And_Max_Pricing_Detail__c canMAxAndMinPricing = new CAN_Min_And_Max_Pricing_Detail__c();
        canMAxAndMinPricing.sc4_tier__c ='TIER 2';
        canMAxAndMinPricing.term__c = 12;
        canMAxAndMinPricing.min_price__c = 1.08;
        canMAxAndMinPricing.max_price__c = 1.46;

        DBManagerTestsStub canPricingDBStubInstance = new DBManagerTestsStub();
        canPricingDBStubInstance.genericReturnObject = new List<CAN_Pricing_Detail__c>{pricingDetail};
        ApplicationManager.canPricingDetailDBInstance = (CANPricingDetailDB) Test.createStub(CANPricingDetailDB.class, canPricingDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub minAndMaxPricingMappingDBStubInstance = new DBManagerTestsStub();
        minAndMaxPricingMappingDBStubInstance.genericReturnObject = new List<CAN_Min_And_Max_Pricing_Detail__c> {canMAxAndMinPricing};
        OriginationHelper.minAndMaxPricingDBInstance = (CANMinAndMaxPricingDetailDB) Test.createStub(CANMinAndMaxPricingDetailDB.class, minAndMaxPricingMappingDBStubInstance);

        Test.startTest();
            String result = ApplicationManager.runApplicationConversionRule(applicationId);
        Test.stopTest();

        System.assertEquals(' -' + CANPricingDetails.TERM_AUDIT_NO_COMPLETE_ERROR_MSG + '\n', result);
    }

    @isTest
    private static void runApplicationConversionRuleNotTermAuditButPricingAccepted() {

        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Id pricingDetailId = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Application__c = applicationId;
        pricingDetail.Id = pricingDetailId;
        pricingDetail.Status__c = CANPricingDetails.STATUS_ACCEPTED;
        pricingDetail.term_audit_complete__c = false;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = applicationId;
        application.Confirmed_Fraud_Flag__c = false;
        application.Pricing_Factor__c = 1.20;
        application.Origination_Fee_Percentage__c = 2.00;
        application.SC4_Tier__c = 'TIER 2';
        application.genesis__Term__c = 12;

        CAN_Min_And_Max_Pricing_Detail__c canMAxAndMinPricing = new CAN_Min_And_Max_Pricing_Detail__c();
        canMAxAndMinPricing.sc4_tier__c ='TIER 2';
        canMAxAndMinPricing.term__c = 12;
        canMAxAndMinPricing.min_price__c = 1.08;
        canMAxAndMinPricing.max_price__c = 1.46;


        DBManagerTestsStub canPricingDBStubInstance = new DBManagerTestsStub();
        canPricingDBStubInstance.genericReturnObject = new List<CAN_Pricing_Detail__c>{pricingDetail};
        ApplicationManager.canPricingDetailDBInstance = (CANPricingDetailDB) Test.createStub(CANPricingDetailDB.class, canPricingDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub minAndMaxPricingMappingDBStubInstance = new DBManagerTestsStub();
        minAndMaxPricingMappingDBStubInstance.genericReturnObject = new List<CAN_Min_And_Max_Pricing_Detail__c> {canMAxAndMinPricing};
        OriginationHelper.minAndMaxPricingDBInstance = (CANMinAndMaxPricingDetailDB) Test.createStub(CANMinAndMaxPricingDetailDB.class, minAndMaxPricingMappingDBStubInstance);

        Test.startTest();
            String result = ApplicationManager.runApplicationConversionRule(applicationId);
        Test.stopTest();

        System.assertEquals(' -' + CANPricingDetails.TERM_AUDIT_NO_COMPLETE_ERROR_MSG + '\n', result);
    }

    @isTest
    private static void runApplicationConversionRuleNoPricingFound() {

        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = applicationId;
        application.Confirmed_Fraud_Flag__c = false;
        application.Pricing_Factor__c = 1.20;
        application.Origination_Fee_Percentage__c = 2.00;
        application.SC4_Tier__c = 'TIER 2';
        application.genesis__Term__c = 12;

        CAN_Min_And_Max_Pricing_Detail__c canMAxAndMinPricing = new CAN_Min_And_Max_Pricing_Detail__c();
        canMAxAndMinPricing.sc4_tier__c ='TIER 2';
        canMAxAndMinPricing.term__c = 12;
        canMAxAndMinPricing.min_price__c = 1.08;
        canMAxAndMinPricing.max_price__c = 1.46;

        DBManagerTestsStub canPricingDBStubInstance = new DBManagerTestsStub();
        canPricingDBStubInstance.genericReturnObject = new List<CAN_Pricing_Detail__c>();
        ApplicationManager.canPricingDetailDBInstance = (CANPricingDetailDB) Test.createStub(CANPricingDetailDB.class, canPricingDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub minAndMaxPricingMappingDBStubInstance = new DBManagerTestsStub();
        minAndMaxPricingMappingDBStubInstance.genericReturnObject = new List<CAN_Min_And_Max_Pricing_Detail__c> {canMAxAndMinPricing};
        OriginationHelper.minAndMaxPricingDBInstance = (CANMinAndMaxPricingDetailDB) Test.createStub(CANMinAndMaxPricingDetailDB.class, minAndMaxPricingMappingDBStubInstance);

        Test.startTest();
            String result = ApplicationManager.runApplicationConversionRule(applicationId);
        Test.stopTest();

        System.assertEquals(CANPricingDetails.NO_ACTIVE_PRICING_RECORD_FOUND_ERROR_MSG + '\n', result);
    }

    @isTest
    private static void runApplicationConversionRuleMaxPricingExceeded() {

        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Id pricingDetailId = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Application__c = applicationId;
        pricingDetail.Id = pricingDetailId;
        pricingDetail.Status__c = CANPricingDetails.STATUS_ACCEPTED;
        pricingDetail.term_audit_complete__c = true;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = applicationId;
        application.Confirmed_Fraud_Flag__c = false;
        application.Pricing_Factor__c = 1.47;
        application.Origination_Fee_Percentage__c = 2.00;
        application.SC4_Tier__c = 'TIER 2';
        application.genesis__Term__c = 12;

        CAN_Min_And_Max_Pricing_Detail__c canMAxAndMinPricing = new CAN_Min_And_Max_Pricing_Detail__c();
        canMAxAndMinPricing.sc4_tier__c ='TIER 2';
        canMAxAndMinPricing.term__c = 12;
        canMAxAndMinPricing.min_price__c = 1.08;
        canMAxAndMinPricing.max_price__c = 1.46;


        DBManagerTestsStub canPricingDBStubInstance = new DBManagerTestsStub();
        canPricingDBStubInstance.genericReturnObject = new List<CAN_Pricing_Detail__c>{pricingDetail};
        ApplicationManager.canPricingDetailDBInstance = (CANPricingDetailDB) Test.createStub(CANPricingDetailDB.class, canPricingDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub minAndMaxPricingMappingDBStubInstance = new DBManagerTestsStub();
        minAndMaxPricingMappingDBStubInstance.genericReturnObject = new List<CAN_Min_And_Max_Pricing_Detail__c> {canMAxAndMinPricing};
        OriginationHelper.minAndMaxPricingDBInstance = (CANMinAndMaxPricingDetailDB) Test.createStub(CANMinAndMaxPricingDetailDB.class, minAndMaxPricingMappingDBStubInstance);

        Test.startTest();
            String result = ApplicationManager.runApplicationConversionRule(applicationId);
        Test.stopTest();

        System.assertEquals(' -' + CANPricingDetails.MAXIMUM_PRICING_FACTOR_ORIGINATION_FEE_PCT_ERROR_MSG + '\n', result);
    }

    @isTest
    private static void runApplicationConversionRuleMinPricingExceeded() {

        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Id pricingDetailId = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Application__c = applicationId;
        pricingDetail.Id = pricingDetailId;
        pricingDetail.Status__c = CANPricingDetails.STATUS_ACCEPTED;
        pricingDetail.term_audit_complete__c = true;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = applicationId;
        application.Confirmed_Fraud_Flag__c = false;
        application.Pricing_Factor__c = 1.05;
        application.Origination_Fee_Percentage__c = 2.00;
        application.SC4_Tier__c = 'TIER 2';
        application.genesis__Term__c = 12;

        CAN_Min_And_Max_Pricing_Detail__c canMAxAndMinPricing = new CAN_Min_And_Max_Pricing_Detail__c();
        canMAxAndMinPricing.sc4_tier__c ='TIER 2';
        canMAxAndMinPricing.term__c = 12;
        canMAxAndMinPricing.min_price__c = 1.08;
        canMAxAndMinPricing.max_price__c = 1.46;


        DBManagerTestsStub canPricingDBStubInstance = new DBManagerTestsStub();
        canPricingDBStubInstance.genericReturnObject = new List<CAN_Pricing_Detail__c>{pricingDetail};
        ApplicationManager.canPricingDetailDBInstance = (CANPricingDetailDB) Test.createStub(CANPricingDetailDB.class, canPricingDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub minAndMaxPricingMappingDBStubInstance = new DBManagerTestsStub();
        minAndMaxPricingMappingDBStubInstance.genericReturnObject = new List<CAN_Min_And_Max_Pricing_Detail__c> {canMAxAndMinPricing};
        OriginationHelper.minAndMaxPricingDBInstance = (CANMinAndMaxPricingDetailDB) Test.createStub(CANMinAndMaxPricingDetailDB.class, minAndMaxPricingMappingDBStubInstance);

        Test.startTest();
            String result = ApplicationManager.runApplicationConversionRule(applicationId);
        Test.stopTest();

        System.assertEquals(' -' + CANPricingDetails.MINIMUM_PRICING_FACTOR_ORIGINATION_FEE_PCT_ERROR_MSG + '\n', result);
    }

    @isTest
    private static void runApplicationConversionRuleNotTermAuditButPricingAcceptedAndMaxPricingExceeded() {

        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Id pricingDetailId = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Application__c = applicationId;
        pricingDetail.Id = pricingDetailId;
        pricingDetail.Status__c = CANPricingDetails.STATUS_ACCEPTED;
        pricingDetail.term_audit_complete__c = false;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = applicationId;
        application.Confirmed_Fraud_Flag__c = false;
        application.Pricing_Factor__c = 1.47;
        application.Origination_Fee_Percentage__c = 2.00;
        application.SC4_Tier__c = 'TIER 2';
        application.genesis__Term__c = 12;

        CAN_Min_And_Max_Pricing_Detail__c canMAxAndMinPricing = new CAN_Min_And_Max_Pricing_Detail__c();
        canMAxAndMinPricing.sc4_tier__c ='TIER 2';
        canMAxAndMinPricing.term__c = 12;
        canMAxAndMinPricing.min_price__c = 1.08;
        canMAxAndMinPricing.max_price__c = 1.46;


        DBManagerTestsStub canPricingDBStubInstance = new DBManagerTestsStub();
        canPricingDBStubInstance.genericReturnObject = new List<CAN_Pricing_Detail__c>{pricingDetail};
        ApplicationManager.canPricingDetailDBInstance = (CANPricingDetailDB) Test.createStub(CANPricingDetailDB.class, canPricingDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub minAndMaxPricingMappingDBStubInstance = new DBManagerTestsStub();
        minAndMaxPricingMappingDBStubInstance.genericReturnObject = new List<CAN_Min_And_Max_Pricing_Detail__c> {canMAxAndMinPricing};
        OriginationHelper.minAndMaxPricingDBInstance = (CANMinAndMaxPricingDetailDB) Test.createStub(CANMinAndMaxPricingDetailDB.class, minAndMaxPricingMappingDBStubInstance);

        Test.startTest();
            String result = ApplicationManager.runApplicationConversionRule(applicationId);
        Test.stopTest();

        System.assert(result.contains(CANPricingDetails.TERM_AUDIT_NO_COMPLETE_ERROR_MSG));
        System.assert(result.contains(CANPricingDetails.MAXIMUM_PRICING_FACTOR_ORIGINATION_FEE_PCT_ERROR_MSG));
    }

    @isTest
    private static void runApplicationConversionRuleTermAuditButNotPricingAcceptedAndMaxPricingExceeded() {

        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Id pricingDetailId = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Application__c = applicationId;
        pricingDetail.Id = pricingDetailId;
        pricingDetail.Status__c = 'Sent To Customer';
        pricingDetail.term_audit_complete__c = true;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = applicationId;
        application.Confirmed_Fraud_Flag__c = false;
        application.Pricing_Factor__c = 1.47;
        application.Origination_Fee_Percentage__c = 2.00;
        application.SC4_Tier__c = 'TIER 2';
        application.genesis__Term__c = 12;

        CAN_Min_And_Max_Pricing_Detail__c canMAxAndMinPricing = new CAN_Min_And_Max_Pricing_Detail__c();
        canMAxAndMinPricing.sc4_tier__c ='TIER 2';
        canMAxAndMinPricing.term__c = 12;
        canMAxAndMinPricing.min_price__c = 1.08;
        canMAxAndMinPricing.max_price__c = 1.46;

        DBManagerTestsStub canPricingDBStubInstance = new DBManagerTestsStub();
        canPricingDBStubInstance.genericReturnObject = new List<CAN_Pricing_Detail__c>{pricingDetail};
        ApplicationManager.canPricingDetailDBInstance = (CANPricingDetailDB) Test.createStub(CANPricingDetailDB.class, canPricingDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub minAndMaxPricingMappingDBStubInstance = new DBManagerTestsStub();
        minAndMaxPricingMappingDBStubInstance.genericReturnObject = new List<CAN_Min_And_Max_Pricing_Detail__c> {canMAxAndMinPricing};
        OriginationHelper.minAndMaxPricingDBInstance = (CANMinAndMaxPricingDetailDB) Test.createStub(CANMinAndMaxPricingDetailDB.class, minAndMaxPricingMappingDBStubInstance);

        Test.startTest();
            String result = ApplicationManager.runApplicationConversionRule(applicationId);
        Test.stopTest();

        System.assert(result.contains(CANPricingDetails.TERM_AUDIT_NO_COMPLETE_ERROR_MSG));
        System.assert(result.contains(CANPricingDetails.MAXIMUM_PRICING_FACTOR_ORIGINATION_FEE_PCT_ERROR_MSG));
    }

    @isTest
    private static void runApplicationConversionRuleNoMaxMinPricingMappingFound() {

        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Id pricingDetailId = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Application__c = applicationId;
        pricingDetail.Id = pricingDetailId;
        pricingDetail.Status__c =  CANPricingDetails.STATUS_ACCEPTED;
        pricingDetail.term_audit_complete__c = true;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = applicationId;
        application.Confirmed_Fraud_Flag__c = false;
        application.Pricing_Factor__c = 1.47;
        application.Origination_Fee_Percentage__c = 2.00;
        application.SC4_Tier__c = 'TIER 2';
        application.genesis__Term__c = 12;

        CAN_Min_And_Max_Pricing_Detail__c canMAxAndMinPricing = new CAN_Min_And_Max_Pricing_Detail__c();
        canMAxAndMinPricing.sc4_tier__c ='TIER 2';
        canMAxAndMinPricing.term__c = 12;
        canMAxAndMinPricing.min_price__c = 1.08;
        canMAxAndMinPricing.max_price__c = 1.46;

        DBManagerTestsStub canPricingDBStubInstance = new DBManagerTestsStub();
        canPricingDBStubInstance.genericReturnObject = new List<CAN_Pricing_Detail__c>{pricingDetail};
        ApplicationManager.canPricingDetailDBInstance = (CANPricingDetailDB) Test.createStub(CANPricingDetailDB.class, canPricingDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub minAndMaxPricingMappingDBStubInstance = new DBManagerTestsStub();
        minAndMaxPricingMappingDBStubInstance.genericReturnObject = new List<CAN_Min_And_Max_Pricing_Detail__c>();
        OriginationHelper.minAndMaxPricingDBInstance = (CANMinAndMaxPricingDetailDB) Test.createStub(CANMinAndMaxPricingDetailDB.class, minAndMaxPricingMappingDBStubInstance);

        Test.startTest();
            String result = ApplicationManager.runApplicationConversionRule(applicationId);
        Test.stopTest();

        System.assert(result.contains(CANPricingDetails.NO_MAX_AND_MIN_PRICING_MAPPING_FOUND_ERROR_MSG));
        //System.assert(result.contains(CANPricingDetails.MAXIMUM_PRICING_FACTOR_ORIGINATION_FEE_PCT_ERROR_MSG));
        }


    @isTest
    private static void runApplicationConversionRuleNotTermAuditButPricingAcceptedAndMinPricingExceeded() {

        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Id pricingDetailId = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Application__c = applicationId;
        pricingDetail.Id = pricingDetailId;
        pricingDetail.Status__c = CANPricingDetails.STATUS_ACCEPTED;
        pricingDetail.term_audit_complete__c = false;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = applicationId;
        application.Confirmed_Fraud_Flag__c = false;
        application.Pricing_Factor__c = 1.05;
        application.Origination_Fee_Percentage__c = 2.00;
        application.SC4_Tier__c = 'TIER 2';
        application.genesis__Term__c = 12;

        CAN_Min_And_Max_Pricing_Detail__c canMAxAndMinPricing = new CAN_Min_And_Max_Pricing_Detail__c();
        canMAxAndMinPricing.sc4_tier__c ='TIER 2';
        canMAxAndMinPricing.term__c = 12;
        canMAxAndMinPricing.min_price__c = 1.08;
        canMAxAndMinPricing.max_price__c = 1.46;


        DBManagerTestsStub canPricingDBStubInstance = new DBManagerTestsStub();
        canPricingDBStubInstance.genericReturnObject = new List<CAN_Pricing_Detail__c>{pricingDetail};
        ApplicationManager.canPricingDetailDBInstance = (CANPricingDetailDB) Test.createStub(CANPricingDetailDB.class, canPricingDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub minAndMaxPricingMappingDBStubInstance = new DBManagerTestsStub();
        minAndMaxPricingMappingDBStubInstance.genericReturnObject = new List<CAN_Min_And_Max_Pricing_Detail__c> {canMAxAndMinPricing};
        OriginationHelper.minAndMaxPricingDBInstance = (CANMinAndMaxPricingDetailDB) Test.createStub(CANMinAndMaxPricingDetailDB.class, minAndMaxPricingMappingDBStubInstance);

        Test.startTest();
            String result = ApplicationManager.runApplicationConversionRule(applicationId);
        Test.stopTest();

        System.assert(result.contains(CANPricingDetails.TERM_AUDIT_NO_COMPLETE_ERROR_MSG));
        System.assert(result.contains(CANPricingDetails.MINIMUM_PRICING_FACTOR_ORIGINATION_FEE_PCT_ERROR_MSG));
    }

    @isTest
    private static void runApplicationConversionRuleTermAuditButNotPricingAcceptedAndMinPricingExceeded() {

        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Id pricingDetailId = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Application__c = applicationId;
        pricingDetail.Id = pricingDetailId;
        pricingDetail.Status__c = 'Sent To Customer';
        pricingDetail.term_audit_complete__c = true;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = applicationId;
        application.Confirmed_Fraud_Flag__c = false;
        application.Pricing_Factor__c = 1.07;
        application.Origination_Fee_Percentage__c = 2.00;
        application.SC4_Tier__c = 'TIER 2';
        application.genesis__Term__c = 12;

        CAN_Min_And_Max_Pricing_Detail__c canMAxAndMinPricing = new CAN_Min_And_Max_Pricing_Detail__c();
        canMAxAndMinPricing.sc4_tier__c ='TIER 2';
        canMAxAndMinPricing.term__c = 12;
        canMAxAndMinPricing.min_price__c = 1.08;
        canMAxAndMinPricing.max_price__c = 1.46;

        DBManagerTestsStub canPricingDBStubInstance = new DBManagerTestsStub();
        canPricingDBStubInstance.genericReturnObject = new List<CAN_Pricing_Detail__c>{pricingDetail};
        ApplicationManager.canPricingDetailDBInstance = (CANPricingDetailDB) Test.createStub(CANPricingDetailDB.class, canPricingDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub minAndMaxPricingMappingDBStubInstance = new DBManagerTestsStub();
        minAndMaxPricingMappingDBStubInstance.genericReturnObject = new List<CAN_Min_And_Max_Pricing_Detail__c> {canMAxAndMinPricing};
        OriginationHelper.minAndMaxPricingDBInstance = (CANMinAndMaxPricingDetailDB) Test.createStub(CANMinAndMaxPricingDetailDB.class, minAndMaxPricingMappingDBStubInstance);

        Test.startTest();
            String result = ApplicationManager.runApplicationConversionRule(applicationId);
        Test.stopTest();

        System.assert(result.contains(CANPricingDetails.TERM_AUDIT_NO_COMPLETE_ERROR_MSG));
        System.assert(result.contains(CANPricingDetails.MINIMUM_PRICING_FACTOR_ORIGINATION_FEE_PCT_ERROR_MSG));
    }

    @isTest
    private static void sendSTIPsIncompleteNotificationTermMatrix() {
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        CAN_General_Settings__c canGeneralSettings = new CAN_General_Settings__c();
        canGeneralSettings.Id = TestUtility.getFakeId(CAN_General_Settings__c.getSObjectType());
        canGeneralSettings.enable_offer_email_term_matrix__c = true;
        CustomSettingsHelper.generalSettings = canGeneralSettings;

        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.AnnualRevenue = 2000000;
        borrowerAccount.Name = 'Magar Industries LLC';
        borrowerAccount.Merchant_ID__c = '3123123';

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'JOHN';
        contactRecord.LastName = 'BOSS';

        STIPS_Checklist__c stipsCheckList = new STIPS_Checklist__c();
        stipsCheckList.Id = TestUtility.getFakeId(STIPS_Checklist__c.getSObjectType());
        stipsCheckList.Additional_Banks__c = false;
        stipsCheckList.Bank_Verification_Call__c = true;
        stipsCheckList.Borrower_Interview__c = true;
        stipsCheckList.Competitors__c = false;
        stipsCheckList.Federal_Tax_ID__c = true;
        stipsCheckList.Identification__c = false;
        stipsCheckList.Month_to_Date_Bank_Statement__c = false;
        stipsCheckList.Proof_of_Ownership__c = true;
        stipsCheckList.Verification_Call__c = true;
        stipsCheckList.Voided_Check__c = false;
        stipsCheckList.Last_Four_Bank_Account_Number__c = null;
        stipsCheckList.Guarantors_Whose_Identity_Not_Verified__c = null;
        stipsCheckList.Competitor_Names__c = null;

        List<STIPS_Checklist__c> stipsCheckListsList = new List<STIPS_Checklist__c>{stipsCheckList};
        String jsonStipsCheckList = '{"totalSize" : 1, "done" : true, "records" : ' + JSON.serialize(stipsCheckListsList, false) + '}';

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Id = TestUtility.getFakeId(CAN_Pricing_Detail__c.getSObjectType());
        pricingDetail.Maximum_Amount__c = 5000;
        pricingDetail.Industry_Rating__c = 'A+ Medical';
        pricingDetail.SC4_Tier__c = 'TIER 1';
        pricingDetail.Annual_Volume__c = 1231232;
        pricingDetail.Loan_Type__c = 'New';
        pricingDetail.Origination_Fee_Percentage__c = 14;
        pricingDetail.Origination_Fee_Amount__c = 299;
        pricingDetail.Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        pricingDetail.Status__c = 'Sent To Customer';
        pricingDetail.Ocrolus_Max_Daily_Payment__c = 132462;
        pricingDetail.Term__c = 6;
        pricingDetail.Maximum_Term__c = 6;
        pricingDetail.Buy_Rate__c = 6;
        pricingDetail.Maximum_Exception_Amount__c = 6000;
        pricingDetail.Pricing_Type__c = CANPricingDetails.PRICING_TYPE_DIRECT_NEW;
        pricingDetail.Random_Number__c = 1;

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        newOpportunity.Offer_Notification_To_Guarantor__c = true;
        newOpportunity.Offer_Notification_To_Broker__c = true;

        List<CAN_Pricing_Detail__c> pricingDetailList = new List<CAN_Pricing_Detail__c>{pricingDetail};
        String jsonPricingDetailList = '{"totalSize" : 1, "done" : true, "records" :' + JSON.serialize(pricingDetailList, false) + '}';

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{"Name" : "APP-00000102", "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship", ' +
                '"Time_In_Business__c" : "1", "Sales_Rep__r.Email" : "sales@youtest.com", "Max_Broker_Commission__c" : "120", ' +
            	'"STIPS_Checklists__r" : ' + jsonStipsCheckList + ', "CAN_Pricing_Details__r" : ' + jsonPricingDetailList +
            '}' , genesis__Applications__c.class
        );

        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Origination_Fee_Percentage__c = 12;
        application.genesis__Collateral_Value__c = 6700;
        application.genesis__Customer_Cash_Available__c = 1500;
        application.genesis__Days_Convention__c = '30/360';
        application.genesis__Estimated_Selling_Price__c = 6700;
        application.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        application.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        application.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        application.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        application.genesis__Fees_Amount__c = 0;
        application.genesis__Financed_Amount__c = 10000;
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Landing_Sequence__c = 3;
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__Other_Financed_fees__c = 0;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.genesis__Product_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
        application.genesis__Sales_Division__c = 'DIRECT';
        application.genesis__Tax_Amount__c = 0;
        application.genesis__Term__c = 12;
        application.genesis__Warranty_Amount__c = 0;
        application.SIC_Code__c = '073';
        application.Primary_Guarantor__c = contactRecord.Id;
        application.genesis__Account__c = borrowerAccount.Id;
        application.Maximum_Funding_Amount__c = 12000;
        application.Industry_Rating__c = 'A+ Medical';
        application.SC4_Tier__c = 'TIER 1';
        application.Type__c = GeneralConstants.LOAN_TYPE_RENEWAL;
        application.genesis__Account__r = borrowerAccount;
        application.Decline_Reasons__c = null;
        application.Annual_Volume__c = 123000;
        application.Pricing_Factor__c = 1.2;
        application.Max_Term__c =6;
        application.Buy_Rate__c = 1.2;
        application.genesis__Requested_Loan_Amount__c = 1009;
        application.Opportunity__c = newOpportunity.Id;
        application.Opportunity__r = newOpportunity;
        application.Random_Number__c = 1;

        stipsCheckList.Application__c = application.Id;

        loan__Loan_Account__c clContract = (loan__Loan_Account__c) JSON.deserialize(
            '{ "Concurrent_Eligible_Amount__c" : "2000"}' , loan__Loan_Account__c.class
        );
        clContract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        application.Renewal_Concurrent_LoanAccount__r = clContract;

        Account accountRecord = new Account();
        accountRecord.Id = application.genesis__Account__c;
        accountRecord.Name = 'Business Account';
        accountRecord.Commision_Based_On__c = Brokers.COMMISSION_CALC_METHOD_FLAT;
        accountRecord.Is_Flat_Renewal__c = true;
        accountRecord.New_Max_Broker_Commission__c = 500;
        accountRecord.Renewal_Amount_Commission__c = Brokers.COMMISSION_CALC_METHOD_FLAT;

        Contact brokerContact = new Contact();
        brokerContact.Id = TestUtility.getFakeId(Contact.getSObjectType());
        brokerContact.Email = 'test@yopmail.com';
        brokerContact.Account = accountRecord;

        User salesRep = new User();
        salesRep.Id = TestUtility.getFakeId(User.getSObjectType());
        salesRep.Email = 'test1@yopmail.com';

        application.Broker_Contact__c = brokerContact.Id;
        application.Broker_Contact__r = brokerContact;
        application.Sales_Rep__c = salesRep.Id;
        application.Sales_Rep__r = salesRep;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Max_Daily_Payment__c = 1000;

        CAN_Max_Amount_And_Max_Term_Mapping__c canMaxAmountMaxTerm = new CAN_Max_Amount_And_Max_Term_Mapping__c();
        canMaxAmountMaxTerm.Id = TestUtility.getFakeId(CAN_Max_Amount_And_Max_Term_Mapping__c.getSObjectType());
        canMaxAmountMaxTerm.Loan_Type__c = application.Type__c;
        canMaxAmountMaxTerm.Industry_Rating__c = application.Industry_Rating__c;
        canMaxAmountMaxTerm.SC4_Tier__c = application.SC4_Tier__c;
        canMaxAmountMaxTerm.Maximum_Term__c = 6;
        canMaxAmountMaxTerm.Maximum_Amount_Single_Location__c = 2000;

        CAN_Pricing_Matrix_Detail__c canPricingMatrixDetail = new CAN_Pricing_Matrix_Detail__c();
        canPricingMatrixDetail.Id = TestUtility.getFakeId(CAN_Pricing_Matrix_Detail__c.getSObjectType());
        canPricingMatrixDetail.Term__c = 6;
        canPricingMatrixDetail.Loan_Type__c = GeneralConstants.LOAN_TYPE_NEW;
        canPricingMatrixDetail.SC4_Tier__c = application.SC4_Tier__c;
        canPricingMatrixDetail.Industry_Rating__c = application.Industry_Rating__c;
        canPricingMatrixDetail.Pricing_Rate__c = 2.2;
        canPricingMatrixDetail.Min_Random_Number__c = 1;
        canPricingMatrixDetail.Max_Random_Number__c = 100;
        canPricingMatrixDetail.Pricing_Type__c = CANPricingDetails.PRICING_TYPE_DIRECT_NEW;

        CAN_GAV_Matrix_Detail__c canGavMatrix = new CAN_GAV_Matrix_Detail__c();
        canGavMatrix.Id = TestUtility.getFakeId(CAN_GAV_Matrix_Detail__c.getSObjectType());
        canGavMatrix.Term__c = 6;
        canGavMatrix.SC4_Tier__c = application.SC4_Tier__c;
        canGavMatrix.Industry_Rating__c = application.Industry_Rating__c;
        canGavMatrix.GAV__c = 3;

        Document canLogo = new Document();
        canLogo.Id = TestUtility.getFakeId(Document.getSObjectType());
        canLogo.Name = 'CAN_CAPITAL_IMAGE_PURPLE_BG';
        canLogo.DeveloperName = 'CAN_CAPITAL_IMAGE_PURPLE_BG';

        GeneralHelper.domainUrl = 'https://www.test.com--main/domain';

        Site siteDetails = (Site) JSON.deserialize(
            '{ "Name" : "instanceSite", "Subdomain" : "subdomain/name", "UrlPathPrefix" : "path/prefix" }' , Site.class
        );

        EmailTemplate emailTemplate = new EmailTemplate();
        emailTemplate.Id = TestUtility.getFakeId(EmailTemplate.getSObjectType());
        emailTemplate.Name = 'Broker_Credit_Incomplete';
        emailTemplate.Subject = 'STIPS Incomplete {{LEGAL_ENTITY_NAME}} {{BROKER_COMPANY_NAME}} {{MERCHANT_ID}}';
        emailTemplate.Body = 'Stips is not completed{{APPLICATION_NAME}} {{MAX_FUNDING_AMOUNT}} {{PARTNER_PRICING_LINK_START}} {{PARTNER_PRICING_LINK_END}}' +
            '{{MAX_TERM}} {{BUY_RATE}} {{MAX_COMMISSION}} {{ORIGINATION_FEE_PERCENTAGE}} {{PAYMENT_FREQUENCY}} {{IMAGE__LOGO}} {{TERM_MATRIX}}'+
            '{{BROKER_PORTAL_LINK}} {{OFFER_APPROVED_STANDARD_START}} {{OFFER_APPROVED_STANDARD_END}} {{OFFER_APPROVED_COUNTER_OFFER_START}}' +
            '{{OFFER_APPROVED_COUNTER_OFFER_END}} {{STANDARD_START}} {{STANDARD_END}} {{COUNTER_OFFER_START}} {{COUNTER_OFFER_END}} {{PARTNER_SECURE_LINK}}';
        emailTemplate.HtmlValue = 'Stips is not completed {{APPLICATION_NAME}} {{MAX_FUNDING_AMOUNT}} {{PARTNER_PRICING_LINK_START}} {{PARTNER_PRICING_LINK_END}}' +
            '{{MAX_TERM}} {{BUY_RATE}} {{MAX_COMMISSION}} {{ORIGINATION_FEE_PERCENTAGE}} {{PAYMENT_FREQUENCY}} {{IMAGE__LOGO}} {{TERM_MATRIX}}'+
            '{{BROKER_PORTAL_LINK}} {{OFFER_APPROVED_STANDARD_START}} {{OFFER_APPROVED_STANDARD_END}} {{OFFER_APPROVED_COUNTER_OFFER_START}}' +
            '{{OFFER_APPROVED_COUNTER_OFFER_END}} {{STANDARD_START}} {{STANDARD_END}} {{COUNTER_OFFER_START}} {{COUNTER_OFFER_END}} {{PARTNER_SECURE_LINK}} ';
        emailTemplate.DeveloperName = 'Broker_Credit_Incomplete';

        List<UnderWriter_Task__c> uwList = new List<UnderWriter_Task__c>();
        List<Credit_Report_Detail__c> creditReportList = new List<Credit_Report_Detail__c>();

        UnderWriter_Task__c uwFraudAlert = new UnderWriter_Task__c();
        uwFraudAlert.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        uwFraudAlert.Task_Name__c = 'OCR Fraud Alert';
        uwFraudAlert.Application__c = application.Id;
        uwList.add(uwFraudAlert);

        UnderWriter_Task__c uwExperianFraud = new UnderWriter_Task__c();
        uwExperianFraud.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        uwExperianFraud.Task_Name__c = 'Experian Fraud Alert';
        uwExperianFraud.Application__c = application.Id;
        uwList.add(uwExperianFraud);

        Credit_Report_Detail__c creditReportConsumer = new Credit_Report_Detail__c();
        creditReportConsumer.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        creditReportConsumer.Type__c = 'Experian Consumer';
        creditReportConsumer.Contact__c = application.Primary_Guarantor__c;
        creditReportList.add(creditReportConsumer);

        Credit_Report_Detail__c creditReportBusiness = new Credit_Report_Detail__c();
        creditReportBusiness.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        creditReportBusiness.Type__c = 'Experian Business';
        creditReportBusiness.Account__c = application.genesis__Account__c;
        creditReportList.add(creditReportBusiness);

        Credit_Report_Detail__c creditReportLexisNexis = new Credit_Report_Detail__c();
        creditReportLexisNexis.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        creditReportLexisNexis.Application__c = application.Id;
        creditReportLexisNexis.Type__c = 'Lexis Nexis';
        creditReportList.add(creditReportLexisNexis);

        clcommon__Party_Type__c partyTypeGuarantor = new clcommon__Party_Type__c();
        partyTypeGuarantor.Name = GeneralConstants.PARTY_TYPE_GUARANTOR;
        partyTypeGuarantor.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());

        Map<String, Id> partyTypeToId = new Map<String, Id>();
        partyTypeToId.put(partyTypeGuarantor.Name, partyTypeGuarantor.Id);
        OriginationHelper.partyTypeToId = partyTypeToId;

        List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();
        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        party.clcommon__Account__c = application.genesis__Account__c;
        party.genesis__Application__c = application.Id;
        party.clcommon__isPrimary__c = false;
        party.clcommon__Type__c = partyTypeGuarantor.Id;
        party.clcommon__Contact__c = contactRecord.Id;
        partyList.add(party);

        DBManagerTestsStub canOcrolusReportDBStubInstance = new DBManagerTestsStub();
        canOcrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c> {ocrolusReport};
        CANPricingDetailManager.canOcrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, canOcrolusReportDBStubInstance);

        DBManagerTestsStub applicationDBBStubInstance = new DBManagerTestsStub();
        applicationDBBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        CANPricingDetailManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBBStubInstance);

        DBManagerTestsStub applicationDBBusinessStubInstance = new DBManagerTestsStub();
        BusinessRuleManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBBusinessStubInstance);

        DBManagerTestsStub stipsDBStubInstance = new DBManagerTestsStub();
        stipsDBStubInstance.genericReturnObject = new List<STIPS_Checklist__c> {stipsCheckList};
        BusinessRuleManager.stipsDBInstance = (STIPSChecklistDB) Test.createStub(STIPSChecklistDB.class, stipsDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c> {application};
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {accountRecord};
        BusinessRuleManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact> {contactRecord};
        ApplicationManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = new List<clcommon__Party__c> {party};
        ApplicationManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        DBManagerTestsStub underWriterTaskDBStubInstance = new DBManagerTestsStub();
        underWriterTaskDBStubInstance.genericReturnObject = uwList;
        BusinessRuleManager.underWriterTaskDBInstance = (UnderWriterTaskDB) Test.createStub(UnderWriterTaskDB.class, underWriterTaskDBStubInstance);

        DBManagerTestsStub creditReportDetailDBStubInstance = new DBManagerTestsStub();
        creditReportDetailDBStubInstance.genericReturnObject = creditReportList;
        BusinessRuleManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBStubInstance);

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        ocrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c> {ocrolusReport};
        BusinessRuleManager.ocrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        DBManagerTestsStub documentDBStubInstance = new DBManagerTestsStub();
        documentDBStubInstance.genericReturnObject = new List<Document> {canLogo};
        ApplicationManager.documentDBInstance = (DocumentDB) Test.createStub(DocumentDB.class, documentDBStubInstance);

        DBManagerTestsStub emailTemplateDBStubInstance = new DBManagerTestsStub();
        emailTemplateDBStubInstance.genericReturnObject = new List<EmailTemplate> {emailTemplate};
        GeneralHelper.emailTemplateDBInstance = (EmailTemplateDB) Test.createStub(EmailTemplateDB.class, emailTemplateDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        ApplicationManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        DBManagerTestsStub siteDBStubInstance = new DBManagerTestsStub();
        siteDBStubInstance.genericReturnObject = new List<Site> {siteDetails};
        GeneralHelper.siteDBInstance = (SiteDB) Test.createStub(SiteDB.class, siteDBStubInstance);

        DBManagerTestsStub pricingMatrixDetailDBStubInstance = new DBManagerTestsStub();
        pricingMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_Pricing_Matrix_Detail__c> {canPricingMatrixDetail};
        OriginationHelper.pricingMatrixDetailDBInstance = (PricingMatrixDetailDB) Test.createStub(PricingMatrixDetailDB.class, pricingMatrixDetailDBStubInstance);

        DBManagerTestsStub gavMatrixDetailDBStubInstance = new DBManagerTestsStub();
        gavMatrixDetailDBStubInstance.genericReturnObject = new List<CAN_GAV_Matrix_Detail__c> {canGavMatrix};
        OriginationHelper.gavMatrixDetailDBInstance = (GAVMatrixDetailDB) Test.createStub(GAVMatrixDetailDB.class, gavMatrixDetailDBStubInstance);

        DBManagerTestsStub maxAmountAndMaxTermMappingDBStubInstance = new DBManagerTestsStub();
        maxAmountAndMaxTermMappingDBStubInstance.genericReturnObject = new List<CAN_Max_Amount_And_Max_Term_Mapping__c> {canMaxAmountMaxTerm};
        OriginationHelper.maxAmountAndMaxTermMappingDBInstance = (MaxAmountAndMaxTermMappingDB) Test.createStub(MaxAmountAndMaxTermMappingDB.class, maxAmountAndMaxTermMappingDBStubInstance);

        Map<String, List<genesis__Applications__c>> applicationByStatus = new Map<String, List<genesis__Applications__c>>();
        applicationByStatus.put(Applications.STATUS_OFFER_SENT, new List<genesis__Applications__c> {application});

        Test.startTest();

            ApplicationManager.handleAfterStatusChange(applicationByStatus);

        Test.stopTest();
        System.assertEquals(1, stipsDBStubInstance.forUpdateSObjects.size());

    }

    @isTest
    private static void handleReadyToFundStatusBeforeUpdate() {
        Account brokerAccount = new Account();
        brokerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        brokerAccount.Name = 'Broker Name';
        brokerAccount.Is_Broker_Active__c = null;

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-00000102", "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship"}' ,
            genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Origination_Fee_Percentage__c = 12;
        application.genesis__Collateral_Value__c = 6700;
        application.genesis__Customer_Cash_Available__c = 1500;
        application.genesis__Days_Convention__c = '30/360';
        application.genesis__Estimated_Selling_Price__c = 6700;
        application.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        application.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        application.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        application.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        application.genesis__Fees_Amount__c = 0;
        application.genesis__Financed_Amount__c = 10000;
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Landing_Sequence__c = 3;
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__Other_Financed_fees__c = 0;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.genesis__Product_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
        application.genesis__Sales_Division__c = 'DIRECT';
        application.genesis__Tax_Amount__c = 0;
        application.genesis__Term__c = 12;
        application.genesis__Warranty_Amount__c = 0;
        application.SIC_Code__c = '073';
        application.Primary_Guarantor__c = TestUtility.getFakeId(Contact.getSObjectType());
        application.Maximum_Funding_Amount__c = 12000;
        application.Industry_Rating__c = 'Prohibited';
        application.SC4_Tier__c = 'TIER 1';
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.Decline_Reasons__c = null;
        application.Annual_Volume__c = 123000;
        application.Broker_Account__c = brokerAccount.Id;
        application.genesis__Status__c = Applications.STATUS_READY_TO_FUND;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        ApplicationManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {brokerAccount};
        ApplicationManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Exception ex;
        Test.startTest();
            try {
                ApplicationManager.handleReadyToFundStatusBeforeUpdate(new List<genesis__Applications__c> {application});
            } catch (Exception e) {
                ex = e;
            }
        Test.stopTest();

        TestUtility.assertException(ex);
        System.assert(ex.getMessage().contains('Broker is not Active. Broker Commission will not be calculated properly unless Broker Account is active prior to funding Application. Please reach out to the Broker Account Owner.'));
    }

    @isTest
    private static void handleAfterStatusChangeDataMerch() {
        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.AnnualRevenue = 2000000;
        borrowerAccount.Last_Business_Credit_Pull__c = null;
        borrowerAccount.Business_Tax_ID__c = '852802924';

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-00000102", "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship"}' ,
            genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Origination_Fee_Percentage__c = 12;
        application.genesis__Collateral_Value__c = 6700;
        application.genesis__Customer_Cash_Available__c = 1500;
        application.genesis__Days_Convention__c = '30/360';
        application.genesis__Estimated_Selling_Price__c = 6700;
        application.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        application.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        application.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        application.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        application.genesis__Fees_Amount__c = 0;
        application.genesis__Financed_Amount__c = 10000;
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Landing_Sequence__c = 3;
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__Other_Financed_fees__c = 0;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.genesis__Product_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
        application.genesis__Sales_Division__c = 'DIRECT';
        application.genesis__Tax_Amount__c = 0;
        application.genesis__Term__c = 12;
        application.genesis__Warranty_Amount__c = 0;
        application.SIC_Code__c = '073';
        application.Primary_Guarantor__c = TestUtility.getFakeId(Contact.getSObjectType());
        application.genesis__Account__c = borrowerAccount.Id;
        application.Maximum_Funding_Amount__c = 12000;
        application.Industry_Rating__c = 'Prohibited';
        application.SC4_Tier__c = 'TIER 1';
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.genesis__Account__r = borrowerAccount;
        application.Decline_Reasons__c = null;
        application.Annual_Volume__c = 123000;
        application.genesis__Status__c = Applications.STATUS_DATAMERCH_CHECK;

        List<UnderWriter_Task__c> uwList = new List<UnderWriter_Task__c>();
        UnderWriter_Task__c uwDataMerch = new UnderWriter_Task__c();
        uwDataMerch.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        uwDataMerch.Task_Name__c = DataMerch.TASK_TYPE_DATA_MERCH;
        uwDataMerch.Application__c = application.Id;
        uwList.add(uwDataMerch);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        DataMerchManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {borrowerAccount};
        DataMerchManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub creditReportDetailDBStubInstance = new DBManagerTestsStub();
        DataMerchManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        DataMerchManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        DBManagerTestsStub dataMerchNoteDBStubInstance = new DBManagerTestsStub();
        DataMerchManager.DataMerchNoteDBInstance = (DataMerchNoteDB) Test.createStub(DataMerchNoteDB.class, dataMerchNoteDBStubInstance);

        DBManagerTestsStub underWriterTaskDBStubInstance = new DBManagerTestsStub();
        underWriterTaskDBStubInstance.genericReturnObject = uwList;
        DataMerchManager.underWriterTaskDBInstance = (UnderWriterTaskDB) Test.createStub(UnderWriterTaskDB.class, underWriterTaskDBStubInstance);

        Map<String, List<genesis__Applications__c>> applicationListByStatus = new Map<String, List<genesis__Applications__c>>();
        applicationListByStatus.put(Applications.STATUS_DATAMERCH_CHECK, new List<genesis__Applications__c> {application});
        Test.startTest();

            ApplicationManager.handleAfterStatusChange(applicationListByStatus);

        Test.stopTest();
        System.assertEquals(Applications.STATUS_DATAMERCH_CHECK, application.genesis__Status__c);
    }

    @isTest
    private static void handleAfterStatusChangeDataMerchFailed() {
        Account borrowerAccount = new Account();
        borrowerAccount.Id = TestUtility.getFakeId(Account.getSObjectType());
        borrowerAccount.AnnualRevenue = 2000000;

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'JOHN';
        contactRecord.LastName = 'BOSS';

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Name" : "APP-00000102", "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship"}' ,
            genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Origination_Fee_Percentage__c = 12;
        application.genesis__Collateral_Value__c = 6700;
        application.genesis__Customer_Cash_Available__c = 1500;
        application.genesis__Days_Convention__c = '30/360';
        application.genesis__Estimated_Selling_Price__c = 6700;
        application.genesis__Expected_Close_Date__c = TestUtility.currentSystemDate.addDays(1);
        application.genesis__Expected_Start_Date__c = TestUtility.currentSystemDate;
        application.genesis__Expected_First_Payment_Date__c = TestUtility.currentSystemDate.addDays(10);
        application.genesis__Maturity_Date__c = TestUtility.currentSystemDate.addMonths(12);
        application.genesis__Fees_Amount__c = 0;
        application.genesis__Financed_Amount__c = 10000;
        application.genesis__Interest_Rate__c = 100;
        application.genesis__Landing_Sequence__c = 3;
        application.genesis__Loan_Amount__c = 10000;
        application.genesis__Other_Financed_fees__c = 0;
        application.genesis__Payment_Frequency__c = GeneralConstants.FREQUENCY_DAILY;
        application.genesis__Product_Type__c = GeneralConstants.PRODUCT_TYPE_LOAN;
        application.genesis__Sales_Division__c = 'DIRECT';
        application.genesis__Tax_Amount__c = 0;
        application.genesis__Term__c = 12;
        application.genesis__Warranty_Amount__c = 0;
        application.SIC_Code__c = '073';
        application.Primary_Guarantor__c = contactRecord.Id;
        application.genesis__Account__c = borrowerAccount.Id;
        application.Maximum_Funding_Amount__c = 12000;
        application.Industry_Rating__c = 'Prohibited';
        application.SC4_Tier__c = 'TIER 1';
        application.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        application.genesis__Account__r = borrowerAccount;
        application.Decline_Reasons__c = null;
        application.Annual_Volume__c = 123000;
        application.genesis__Status__c = Applications.STATUS_DATAMERCH_CHECK_FAILED;

        List<clcommon__Party__c> partyList = new List<clcommon__Party__c> ();
        List<clcommon__Party_Type__c> partyTypeList = new List<clcommon__Party_Type__c> ();

        clcommon__Party_Type__c partyTypeGuarantor = new clcommon__Party_Type__c();
        partyTypeGuarantor.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());
        partyTypeGuarantor.Name = 'GUARANTOR';
        partyTypeList.add(partyTypeGuarantor);

        clcommon__Party_Type__c partyTypeBorrower = new clcommon__Party_Type__c();
        partyTypeGuarantor.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());
        partyTypeBorrower.Name = 'BORROWER';
        partyTypeList.add(partyTypeBorrower);

        clcommon__Party__c partyBorrower = new clcommon__Party__c();
        partyBorrower.clcommon__Account__c = application.genesis__Account__c;
        partyBorrower.genesis__Application__c = application.Id;
        partyBorrower.clcommon__Type__c = partyTypeBorrower.Id;
        partyBorrower.clcommon__isPrimary__c = false;
        partyBorrower.genesis__Application__r = application;
        partyList.add(partyBorrower);

        clcommon__Party__c partyGuarantor = new clcommon__Party__c();
        partyGuarantor.clcommon__Account__c = application.genesis__Account__c;
        partyGuarantor.genesis__Application__c = application.Id;
        partyGuarantor.clcommon__Type__c = partyTypeGuarantor.Id;
        partyGuarantor.clcommon__isPrimary__c = true;
        partyGuarantor.clcommon__Contact__c = application.Primary_Guarantor__c;
        partyGuarantor.genesis__Application__r = application;
        partyList.add(partyGuarantor);

        List<UnderWriter_Task__c> uwList = new List<UnderWriter_Task__c>();
        UnderWriter_Task__c uwProofOfOwnership = new UnderWriter_Task__c();
        uwProofOfOwnership.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        uwProofOfOwnership.Task_Name__c = LexisNexiss.TASK_TYPE_PROOF_OF_OWNERSHIP;
        uwProofOfOwnership.Application__c = application.Id;
        uwList.add(uwProofOfOwnership);

        UnderWriter_Task__c uwLegalName = new UnderWriter_Task__c();
        uwLegalName.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        uwLegalName.Task_Name__c = LexisNexiss.TASK_TYPE_LEGAL_NAME;
        uwLegalName.Application__c = application.Id;
        uwList.add(uwLegalName);

        UnderWriter_Task__c uwLegalAddress = new UnderWriter_Task__c();
        uwLegalAddress.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        uwLegalAddress.Task_Name__c = LexisNexiss.TASK_TYPE_LEGAL_ADDRESS;
        uwLegalAddress.Application__c = application.Id;
        uwList.add(uwLegalAddress);

        UnderWriter_Task__c uwCANHistory = new UnderWriter_Task__c();
        uwCANHistory.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        uwCANHistory.Task_Name__c = LexisNexiss.TASK_TYPE_PRIOR_CAN_HISTORY;
        uwCANHistory.Application__c = application.Id;
        uwList.add(uwCANHistory);

        UnderWriter_Task__c uwBusinessPhone = new UnderWriter_Task__c();
        uwBusinessPhone.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        uwBusinessPhone.Task_Name__c = LexisNexiss.TASK_TYPE_BUSINESS_PHONE;
        uwBusinessPhone.Application__c = application.Id;
        uwList.add(uwBusinessPhone);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        LexisNexisManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        LexisNexisManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        DBManagerTestsStub creditReportDetailDBStubInstance = new DBManagerTestsStub();
        LexisNexisManager.creditReportDetailDBInstance =
            (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBStubInstance);

        DBManagerTestsStub underWriterTaskDBStubInstance = new DBManagerTestsStub();
        underWriterTaskDBStubInstance.genericReturnObject = uwList;
        LexisNexisManager.underWriterTaskDBInstance = (UnderWriterTaskDB) Test.createStub(UnderWriterTaskDB.class, underWriterTaskDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {borrowerAccount};
        LexisNexisManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact> {contactRecord};
        LexisNexisManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = partyList;
        LexisNexisManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        DBManagerTestsStub partyTypeDBStubInstance = new DBManagerTestsStub();
        partyTypeDBStubInstance.genericReturnObject = partyTypeList;
        OriginationHelper.partyTypeDBInstance = (PartyTypeDB) Test.createStub(PartyTypeDB.class, partyTypeDBStubInstance);

        Map<String, List<genesis__Applications__c>> applicationListByStatus = new Map<String, List<genesis__Applications__c>>();
        applicationListByStatus.put(Applications.STATUS_DATAMERCH_CHECK_FAILED, new List<genesis__Applications__c> {application});

        Test.startTest();

            ApplicationManager.handleAfterStatusChange(applicationListByStatus);

        Test.stopTest();
        System.assertEquals(Applications.STATUS_DATAMERCH_CHECK_FAILED, application.genesis__Status__c);
    }

}