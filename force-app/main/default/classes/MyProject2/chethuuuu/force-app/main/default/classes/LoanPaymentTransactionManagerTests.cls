@IsTest
public class LoanPaymentTransactionManagerTests
{
    @IsTest
    private static void whenCleared() {
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Boolean isIncrement = true;

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        account.Legacy_Ever_Paid_Days__c = 2;

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {account};
        LoanPaymentTransactionManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Set<Id> accountIds = new Set<Id>();
        accountIds.add(account.Id);

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
            LoanPaymentTransactionManager.setAccountEverPaidDaysField(accountIds, true);
        Test.stopTest();

        System.assertEquals(1, accountDBStubInstance.forUpdateSObjects.size());
        Account newAccount = (Account)accountDBStubInstance.forUpdateSObjects.get(0);
        System.assertEquals(account.Id, newAccount.Id);
        System.assertEquals(3, newAccount.Legacy_Ever_Paid_Days__c);
    }

    @IsTest
    private static void whenReversed() {
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Boolean isIncrement = false;

        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        account.Legacy_Ever_Paid_Days__c = 2;

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {account};
        LoanPaymentTransactionManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Set<Id> accountIds = new Set<Id>();
        accountIds.add(account.Id);

        loan__Loan_Account__c clContract = new loan__Loan_Account__c();
        clContract.loan__Account__c = account.Id;

        String accountId = JSON.serialize(account.Id);
        loan__Loan_Payment_Transaction__c newLoanPayment = (loan__Loan_Payment_Transaction__c) JSON.deserialize(
            '{ "Contract_Account_Id__c" :' + accountId + '}',
            loan__Loan_Payment_Transaction__c.class
        );
        newLoanPayment.loan__Payment_Type__c = 'Regular';
        newLoanPayment.loan__Reversed__c = true;

        Map<Id, loan__Loan_Payment_Transaction__c> lptNewMap = new Map<Id, loan__Loan_Payment_Transaction__c>();
        lptNewMap.put(newLoanPayment.Id, newLoanPayment);

        Test.startTest();
            LoanPaymentTransactionManager.setAccountEverPaidDaysField(accountIds, false);
        Test.stopTest();

        System.assertEquals(1, accountDBStubInstance.forUpdateSObjects.size());
        Account newAccount = (Account)accountDBStubInstance.forUpdateSObjects.get(0);
        System.assertEquals(account.Id, newAccount.Id);
        System.assertEquals(1, newAccount.Legacy_Ever_Paid_Days__c);
    }

    @IsTest
    private static void Exception() {
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Boolean isIncrement = true;
        Account account = new Account();

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account> {account};
        LoanPaymentTransactionManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        LoanPaymentTransactionManager.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Set<Id> accountIds = new Set<Id>();
        Exception ex;

        System.Test.startTest();
            try {
                LoanPaymentTransactionManager.setAccountEverPaidDaysField(accountIds, true);
            }
            catch(Exception e) {
                ex = e;
            }
        System.Test.stopTest();

        System.assertEquals(1, errorLogDBStubInstance.forInsertSObjects.size());
    }
}