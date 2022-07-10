public class AutomatedPaymentSetups {

    public static final String APS_LOAN_TYPE_RECURRING = 'RECURRING';
    public static final String AMOUNT_TYPE = CustomSettingsHelper.generalSettings.APS_Amount_Type__c;

    public static loan__Automated_Payment_Setup__c createRecurringAutomatedPaymentSetup(loan__Loan_Account__c loanAccount) {
        loan__Automated_Payment_Setup__c recurringAps = new loan__Automated_Payment_Setup__c();
        recurringAps.loan__Type__c = APS_LOAN_TYPE_RECURRING;
        recurringAps.loan__Amount_Type__c = AMOUNT_TYPE;
        recurringAps.loan__CL_Contract__c = loanAccount.Id;
        recurringAps.loan__Payment_Mode__c = ServicingHelper.paymentModeIdByName.get(GeneralConstants.PAYMENT_MODE_ACH);
        recurringAps.loan__Active__c = true;
        recurringAPS.loan__Bank_Account__c = loanAccount.Bank_Account__c;
        recurringAps.loan__Debit_Date__c = loanAccount.loan__Next_Installment_Date__c;
        recurringAps.loan__Frequency__c = loanAccount.loan__Frequency_of_Loan_Payment__c;
        recurringAPS.loan__Setup_Date__c = GeneralHelper.currentSystemDate;
        recurringAps.loan__Recurring_ACH_Start_Date__c = loanAccount.loan__Next_Installment_Date__c;
        recurringAps.loan__Recurring_ACH_End_Date__c = loanAccount.loan__Last_Installment_Date__c.addDays(1);
        return recurringAps;
    }
}