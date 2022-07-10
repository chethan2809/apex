public class LoanAccountDailyUpdateJobManager {

    @TestVisible
    private static LoanCalculatorManager loanCalculatorManagerInstance = new LoanCalculatorManager();
    @TestVisible
    private static CLContractDB clContractDBInstance = new CLContractDB();
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    public static void calculateConcurrentInterestRate(List<loan__Loan_Account__c> loanAccountList){
        System.debug('01loanAccountList'+loanAccountList);
        System.debug('01loanAccountList.size'+loanAccountList.size());
        for(loan__Loan_Account__c loanAccount : loanAccountList) {
            System.debug('02loanAccount'+loanAccount);
            if(loanAccount.Disbursement_Count__c == null || loanAccount.Pricing_Factor__c == null||
                loanAccount.Disbursement_Count__c > 1 || loanAccount.Concurrent_Eligible_Amount__c <= 0 ||loanAccount.Remaining_Number_of_Payments__c <= 0
            ) {
            System.debug('01loanAccount'+loanAccount);
                continue;
            }

            System.debug('00loanAccount'+loanAccount);
            System.debug('00Concurrent_Eligible_Amount__c'+loanAccount.Concurrent_Eligible_Amount__c);
            System.debug('00Pricing_Factor__c'+loanAccount.Pricing_Factor__c);
            System.debug('00Remaining_Number_of_Payments__c'+loanAccount.Remaining_Number_of_Payments__c);
            try {
                Decimal paymentAmount = (loanAccount.Concurrent_Eligible_Amount__c * loanAccount.Pricing_Factor__c) / loanAccount.Remaining_Number_of_Payments__c;
                Decimal interestRate = loanCalculatorManagerInstance.getInterestRate(
                    loanAccount.Concurrent_Eligible_Amount__c, paymentAmount, GeneralHelper.currentSystemDate,
                    GeneralHelper.getNBusinessDate(GeneralHelper.currentSystemDate, 1), (Integer) loanAccount.Remaining_Number_of_Payments__c.round(),
                    loanAccount.loan__Frequency_of_Loan_Payment__c
                );
                System.debug('00interestRate'+interestRate);
                loanAccount.Concurrent_Interest_Rate__c = interestRate;
                System.debug('00loanAccount.Concurrent_Interest_Rate__c'+loanAccount.Concurrent_Interest_Rate__c);
                clContractDBInstance.addUpdate(loanAccount);
            } catch(Exception e){
                Error_Log__c errorLog = ErrorLogs.createErrorLog(
                    'Concurrent Interest Rate Calculation Failed', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                    loanAccount.Id, false
                );
                System.debug('00errorLog'+errorLog);
                errorLogDBInstance.addInsert(errorLog);
            }
        }
        clContractDBInstance.executeUpdates();
        errorLogDBInstance.executeInserts();
    }
}