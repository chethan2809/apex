@isTest
private class LoanRenewalEligibilityJobTests {
    @TestSetup
    static void makeData(){
        TestUtility.runSetupData();
        loan__Loan_Account__c loanAccount = TestUtility.createContract();
    }

    @isTest
    private static void loanRenewalEligibilityJob(){

        loan__Loan_Account__c loanAccount = [
            SELECT Id, loan__Account__c, loan__Frequency_of_Loan_Payment__c, Latest_Missed_Payment_Date__c,
                loan__Interest_Paid__c, loan__Principal_Paid__c, loan__Fees_Paid__c, loan__Penalty_Paid__c,
                loan__Principal_Remaining__c, loan__Interest_Accrued_Not_Due__c, loan__Fees_Remaining__c,
            	loan__Disbursed_Amount__c, loan__Total_Interest_Amortization_Based__c, Percentage_Paid__c
            FROM loan__Loan_Account__c
        ];
        GeneralHelper.currentSystemDate = TestUtility.currentSystemDate;

        loanAccount.loan__Frequency_of_Loan_Payment__c = 'Daily';
        loanAccount.Latest_Missed_Payment_Date__c = GeneralHelper.currentSystemDate.addDays(-12);
        loanAccount.loan__Interest_Paid__c = 2000;
        loanAccount.loan__Principal_Paid__c = 6000;
        loanAccount.loan__Fees_Paid__c = 9000;
        loanAccount.loan__Penalty_Paid__c = 1000;
        loanAccount.loan__Principal_Remaining__c = 4000;
        loanAccount.loan__Interest_Accrued_Not_Due__c = 2000;
        loanAccount.loan__Fees_Remaining__c = 5350;
        loanAccount.Auto_Renewed__c = false;
        loanAccount.loan__Disbursed_Amount__c = 10000;
        loanAccount.Latest_Number_Of_Missed_Payments__c = 1;
        loanAccount.loan__Loan_Status__c = CLContracts.LOAN_STATUS_ACTIVE_GOOD_STANDING;
        update loanAccount;

        loan__Repayment_Schedule__c repaymentSchedule = new loan__Repayment_Schedule__c();
        repaymentSchedule.loan__Due_Interest__c = 10;
        repaymentSchedule.loan__Loan_Account__c = loanAccount.Id;
        repaymentSchedule.loan__Is_Archived__c = false;
        repaymentSchedule.loan__Due_Date__c = GeneralHelper.currentSystemDate;
        insert repaymentSchedule;

        CAN_General_Settings__c canGeneralSettings = new CAN_General_Settings__c();
        canGeneralSettings.Id = TestUtility.getFakeId(CAN_General_Settings__c.getSObjectType());
        canGeneralSettings.Renewal_Eligible_Days__c = 60;
        CustomSettingsHelper.generalSettings = canGeneralSettings;

        Exception ex;

        Test.startTest();
        try{
            loanRenewalEligibilityJob.execute();
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();

        list<loan__Loan_Account__c> updatedAccount = [
            SELECT Id, loan__Account__c
            FROM loan__Loan_Account__c
            WHERE Id = :loanAccount.Id
        ];

        System.assertEquals(1, updatedAccount.size());
        System.assertEquals(loanAccount.loan__Account__c, updatedAccount.get(0).loan__Account__c);

    }

    @isTest
    private static void loanRenewalEligibilityJobCheckBatchSizeException() {

        Origination_Settings__mdt originationSettings = new Origination_Settings__mdt();
        originationSettings.Loan_Renewal_Batch_Size__c = null;
        CustomMetaDataHelper.defaultOriginationSetting = originationSettings;
        Exception ex;

        Test.startTest();
            try {
                loanRenewalEligibilityJob.execute();
            }
            catch(Exception e){
                ex = e;
            }
        Test.stopTest();

        TestUtility.assertException(ex);
        System.assertEquals(ex.getMessage(), 'Loan_Renewal_Batch_Size__c is null');

    }

}