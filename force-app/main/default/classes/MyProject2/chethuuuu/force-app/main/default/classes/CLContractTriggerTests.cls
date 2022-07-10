@isTest
private class CLContractTriggerTests {
    @testSetup
    static void makeData() {
        TestUtility.runSetupData();
        genesis__Applications__c application = TestUtility.createApplication();
        loan__Loan_Product__c loanProduct = TestUtility.createLoanProduct();
        loan__Bank_Account__c bankAccount = TestUtility.createBankAccount();
        loan__Loan_Payment_Spread__c canPaymentSpread =  new loan__Loan_Payment_Spread__c();
        canPaymentSpread.Name = 'CAN Payment Spread';
        insert canPaymentSpread;
    }
    @isTest
    static void beforeInsertCLContract() {
        genesis__Applications__c application = [
            SELECT Id, genesis__Account__c, Primary_Guarantor__c
            FROM genesis__Applications__c LIMIT 1
        ];

        loan__Loan_Product__c loanProduct = [
            SELECT Id
            FROM loan__Loan_Product__c LIMIT 1
        ];

        loan__Bank_Account__c bankAccount = [
            SELECT Id
            FROM loan__Bank_Account__c LIMIT 1
        ];

        loan__Loan_Account__c loanAccount = TestUtility.generateContract(application, loanProduct, bankAccount);
        loanAccount.loan__Loan_Amount__c = 5000;

        Exception ex;
        Test.startTest();
            try {
                insert loanAccount;
            } catch (Exception e) {
                ex = e;
            }
        Test.stopTest();

        TestUtility.assertNullException(ex);

        loan__Loan_Account__c actualLoanAccount = [
            SELECT Id, loan__Loan_Amount__c, Application__c, loan__Loan_Product_Name__c, Bank_Account__c
            FROM loan__Loan_Account__c
            WHERE Id =: loanAccount.Id
            LIMIT 1
        ];

        System.assertEquals(application.Id, actualLoanAccount.Application__c);
        System.assertEquals(loanProduct.Id, actualLoanAccount.loan__Loan_Product_Name__c);
        System.assertEquals(bankAccount.Id, actualLoanAccount.Bank_Account__c);
        System.assertEquals(5000, actualLoanAccount.loan__Loan_Amount__c);
    }

    @isTest
    static void beforeUpdateCLContract() {
        genesis__Applications__c application = [
            SELECT Id, genesis__Account__c, Primary_Guarantor__c
            FROM genesis__Applications__c LIMIT 1
        ];

        loan__Loan_Product__c loanProduct = [
            SELECT Id
            FROM loan__Loan_Product__c LIMIT 1
        ];

        loan__Bank_Account__c bankAccount = [
            SELECT Id
            FROM loan__Bank_Account__c LIMIT 1
        ];

        loan__Loan_Account__c loanAccount = TestUtility.generateContract(application, loanProduct, bankAccount);
        loanAccount.loan__Loan_Amount__c = 5000;
        insert loanAccount;

        loan__Loan_Account__c updatedLoanAccount = [
            SELECT Id, loan__Loan_Amount__c
            FROM loan__Loan_Account__c
            LIMIT 1
        ];
        updatedLoanAccount.loan__Loan_Amount__c = 7000;

        Exception ex;
        Test.startTest();
            try {
                update updatedLoanAccount;
            } catch (Exception e) {
                ex = e;
            }
        Test.stopTest();

        TestUtility.assertNullException(ex);

        List<loan__Loan_Account__c> actualLoanAccount = [
            SELECT Id, loan__Loan_Amount__c
            FROM loan__Loan_Account__c
        ];

        System.assertEquals(1, actualLoanAccount.size());
        System.assertEquals(7000, actualLoanAccount.get(0).loan__Loan_Amount__c);
    }
}