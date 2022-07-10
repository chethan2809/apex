@isTest
private class LoanAccountDailyUpdateJobTests {

    @TestSetup
    static void makeData(){
        TestUtility.runSetupData();
        loan__Loan_Disbursal_Transaction__c disbursalTransaction = TestUtility.createLoanDisbursalTransaction();
    }

    @isTest
    private static void ApplicationDailyUpdateDynamicJob(){
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);

        loan__Loan_Payment_Spread__c canPaymentSpread =  new loan__Loan_Payment_Spread__c();
        canPaymentSpread.Name = 'CAN Payment Spread';
        insert canPaymentSpread;

        Id userId = userinfo.getUserId();
        CAN_General_Settings__c generalSetting = new CAN_General_Settings__c();
        generalSetting.Name='TEST LOAN ACCOUNT GENERAL SETTINGS';
        generalSetting.Policy_Cap__c = 99.99;
        generalSetting.Concurrent_Eligible_Days__c = 90;
        generalSetting.Late_fee_job_time__c = '12:22:30';
        generalSetting.SetupOwnerId = userId;
        insert generalSetting;

        loan__Loan_Disbursal_Transaction__c disbursalTransaction = [
            SELECT Id, loan__Disbursal_Date__c, loan__Cleared__c, loan__Reversed__c, loan__Loan_Account__c
            FROM loan__Loan_Disbursal_Transaction__c
        ];
        disbursalTransaction.loan__Disbursal_Date__c = TestUtility.currentSystemDate;
        disbursalTransaction.loan__Cleared__c = true;
        disbursalTransaction.loan__Reversed__c = false;
        update disbursalTransaction;

        loan__Loan_Account__c loanAccount = [
            SELECT Id, Name, Concurrent_Eligible_Amount__c, Pricing_Factor__c, Remaining_Number_of_Payments__c, loan__Frequency_of_Loan_Payment__c,
                Disbursement_Count__c, Concurrent_Interest_Rate__c, loan__Delinquent_Amount__c, Application__c, loan__Payment_Amount__c
            FROM loan__Loan_Account__c
            WHERE Id = :disbursalTransaction.loan__Loan_Account__c
        ];
        loanAccount.loan__Loan_Status__c = 'Active - Good Standing';
        loanAccount.Pricing_Factor__c = 1.0;
        loanAccount.loan__Frequency_of_Loan_Payment__c = 'Daily';
        loanAccount.Max_Number_Of_Missed_Payments__c = 1;
        loanAccount.loan__Delinquent_Amount__c = 0;
        loanAccount.loan__Payment_Amount__c = 3000;
        loanAccount.loan__Last_Disbursal_Amount__c = 3000;
        loanAccount.loan__Last_Disbursal_Date__c = Date.today();
        update loanAccount;

        loan__Repayment_Schedule__c repaymentSchedule =  TestUtility.generateRepaymentSchedule(
            loanAccount.Id, GeneralHelper.currentSystemDate, 15000, 3000
        );
        repaymentSchedule.loan__Is_Archived__c = false;
        repaymentSchedule.loan__Is_Billed__c = false;
        insert repaymentSchedule;

        genesis__Applications__c application =  [
            SELECT Id, Max_Payment_Amount__c, Pricing_Factor__c
            FROM genesis__Applications__c
            WHERE Id = :loanAccount.Application__c
        ];
        application.Max_Payment_Amount__c = 12000;
        application.Pricing_Factor__c = 1;
        update application;

        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.Loan_Account_Update_Job_Size__c = 50;
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;
        Exception ex;

        Test.startTest();
        try{
            LoanAccountDailyUpdateJob.execute();
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();

        list<loan__Loan_Account__c> updatedAccount = [
            SELECT Id, Concurrent_Interest_Rate__c
            FROM loan__Loan_Account__c
            WHERE Id = :loanAccount.Id
        ];

        TestUtility.assertNullException(ex);
        System.assertEquals(1, updatedAccount.size());
        System.assertNotEquals(null, updatedAccount.get(0).Concurrent_Interest_Rate__c );
    }

    @isTest
    private static void loanAccountDailyUpdateJobCheckBatchSizeException() {

        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.Loan_Account_Update_Job_Size__c = null;
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;
        Exception ex;

        loan__Loan_Payment_Spread__c canPaymentSpread =  new loan__Loan_Payment_Spread__c();
        canPaymentSpread.Name = 'CAN Payment Spread';
        insert canPaymentSpread;

        Test.startTest();
            try {
                LoanAccountDailyUpdateJob.execute();
            }
            catch(Exception e){
                ex = e;
            }
        Test.stopTest();

        TestUtility.assertException(ex);
        System.assertEquals(ex.getMessage(), 'Loan_Account_Update_Job_Size__c is null');
    }

    @isTest
    private static void loanAccountDailyUpdateJobException(){
        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);

        loan__Loan_Payment_Spread__c canPaymentSpread =  new loan__Loan_Payment_Spread__c();
        canPaymentSpread.Name = 'CAN Payment Spread';
        insert canPaymentSpread;

        Id userId = userinfo.getUserId();
        CAN_General_Settings__c generalSetting = new CAN_General_Settings__c();
        generalSetting.Name='TEST LOAN ACCOUNT GENERAL SETTINGS';
        generalSetting.Policy_Cap__c = 99.99;
        generalSetting.Concurrent_Eligible_Days__c = 90;
        generalSetting.Late_fee_job_time__c = '12:22:30';
        generalSetting.SetupOwnerId = userId;
        insert generalSetting;

        loan__Loan_Disbursal_Transaction__c disbursalTransaction = [
            SELECT Id, loan__Disbursal_Date__c, loan__Cleared__c, loan__Reversed__c, loan__Loan_Account__c
            FROM loan__Loan_Disbursal_Transaction__c
        ];
        disbursalTransaction.loan__Disbursal_Date__c = TestUtility.currentSystemDate;
        disbursalTransaction.loan__Cleared__c = true;
        disbursalTransaction.loan__Reversed__c = false;
        update disbursalTransaction;

        loan__Loan_Account__c loanAccount = [
            SELECT Id, Name, Concurrent_Eligible_Amount__c, Pricing_Factor__c, Remaining_Number_of_Payments__c, loan__Frequency_of_Loan_Payment__c,
                Disbursement_Count__c, Concurrent_Interest_Rate__c, loan__Delinquent_Amount__c, Application__c, loan__Payment_Amount__c
            FROM loan__Loan_Account__c
            WHERE Id = :disbursalTransaction.loan__Loan_Account__c
        ];
        loanAccount.loan__Loan_Status__c = 'Active - Good Standing';
        loanAccount.loan__Frequency_of_Loan_Payment__c = 'Daily';
        loanAccount.Max_Number_Of_Missed_Payments__c = 1;
        loanAccount.loan__Delinquent_Amount__c = 0;
        loanAccount.loan__Payment_Amount__c = 3000;
        loanAccount.loan__Last_Disbursal_Amount__c = 3000;
        loanAccount.loan__Last_Disbursal_Date__c = Date.today();
        update loanAccount;

        loan__Repayment_Schedule__c repaymentSchedule =  TestUtility.generateRepaymentSchedule(
            loanAccount.Id, GeneralHelper.currentSystemDate, 15000, 3000
        );
        repaymentSchedule.loan__Is_Archived__c = false;
        repaymentSchedule.loan__Is_Billed__c = false;
        insert repaymentSchedule;

        genesis__Applications__c application =  [
            SELECT Id, Max_Payment_Amount__c, Pricing_Factor__c
            FROM genesis__Applications__c
            WHERE Id = :loanAccount.Application__c
        ];
        application.Max_Payment_Amount__c = 12000;
        application.Pricing_Factor__c = 1;
        update application;

        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.Loan_Account_Update_Job_Size__c = 50;
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;

        Exception ex;

        Test.startTest();
        try{
            LoanAccountDailyUpdateJob.execute();
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();
        list<loan__Loan_Account__c> updatedAccount = [
            SELECT Id, Concurrent_Interest_Rate__c
            FROM loan__Loan_Account__c
            WHERE Id = :loanAccount.Id
        ];

        TestUtility.assertNullException(ex);
    }
}