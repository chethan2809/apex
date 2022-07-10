@isTest
public class OnDemandLoanPaymentACHFileGenJobTests {
    @TestSetup
    static void makeData(){
        TestUtility.runSetupData();
        loan__Loan_Account__c loanAccount = TestUtility.createContract();
        loan__Payment_Mode__c paymentMode = TestUtility.createPaymentMode('ACH');
        loan__Loan_Payment_Transaction__c loanPaymentTransaction = TestUtility.generateLoanPaymentTransaction(loanAccount.Id, 2000, paymentMode.Id);
        insert loanPaymentTransaction;
    }

    @isTest
    private static void onDemandLoanPaymentACHFileGenJobTest (){

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        loan__Loan_Payment_Transaction__c loanPaymentTransaction = [
             SELECT loan__Loan_Account__c, loan__ACH_Filename__c, loan__Actual_TDS__c, loan__Additional_Interest__c, loan__Affected_Installment_Ids__c, loan__Applied_Spread__c, loan__Archived__c, loan__Automated_Payment_Setup__c,
                loan__Backdated_Reschedule_Required__c, loan__Balance__c, loan__Balance_s_Snapshot__c, loan__Bank_Name__c, loan__Borrower_Email__c, loan__Cash_Receipt_Application__c, loan__Check__c, loan__Cheque_Date__c, loan__Cheque_Number__c,
                loan__Cleared__c, loan__Clearing_Date__c, loan__Closure_Tolerance_Payment__c, loan__Consolidated_Loan_Payment__c, loan__Custom_Logic__c, loan__Dependent_Payment_Transaction__c, loan__Deposit_Snapshot__c, loan__Deposit__c, loan__Dues_Snapshot__c,
                loan__Early_Payment__c, loan__Early_Total_Repayment_of_the_Loan__c, loan__Excess__c, loan__Expected_TDS__c, loan__External_Id__c, loan__Fee_Snapshot__c, loan__Fees__c, loan__Force_No_Loan_Payoff__c, loan__IOA__c, loan__Id__c, loan__Installment_Date__c,
                loan__Installment_Payment__c, loan__Interest_Component_Snapshot__c, loan__Interest_Rate__c, loan__Interest__c, loan__Internal_Accounting_Generated__c, loan__Investor_Rebate_Amount_On_Payoff__c, loan__Investor_Rebate_Amount_On_Refinance__c, loan__Investor_Rebate_Amount_On_Writeoff__c,
                loan__Ipt_Snapshot__c, loan__Is_Adjustment_Entry_Created__c, loan__Late_Charge_Interest__c, loan__Late_Charge_Principal__c, loan__Loan_Payment_Spread__c, loan__Loan_Snapshot__c, loan__Manual_Payment__c, loan__Master_Archive_Object__c, loan__Missed_Loan_Installment__c, loan__Number_Of_Bills_Waived__c,
                loan__Other_Charges_Interest__c, loan__Other_Charges_Principal__c, loan__Out_of_Order_Payment__c, loan__Out_of_Order_Status__c, loan__Override_Payments_To_Deposit__c, loan__Paid_to_Broker_Reversed__c, loan__Paid_to_Broker__c, loan__Paid_to_Investor_Reversed__c, loan__Paid_to_Investor__c,
                loan__Partial_Payment_del__c, loan__Payment_Application_Mode__c, loan__Payment_Mode__c, loan__Payment_Type__c, loan__Payoff_Balance__c, loan__Principal__c, loan__Product_Code__c, loan__Protect_Principal__c, loan__Rebate_Amount__c, loan__Rebate_Payment__c, loan__Receipt_Amount__c, loan__Receipt_Date__c,
                loan__Receipt_ID__c, loan__Refinance_Transaction__c, loan__Rejected__c, loan__Rejection_Date__c, loan__Rejection_Reason__c, loan__Reschedule_Threshold_Crossed__c, loan__Retried__c, loan__Retry_Attempt_Number__c, loan__Retry_Attempt_for__c, loan__Retry_On__c, loan__Reversal_Reason__c, loan__Reversed__c,
                loan__Sent_To_ACH_On__c, loan__Sent_to_ACH__c, loan__Skip_Validation__c, loan__Summary_Record_Id__c, loan__Summary__c, loan__Total_Charges_Interest__c, loan__Total_Charges_Principal__c, loan__Transaction_Amount__c, loan__Transaction_Creation_Date__c, loan__Transaction_Date__c, loan__Transaction_Time__c,
                loan__Write_Off_Recovery_Payment__c, loan__protect_interest__c, loan__waived__c, loan__Cleared_Reversal_Txn_Count__c, peer__BTransaction_Hash__c, peer__Bank_Reference__c, peer__Bank_Statement_Date__c, peer__Bank_Statement_Exception__c, peer__Loan_Cancellation__c, peer__Verification__c, peer__Verified_From_Bank_Statement__c,
                Wire_Payment_Transaction__c, CL_Contract__c, Internal_Accounting_Generated_Reversed__c, Reversed_Date__c, Pre_Closure_Charges__c, Reversed_LPT_Reference__c, Transaction_Date_For_Portal__c, Contract_Account_Id__c, Name, Id, loan__Loan_Account__r.loan__Loan_Status__c, loan__Loan_Account__r.loan__Invalid_Data__c
            FROM loan__Loan_Payment_Transaction__c
            LIMIT 1
        ];
        loan__Loan_Account__c loanAccount = [
            SELECT Id, loan__Loan_Status__c,loan__Invalid_Data__c
            FROM loan__Loan_Account__c WHERE Id = :loanPaymentTransaction.loan__Loan_Account__c
            LIMIT 1
        ];
        loanPaymentTransaction.loan__Sent_To_ACH_On__c =GeneralHelper.currentSystemDate;
        loanPaymentTransaction.loan__Loan_Account__r.loan__Loan_Status__c = CLContracts.LOAN_STATUS_CANCELED;
        loanPaymentTransaction.loan__Loan_Account__r.loan__Invalid_Data__c = false;
        loanPaymentTransaction.loan__Receipt_Date__c=GeneralHelper.currentSystemDate;
        loanPaymentTransaction.loan__Reversed__c = false;
        update loanPaymentTransaction;

        Exception ex;

        OnDemandLoanPaymentACHFileGenJob demandJob = new OnDemandLoanPaymentACHFileGenJob();

        Test.startTest();
        try{
            Database.executeBatch(demandJob, 200);
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();

        list<loan__Loan_Payment_Transaction__c> actualLoanPaymentTransactionList = [
            SELECT Id, loan__Sent_to_ACH__c, loan__ACH_Filename__c,loan__Sent_To_ACH_On__c
            FROM loan__Loan_Payment_Transaction__c
            WHERE Id = :loanPaymentTransaction.Id
        ];
        System.assertEquals(false, actualLoanPaymentTransactionList[0].loan__Sent_to_ACH__c);

    }
}