@IsTest
private class LoanPaymentTxnTriggerHandlerTests
{
    @IsTest
    private static void beforeUpdateTests()
    {
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);

        loan__Loan_Payment_Transaction__c loanPayment = new loan__Loan_Payment_Transaction__c();
        Map<Id, loan__Loan_Payment_Transaction__c> lptMap = new Map<Id, loan__Loan_Payment_Transaction__c>();
        loanPayment.loan__Reversed__c = false;
        loanPayment.loan__Retry_On__c = GeneralHelper.currentSystemDate;
        loanPayment.Id = TestUtility.getFakeId(loan__Loan_Payment_Transaction__c.getSObjectType());
        lptMap.put(loanPayment.Id, loanPayment);

        loan__Loan_Payment_Transaction__c newLoanPayment = new loan__Loan_Payment_Transaction__c();
        newLoanPayment.loan__Reversed__c = true;
        newLoanPayment.Id = loanPayment.Id;
        newLoanPayment.loan__Retry_On__c = GeneralHelper.currentSystemDate.addDays(2);

        List<loan__Loan_Payment_Transaction__c> lptList = new List<loan__Loan_Payment_Transaction__c>();
        lptList.add(newLoanPayment);

        Test.startTest();
            new LoanPaymentTxnTriggerHandler().beforeUpdate(lptList, lptMap);
        Test.stopTest();

        System.assert(lptList != null);
    }

    @IsTest
    private static void afterInsertWhenCleared()
    {
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        account.Legacy_Ever_Paid_Days__c = 2;

		DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {account};
        LoanPaymentTransactionManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        loan__Loan_Account__c clContract = new loan__Loan_Account__c();
        clContract.loan__Account__c = account.Id;

		String accountId = JSON.serialize(account.Id);
        loan__Loan_Payment_Transaction__c newLoanPayment = (loan__Loan_Payment_Transaction__c) JSON.deserialize(
            '{ "Contract_Account_Id__c" :' + accountId + '}',
            loan__Loan_Payment_Transaction__c.class
        );
        newLoanPayment.loan__Payment_Type__c = 'Regular';

        Map<Id, loan__Loan_Payment_Transaction__c> lptNewMap = new Map<Id, loan__Loan_Payment_Transaction__c>();
        lptNewMap.put(newLoanPayment.Id, newLoanPayment);

        Test.startTest();
        	new LoanPaymentTxnTriggerHandler().afterInsert(lptNewMap);
        Test.stopTest();

        System.assertEquals(1, accountDBStubInstance.forUpdateSObjects.size());
        Account newAccount = (Account)accountDBStubInstance.forUpdateSObjects.get(0);
        System.assertEquals(account.Id, newAccount.Id);
        System.assertEquals(3, newAccount.Legacy_Ever_Paid_Days__c);
    }

    @IsTest
    private static void afterUpdateWhenReversed()
    {
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        account.Legacy_Ever_Paid_Days__c = 2;

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {account};
        LoanPaymentTransactionManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        loan__Loan_Account__c clContract = new loan__Loan_Account__c();
        clContract.loan__Account__c = account.Id;

        Map<Id, loan__Loan_Payment_Transaction__c> lptMap = new Map<Id, loan__Loan_Payment_Transaction__c>();
        loan__Loan_Payment_Transaction__c oldloanPayment = new loan__Loan_Payment_Transaction__c();
        oldloanPayment.loan__Reversed__c = false;
        oldloanPayment.Id = TestUtility.getFakeId(loan__Loan_Payment_Transaction__c.getSObjectType());
        lptMap.put(oldloanPayment.Id, oldloanPayment);

        String accountId = JSON.serialize(account.Id);
        loan__Loan_Payment_Transaction__c newLoanPayment = (loan__Loan_Payment_Transaction__c) JSON.deserialize(
            '{ "Contract_Account_Id__c" :' + accountId + '}',
            loan__Loan_Payment_Transaction__c.class
        );
        newLoanPayment.Id = oldloanPayment.Id;
        newLoanPayment.loan__Reversed__c = true;
        newLoanPayment.loan__Payment_Type__c = 'Regular';

        Map<Id, loan__Loan_Payment_Transaction__c> lptNewMap = new Map<Id, loan__Loan_Payment_Transaction__c>();
        lptNewMap.put(newLoanPayment.Id, newLoanPayment);

        Test.startTest();
            new LoanPaymentTxnTriggerHandler().afterUpdate(lptNewMap, lptMap);
        Test.stopTest();

        System.assertEquals(1, accountDBStubInstance.forUpdateSObjects.size());
        Account newAccount = (Account)accountDBStubInstance.forUpdateSObjects.get(0);
        System.assertEquals(account.Id, newAccount.Id);
        System.assertEquals(1, newAccount.Legacy_Ever_Paid_Days__c);
    }

    @IsTest
    private static void beforeInsertTests() {
        List<loan__Loan_Payment_Transaction__c> loanPaymentTransactionList = new List<loan__Loan_Payment_Transaction__c>();

        loan__Loan_Account__c loanAccount = new loan__Loan_Account__c();
        loanAccount.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        loanAccount.loan__Loan_Status__c = CLContracts.LOAN_STATUS_CLOSED_WRITTEN_OFF;

        loan__Loan_Payment_Transaction__c loanPayment = new loan__Loan_Payment_Transaction__c();
        loanPayment.loan__Loan_Account__c = loanAccount.Id;
        loanPayment.loan__Loan_Account__r = loanAccount;
        loanPayment.Id = TestUtility.getFakeId(loan__Loan_Payment_Transaction__c.getSObjectType());
        loanPaymentTransactionList.add(loanPayment);

        DBManagerTestsStub loanPaymentDBInstance = new DBManagerTestsStub();
        LoanPaymentTxnTriggerHandler.loanPaymentDBInstance =
            (LoanPaymentTransactionDB) Test.createStub(LoanPaymentTransactionDB.class, loanPaymentDBInstance);


        Test.startTest();
            new LoanPaymentTxnTriggerHandler().beforeInsert(loanPaymentTransactionList);
        Test.stopTest();

        System.assertEquals(CLContracts.LOAN_STATUS_CLOSED_WRITTEN_OFF, loanAccount.loan__Loan_Status__c);
    }
}