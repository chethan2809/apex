@IsTest
private class SnapShotManagerTests
{
    @IsTest
    private static void updateAccount()
    {
        loan__Loan_Account__c clContractRecord = new loan__Loan_Account__c();
        Account accountRecord = TestUtility.createAccount();

        clContractRecord.loan__Account__c = accountRecord.Id;
     	clContractRecord.loan__Loan_Status__c = 'Closed- Written Off';

        Test.startTest();
            Account acc = SnapShotManager.updateAccount(clContractRecord);
        Test.stopTest();
        System.assertEquals(clContractRecord.loan__Account__c, acc.Id);
    }

    @IsTest
    private static void updateAccountFrequencyDaily()
    {
        loan__Loan_Account__c clContractRecord = new loan__Loan_Account__c();
        Account accountRecord = TestUtility.createAccount();

        clContractRecord.loan__Account__c = accountRecord.Id;
     	clContractRecord.loan__Frequency_of_Loan_Payment__c ='Daily';
        clContractRecord.Latest_Number_Of_Missed_Payments__c = 24;

        Test.startTest();
            Account acc = SnapShotManager.updateAccount(clContractRecord);
        Test.stopTest();
        System.assertEquals(clContractRecord.loan__Account__c, acc.Id);
    }

    @IsTest
    private static void updateAccountFrequencyWeekly()
    {
        loan__Loan_Account__c clContractRecord = new loan__Loan_Account__c();
        Account accountRecord = TestUtility.createAccount();

        clContractRecord.loan__Account__c = accountRecord.Id;
     	clContractRecord.loan__Frequency_of_Loan_Payment__c ='Weekly';
        clContractRecord.Latest_Number_Of_Missed_Payments__c = 4;

        Test.startTest();
            Account acc = SnapShotManager.updateAccount(clContractRecord);
        Test.stopTest();
        System.assertEquals(clContractRecord.loan__Account__c, acc.Id);
    }

    @IsTest
    private static void updateAccountelse()
    {
        loan__Loan_Account__c clContractRecord = new loan__Loan_Account__c();
        Account accountRecord = TestUtility.createAccount();

        clContractRecord.loan__Account__c = accountRecord.Id;

        Test.startTest();
            Account acc = SnapShotManager.updateAccount(clContractRecord);
        Test.stopTest();
        System.assertEquals(clContractRecord.loan__Account__c, acc.Id);
    }

    @IsTest
    private static void updateAccountTransaction()
    {
        Account accountRecord = TestUtility.createAccount();

		GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);

        loan__Loan_Payment_Transaction__c loanPaymentTransaction = (loan__Loan_Payment_Transaction__c) JSON.deserialize(
            '{"Name" : "LPT-000000067" }', loan__Loan_Payment_Transaction__c.class
        );
        loanPaymentTransaction.Id = TestUtility.getFakeId(loan__Loan_Payment_Transaction__c.getSObjectType());
		loanPaymentTransaction.loan__Reversed__c = true;
        loanPaymentTransaction.Reversed_Date__c = Date.newInstance(2019, 02, 01);

        List<loan__Loan_Payment_Transaction__c> loanPaymentTxnList = new List<loan__Loan_Payment_Transaction__c> {loanPaymentTransaction};
 		String jsonLPT = '{"totalSize" : 1, "done" : true, "records" : ' + JSON.serialize(loanPaymentTxnList, false) + '}';

        loan__Loan_Account__c clContractRecord = (loan__Loan_Account__c) JSON.deserialize(
            '{"Name" : "LAI-00000018", "loan__Loan_Payment_Transactions__r" : ' + jsonLPT + '}', loan__Loan_Account__c.class
        );
        clContractRecord.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        clContractRecord.loan__Account__c = accountRecord.Id;
        List<loan__Loan_Account__c> clContract = [Select Id,(Select Id from loan__Loan_Payment_Transactions__r) from loan__Loan_Account__c];

        Test.startTest();
            Account acc = SnapShotManager.updateAccount(clContractRecord);
        Test.stopTest();
        System.assertEquals(clContractRecord.loan__Account__c, acc.Id);
    }

    @IsTest
    private static void updateAccountTransactionNoReverse()
    {
        Account accountRecord = TestUtility.createAccount();

		GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);

        loan__Loan_Payment_Transaction__c loanPaymentTransaction = (loan__Loan_Payment_Transaction__c) JSON.deserialize(
            '{"Name" : "LPT-000000067" }', loan__Loan_Payment_Transaction__c.class
        );
        loanPaymentTransaction.Id = TestUtility.getFakeId(loan__Loan_Payment_Transaction__c.getSObjectType());
		loanPaymentTransaction.loan__Cleared__c = true;

        List<loan__Loan_Payment_Transaction__c> loanPaymentTxnList = new List<loan__Loan_Payment_Transaction__c> {loanPaymentTransaction};
 		String jsonLPT = '{"totalSize" : 1, "done" : true, "records" : ' + JSON.serialize(loanPaymentTxnList, false) + '}';

        loan__Loan_Account__c clContractRecord = (loan__Loan_Account__c) JSON.deserialize(
            '{"Name" : "LAI-00000018", "loan__Loan_Payment_Transactions__r" : ' + jsonLPT + '}', loan__Loan_Account__c.class
        );
        clContractRecord.Id = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());
        clContractRecord.loan__Account__c = accountRecord.Id;
        List<loan__Loan_Account__c> clContract = [Select Id,(Select Id from loan__Loan_Payment_Transactions__r) from loan__Loan_Account__c];

        Test.startTest();
            Account acc = SnapShotManager.updateAccount(clContractRecord);
        Test.stopTest();
        System.assertEquals(clContractRecord.loan__Account__c, acc.Id);
    }

    @IsTest
    private static void updateAccountOnPayOff()
    {
        loan__Loan_Account__c clContractRecord = new loan__Loan_Account__c();
        Account accountRecord = TestUtility.createAccount();

        clContractRecord.loan__Account__c = accountRecord.Id;
     	clContractRecord.loan__Loan_Status__c = 'Closed - Obligations met';

        Test.startTest();
            Account acc = SnapShotManager.updateAccount(clContractRecord);
        Test.stopTest();
        System.assertEquals(clContractRecord.loan__Account__c, acc.Id);
    }
}