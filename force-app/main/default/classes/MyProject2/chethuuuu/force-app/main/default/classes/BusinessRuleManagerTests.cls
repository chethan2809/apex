@isTest(isParallel=true)
private class BusinessRuleManagerTests {

    @isTest
    private static void runSTIPSAndUWTasksVerificationRules() {

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship"}' , genesis__Applications__c.class
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
        application.Maximum_Funding_Amount__c = 275000;

        Account accountRecord = new Account();
        accountRecord.Id = application.genesis__Account__c;
        accountRecord.Name = 'DELTA FRESH, L.L.C';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);
        accountRecord.Business_Tax_ID__c = '976297423';

        Contact contactRecord = new Contact();
        contactRecord.Id = application.Primary_Guarantor__c;
        contactRecord.FirstName = 'John';
        contactRecord.LastName = 'Boos';

        List<Credit_Report_Detail__c> creditReportList = new List<Credit_Report_Detail__c>();
        Credit_Report_Detail__c businessCreditReport = new Credit_Report_Detail__c();
        businessCreditReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        businessCreditReport.Account__c = application.genesis__Account__c;
        businessCreditReport.Tax_Liens__c = 53423;
        businessCreditReport.Judgement_Liens__c = 24324;
        businessCreditReport.Is_Recent_Bankruptcy__c = false;
        businessCreditReport.Is_Open_Bankruptcy__c = false;
        businessCreditReport.Competitor_Judgement__c = false;
        businessCreditReport.Type__c = GeneralConstants.CREDIT_REPORT_TYPE_EXPERIAN_BUSINESS;
        businessCreditReport.Financial_Services_Charge_off__c = true;
        creditReportList.add(businessCreditReport);

        Credit_Report_Detail__c consumerCreditReport = new Credit_Report_Detail__c();
        consumerCreditReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        consumerCreditReport.Credit_Statement__c = BusinessRules.FRAUD_ALERT_FRAUD_STATEMENT;
        consumerCreditReport.Type__c = GeneralConstants.CREDIT_REPORT_TYPE_EXPERIAN_CONSUMER;
        creditReportList.add(consumerCreditReport);

        Credit_Report_Detail__c lexisNexisReport = new Credit_Report_Detail__c();
        lexisNexisReport.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        lexisNexisReport.Is_Proof_Of_Ownership_Verified__c = false;
        lexisNexisReport.Is_Guarantor_Identity_Verified__c = false;
        lexisNexisReport.Type__c = GeneralConstants.CREDIT_REPORT_TYPE_LEXIS_NEXIS;
        creditReportList.add(lexisNexisReport);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{accountRecord};
        BusinessRuleManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        BusinessRuleManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        clcommon__Party_Type__c partyTypeGuarantor = new clcommon__Party_Type__c();
        partyTypeGuarantor.Name = GeneralConstants.PARTY_TYPE_GUARANTOR;
        partyTypeGuarantor.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());

        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        party.genesis__Application__c = application.Id;
        party.clcommon__Contact__c = contactRecord.Id;
        party.clcommon__Account__c = accountRecord.Id;
        party.clcommon__Type__c = partyTypeGuarantor.Id;

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = new List<clcommon__Party__c>{party};
        BusinessRuleManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        DBManagerTestsStub partyTypeDBStubInstance = new DBManagerTestsStub();
        partyTypeDBStubInstance.genericReturnObject = new List<clcommon__Party_Type__c>{partyTypeGuarantor};
        OriginationHelper.partyTypeDBInstance = (PartyTypeDB) Test.createStub(PartyTypeDB.class, partyTypeDBStubInstance);

        DBManagerTestsStub creditReportDetailDBStubInstance = new DBManagerTestsStub();
        creditReportDetailDBStubInstance.genericReturnObject = creditReportList;
        BusinessRuleManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBStubInstance);

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Is_Potential_Fraud__c = true;
        ocrolusReport.Max_Daily_Payment__c = 851.2645;
        ocrolusReport.Primary_Bank_Account_Number__c = '34234243243';
        ocrolusReport.Number_Of_Competitors__c = 3;
        ocrolusReport.Number_Of_Bank_Statements__c = 10;
        ocrolusReport.Competitor_Names__c = 'COMPETITOR';

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        ocrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c>{ ocrolusReport };
        BusinessRuleManager.ocrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        List<UnderWriter_Task__c> underWriterList = new List<UnderWriter_Task__c>();

        UnderWriter_Task__c underWriterTaskOCRFraudAlert = new UnderWriter_Task__c();
        underWriterTaskOCRFraudAlert.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        underWriterTaskOCRFraudAlert.Application__c = application.Id;
        underWriterTaskOCRFraudAlert.Task_Name__c = BusinessRules.TASK_NAME_OCR_FRAUD_ALERT;
        underWriterList.add(underWriterTaskOCRFraudAlert);

        UnderWriter_Task__c underWriterTaskExperianFraudAlert = new UnderWriter_Task__c();
        underWriterTaskExperianFraudAlert.Id = TestUtility.getFakeId(UnderWriter_Task__c.getSObjectType());
        underWriterTaskExperianFraudAlert.Application__c = application.Id;
        underWriterTaskExperianFraudAlert.Task_Name__c = BusinessRules.TASK_NAME_EXPERIAN_FRAUD_ALERT;
        underWriterList.add(underWriterTaskExperianFraudAlert);

        DBManagerTestsStub underWriterTaskDBStubInstance = new DBManagerTestsStub();
        underWriterTaskDBStubInstance.genericReturnObject = underWriterList;
        BusinessRuleManager.underWriterTaskDBInstance = (UnderWriterTaskDB) Test.createStub(UnderWriterTaskDB.class, underWriterTaskDBStubInstance);

        STIPS_Checklist__c stipsCheck = new STIPS_Checklist__c();
        stipsCheck.Id = TestUtility.getFakeId(STIPS_Checklist__c.getSObjectType());
        stipsCheck.Application__c = application.Id;
        stipsCheck.Borrower_Interview__c = true;

        DBManagerTestsStub stipsDBStubInstance = new DBManagerTestsStub();
        stipsDBStubInstance.genericReturnObject = new List<STIPS_Checklist__c>{stipsCheck};
        BusinessRuleManager.stipsDBInstance = (STIPSChecklistDB) Test.createStub(STIPSChecklistDB.class, stipsDBStubInstance);

        Exception ex;
        Test.startTest();

            BusinessRuleManager.runSTIPSAndUWTasksVerificationRules(new List<genesis__Applications__c>{application});

        Test.stopTest();

        System.assertEquals(true, stipsCheck.Competitors__c);
    }

    @isTest
    private static void declineDuplicateApplicationForBorrower(){
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
        application.Confirmed_Fraud_Flag__c = true;

        Account accountRecord = new Account();
        accountRecord.Id = application.genesis__Account__c;
        accountRecord.Name = 'DELTA FRESH, L.L.C';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);
        accountRecord.Legacy_Active_Contract__c = true;
        accountRecord.Confirmed_Fraud_Flag__c = true;

        loan__Loan_Account__c clContract = new loan__Loan_Account__c();
        clContract.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        clContract.loan__Account__c = accountRecord.Id;
        clContract.Application__c = application.Id;

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{clContract};
        BusinessRuleManager.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Id = TestUtility.getFakeId(CAN_Ocrolus_Report__c.getSObjectType());
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Is_Potential_Fraud__c = true;
        ocrolusReport.Max_Daily_Payment__c = 851.2645;

        DBManagerTestsStub ocrolusReportDBStubInstance = new DBManagerTestsStub();
        ocrolusReportDBStubInstance.genericReturnObject = new List<CAN_Ocrolus_Report__c>{ocrolusReport};
        BusinessRuleManager.ocrolusReportDBInstance = (OcrolusReportDB) Test.createStub(OcrolusReportDB.class, ocrolusReportDBStubInstance);

        Credit_Report_Detail__c creditReportDetail = new Credit_Report_Detail__c();
        creditReportDetail.Id = TestUtility.getFakeId(Credit_Report_Detail__c.getSObjectType());
        creditReportDetail.Type__c = 'Experian Business';
        creditReportDetail.Application__c = application.Id;
        creditReportDetail.Account__c = accountRecord.Id;
        creditReportDetail.Judgement_Liens__c = 180000;
        creditReportDetail.Tax_Liens__c = 80000;
        creditReportDetail.Is_Recent_Bankruptcy__c = false;
        creditReportDetail.Is_Open_Bankruptcy__c = false;
        creditReportDetail.Competitor_Judgement__c = false;

        Contact contact = new Contact();
        contact.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contact.Confirmed_Fraud_Flag__c = true;

        List<clcommon__Party__c> partyList = new List<clcommon__Party__c> ();

        clcommon__Party__c partyBorrower = new clcommon__Party__c();
        partyBorrower.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        partyBorrower.genesis__Application__c = application.Id;
        partyBorrower.clcommon__Type__c = OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BORROWER);
        partyBorrower.clcommon__Account__c = accountRecord.Id;

        partyList.add(partyBorrower);

        clcommon__Party__c partyGuarantor = new clcommon__Party__c();
        partyGuarantor.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        partyGuarantor.genesis__Application__c = application.Id;
        partyGuarantor.clcommon__Type__c = OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_GUARANTOR);
        partyGuarantor.clcommon__Contact__c = contact.Id;
        partyGuarantor.clcommon__Account__c = accountRecord.Id;

        partyList.add(partyGuarantor);

        DBManagerTestsStub creditReportDetailDBStubInstance = new DBManagerTestsStub();
        creditReportDetailDBStubInstance.genericReturnObject = new List<Credit_Report_Detail__c>{creditReportDetail};
        BusinessRuleManager.creditReportDetailDBInstance = (CreditReportDetailDB) Test.createStub(CreditReportDetailDB.class, creditReportDetailDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{accountRecord};
        BusinessRuleManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        BusinessRuleManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = partyList;
        BusinessRuleManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{contact};
        BusinessRuleManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        Map<Id, genesis__Applications__c> borrowerIdToApplication = new Map<Id, genesis__Applications__c>();
        borrowerIdToApplication.put(accountRecord.Id, application);
        Map<Id, Account> accountMap = new Map<Id, Account>();
        accountMap.put(accountRecord.Id, accountRecord);

        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>{application.Id => application};
        Test.startTest();
            BusinessRuleManager.runGeneralDeclineRules(new List<genesis__Applications__c>{application});
            BusinessRuleManager.runExperianConsumerDeclineRules(new List<genesis__Applications__c>{application});
            BusinessRuleManager.runExperianBusinessDeclineRules(new List<genesis__Applications__c>{application});
            BusinessRuleManager.runIndustryCheckDeclineRulesAndUWTask(new List<genesis__Applications__c>{application});
            BusinessRuleManager.runCanScoringDeclineRules(new List<genesis__Applications__c>{application});
            BusinessRuleManager.runOcrolusDeclineRules(applicationMap, new List<CAN_Ocrolus_Report__c>{ocrolusReport});
            BusinessRuleManager.declineDuplicateApplicationForBorrower(borrowerIdToApplication);
            BusinessRuleManager.declineDuplicateEISApplicationForBorrower(new List<genesis__Applications__c> {application}, accountMap);
        Test.stopTest();

        System.assertEquals(Applications.STATUS_DECLINED, application.genesis__Status__c);
        System.assertEquals(
            BusinessRules.DENIAL_REASON_LIEN_JUDGEMENT+ ';' + BusinessRules.DENIAL_REASON_ACTIVE_APPLICATION_OR_CONTRACT,
            application.Decline_Reasons__c
        );
    }

    @isTest
    private static void runDeclineRulesForExclusivityPeriod() {
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
        application.Broker_Contact__c = TestUtility.getFakeId(Contact.getSObjectType());

        Account accountRecord = (Account) JSON.deserialize('{"Is_Exclusivity__c" : ' + true + '}', Account.class);
        accountRecord.Id = application.genesis__Account__c;
        accountRecord.Name = 'DELTA FRESH, L.L.C';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);
        accountRecord.Broker_Contact__c = TestUtility.getFakeId(Contact.getSObjectType());

        Contact brokerContact = new Contact();
        brokerContact.Id = application.Broker_Contact__c;
        brokerContact.AccountId = TestUtility.getFakeId(Account.getSObjectType());

        Map<Id, genesis__Applications__c> borrowerIdToApplication = new Map<Id, genesis__Applications__c>();
        borrowerIdToApplication.put(application.genesis__Account__c, application);

        Set<Id> brokerContactIds = new Set<Id> {application.Broker_Contact__c};

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        BusinessRuleManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {accountRecord};
        BusinessRuleManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact> {brokerContact};
        BusinessRuleManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        Test.startTest();
            BusinessRuleManager.runDeclineRulesForExclusivityPeriod(borrowerIdToApplication, brokerContactIds);
        Test.stopTest();

        genesis__Applications__c updateApplication = borrowerIdToApplication.get(application.genesis__Account__c);

        System.assertEquals(Applications.STATUS_DECLINED, updateApplication.genesis__Status__c);
    }

    @isTest
    private static void runDeclineRulesForExclusivityPeriodNoBroker() {
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
        application.Broker_Contact__c = TestUtility.getFakeId(Contact.getSObjectType());

        Account accountRecord = (Account) JSON.deserialize('{"Is_Exclusivity__c" : ' + true + '}', Account.class);
        accountRecord.Id = application.genesis__Account__c;
        accountRecord.Name = 'DELTA FRESH, L.L.C';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);
        accountRecord.Broker_Account__c = TestUtility.getFakeId(Account.getSObjectType());
        accountRecord.Broker_Contact__c = TestUtility.getFakeId(Contact.getSObjectType());

        Map<Id, genesis__Applications__c> borrowerIdToApplication = new Map<Id, genesis__Applications__c>();
        borrowerIdToApplication.put(application.genesis__Account__c, application);

        Set<Id> brokerContactIds = new Set<Id> {application.Broker_Contact__c};

        Contact brokerContact = new Contact();
        brokerContact.Id = TestUtility.getFakeId(Contact.getSObjectType());
        brokerContact.AccountId = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        BusinessRuleManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {accountRecord};
        BusinessRuleManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact> {brokerContact};
        BusinessRuleManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        Test.startTest();
            BusinessRuleManager.runDeclineRulesForExclusivityPeriod(borrowerIdToApplication, brokerContactIds);
        Test.stopTest();

        genesis__Applications__c updateApplication = borrowerIdToApplication.get(application.genesis__Account__c);

        System.assertEquals(Applications.STATUS_DECLINED, updateApplication.genesis__Status__c);
    }

    @isTest
    private static void runAutoDeclineRulesWhenDecline(){

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c> ();

        genesis__Applications__c applicationFirstSameBorrower = (genesis__Applications__c) JSON.deserialize(
            '{ "Origination_Fee_Amount__c" : "299"}' , genesis__Applications__c.class
        );
        applicationFirstSameBorrower.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        applicationFirstSameBorrower.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        applicationFirstSameBorrower.genesis__Status__c = Applications.STATUS_DOCS_IN;
        applicationFirstSameBorrower.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        applicationList.add(applicationFirstSameBorrower);

        genesis__Applications__c applicationSecondSameBorrower = (genesis__Applications__c) JSON.deserialize(
            '{ "Origination_Fee_Amount__c" : "299"}' , genesis__Applications__c.class
        );
        applicationSecondSameBorrower.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        applicationSecondSameBorrower.genesis__Account__c = applicationFirstSameBorrower.genesis__Account__c;
        applicationSecondSameBorrower.genesis__Status__c = Applications.STATUS_DOCS_OUT;
        applicationSecondSameBorrower.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        applicationList.add(applicationSecondSameBorrower);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = applicationList;
        BusinessRuleManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        Test.startTest();
            BusinessRuleManager.runAutoDeclineForSameBorrowerRules(applicationList);
        Test.stopTest();

        System.assertEquals(Applications.STATUS_DECLINED, applicationSecondSameBorrower.genesis__Status__c);

    }

    @isTest
    private static void runAutoDeclineRulesWhenNoDecline(){

        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c> ();

        genesis__Applications__c applicationFirstSameBorrower = (genesis__Applications__c) JSON.deserialize(
            '{ "Origination_Fee_Amount__c" : "299"}' , genesis__Applications__c.class
        );
        applicationFirstSameBorrower.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        applicationFirstSameBorrower.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        applicationFirstSameBorrower.genesis__Status__c = Applications.STATUS_DOCS_OUT;
        applicationFirstSameBorrower.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        applicationList.add(applicationFirstSameBorrower);

        genesis__Applications__c applicationSecondSameBorrower = (genesis__Applications__c) JSON.deserialize(
            '{ "Origination_Fee_Amount__c" : "299"}' , genesis__Applications__c.class
        );
        applicationSecondSameBorrower.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        applicationSecondSameBorrower.genesis__Account__c = applicationFirstSameBorrower.genesis__Account__c;
        applicationSecondSameBorrower.genesis__Status__c = Applications.STATUS_DOCS_IN;
        applicationSecondSameBorrower.Type__c = GeneralConstants.LOAN_TYPE_NEW;
        applicationList.add(applicationSecondSameBorrower);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = applicationList;
        BusinessRuleManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        Test.startTest();
            BusinessRuleManager.runAutoDeclineForSameBorrowerRules(applicationList);
        Test.stopTest();

        System.assertEquals(Applications.STATUS_DOCS_IN, applicationSecondSameBorrower.genesis__Status__c);

    }

    @isTest
    private static void declineWithRecentDeclineApplicationForBorrower(){
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

        genesis__Applications__c declineApplication = (genesis__Applications__c) JSON.deserialize(
            '{ "Origination_Fee_Amount__c" : "299"}' , genesis__Applications__c.class
        );
        GeneralHelper.currentSystemDate = Date.newInstance(2021, 03, 01);
        CustomSettingsHelper.generalSettings.Decline_Until_Days__c = 30;
        Integer declineUntilDays = Integer.valueOf(CustomSettingsHelper.generalSettings.Decline_Until_Days__c);
        Date currentSystemDate = GeneralHelper.currentSystemDate;
        declineApplication.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        declineApplication.genesis__Account__c = application.genesis__Account__c;
        declineApplication.decline_until_date__c = currentSystemDate.addDays(declineUntilDays);
        declineApplication.Decline_Reasons__c = 'Competitor Stacking';

        Account accountRecord = new Account();
        accountRecord.Id = application.genesis__Account__c;
        accountRecord.Name = 'DELTA FRESH, L.L.C';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{accountRecord};
        BusinessRuleManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{declineApplication};
        BusinessRuleManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        Test.startTest();
            BusinessRuleManager.runGeneralDeclineRules(new List<genesis__Applications__c>{application});
        Test.stopTest();

        System.assertEquals(Applications.STATUS_DECLINED, application.genesis__Status__c);
    }

    @isTest
    private static void runDataMerchDeclineRulesWithDecline(){
        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Origination_Fee_Amount__c" : "299"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        application.Opportunity__c = TestUtility.getFakeId(Opportunity.getSObjectType());
        application.Annual_Volume__c = 1413777;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 1;
        application.genesis__Payment_Frequency__c = 'DAILY';
        application.Broker_Contact__c = TestUtility.getFakeId(Contact.getSObjectType());

        Account accountRecord = (Account) JSON.deserialize('{"Is_Exclusivity__c" : ' + true + '}', Account.class);
        accountRecord.Id = application.genesis__Account__c;
        accountRecord.Name = 'DELTA FRESH, L.L.C';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '375043024';
        accountRecord.Biz_Start_Date__c = TestUtility.currentSystemDate.addYears(-10);
        accountRecord.Broker_Account__c = TestUtility.getFakeId(Account.getSObjectType());
        accountRecord.Broker_Contact__c = TestUtility.getFakeId(Contact.getSObjectType());

        GeneralHelper.currentSystemDate = Date.newInstance(2022, 06, 01);

        Data_Merch_Note__c dataMerchNote = new Data_Merch_Note__c();
        dataMerchNote.Account__c = accountRecord.Id;
        dataMerchNote.Application__c = application.Id;
        dataMerchNote.Added_at__c = GeneralHelper.currentSystemDate.addDays(-20);
        dataMerchNote.Note_Category__c = 'Suspicious Activity';

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        BusinessRuleManager.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{accountRecord};
        BusinessRuleManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub dataMerchNoteStubInstance = new DBManagerTestsStub();
        dataMerchNoteStubInstance.genericReturnObject = new List<Data_Merch_Note__c>{dataMerchNote};
        BusinessRuleManager.DataMerchNoteDBInstance = (DataMerchNoteDB) Test.createStub(DataMerchNoteDB.class, dataMerchNoteStubInstance);

        Test.startTest();
            BusinessRuleManager.runDataMerchDeclineRules(new List<genesis__Applications__c>{application});
        Test.stopTest();

        System.assertEquals(Applications.STATUS_DECLINED, application.genesis__Status__c);
        System.assertEquals(BusinessRules.DENIAL_REASON_NEGATIVE_HISTORY_WITH_COMPETITOR, application.Decline_Reasons__c);

    }

}