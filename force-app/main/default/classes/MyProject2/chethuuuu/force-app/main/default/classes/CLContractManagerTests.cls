@isTest
private class CLContractManagerTests {

    @isTest
    private static void createLoanDisbursalAndAPSSetup(){

        loan__Loan_Payment_Spread__c canPaymentSpread =  new loan__Loan_Payment_Spread__c();
        canPaymentSpread.Id = TestUtility.getFakeId(loan__Loan_Payment_Spread__c.getSObjectType());
        canPaymentSpread.Name = 'CAN Payment Spread';

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Date expectedDisbursalDate = GeneralHelper.currentSystemDate;

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{"Refinance_Paid_Off_Amount__c" : "1000", "Oldest_Unpaid_Due_As_Of_Today__c" : "1"}', genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Type__c = 'Renewal';
        application.CAN_Pay_Off_Type__c = 'LOAN';
        application.CLContract__c = null;
        application.genesis__Loan_Amount__c = 1200;
        application.CAN_Pay_Off_Type__c = 'LOAN';
        application.genesis__Collateral_Value__c = 100;
        application.genesis__Customer_Cash_Available__c = 1000;
        application.genesis__Days_Convention__c = '30/360';
        application.genesis__Estimated_Selling_Price__c = 500;
        application.genesis__Expected_Close_Date__c = Date.newInstance(2022, 01, 01);
        application.genesis__Expected_Start_Date__c = Date.newInstance(2020, 01, 01);
        application.genesis__Expected_First_Payment_Date__c = Date.newInstance(2021, 01, 01);
        application.genesis__Maturity_Date__c = Date.newInstance(2022, 01, 01);
        application.genesis__Fees_Amount__c = 100;
        application.genesis__Financed_Amount__c = 40;
        application.genesis__Interest_Rate__c = 2.5;
        application.genesis__Landing_Sequence__c = 20;
        application.genesis__Other_Financed_fees__c = 200;
        application.genesis__Payment_Frequency__c = 'DAILY';
        application.genesis__Sales_Division__c = 'DIRECT';
        application.genesis__Status__c = 'NEW ENTERED';
        application.genesis__Product_Type__c = 'Days Convention';
        application.genesis__Tax_Amount__c = 20;
        application.genesis__Term__c = 13;
        application.genesis__Warranty_Amount__c = 200;
        application.SIC_Code__c ='99';
        application.Maximum_Funding_Amount__c = 500;
        application.Renewal_Concurrent_LoanAccount__c = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        party.genesis__Application__c = application.Id;
        party.genesis__Application__r = application;
        party.Competitor_Amount__c = 1000;
        List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();
        partyList.add(party);

        loan__Bank_Account__c bankAccount = new loan__Bank_Account__c();
        bankAccount.Id = TestUtility.getFakeId(loan__Bank_Account__c.getSObjectType());
        bankAccount.loan__Active__c = true;
        bankAccount.loan__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        String jsonPartyList = '{"totalSize" : 1, "done" : true, "records" : ' + JSON.serialize(partyList, false) + '}';

        loan__Loan_Account__c loanAccount = (loan__Loan_Account__c) JSON.deserialize('{"Parties__r" : ' + jsonPartyList + ' }', loan__Loan_Account__c.class);
        loanAccount.Bank_Account__c = bankAccount.Id;
        loanAccount.loan__Disbursal_Date__c = Date.newInstance(2019, 12, 01);
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccount.Application__c = application.Id;
        loanAccount.Application__r = application;
        loanAccount.Refinance_Paid_Off_Amount__c = 1000;

        Account investorAccount = new Account();
        investorAccount.Id = TestUtility.getFakeId(Account.getSObjectType());

        ServicingHelper.canBankAccount = bankAccount;

        CAN_General_Settings__c generalSetting = new CAN_General_Settings__c();
        generalSetting.Id = TestUtility.getFakeId(CAN_General_Settings__c.getSObjectType());
        generalSetting.Default_Investor_Account_Id__c = investorAccount.Id;
        CustomSettingsHelper.generalSettings = generalSetting;

        DBManagerTestsStub clContractDBStubInstance1 = new DBManagerTestsStub();
        clContractDBStubInstance1.genericReturnObject = new List<loan__Loan_Account__c>{loanAccount};
        CLContractManager.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance1);

        genesis__Applications__c newApplication = new genesis__Applications__c();
        newApplication.Id = application.Id;
        newApplication.CLContract__c = null;
        newApplication.Renewal_Concurrent_LoanAccount__c  = loanAccount.Id;

        DBManagerTestsStub partyDBInstance = new DBManagerTestsStub();
        partyDBInstance.genericReturnObject = new List<clcommon__Party__c>{party};
        CLContractManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBInstance);

        loan__Payment_Mode__c mode = new loan__Payment_Mode__c();
        mode.Id = TestUtility.getFakeId(loan__Payment_Mode__c.getSObjectType());
        mode.Name ='ACH';

        DBManagerTestsStub paymentModeDBInstance = new DBManagerTestsStub();
        paymentModeDBInstance.genericReturnObject = new List<loan__Payment_Mode__c>{mode};
        ServicingHelper.paymentModeDBInstance = (PaymentModeDB) Test.createStub(PaymentModeDB.class, paymentModeDBInstance);

        Set<Id> loanAccountIds = new Set<Id>();
        loanAccountIds.add(loanAccount.Id);

        Set<String> loanNames = new Set<String>();
        loanNames.add(loanAccount.Name);

        loan__Loan_Disbursal_Transaction__c disbursal = new  loan__Loan_Disbursal_Transaction__c();
        disbursal.loan__Loan_Account__c = loanAccount.Id;
        disbursal.Id = TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType());

        loan__Disbursal_Txn_Distribution__c disbursalTxnDistribution = new loan__Disbursal_Txn_Distribution__c();
        disbursalTxnDistribution.Id = TestUtility.getFakeId(loan__Disbursal_Txn_Distribution__c.getSObjectType());

        DBManagerTestsStub loanDisbursalTransactionsDBStubInstance = new DBManagerTestsStub();
        loanDisbursalTransactionsDBStubInstance.genericReturnObject = new List<loan__Loan_Disbursal_Transaction__c>{disbursal};
        CLContractManager.loanDisbursalTransactionsDBInstance = (LoanDisbursalTransactionsDB) Test.createStub(LoanDisbursalTransactionsDB.class, loanDisbursalTransactionsDBStubInstance);

        DBManagerTestsStub loanDisbursalTransactiondistributionDBStubInstance = new DBManagerTestsStub();
        loanDisbursalTransactiondistributionDBStubInstance.genericReturnObject = new List<loan__Disbursal_Txn_Distribution__c> {disbursalTxnDistribution};
        CLContractManager.loanDisbursalTxnDistributionInstance = (LoanDisbursalTxnDistributionDB) Test.createStub(LoanDisbursalTxnDistributionDB.class, loanDisbursalTransactiondistributionDBStubInstance);

        Test.startTest();
        CLContractManager.createLoanDisbursalTransaction(loanAccountIds);
        Test.stopTest();

        System.assertEquals('Renewal', application.Type__c);
        System.assertEquals(1000, party.Competitor_Amount__c);

    }

    @isTest
    private static void createLoanParties(){

        loan__Loan_Payment_Spread__c canPaymentSpread =  new loan__Loan_Payment_Spread__c();
        canPaymentSpread.Id = TestUtility.getFakeId(loan__Loan_Payment_Spread__c.getSObjectType());
        canPaymentSpread.Name = 'CAN Payment Spread';

        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Date expectedDisbursalDate = GeneralHelper.currentSystemDate;

        genesis__Applications__c application = new  genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Type__c = 'Renewal';
        application.CAN_Pay_Off_Type__c = 'LOAN';

        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        loanAccount.Application__c = application.Id;
        loanAccount.Application__r = application;
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{loanAccount};
        CLContractManager.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        Map<Id, Id> applicationIds = new Map<Id, Id>();
        applicationIds.put(application.Id, loanAccount.Id);

        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        party.genesis__Application__c = application.Id;
        party.clcommon__Account__c = accountRecord.Id;
        party.clcommon__Contact__c = contactRecord.Id;
        party.Competitor_Amount__c=4000;
        List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();
        partyList.add(party);

        DBManagerTestsStub partyDBInstance = new DBManagerTestsStub();
        partyDBInstance.genericReturnObject = new List<clcommon__Party__c>{party};
        CLContractManager.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBInstance);

        DBManagerTestsStub coBorrowerDBStubInstance = new DBManagerTestsStub();
        CLContractManager.coBorrowerDBInstance = (CoBorrowerDB) Test.createStub(CoBorrowerDB.class, coBorrowerDBStubInstance);

        Test.startTest();
        CLContractManager.createLoanParties(applicationIds);
        Test.stopTest();

         System.assertEquals(4000, party.Competitor_Amount__c);
         System.assertEquals(0, partyDBInstance.forInsertSObjects.size());

    }

    @isTest
    private static void investorIdNull(){

        loan__Loan_Payment_Spread__c canPaymentSpread =  new loan__Loan_Payment_Spread__c();
        canPaymentSpread.Id = TestUtility.getFakeId(loan__Loan_Payment_Spread__c.getSObjectType());
        canPaymentSpread.Name = 'CAN Payment Spread';

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Date expectedDisbursalDate = GeneralHelper.currentSystemDate;

        CAN_General_Settings__c generalSetting = new CAN_General_Settings__c();
        generalSetting.Id = TestUtility.getFakeId(CAN_General_Settings__c.getSObjectType());
        generalSetting.Default_Investor_Account_Id__c = null;

        genesis__Applications__c application = new genesis__Applications__c();
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.Type__c = 'Renewal';
        application.CAN_Pay_Off_Type__c = 'LOAN';
        application.genesis__Loan_Amount__c = 200;

        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        loanAccount.loan__Expected_Disbursal_Date__c = Date.newInstance(2018, 01, 01);
        loanAccount.Application__c = application.Id;
        loanAccount.Application__r = application;
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{loanAccount};
        CLContractManager.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        Exception ex;
        Test.startTest();
            try {
                CLContractManager.createLoanDisbursalTransaction(new Set<Id> {loanAccount.Id});
            } catch (Exception e) {
                ex = e;
            }
        Test.stopTest();

        TestUtility.assertException(ex);
        System.assert(ex.getMessage().contains('There is no default Investor exist in the system'));
    }

    @isTest
    static void adjustLastRepaymentScheduleWhenPricingFactoreRepaymentIsMore() {

        GeneralHelper.currentSystemDate = Date.newInstance(2010, 01, 01);
        Id loanAccountId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loan__Repayment_Schedule__c lastRepaymentSchedule = TestUtility.generateRepaymentSchedule(
            loanAccountId, GeneralHelper.currentSystemDate.addMonths(1), 553, 193.35
        );
        lastRepaymentSchedule.Id = TestUtility.getFakeId(loan__Repayment_Schedule__c.getSObjectType());

        List<loan__Repayment_Schedule__c> repaymentScheduleList = new List<loan__Repayment_Schedule__c>{lastRepaymentSchedule};
        String jsonRepaymentScheduleList = '{"totalSize" : 1, "done" : true, "records" :' + JSON.serialize(repaymentScheduleList, false) + '}';

        loan__Loan_Account__c loanAccount =  (loan__Loan_Account__c) JSON.deserialize (
            '{ "loan__Total_Interest_Amortization_Based__c" : "580.35", "loan__Repayment_Schedule__r" : ' + jsonRepaymentScheduleList + '}',
            loan__Loan_Account__c.class
        );
        loanAccount.Id = loanAccountId;
        loanAccount.loan__Loan_Amount__c = 1659;
        loanAccount.loan__Disbursed_Amount__c = 1659;
        loanAccount.loan__Next_Installment_Date__c = GeneralHelper.currentSystemDate.addMonths(1);
        loanAccount.Pricing_Factor__c = 1.35;

        genesis__Company__c company = new genesis__Company__c();
        company.Name = 'CAN Capital';
        company.genesis__Short_Name__c = 'CAN';
        insert company;

        clcommon__Company__c clCompany = new clcommon__Company__c();
        clCompany.clcommon__Company_Name__c = 'CAN Capital';
        clCompany.clcommon__Branch_Date__c = GeneralHelper.currentSystemDate;
        insert clCompany;

        DBManagerTestsStub contractDBStubInstance = new DBManagerTestsStub();
        contractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c> {loanAccount};
        CLContractManager.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, contractDBStubInstance);

        DBManagerTestsStub repaymentScheduleDBStubInstance = new DBManagerTestsStub();
        CLContractManager.repaymentScheduleDBInstance = (RepaymentScheduleDB) Test.createStub(RepaymentScheduleDB.class, repaymentScheduleDBStubInstance);

        Test.startTest();
            CLContractManager.adjustLastRepaymentSchedule(new Set<Id> {loanAccount.Id});
        Test.stopTest();

        System.assertEquals(1, repaymentScheduleDBStubInstance.forUpdateSObjects.size());

        loan__Repayment_Schedule__c actualLastRepaymentSchedule = (loan__Repayment_Schedule__c) repaymentScheduleDBStubInstance.forUpdateSObjects.get(0);
        System.assertEquals(lastRepaymentSchedule.Id, actualLastRepaymentSchedule.Id);
        System.assertEquals(746.65, actualLastRepaymentSchedule.loan__Due_Amount__c);
        System.assertEquals(193.65, actualLastRepaymentSchedule.loan__Due_Interest__c);
    }

    @isTest
    static void adjustLastRepaymentScheduleWhenContractRepaymentIsMore() {

        GeneralHelper.currentSystemDate = Date.newInstance(2010, 01, 01);
        Id loanAccountId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loan__Repayment_Schedule__c lastRepaymentSchedule = TestUtility.generateRepaymentSchedule(
            loanAccountId, GeneralHelper.currentSystemDate.addMonths(1), 553, 193.85
        );
        lastRepaymentSchedule.Id = TestUtility.getFakeId(loan__Repayment_Schedule__c.getSObjectType());

        List<loan__Repayment_Schedule__c> repaymentScheduleList = new List<loan__Repayment_Schedule__c>{lastRepaymentSchedule};
        String jsonRepaymentScheduleList = '{"totalSize" : 1, "done" : true, "records" :' + JSON.serialize(repaymentScheduleList, false) + '}';

        loan__Loan_Account__c loanAccount =  (loan__Loan_Account__c) JSON.deserialize (
            '{ "loan__Total_Interest_Amortization_Based__c" : "580.85", "loan__Repayment_Schedule__r" : ' + jsonRepaymentScheduleList + '}',
            loan__Loan_Account__c.class
        );
        loanAccount.Id = loanAccountId;
        loanAccount.loan__Loan_Amount__c = 1659;
        loanAccount.loan__Disbursed_Amount__c = 1659;
        loanAccount.loan__Next_Installment_Date__c = GeneralHelper.currentSystemDate.addMonths(1);
        loanAccount.Pricing_Factor__c = 1.35;

        DBManagerTestsStub contractDBStubInstance = new DBManagerTestsStub();
        contractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c> {loanAccount};
        CLContractManager.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, contractDBStubInstance);

        DBManagerTestsStub repaymentScheduleDBStubInstance = new DBManagerTestsStub();
        CLContractManager.repaymentScheduleDBInstance = (RepaymentScheduleDB) Test.createStub(RepaymentScheduleDB.class, repaymentScheduleDBStubInstance);

        Test.startTest();
            CLContractManager.adjustLastRepaymentSchedule(new Set<Id> {loanAccount.Id});
        Test.stopTest();

        System.assertEquals(1, repaymentScheduleDBStubInstance.forUpdateSObjects.size());

        loan__Repayment_Schedule__c actualLastRepaymentSchedule = (loan__Repayment_Schedule__c) repaymentScheduleDBStubInstance.forUpdateSObjects.get(0);
        System.assertEquals(lastRepaymentSchedule.Id, actualLastRepaymentSchedule.Id);
        System.assertEquals(746.65, actualLastRepaymentSchedule.loan__Due_Amount__c);
        System.assertEquals(193.65, actualLastRepaymentSchedule.loan__Due_Interest__c);
    }

    @isTest
    static void adjustLastRepaymentScheduleWhenNoScheduleFound() {

        GeneralHelper.currentSystemDate = Date.newInstance(2010, 01, 01);
        Id loanAccountId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        List<loan__Repayment_Schedule__c> repaymentScheduleList = new List<loan__Repayment_Schedule__c>();
        String jsonRepaymentScheduleList = '{"totalSize" : 0, "done" : true, "records" :' + JSON.serialize(repaymentScheduleList, false) + '}';

        loan__Loan_Account__c loanAccount =  (loan__Loan_Account__c) JSON.deserialize (
            '{ "loan__Total_Interest_Amortization_Based__c" : "580.35", "loan__Repayment_Schedule__r" : ' + jsonRepaymentScheduleList + '}',
            loan__Loan_Account__c.class
        );
        loanAccount.Id = loanAccountId;
        loanAccount.loan__Loan_Amount__c = 1659;
        loanAccount.loan__Disbursed_Amount__c = 1659;
        loanAccount.loan__Next_Installment_Date__c = GeneralHelper.currentSystemDate.addMonths(1);
        loanAccount.Pricing_Factor__c = 1.35;

        DBManagerTestsStub contractDBStubInstance = new DBManagerTestsStub();
        contractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c> {loanAccount};
        CLContractManager.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, contractDBStubInstance);

        DBManagerTestsStub repaymentScheduleDBStubInstance = new DBManagerTestsStub();
        CLContractManager.repaymentScheduleDBInstance = (RepaymentScheduleDB) Test.createStub(RepaymentScheduleDB.class, repaymentScheduleDBStubInstance);

        Test.startTest();
            CLContractManager.adjustLastRepaymentSchedule(new Set<Id> {loanAccount.Id});
        Test.stopTest();

        System.assertEquals(0, repaymentScheduleDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    static void createContractCondition() {
        ServicingHelper.conditionsOnSpreadId = TestUtility.getFakeId(loan__Conditions_On_Spread__c.getSObjectType());
        ServicingHelper.defaultPaymentSpreadId = TestUtility.getFakeId(loan__Loan_Payment_Spread__c.getSObjectType());

        GeneralHelper.currentSystemDate = Date.newInstance(2010, 01, 01);
        Id loanAccountId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        DBManagerTestsStub contractConditionStubDBInstance = new DBManagerTestsStub();
        CLContractManager.contractConditionDBInstance = (ContractConditionDB) Test.createStub(ContractConditionDB.class, contractConditionStubDBInstance);

        Test.startTest();
            CLContractManager.createContractCondition(new Set<Id> {loanAccountId});
        Test.stopTest();

        System.assertEquals(1, contractConditionStubDBInstance.forInsertSObjects.size());
    }

    @isTest
    static void createContractConditionException() {
        ServicingHelper.conditionsOnSpreadId = TestUtility.getFakeId(loan__Conditions_On_Spread__c.getSObjectType());
        ServicingHelper.defaultPaymentSpreadId = TestUtility.getFakeId(loan__Loan_Payment_Spread__c.getSObjectType());

        GeneralHelper.currentSystemDate = Date.newInstance(2010, 01, 01);
        Id loanAccountId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        CLContractManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Test.startTest();
            CLContractManager.createContractCondition(new Set<Id> {loanAccountId});
        Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }
}