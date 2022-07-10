@isTest
private class RepaymentTxnAdjustmentTriggerHndlrTests {

    private static RepaymentTxnAdjustmentTriggerHandler repaymentTxnAdjustmentTriggerHandlerInstance = new RepaymentTxnAdjustmentTriggerHandler();

    @isTest
    private static void afterInsertReversalTransaction() {

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Contact primaryContact = (Contact) JSON.deserialize(
            '{ "Name" : "Test Primary"}' ,
            Contact.class
        );
        primaryContact.Id = TestUtility.getFakeId(Contact.getSObjectType());
        primaryContact.FirstName = 'Test First';
        primaryContact.LastName = 'Test Last';
        primaryContact.Email = 'Test@sample.com';

        loan__Loan_Account__c loanAccount = (loan__Loan_Account__c) JSON.deserialize(
            '{ "Name" : "LAI-000000"}' ,
            loan__Loan_Account__c.class
        );
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccount.loan__Last_Accrual_Date__c = GeneralHelper.currentSystemDate;
        loanAccount.Primary_Contact__c = primaryContact.Id;
        loanAccount.Primary_Contact__r = primaryContact;
        loanAccount.loan__Disbursed_Amount__c = 5000;
        loanAccount.loan__Disbursal_Date__c = Date.newInstance(2020, 02, 21);

        loan__Loan_Payment_Transaction__c loanPayment = (loan__Loan_Payment_Transaction__c) JSON.deserialize(
            '{ "Name" : "Test LoanPayment", "loan__Loan_Account__c" : "aBj6w000000GtIv"}' ,
            loan__Loan_Payment_Transaction__c.class
        );
        loanPayment.Id = TestUtility.getFakeId(loan__Loan_Payment_Transaction__c.getSObjectType());
        loanPayment.loan__Payment_Mode__c = TestUtility.getFakeId(loan__Payment_Mode__c.getSObjectType());
        loanPayment.loan__Transaction_Amount__c = 5000;
        loanPayment.loan__Loan_Account__r  = loanAccount;
        loanPayment.loan__Skip_Validation__c = true;
        loanPayment.loan__Cleared__c = true;

        List<loan__Repayment_Transaction_Adjustment__c> repaymentTransactionList = new List<loan__Repayment_Transaction_Adjustment__c>();
        loan__Repayment_Transaction_Adjustment__c repaymentTransaction = (loan__Repayment_Transaction_Adjustment__c) JSON.deserialize(
            '{ "Name" : "Test Reversal", "loan__Loan_Payment_Transaction__c" : "loanPayment.Id"}' ,
            loan__Repayment_Transaction_Adjustment__c.class
        );
        repaymentTransaction.Id = TestUtility.getFakeId(loan__Repayment_Transaction_Adjustment__c.getSObjectType());
        repaymentTransaction.loan__Reason_Code__c = 'R01';
        repaymentTransaction.loan__Transaction_Creation_Date__c = Date.today();
        repaymentTransaction.loan__Loan_Payment_Transaction__r = loanPayment;
        repaymentTransaction.loan__Adjustment_Txn_Date__c = GeneralHelper.currentSystemDate;

        Map<Id, loan__Repayment_Transaction_Adjustment__c> repaymentTransactionMap = new Map<Id, loan__Repayment_Transaction_Adjustment__c>();
        repaymentTransactionMap.put(repaymentTransaction.Id, repaymentTransaction);

        User collector = new User();
        collector.FirstName = 'Sales';
        collector.LastName = 'Rep';
        collector.ProfileID = [Select Id From Profile Where Name='System Administrator'].Id;
        collector.Email = 'testunique@cancapital.com';
        collector.Title = 'SalesRepresentative';
        collector.Phone = '98765';
        collector.EmailEncodingKey = 'ISO-8859-1';
        collector.LanguageLocaleKey = 'en_US';
        collector.TimeZoneSidKey = 'America/New_York';
        collector.LocaleSidKey = 'en_US';
        collector.Username = TestUtility.generateFakeName() + '@example.com';
        collector.CommunityNickname = 'testUser123';
        collector.Alias = 't1';
        collector.IsActive = true;
        insert collector;

        loan__Office_Name__c loanOfficeName = new loan__Office_Name__c();
        loanOfficeName.Id = loanOfficeName.Id = TestUtility.getFakeId(loan__Office_Name__c.getSObjectType());

        loan__User_Branch_Info__c userBranchInfo = new loan__User_Branch_Info__c();
        userBranchInfo.Id = TestUtility.getFakeId(loan__User_Branch_Info__c.getSObjectType());

        DBManagerTestsStub loanOfficeNameDBInstance = new DBManagerTestsStub();
        loanOfficeNameDBInstance.genericReturnObject = new List<loan__Office_Name__c>{loanOfficeName};
        UserManager.loanOfficeNameDBInstance = (LoanOfficeNameDB) Test.createStub(LoanOfficeNameDB.class, loanOfficeNameDBInstance);

        DBManagerTestsStub userBranchInfoDBInstance = new DBManagerTestsStub();
        userBranchInfoDBInstance.genericReturnObject = new List<loan__Office_Name__c>{loanOfficeName};
        UserManager.userBranchInfoDBInstance = (UserBranchInfoDB) Test.createStub(UserBranchInfoDB.class, userBranchInfoDBInstance);

        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.DeveloperName = 'Default';
        originationSettings.MasterLabel = originationSettings.DeveloperName;
        originationSettings.Derron_Hardy_Email__c = 'testunique@cancapital.com';
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;

        DBManagerTestsStub clContractDBStubInstance = new DBManagerTestsStub();
        clContractDBStubInstance.genericReturnObject = new List<loan__Loan_Account__c>{loanAccount};
        RepaymentTxnAdjustmentManager.contractDBInstance = (CLContractDB) Test.createStub(CLContractDB.class, clContractDBStubInstance);

        DBManagerTestsStub loanPaymentTransactionDBStubInstance = new DBManagerTestsStub();
        RepaymentTxnAdjustmentManager.loanPaymentTransactionDBInstance = (LoanPaymentTransactionDB) Test.createStub(LoanPaymentTransactionDB.class, loanPaymentTransactionDBStubInstance);

        Test.startTest();
            repaymentTxnAdjustmentTriggerHandlerInstance.afterInsert(repaymentTransactionMap);
        Test.stopTest();

        System.assert(repaymentTransactionMap.values() != null);
    }
}