@isTest
private class LoanDisbursalTransactionTrgerHndlrTests {

    private static LoanDisbursalTransactionTriggerHandler loanDisbursalTransactionTriggerHandlerInstance = new LoanDisbursalTransactionTriggerHandler();

    @isTest
    private static void beforeInsert() {

        CAN_General_Settings__c canGeneralSettings = CAN_General_Settings__c.getOrgDefaults();
        canGeneralSettings.Default_Investor_Account_Id__c = TestUtility.getFakeId(Account.getSObjectType());

        CustomSettingsHelper.generalSettings = canGeneralSettings;

        loan__Loan_Disbursal_Transaction__c disbursalTransaction = new loan__Loan_Disbursal_Transaction__c();

        Test.startTest();
            loanDisbursalTransactionTriggerHandlerInstance.beforeInsert(
                new List<loan__Loan_Disbursal_Transaction__c> {disbursalTransaction}
            );
        Test.stopTest();

        System.assertEquals(canGeneralSettings.Default_Investor_Account_Id__c, disbursalTransaction.Investor_Account__c);
    }

    @isTest
    private static void loanDisbursalAfterInsert() {

        Account investorAccount = TestUtility.createAccount();

        loan__Loan_Disbursal_Transaction__c disbursalTransaction = new loan__Loan_Disbursal_Transaction__c();
        disbursalTransaction.Id = TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType());
        disbursalTransaction.Investor_Account__c = investorAccount.Id;

        Map<Id, loan__Loan_Disbursal_Transaction__c> disbursalTransactionMap = new Map<Id, loan__Loan_Disbursal_Transaction__c>();
        disbursalTransactionMap.put(disbursalTransaction.Id, disbursalTransaction);

        DBManagerTestsStub loanDisbursalTransactionsDBStubInstance = new DBManagerTestsStub();
        loanDisbursalTransactionsDBStubInstance.genericReturnObject = new List<loan__Loan_Disbursal_Transaction__c>{disbursalTransaction};
        LoanDisbursalTransactionTriggerHandler.loanDisbursalTransactionsDBInstance = (LoanDisbursalTransactionsDB) Test.createStub(LoanDisbursalTransactionsDB.class, loanDisbursalTransactionsDBStubInstance);

        Test.startTest();
            loanDisbursalTransactionTriggerHandlerInstance.afterInsert(disbursalTransactionMap);
        Test.stopTest();

        System.assertEquals(disbursalTransaction, disbursalTransactionMap.get(disbursalTransaction.Id));
    }

    @isTest
    private static void loanDisbursalAfterUpdate() {

        Account investorAccount = TestUtility.createAccount();

        loan__Loan_Disbursal_Transaction__c oldDisbursalTransaction = new loan__Loan_Disbursal_Transaction__c();
        oldDisbursalTransaction.Id = TestUtility.getFakeId(loan__Loan_Disbursal_Transaction__c.getSObjectType());

        Map<Id, loan__Loan_Disbursal_Transaction__c> oldDisbursalTransactionMap = new Map<Id, loan__Loan_Disbursal_Transaction__c>();
        oldDisbursalTransactionMap.put(oldDisbursalTransaction.Id, oldDisbursalTransaction);

        loan__Loan_Disbursal_Transaction__c newDisbursalTransaction = new loan__Loan_Disbursal_Transaction__c();
        newDisbursalTransaction.Id = oldDisbursalTransaction.Id;
        newDisbursalTransaction.Investor_Account__c = investorAccount.Id;

        Map<Id, loan__Loan_Disbursal_Transaction__c> newDisbursalTransactionMap = new Map<Id, loan__Loan_Disbursal_Transaction__c>();
        newDisbursalTransactionMap.put(newDisbursalTransaction.Id, newDisbursalTransaction);

        DBManagerTestsStub loanDisbursalTransactionsDBStubInstance = new DBManagerTestsStub();
        loanDisbursalTransactionsDBStubInstance.genericReturnObject = new List<loan__Loan_Disbursal_Transaction__c>{newDisbursalTransaction};
        LoanDisbursalTransactionTriggerHandler.loanDisbursalTransactionsDBInstance = (LoanDisbursalTransactionsDB) Test.createStub(LoanDisbursalTransactionsDB.class, loanDisbursalTransactionsDBStubInstance);

        Test.startTest();
            loanDisbursalTransactionTriggerHandlerInstance.afterUpdate(newDisbursalTransactionMap, oldDisbursalTransactionMap);
        Test.stopTest();

        System.assertEquals(newDisbursalTransaction, newDisbursalTransactionMap.get(newDisbursalTransaction.Id));
    }
}