@isTest(isParallel=true)
private class CLContractsTests {

    @isTest
    private static void setLoanAccountFieldsOnInsert() {

        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        loanAccount.loan__Loan_Status__c = 'Approved';

        Test.startTest();
            CLContracts.setLoanAccountFieldsOnInsert(loanAccount);
        Test.stopTest();

        System.assertEquals('Approved', loanAccount.loan__Loan_Status__c);
    }

    @isTest
    private static void setLatestMissedPaymentDate() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);
        loan__Loan_Account__c loanAccount = (loan__Loan_Account__c) JSON.deserialize(
            '{ "Total_Unpaid_Due_Amount_To_Current__c" : "501"}' , loan__Loan_Account__c.class
        );
        loanAccount.loan__Pmt_Amt_Cur__c = 100;
        loanAccount.loan__Previous_Installment_Date__c = GeneralHelper.currentSystemDate;
        loanAccount.loan__Frequency_of_Loan_Payment__c = GeneralConstants.FREQUENCY_WEEKLY;

        List<loan__Loan_Account__c> contractsForUpdate = new List<loan__Loan_Account__c>();

        Test.startTest();
            CLContracts.setLatestMissedPaymentDate(loanAccount, contractsForUpdate);
        Test.stopTest();

        System.assert(!contractsForUpdate.isEmpty());
    }

    @isTest
    private static void setReturnedACHFeeFields() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 15);

        loan__Loan_Account__c loanAccountOne = new loan__Loan_Account__c();
        loanAccountOne.Return_ACH_Fee_Applied_Date__c = GeneralHelper.currentSystemDate.addDays(-4);
        loanAccountOne.Return_ACH_Fee_Count__c = 2;

        loan__Loan_Account__c loanAccountTwo = new loan__Loan_Account__c();
        loanAccountTwo.Return_ACH_Fee_Applied_Date__c = GeneralHelper.currentSystemDate.addMonths(-1);

        Test.startTest();
            CLContracts.setReturnedACHFeeFields(loanAccountOne);
            CLContracts.setReturnedACHFeeFields(loanAccountTwo);
        Test.stopTest();

        System.assertEquals(3, loanAccountOne.Return_ACH_Fee_Count__c);
        System.assertEquals(GeneralHelper.currentSystemDate, loanAccountOne.Return_ACH_Fee_Applied_Date__c);

        System.assertEquals(1, loanAccountTwo.Return_ACH_Fee_Count__c);
        System.assertEquals(GeneralHelper.currentSystemDate, loanAccountTwo.Return_ACH_Fee_Applied_Date__c);
    }

    @isTest
    private static void setBlockedAccountFeeFields() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 15);

        loan__Loan_Account__c loanAccountOne = new loan__Loan_Account__c();
        loanAccountOne.Return_Blocked_Account_Fee_Applied_Date__c = GeneralHelper.currentSystemDate.addDays(-4);
        loanAccountOne.Return_Blocked_Account_Fee_Count__c = 0;

        loan__Loan_Account__c loanAccountTwo = new loan__Loan_Account__c();
        loanAccountTwo.Return_Blocked_Account_Fee_Applied_Date__c = GeneralHelper.currentSystemDate.addMonths(-1);

        Test.startTest();
            CLContracts.setBlockedAccountFeeFields(loanAccountOne);
            CLContracts.setBlockedAccountFeeFields(loanAccountTwo);
        Test.stopTest();

        System.assertEquals(1, loanAccountOne.Return_Blocked_Account_Fee_Count__c);
        System.assertEquals(GeneralHelper.currentSystemDate, loanAccountOne.Return_Blocked_Account_Fee_Applied_Date__c);

        System.assertEquals(1, loanAccountTwo.Return_Blocked_Account_Fee_Count__c);
        System.assertEquals(GeneralHelper.currentSystemDate, loanAccountTwo.Return_Blocked_Account_Fee_Applied_Date__c);
    }

    @isTest
    private static void isClosed() {
        loan__Loan_Account__c oldLoan = new loan__Loan_Account__c();
        oldLoan.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        oldLoan.loan__Loan_Status__c = CLContracts.LOAN_STATUS_ACTIVE_GOOD_STANDING;

        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        loanAccount.Id = oldLoan.Id;
        loanAccount.loan__Loan_Status__c = CLContracts.LOAN_STATUS_CLOSED_OBLIGATION_MET;

        Test.startTest();
            Boolean isClosed = CLContracts.isClosed(loanAccount, oldLoan);
        Test.stopTest();

        System.assert(isClosed);
    }

    @isTest
    private static void isCanceledwithCanceledStatus() {
        loan__Loan_Account__c oldLoan = new loan__Loan_Account__c();
        oldLoan.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        oldLoan.loan__Loan_Status__c = CLContracts.LOAN_STATUS_ACTIVE_GOOD_STANDING;

        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        loanAccount.Id = oldLoan.Id;
        loanAccount.loan__Loan_Status__c = CLContracts.LOAN_STATUS_CANCELED;
        loanAccount.loan__Disbursal_Date__c = system.today();
        loanAccount.loan__Closed_Date__c = system.today();

        Test.startTest();
            Boolean isCanceled = CLContracts.isCanceledWithinTenDays(loanAccount, oldLoan);
        Test.stopTest();

        System.assert(isCanceled);
    }

    @isTest
    private static void isCanceledWithReturnOfFunds() {
        loan__Loan_Account__c oldLoan = new loan__Loan_Account__c();
        oldLoan.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        oldLoan.loan__Loan_Status__c = CLContracts.LOAN_STATUS_ACTIVE_GOOD_STANDING;

        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        loanAccount.Id = oldLoan.Id;
        loanAccount.loan__Loan_Status__c = CLContracts.LOAN_STATUS_CLOSED_OBLIGATION_MET;
        loanAccount.loan__Disbursal_Date__c = system.today();
        loanAccount.loan__Closed_Date__c = system.today().addDays(10);

        Test.startTest();
            Boolean isCanceled = CLContracts.isCanceledWithinTenDays(loanAccount, oldLoan);
        Test.stopTest();

        System.assert(isCanceled);
    }

    @isTest
    private static void isClosedObligationMetWithMore10daysFunded() {
        loan__Loan_Account__c oldLoan = new loan__Loan_Account__c();
        oldLoan.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        oldLoan.loan__Loan_Status__c = CLContracts.LOAN_STATUS_ACTIVE_GOOD_STANDING;

        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        loanAccount.Id = oldLoan.Id;
        loanAccount.loan__Loan_Status__c = CLContracts.LOAN_STATUS_CLOSED_OBLIGATION_MET;
        loanAccount.loan__Disbursal_Date__c = system.today();
        loanAccount.loan__Closed_Date__c = system.today().addDays(11);

        Test.startTest();
            Boolean isCanceled = CLContracts.isCanceledWithinTenDays(loanAccount, oldLoan);
        Test.stopTest();

        System.assertNotEquals(true, isCanceled);
    }

    @isTest
    private static void isFirstDisbursed() {
        loan__Loan_Account__c oldLoan = new loan__Loan_Account__c();
        oldLoan.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        oldLoan.loan__Loan_Status__c = CLContracts.LOAN_STATUS_APPROVED;

        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        loanAccount.Id = oldLoan.Id;
        loanAccount.loan__Loan_Status__c = CLContracts.LOAN_STATUS_ACTIVE_GOOD_STANDING;

        Test.startTest();
            Boolean isFirstDisbursed = CLContracts.isFirstDisbursed(loanAccount, oldLoan);
        Test.stopTest();

        System.assert(isFirstDisbursed);
    }

    @isTest
    private static void isRepaymentScheduleGeneratedOnFirstDisbursal() {
        loan__Loan_Account__c oldLoan = new loan__Loan_Account__c();
        oldLoan.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        oldLoan.loan__Number_of_Installments__c = null;

        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        loanAccount.Id = oldLoan.Id;
        loanAccount.loan__Number_of_Installments__c = 10;


        Test.startTest();
            Boolean isRepaymentScheduleGeneratedOnFirstDisbursal = CLContracts.isRepaymentScheduleGeneratedOnFirstDisbursal(loanAccount, oldLoan);
        Test.stopTest();

        System.assert(isRepaymentScheduleGeneratedOnFirstDisbursal);
    }


    @isTest
    private static void isConcurrentDisbursal() {
        loan__Loan_Account__c oldLoan = new loan__Loan_Account__c();
        oldLoan.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        oldLoan.loan__Disbursed_Amount__c = 100;

        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        loanAccount.Id = oldLoan.Id;
        loanAccount.loan__Disbursed_Amount__c = 1659;
        loanAccount.loan__Last_Transaction_Id__c = 'FAKE ID';
        loanAccount.Pricing_Factor__c = 1.35;
        loanAccount.loan__Last_Transaction_Type__c = 'Disbursal Transaction';

        Test.startTest();
            Boolean isConcurrentDisbursal = CLContracts.isConcurrentDisbursal(loanAccount, oldLoan);
        Test.stopTest();

        System.assert(isConcurrentDisbursal);
    }

    @isTest
    private static void isRepaymentScheduleGenerated() {
        loan__Loan_Account__c oldLoan = new loan__Loan_Account__c();
        oldLoan.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        oldLoan.loan__Pmt_Amt_Cur__c = 0;

        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        loanAccount.Id = oldLoan.Id;
        loanAccount.loan__Loan_Amount__c = 1659;
        loanAccount.loan__Pmt_Amt_Cur__c = 100;
        loanAccount.Pricing_Factor__c = 1.35;
        loanAccount.loan__Number_of_Installments__c = 10;

        Test.startTest();
            Boolean isRepaymentScheduleGenerated = CLContracts.isRepaymentScheduleGenerated(loanAccount, oldLoan);
        Test.stopTest();

        System.assert(isRepaymentScheduleGenerated);
    }
}