@IsTest
public class RepaymentTxnAdjustmentTriggerTests {
    loan__Loan_Account__c loanAccount = TestUtility.createContract();

    @isTest
    static void afterInsertreversalTransaction() {
        CAN_General_Settings__c generalSetting = new CAN_General_Settings__c();
        generalSetting.Name='test';
        generalSetting.Disable_Repayment_Txn_Adjustment_Trigger__c = true;
        insert generalSetting;

        TestUtility.runSetupData();
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 02, 14);
        Contact primaryContact = new Contact();
        primaryContact.FirstName = 'Test First';
        primaryContact.LastName = 'Test Last';
        primaryContact.Email = 'Test@sample.com';
        insert primaryContact;

        loan__Loan_Account__c loanAccount = TestUtility.createContract();
        loanAccount.loan__Last_Accrual_Date__c = GeneralHelper.currentSystemDate;
        loanAccount.Primary_Contact__c = primaryContact.Id;
        loanAccount.loan__Disbursed_Amount__c = 5000;
        loanAccount.loan__Disbursal_Date__c = Date.newInstance(2020, 02, 21);
        update loanAccount;

        loan__Loan_Account__c actualLoanAccount = [
            SELECT Id, Primary_Contact__c, Primary_Contact__r.Email
            FROM loan__Loan_Account__c
        ];

        loan__Payment_Mode__c mode = new loan__Payment_Mode__c();
        mode.Name ='test';
        insert mode;

        loan__Loan_Payment_Transaction__c loanPayment = TestUtility.generateLoanPaymentTransaction(actualLoanAccount.Id, 1200, mode.Id);
        insert loanPayment;

        loan__Repayment_Transaction_Adjustment__c repaymentTransaction = new loan__Repayment_Transaction_Adjustment__c();
        repaymentTransaction.loan__Reason_Code__c = 'NSF';
        repaymentTransaction.loan__Transaction_Creation_Date__c = Date.today();
        repaymentTransaction.loan__Loan_Payment_Transaction__c = loanPayment.Id;
        repaymentTransaction.loan__Adjustment_Txn_Date__c = GeneralHelper.currentSystemDate;

        Exception ex;
        Test.startTest();
        try {
            insert repaymentTransaction;
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        List<loan__Repayment_Transaction_Adjustment__c> actualRepaymentTransaction = [
            SELECT Id
            FROM loan__Repayment_Transaction_Adjustment__c
        ];

        System.assertEquals(1, actualRepaymentTransaction.size());
    }

}