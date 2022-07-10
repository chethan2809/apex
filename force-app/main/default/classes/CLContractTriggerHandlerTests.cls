@isTest
private class CLContractTriggerHandlerTests {

    @isTest
    static void beforeInsertTest() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        Id loanId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        loan__Loan_Account__c newLoan = new loan__Loan_Account__c();
        newLoan.Id = loanId;
        newLoan.loan__Next_Accrual_Entry_Date__c = GeneralHelper.currentSystemDate;
        newLoan.loan__Loan_Status__c = CLContracts.LOAN_STATUS_CLOSED_OBLIGATION_MET;
        newLoan.Application__c = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        CLContractTriggerHandler clContractTriggerHandlerInstance = new CLContractTriggerHandler();

        Test.startTest();
            clContractTriggerHandlerInstance.beforeInsert(new List<loan__Loan_Account__c> {newLoan});
        Test.stopTest();

        System.assertEquals('Approved', newLoan.loan__Loan_Status__c);
    }

    @isTest
    static void afterInsertTest() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        Id loanId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        Map<Id, loan__Loan_Account__c> newMap = new Map<Id, loan__Loan_Account__c>();
        loan__Loan_Account__c newLoan = new loan__Loan_Account__c();
        newLoan.Id = loanId;
        newLoan.loan__Next_Accrual_Entry_Date__c = GeneralHelper.currentSystemDate;
        newLoan.loan__Loan_Status__c = CLContracts.LOAN_STATUS_CLOSED_OBLIGATION_MET;
        newLoan.Application__c = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        newLoan.loan__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        newLoan.Broker_Account__c = TestUtility.getFakeId(Account.getSObjectType());
        newLoan.Broker_Contact__c = TestUtility.getFakeId(Contact.getSObjectType());
        newMap.put(loanId, newLoan);

        Account borrowerAccount = new Account();
        borrowerAccount.Id =  newLoan.loan__Account__c;
        borrowerAccount.AnnualRevenue = 2000000;
        borrowerAccount.Name = 'Magar Industries LLC';
        borrowerAccount.Merchant_ID__c = '3123123';

        ServicingHelper.conditionsOnSpreadId = TestUtility.getFakeId(loan__Conditions_On_Spread__c.getSObjectType());
        ServicingHelper.defaultPaymentSpreadId = TestUtility.getFakeId(loan__Loan_Payment_Spread__c.getSObjectType());

        CLContractTriggerHandler clContractTriggerHandlerInstance = new CLContractTriggerHandler();

        DBManagerTestsStub applicationStubDBInstance = new DBManagerTestsStub();
        CLContractTriggerHandler.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationStubDBInstance);

        DBManagerTestsStub contractConditionStubDBInstance = new DBManagerTestsStub();
        CLContractManager.contractConditionDBInstance = (ContractConditionDB) Test.createStub(ContractConditionDB.class, contractConditionStubDBInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> { borrowerAccount };
        CLContractTriggerHandler.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Test.startTest();
            clContractTriggerHandlerInstance.afterInsert(newMap);
        Test.stopTest();

        System.assertEquals(1, accountDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    static void beforeUpdateIsClosed() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        Map<Id, loan__Loan_Account__c> newMap = new Map<Id, loan__Loan_Account__c>();
        Map<Id, loan__Loan_Account__c> oldMap = new Map<Id, loan__Loan_Account__c>();

        Id loanId = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        loan__Loan_Account__c oldLoan = new loan__Loan_Account__c();
        oldLoan.Id = loanId;
        oldLoan.loan__Next_Accrual_Entry_Date__c = GeneralHelper.currentSystemDate;
        oldLoan.loan__Loan_Status__c = 'Approved';
        oldMap.put(loanId, oldLoan);

        loan__Loan_Account__c newLoan = new loan__Loan_Account__c();
        newLoan.Id = loanId;
        newLoan.loan__Next_Accrual_Entry_Date__c = GeneralHelper.currentSystemDate;
        newLoan.loan__Loan_Status__c = CLContracts.LOAN_STATUS_CLOSED_OBLIGATION_MET;
        newMap.put(loanId, newLoan);

        CLContractTriggerHandler clContractTriggerHandlerInstance = new CLContractTriggerHandler();

        Test.startTest();
            clContractTriggerHandlerInstance.beforeUpdate(newMap, oldMap);
        Test.stopTest();

        System.assertEquals(null, newLoan.loan__Next_Accrual_Entry_Date__c);
    }

    @isTest
    static void afterUpdateIsApproved() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        Map<Id, loan__Loan_Account__c> newMap = new Map<Id, loan__Loan_Account__c>();
        Map<Id, loan__Loan_Account__c> oldMap = new Map<Id, loan__Loan_Account__c>();

        loan__Loan_Account__c oldLoan =  (loan__Loan_Account__c) JSON.deserialize (
            '{ "Total_Unpaid_Due_Amount_To_Current__c" : "400"}', loan__Loan_Account__c.class
        );
        oldLoan.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        oldLoan.loan__Next_Accrual_Entry_Date__c = GeneralHelper.currentSystemDate;
        oldLoan.loan__Loan_Status__c = CLContracts.LOAN_STATUS_APPROVED;
        oldLoan.loan__Pmt_Amt_Cur__c = 860.52;
        oldLoan.Latest_Number_Of_Missed_Payments__c = 1;
        oldLoan.Max_Number_Of_Missed_Payments__c = 1;
        oldLoan.loan__Frequency_of_Loan_Payment__c = GeneralConstants.FREQUENCY_DAILY;
        oldLoan.loan__Last_Disbursal_Amount__c = 1000;
        oldLoan.loan__Expected_Disbursal_Date__c = GeneralHelper.currentSystemDate.addMonths(10);
        oldLoan.loan__Last_Disbursal_Date__c = GeneralHelper.currentSystemDate.addDays(-2);
        oldLoan.loan__Last_Installment_Date__c = GeneralHelper.currentSystemDate.addYears(1);
        oldLoan.loan__Next_Installment_Date__c = GeneralHelper.currentSystemDate.addMonths(1);

        oldMap.put(oldLoan.Id, oldLoan);

        loan__Loan_Account__c newLoan =  (loan__Loan_Account__c) JSON.deserialize (
            '{ "Total_Unpaid_Due_Amount_To_Current__c" : "400"}', loan__Loan_Account__c.class
        );
        newLoan.Id = oldLoan.Id;
        newLoan.loan__Next_Accrual_Entry_Date__c = GeneralHelper.currentSystemDate;
        newLoan.loan__Loan_Status__c = CLContracts.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        newLoan.loan__Pmt_Amt_Cur__c = 860.52;
        newLoan.Latest_Number_Of_Missed_Payments__c = 1;
        newLoan.Max_Number_Of_Missed_Payments__c = 2;
        newLoan.loan__Frequency_of_Loan_Payment__c = GeneralConstants.FREQUENCY_DAILY;
        newLoan.loan__Last_Transaction_Type__c = 'Disbursal Transaction';
        newLoan.loan__Last_Disbursal_Amount__c = 1000;
        newLoan.loan__Expected_Disbursal_Date__c = GeneralHelper.currentSystemDate;
        newLoan.loan__Last_Disbursal_Date__c = GeneralHelper.currentSystemDate.addDays(-1);
        newLoan.loan__Last_Installment_Date__c = GeneralHelper.currentSystemDate.addYears(1);
        newLoan.loan__Next_Installment_Date__c = GeneralHelper.currentSystemDate.addMonths(1);
        newLoan.loan__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        newMap.put(newLoan.Id, newLoan);

        ServicingHelper.paymentModeIdByName.put('ACH', TestUtility.getFakeId(loan__Payment_Mode__c.getSObjectType()));

        DBManagerTestsStub automatedPaymentSetupDBStubInstance = new DBManagerTestsStub();
        CLContractTriggerHandler.automatedPaymentSetupDBInstance = (AutomatedPaymentSetupDB) Test.createStub(AutomatedPaymentSetupDB.class, automatedPaymentSetupDBStubInstance);

        DBManagerTestsStub chargeDBStubInstance = new DBManagerTestsStub();
        CLContractTriggerHandler.chargeDBInstance = (ChargeDB) Test.createStub(ChargeDB.class, chargeDBStubInstance);

        DBManagerTestsStub contractDBStubInstance = new DBManagerTestsStub();
        CLContractTriggerHandler.contractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, contractDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        CLContractTriggerHandler.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        CLContractTriggerHandler clContractTriggerHandlerInstance = new CLContractTriggerHandler();

        Test.startTest();
            clContractTriggerHandlerInstance.afterUpdate(newMap, oldMap);
        Test.stopTest();

        System.assertEquals(1, newLoan.Latest_Number_Of_Missed_Payments__c);
    }

    @isTest
    static void afterUpdateIsPaidOff() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        Map<Id, loan__Loan_Account__c> newMap = new Map<Id, loan__Loan_Account__c>();
        Map<Id, loan__Loan_Account__c> oldMap = new Map<Id, loan__Loan_Account__c>();

        loan__Loan_Account__c oldLoan =  (loan__Loan_Account__c) JSON.deserialize (
            '{ "Total_Unpaid_Due_Amount_To_Current__c" : "400"}', loan__Loan_Account__c.class
        );
        oldLoan.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        oldLoan.loan__Loan_Status__c = CLContracts.LOAN_STATUS_ACTIVE_GOOD_STANDING;

        oldMap.put(oldLoan.Id, oldLoan);

        loan__Loan_Account__c newLoan =  (loan__Loan_Account__c) JSON.deserialize (
            '{ "Total_Unpaid_Due_Amount_To_Current__c" : "400"}', loan__Loan_Account__c.class
        );
        newLoan.Id = oldLoan.Id;
        newLoan.loan__Loan_Status__c = CLContracts.LOAN_STATUS_CLOSED_OBLIGATION_MET;
        newLoan.loan__Disbursal_Date__c = GeneralHelper.currentSystemDate;
        newLoan.loan__Closed_Date__c = GeneralHelper.currentSystemDate.addDays(11);
        newLoan.loan__Account__c = TestUtility.getFakeId(Account.getSObjectType());

        newMap.put(newLoan.Id, newLoan);

        DBManagerTestsStub contractDBStubInstance = new DBManagerTestsStub();
        CLContractTriggerHandler.contractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, contractDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        CLContractTriggerHandler.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        CLContractTriggerHandler clContractTriggerHandlerInstance = new CLContractTriggerHandler();

        Test.startTest();
            clContractTriggerHandlerInstance.afterUpdate(newMap, oldMap);
        Test.stopTest();

        System.assertEquals(1, accountDBStubInstance.forUpdateSObjects.size());
    }

    @isTest
    static void afterUpdateAdjustLastRepaymentSchedule() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        Map<Id, loan__Loan_Account__c> newMap = new Map<Id, loan__Loan_Account__c>();
        Map<Id, loan__Loan_Account__c> oldMap = new Map<Id, loan__Loan_Account__c>();

        loan__Loan_Account__c oldLoan = new loan__Loan_Account__c();
        oldLoan.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        oldMap.put(oldLoan.Id, oldLoan);

        loan__Repayment_Schedule__c lastRepaymentSchedule = TestUtility.generateRepaymentSchedule(
            oldLoan.Id, GeneralHelper.currentSystemDate.addMonths(1), 553, 193.25
        );
        lastRepaymentSchedule.Id = TestUtility.getFakeId(loan__Repayment_Schedule__c.getSObjectType());

        List<loan__Repayment_Schedule__c> repaymentScheduleList = new List<loan__Repayment_Schedule__c>{lastRepaymentSchedule};
        String jsonRepaymentScheduleList = '{"totalSize" : 1, "done" : true, "records" :' + JSON.serialize(repaymentScheduleList, false) + '}';

        loan__Loan_Account__c loanAccount =  (loan__Loan_Account__c) JSON.deserialize (
            '{ "loan__Total_Interest_Amortization_Based__c" : "580.35", "Total_Unpaid_Due_Amount_To_Current__c" : "100", "loan__Repayment_Schedule__r" : ' + jsonRepaymentScheduleList + '}',
            loan__Loan_Account__c.class
        );
        loanAccount.loan__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        loanAccount.Id = oldLoan.Id;
        loanAccount.loan__Loan_Amount__c = 1659;
        loanAccount.loan__Disbursed_Amount__c = 1659;
        loanAccount.loan__Next_Installment_Date__c = GeneralHelper.currentSystemDate.addMonths(1);
        loanAccount.Pricing_Factor__c = 1.35;
        loanAccount.loan__Number_of_Installments__c = 10;
        loanAccount.loan__Pmt_Amt_Cur__c = 100;
        loanAccount.loan__Last_Installment_Date__c = GeneralHelper.currentSystemDate.addMonths(2);
        newMap.put(loanAccount.Id, loanAccount);

        DBManagerTestsStub contractDBStubInstance = new DBManagerTestsStub();
        contractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c> {loanAccount};
        CLContractManager.clContractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, contractDBStubInstance);

        DBManagerTestsStub repaymentScheduleDBStubInstance = new DBManagerTestsStub();
        CLContractManager.repaymentScheduleDBInstance = (RepaymentScheduleDB) Test.createStub(RepaymentScheduleDB.class, repaymentScheduleDBStubInstance);

        DBManagerTestsStub automatedPaymentSetupDBStubInstance = new DBManagerTestsStub();
        CLContractTriggerHandler.automatedPaymentSetupDBInstance = (AutomatedPaymentSetupDB) Test.createStub(AutomatedPaymentSetupDB.class, automatedPaymentSetupDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        CLContractTriggerHandler.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        CLContractTriggerHandler clContractTriggerHandlerInstance = new CLContractTriggerHandler();

        Test.startTest();
            clContractTriggerHandlerInstance.afterUpdate(newMap, oldMap);
        Test.stopTest();

        System.assertEquals(1, repaymentScheduleDBStubInstance.forUpdateSObjects.size());

        loan__Repayment_Schedule__c actualLastRepaymentSchedule = (loan__Repayment_Schedule__c) repaymentScheduleDBStubInstance.forUpdateSObjects.get(0);
        System.assertEquals(lastRepaymentSchedule.Id, actualLastRepaymentSchedule.Id);
        System.assertEquals(746.55, actualLastRepaymentSchedule.loan__Due_Amount__c);
        System.assertEquals(193.55, actualLastRepaymentSchedule.loan__Due_Interest__c);
    }

    @isTest
    private static void afterUpdateUCCFiling() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        Map<Id, loan__Loan_Account__c> newMap = new Map<Id, loan__Loan_Account__c>();
        Map<Id, loan__Loan_Account__c> oldMap = new Map<Id, loan__Loan_Account__c>();

        CAN_General_Settings__c canGeneralSettings = new CAN_General_Settings__c();
        canGeneralSettings.Id = TestUtility.getFakeId(CAN_General_Settings__c.getSObjectType());
        canGeneralSettings.UCC_Filing_Eligible_Amount__c = 50000;
        CustomSettingsHelper.generalSettings = canGeneralSettings;

        Account account = TestUtility.createAccount();
        account.UCC_Status__c = 'No UCC';
        account.UCC_Opt_Out__c = false;
        update account;

        loan__Loan_Account__c oldLoan = new loan__Loan_Account__c();
        oldLoan.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        oldLoan.loan__Disbursed_Amount__c = 55000;
        oldLoan.loan__Account__c =  account.Id;
        oldMap.put(oldLoan.Id, oldLoan);

        loan__Repayment_Schedule__c lastRepaymentSchedule = TestUtility.generateRepaymentSchedule(
            oldLoan.Id, GeneralHelper.currentSystemDate.addMonths(1), 553, 193.25
        );
        lastRepaymentSchedule.Id = TestUtility.getFakeId(loan__Repayment_Schedule__c.getSObjectType());

        List<loan__Repayment_Schedule__c> repaymentScheduleList = new List<loan__Repayment_Schedule__c>{lastRepaymentSchedule};
        String jsonRepaymentScheduleList = '{"totalSize" : 1, "done" : true, "records" :' + JSON.serialize(repaymentScheduleList, false) + '}';

        loan__Loan_Account__c loanAccount =  (loan__Loan_Account__c) JSON.deserialize (
            '{ "loan__Total_Interest_Amortization_Based__c" : "580.35", "Total_Unpaid_Due_Amount_To_Current__c" : "100", "loan__Repayment_Schedule__r" : ' + jsonRepaymentScheduleList + '}',
            loan__Loan_Account__c.class
        );
        loanAccount.Id = oldLoan.Id;
        loanAccount.loan__Account__c =  account.Id;
        loanAccount.loan__Disbursed_Amount__c = 55001;
        newMap.put(loanAccount.Id, loanAccount);

        CLContractTriggerHandler clContractTriggerHandlerInstance = new CLContractTriggerHandler();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        Account acc = [Select id, name, UCC_Status__c, UCC_Opt_Out__c from account where Id =: loanAccount.loan__Account__c ];
        accountMap.put(acc.Id, acc);

        DBManagerTestsStub contractDBStubInstance = new DBManagerTestsStub();
        CLContractTriggerHandler.contractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, contractDBStubInstance);

        DBManagerTestsStub repaymentScheduleDBStubInstance = new DBManagerTestsStub();
        CLContractManager.repaymentScheduleDBInstance = (RepaymentScheduleDB) Test.createStub(RepaymentScheduleDB.class, repaymentScheduleDBStubInstance);

        Test.startTest();
            clContractTriggerHandlerInstance.afterUpdate(newMap, oldMap);
        Test.stopTest();
    }

    @isTest
    static void afterUpdateIsCanceled() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        Map<Id, loan__Loan_Account__c> newMap = new Map<Id, loan__Loan_Account__c>();
        Map<Id, loan__Loan_Account__c> oldMap = new Map<Id, loan__Loan_Account__c>();

        loan__Loan_Account__c oldLoan =  (loan__Loan_Account__c) JSON.deserialize (
            '{ "Total_Unpaid_Due_Amount_To_Current__c" : "400"}', loan__Loan_Account__c.class
        );
        oldLoan.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        oldLoan.loan__Loan_Status__c = CLContracts.LOAN_STATUS_ACTIVE_GOOD_STANDING;

        oldMap.put(oldLoan.Id, oldLoan);

        loan__Loan_Account__c newLoan =  (loan__Loan_Account__c) JSON.deserialize (
            '{ "Total_Unpaid_Due_Amount_To_Current__c" : "400"}', loan__Loan_Account__c.class
        );
        newLoan.Id = oldLoan.Id;
        newLoan.loan__Loan_Status__c = CLContracts.LOAN_STATUS_CANCELED;
        newLoan.loan__Disbursal_Date__c =  GeneralHelper.currentSystemDate;
        newLoan.loan__Closed_Date__c = GeneralHelper.currentSystemDate;
        newLoan.loan__Account__c = TestUtility.getFakeId(Account.getSObjectType());

        newMap.put(newLoan.Id, newLoan);

        Account borrowerAccountRecord = new Account();
        borrowerAccountRecord.Type =  Accounts.BORROWER;
        borrowerAccountRecord.Id = newLoan.loan__Account__c;
        borrowerAccountRecord.Legacy_Number_of_Contracts__c = 1;


        DBManagerTestsStub contractDBStubInstance = new DBManagerTestsStub();
        CLContractTriggerHandler.contractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, contractDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {borrowerAccountRecord};
        CLContractTriggerHandler.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        CLContractTriggerHandler clContractTriggerHandlerInstance = new CLContractTriggerHandler();

        Test.startTest();
            clContractTriggerHandlerInstance.afterUpdate(newMap, oldMap);
        Test.stopTest();

        System.assertEquals(1, accountDBStubInstance.forUpdateSObjects.size());
        Account actualUpdatedAccount = (Account) accountDBStubInstance.forUpdateSObjects.get(0);
        System.assertEquals(borrowerAccountRecord.Id, actualUpdatedAccount.Id);
        System.assertEquals(0, actualUpdatedAccount.Legacy_Number_of_Contracts__c);
    }

    @isTest
    static void afterUpdateReturnOfFundsWithin10days() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        Map<Id, loan__Loan_Account__c> newMapLoan = new Map<Id, loan__Loan_Account__c>();
        Map<Id, loan__Loan_Account__c> oldMapLoan = new Map<Id, loan__Loan_Account__c>();

        loan__Loan_Account__c oldLoan =  (loan__Loan_Account__c) JSON.deserialize (
            '{ "Total_Unpaid_Due_Amount_To_Current__c" : "400"}', loan__Loan_Account__c.class
        );
        oldLoan.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        oldLoan.loan__Loan_Status__c = CLContracts.LOAN_STATUS_ACTIVE_GOOD_STANDING;

        oldMapLoan.put(oldLoan.Id, oldLoan);

        loan__Loan_Account__c newLoan =  (loan__Loan_Account__c) JSON.deserialize (
            '{ "Total_Unpaid_Due_Amount_To_Current__c" : "400"}', loan__Loan_Account__c.class
        );
        newLoan.Id = oldLoan.Id;
        newLoan.loan__Loan_Status__c = CLContracts.LOAN_STATUS_CLOSED_OBLIGATION_MET;
        newLoan.loan__Disbursal_Date__c = GeneralHelper.currentSystemDate;
        newLoan.loan__Closed_Date__c = GeneralHelper.currentSystemDate.addDays(10);
        newLoan.loan__Account__c = TestUtility.getFakeId(Account.getSObjectType());

        newMapLoan.put(newLoan.Id, newLoan);

        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Account accountRecord = new Account();
        accountRecord.Type =  Accounts.BORROWER;
        accountRecord.Id = newLoan.loan__Account__c;
        accountRecord.Legacy_Number_of_Contracts__c = 1;


        DBManagerTestsStub contractDBStubInstance = new DBManagerTestsStub();
        CLContractTriggerHandler.contractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, contractDBStubInstance);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {accountRecord};
        CLContractTriggerHandler.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        CLContractTriggerHandler clContractTriggerHandlerInstance = new CLContractTriggerHandler();

        Test.startTest();
            clContractTriggerHandlerInstance.afterUpdate(newMapLoan, oldMapLoan);
        Test.stopTest();

        System.assertEquals(1, accountDBStubInstance.forUpdateSObjects.size());
        Account updatedAccount = (Account) accountDBStubInstance.forUpdateSObjects.get(0);
        System.assertEquals(accountRecord.Id, updatedAccount.Id);
        System.assertEquals(0, updatedAccount.Legacy_Number_of_Contracts__c);
    }
}