@isTest
private class ClawbackProcessingJobTests {
    @TestSetup
    static void makeData(){
        TestUtility.runSetupData();
        loan__Loan_Account__c loanAccount = TestUtility.createContract();
        Contact contactRecord = TestUtility.createContact();
    }

    @isTest
    private static void clawbackProcessingJob(){

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        Id userId = userInfo.getUserId();

        CAN_General_Settings__c generalSetting = new CAN_General_Settings__c();
        generalSetting.Name='TEST CLAWBACK GENERAL SETTINGS';
        generalSetting.Clawback_Eligible_Days_Daily__c = 20;
        generalSetting.Late_fee_job_time__c = '12:22:30';
        generalSetting.SetupOwnerId = userId;
        insert generalSetting;

        Contact contactRecord = [
            SELECT Id, AccountId
            FROM Contact
            LIMIT 1
        ];

        loan__Loan_Account__c loanAccount = [
            SELECT Id, loan__Account__c, loan__Frequency_of_Loan_Payment__c, loan__Disbursal_Date__c, Latest_Number_Of_Missed_Payments__c,
            Total_Unpaid_Due_Amount_To_Current__c, loan__Previous_Installment_Date__c, loan__Pmt_Amt_Cur__c, Broker_Contact__c, Broker_Contact__r.AccountId
            FROM loan__Loan_Account__c
        ];

        loanAccount.loan__Frequency_of_Loan_Payment__c = GeneralConstants.FREQUENCY_DAILY;
        loanAccount.loan__Disbursal_Date__c = GeneralHelper.currentSystemDate.addDays(-20);
        loanAccount.loan__Previous_Installment_Date__c = Date.today().addDays(-1);
        loanAccount.loan__Pmt_Amt_Cur__c = 100;
        loanAccount.Broker_Contact__c = contactRecord.Id;
        update loanAccount;

        loan__Loan_account_Due_Details__c billsRec = new loan__Loan_account_Due_Details__c();
        billsRec.loan__Principal_Billed__c = 500;
        billsRec.loan__Interest_Billed__c = 2;
        billsRec.loan__Fees_Billed__c = 200;
        billsRec.loan__Payment_Amt__c =100;
        billsRec.loan__DD_Primary_Flag__c = True;
        billsRec.loan__Archived__c = False;
        billsRec.loan__Due_Amt__c = 5000;
        billsRec.loan__Loan_Account__c = loanAccount.Id;
        insert billsRec;

        loan__Loan_Account__c updatedLoanAccount = [
            SELECT Id, loan__Account__c, loan__Frequency_of_Loan_Payment__c, loan__Disbursal_Date__c, Latest_Number_Of_Missed_Payments__c,
            Total_Unpaid_Due_Amount_To_Current__c, loan__Previous_Installment_Date__c, loan__Pmt_Amt_Cur__c, Broker_Contact__c, Broker_Contact__r.AccountId
            FROM loan__Loan_Account__c
        ];
        loanAccount.Latest_Number_Of_Missed_Payments__c = 5;
        update updatedLoanAccount;

        Exception ex;

        Test.startTest();
        try{
            ClawbackProcessingJob.execute();
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();

        list<loan__Loan_Account__c> updatedAccount = [
            SELECT Id, loan__Account__c, Total_Unpaid_Due_Amount_To_Current__c
            FROM loan__Loan_Account__c
            WHERE Id = :loanAccount.Id
        ];

        System.assertEquals(1, updatedAccount.size());
        System.assertEquals(loanAccount.loan__Account__c, updatedAccount.get(0).loan__Account__c);

    }

    @isTest
    private static void clawbackProcessingJobCheckBatchSizeException() {

        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.Clawback_Batch_Size__c = null;
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;
        Exception ex;

        Test.startTest();
            try {
                ClawbackProcessingJob.execute();
            }
            catch(Exception e){
                ex = e;
            }
        Test.stopTest();

        TestUtility.assertException(ex);
        System.assertEquals(ex.getMessage(), 'Clawback_Batch_Size__c is null');

    }
}