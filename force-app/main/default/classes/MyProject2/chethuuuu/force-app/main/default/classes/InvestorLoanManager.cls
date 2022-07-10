public class InvestorLoanManager {

    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    @TestVisible
    private static LoanDisbursalTransactionsDB loanDisbursalTransactionsDBInstance = new LoanDisbursalTransactionsDB();
    @future
    public static void createInvestorLoans(Set<Id> loanDisbursalTransactionIds) {
        List<loan__Loan_Disbursal_Transaction__c> loanDisbursalTransactionList = loanDisbursalTransactionsDBInstance.getLoanDisbursalTransactionsByIds(
            loanDisbursalTransactionIds
        );
        List<loan__Investor_Loan__c> investorLoanForInsert = new List<loan__Investor_Loan__c>();
        for(loan__Loan_Disbursal_Transaction__c loanDisbursalTransaction : loanDisbursalTransactionList) {
            if(loanDisbursalTransaction.Investor_Account__c != null) {
                loan__Investor_Loan__c investorLoan = new loan__Investor_Loan__c();
                investorLoan.loan__Investment_Amount__c = loanDisbursalTransaction.loan__Disbursed_Amt__c;
                investorLoan.loan__Loan__c = loanDisbursalTransaction.loan__Loan_Account__c;
                investorLoan.loan__Account__c = loanDisbursalTransaction.Investor_Account__c;
                investorLoan.loan__Certificate_Rate__c = loanDisbursalTransaction.loan__Loan_Account__r.loan__Interest_Rate__c;
                investorLoan.loan__Service_Rate__c = loanDisbursalTransaction.Investor_Account__r.loan__Service_Rate_On_Investment__c;
                investorLoan.loan__Collect_Service_Fees_On__c = loanDisbursalTransaction.Investor_Account__r.loan__Collect_Service_Fees_on__c;
                investorLoan.loan__Inv_Last_Interest_Accrual_Post_Date__c = loanDisbursalTransaction.loan__Disbursal_Date__c;
                investorLoan.Loan_Disbursal_Transaction__c = loanDisbursalTransaction.Id;
                investorLoanForInsert.add(investorLoan);
            }
        }

        if(!investorLoanForInsert.isEmpty()) {
            try {
                loan.InvestorAPI investorAPIInstance = loan.APIFactory.getInvestorAPI();
                investorAPIInstance.createInvestmentOrders(investorLoanForInsert);
            } catch (Exception e) {
                Error_Log__c errorLog = ErrorLogs.createErrorLog(
                    'Investor Loan Creation On Disbursal', e.getMessage() + e.getStackTraceString(), JSON.serialize(investorLoanForInsert), null,
                    ErrorLogs.ERROR, null, false
                );
                errorLogDBInstance.addInsert(errorLog);
            }
            errorLogDBInstance.executeInserts();
        }
    }
}