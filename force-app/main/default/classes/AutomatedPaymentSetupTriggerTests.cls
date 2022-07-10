@isTest
public class AutomatedPaymentSetupTriggerTests {

    @isTest
    static void beforeInsertAutomatedPaymentSetup() {
        CAN_General_Settings__c generalSetting = new CAN_General_Settings__c();
        generalSetting.Name='test';
        generalSetting.Disable_Automated_Payment_Setup_Trigger__c = false;
        insert generalSetting;

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        loan__Loan_Payment_Spread__c canPaymentSpread =  new loan__Loan_Payment_Spread__c();
        canPaymentSpread.Name = 'CAN Payment Spread';
        insert canPaymentSpread;

        Id bankAccountId = TestUtility.getFakeId(loan__Bank_Account__c.getSObjectType());
        loan__Payment_Mode__c paymentMode = new loan__Payment_Mode__c();
        paymentMode.Name ='ACH';
        insert paymentMode;

        TestUtility.runSetupData();
        loan__Loan_Account__c loanAccount = TestUtility.createContract();
        loanAccount.loan__Next_Installment_Date__c = GeneralHelper.currentSystemDate;
        loanAccount.loan__Frequency_of_Loan_Payment__c = 'Daily';
        update loanAccount;

        loan__Automated_Payment_Setup__c automatedPaymentSetUp = new loan__Automated_Payment_Setup__c();
        automatedPaymentSetUp.loan__Type__c = 'RECURRING';
        automatedPaymentSetUp.loan__Amount_Type__c = 'OLDEST UNPAID BILL AMOUNT';
        automatedPaymentSetUp.loan__CL_Contract__c = loanAccount.Id;
        automatedPaymentSetUp.loan__Payment_Mode__c = paymentMode.Id;
        automatedPaymentSetUp.loan__Active__c = true;
        automatedPaymentSetUp.loan__Bank_Account__c = loanAccount.Bank_Account__c;
        automatedPaymentSetUp.loan__Debit_Date__c = loanAccount.loan__Next_Installment_Date__c;
        automatedPaymentSetUp.loan__Frequency__c = loanAccount.loan__Frequency_of_Loan_Payment__c;
        automatedPaymentSetUp.loan__Setup_Date__c = GeneralHelper.currentSystemDate;
        automatedPaymentSetUp.loan__Recurring_ACH_Start_Date__c = loanAccount.loan__Next_Installment_Date__c;
        automatedPaymentSetUp.loan__Recurring_ACH_End_Date__c = loanAccount.loan__Next_Installment_Date__c.addDays(1);
        automatedPaymentSetUp.loan__Retry__c = 'Enabled';
        automatedPaymentSetUp.loan__Return_Codes_for_Retry__c = 'R01; R09';
        automatedPaymentSetUp.loan__Apply_NSF_on_Attempt__c = '0';
        automatedPaymentSetUp.loan__Number_of_Retry_Attempts__c = 1;
        automatedPaymentSetUp.loan__Retry_Attempt_Interval__c = 1;

        Exception ex;
        Test.startTest();
        try {
            insert automatedPaymentSetUp;
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        TestUtility.assertNullException(ex);

        List<loan__Automated_Payment_Setup__c> actualAutomatedPaymentSetUp = [
            SELECT Id, loan__CL_Contract__c, loan__Payment_Mode__c, loan__Bank_Account__c, loan__Debit_Date__c, loan__Frequency__c
            FROM loan__Automated_Payment_Setup__c
            WHERE Id =:automatedPaymentSetUp.Id
        ];

       System.assertEquals(1,actualAutomatedPaymentSetUp.size());
       System.assertEquals(loanAccount.Id,actualAutomatedPaymentSetUp.get(0).loan__CL_Contract__c);
       System.assertEquals(paymentMode.Id,actualAutomatedPaymentSetUp.get(0).loan__Payment_Mode__c);
       System.assertEquals(loanAccount.Bank_Account__c,actualAutomatedPaymentSetUp.get(0).loan__Bank_Account__c);
       System.assertEquals(loanAccount.loan__Next_Installment_Date__c,actualAutomatedPaymentSetUp.get(0).loan__Debit_Date__c);
       System.assertEquals(loanAccount.loan__Frequency_of_Loan_Payment__c,actualAutomatedPaymentSetUp.get(0).loan__Frequency__c);

    }

    @isTest
    static void beforeUpdateAutomatedPaymentSetup() {
        CAN_General_Settings__c generalSetting = new CAN_General_Settings__c();
        generalSetting.Name='test';
        generalSetting.Disable_Automated_Payment_Setup_Trigger__c = false;
        insert generalSetting;

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        loan__Loan_Payment_Spread__c canPaymentSpread =  new loan__Loan_Payment_Spread__c();
        canPaymentSpread.Name = 'CAN Payment Spread';
        insert canPaymentSpread;

        Id bankAccountId = TestUtility.getFakeId(loan__Bank_Account__c.getSObjectType());
        loan__Payment_Mode__c paymentMode = new loan__Payment_Mode__c();
        paymentMode.Name ='ACH';
        insert paymentMode;

        TestUtility.runSetupData();
        loan__Loan_Account__c loanAccount = TestUtility.createContract();
        loanAccount.loan__Next_Installment_Date__c = GeneralHelper.currentSystemDate;
        loanAccount.loan__Frequency_of_Loan_Payment__c = 'Daily';
        update loanAccount;

        loan__Automated_Payment_Setup__c automatedPaymentSetUp = new loan__Automated_Payment_Setup__c();
        automatedPaymentSetUp.loan__Type__c = 'RECURRING';
        automatedPaymentSetUp.loan__Amount_Type__c = 'OLDEST UNPAID BILL AMOUNT';
        automatedPaymentSetUp.loan__CL_Contract__c = loanAccount.Id;
        automatedPaymentSetUp.loan__Payment_Mode__c = paymentMode.Id;
        automatedPaymentSetUp.loan__Active__c = true;
        automatedPaymentSetUp.loan__Bank_Account__c = loanAccount.Bank_Account__c;
        automatedPaymentSetUp.loan__Debit_Date__c = loanAccount.loan__Next_Installment_Date__c;
        automatedPaymentSetUp.loan__Frequency__c = loanAccount.loan__Frequency_of_Loan_Payment__c;
        automatedPaymentSetUp.loan__Setup_Date__c = GeneralHelper.currentSystemDate;
        automatedPaymentSetUp.loan__Recurring_ACH_Start_Date__c = loanAccount.loan__Next_Installment_Date__c;
        automatedPaymentSetUp.loan__Recurring_ACH_End_Date__c = loanAccount.loan__Next_Installment_Date__c.addDays(1);
        automatedPaymentSetUp.loan__Retry__c = 'Enabled';
        automatedPaymentSetUp.loan__Return_Codes_for_Retry__c = 'R01; R09';
        automatedPaymentSetUp.loan__Apply_NSF_on_Attempt__c = '0';
        automatedPaymentSetUp.loan__Number_of_Retry_Attempts__c = 1;
        automatedPaymentSetUp.loan__Retry_Attempt_Interval__c = 1;
        insert automatedPaymentSetUp;

        loan__Automated_Payment_Setup__c insertedAutomatedPaymentSetUp = [
            SELECT Id, loan__Number_of_Retry_Attempts__c
            FROM loan__Automated_Payment_Setup__c
            WHERE Id =:automatedPaymentSetUp.Id
            LIMIT 1
        ];
        insertedAutomatedPaymentSetUp.loan__Number_of_Retry_Attempts__c = 3;

        Exception ex;
        Test.startTest();
        try {
            update insertedAutomatedPaymentSetUp;
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        TestUtility.assertNullException(ex);

        List<loan__Automated_Payment_Setup__c> actualAutomatedPaymentSetUp = [
            SELECT Id, loan__Number_of_Retry_Attempts__c
            FROM loan__Automated_Payment_Setup__c
            WHERE Id =:automatedPaymentSetUp.Id
        ];

       System.assertEquals(1,actualAutomatedPaymentSetUp.size());
       System.assertEquals(3,actualAutomatedPaymentSetUp.get(0).loan__Number_of_Retry_Attempts__c);

    }

    @isTest
    static void disablingAutomatedPaymentSetup() {
        CAN_General_Settings__c generalSetting = new CAN_General_Settings__c();
        generalSetting.Name='test';
        generalSetting.Disable_Automated_Payment_Setup_Trigger__c = true;
        insert generalSetting;

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        loan__Loan_Payment_Spread__c canPaymentSpread =  new loan__Loan_Payment_Spread__c();
        canPaymentSpread.Name = 'CAN Payment Spread';
        insert canPaymentSpread;

        Id bankAccountId = TestUtility.getFakeId(loan__Bank_Account__c.getSObjectType());
        loan__Payment_Mode__c paymentMode = new loan__Payment_Mode__c();
        paymentMode.Name ='ACH';
        insert paymentMode;

        TestUtility.runSetupData();
        loan__Loan_Account__c loanAccount = TestUtility.createContract();
        loanAccount.loan__Next_Installment_Date__c = GeneralHelper.currentSystemDate;
        loanAccount.loan__Frequency_of_Loan_Payment__c = 'Daily';
        update loanAccount;

        loan__Automated_Payment_Setup__c automatedPaymentSetUp = new loan__Automated_Payment_Setup__c();
        automatedPaymentSetUp.loan__Type__c = 'RECURRING';
        automatedPaymentSetUp.loan__Amount_Type__c = 'OLDEST UNPAID BILL AMOUNT';
        automatedPaymentSetUp.loan__CL_Contract__c = loanAccount.Id;
        automatedPaymentSetUp.loan__Payment_Mode__c = paymentMode.Id;
        automatedPaymentSetUp.loan__Active__c = true;
        automatedPaymentSetUp.loan__Bank_Account__c = loanAccount.Bank_Account__c;
        automatedPaymentSetUp.loan__Debit_Date__c = loanAccount.loan__Next_Installment_Date__c;
        automatedPaymentSetUp.loan__Frequency__c = loanAccount.loan__Frequency_of_Loan_Payment__c;
        automatedPaymentSetUp.loan__Setup_Date__c = GeneralHelper.currentSystemDate;
        automatedPaymentSetUp.loan__Recurring_ACH_Start_Date__c = loanAccount.loan__Next_Installment_Date__c;
        automatedPaymentSetUp.loan__Recurring_ACH_End_Date__c = loanAccount.loan__Next_Installment_Date__c.addDays(1);
        automatedPaymentSetUp.loan__Retry__c = 'Enabled';
        automatedPaymentSetUp.loan__Return_Codes_for_Retry__c = 'R01; R09';
        automatedPaymentSetUp.loan__Apply_NSF_on_Attempt__c = '0';
        automatedPaymentSetUp.loan__Number_of_Retry_Attempts__c = 1;
        automatedPaymentSetUp.loan__Retry_Attempt_Interval__c = 1;

        Exception ex;
        Test.startTest();
        try {
            insert automatedPaymentSetUp;
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

        TestUtility.assertNullException(ex);

        List<loan__Automated_Payment_Setup__c> actualAutomatedPaymentSetUp = [
            SELECT Id, loan__Number_of_Retry_Attempts__c
            FROM loan__Automated_Payment_Setup__c
            WHERE Id =:automatedPaymentSetUp.Id
        ];

       System.assertEquals(1,actualAutomatedPaymentSetUp.size());

    }
}