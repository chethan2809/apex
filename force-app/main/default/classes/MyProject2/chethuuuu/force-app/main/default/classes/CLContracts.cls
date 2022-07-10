public class CLContracts {

    public static final String LOAN_STATUS_APPROVED = 'Approved';
    public static final String LOAN_STATUS_ACTIVE_GOOD_STANDING = 'Active - Good Standing';
    public static final String LOAN_STATUS_ACTIVE_BAD_STANDING = 'Active - Bad Standing';
    public static final String LOAN_STATUS_CLOSED_OBLIGATION_MET = 'Closed - Obligations met';
    public static final String LOAN_STATUS_CLOSED_WRITTEN_OFF = 'Closed- Written Off';
    public static final String LOAN_STATUS_ACTIVE_MATURED = 'Active - Matured';
    public static final String LOAN_STATUS_CANCELED = 'Canceled';
    public static final String LOAN_STATUS_CLOSED_REFINANCED = 'Closed - Refinanced';
    public static final String LOAN_STATUS_PARTIAL_APPLICATION = 'Partial Application';
    public static final String LOAN_STATUS_PENDING_APPROVAL = 'Pending Approval';
    public static final String LOAN_STATUS_PREMATURE_CLOSURE_INITIATED = 'Premature Closure Initiated';
    public static final Set<String> LOAN_GOOD_AND_BAD_STATUSES = new Set<String> {
        'Active - Good Standing', 'Active - Bad Standing'
    };
    public static final Set<String> LOAN_ACTIVE_STATUSES = new Set<String> {
        'Active - Good Standing', 'Active - Bad Standing', 'Active - Matured'
    };
    public static final Set<String> LOAN_CLOSED_STATUSES = new Set<String> {
        'Closed - Obligations met', 'Closed- Written Off'
    };
    public static final Set<String> LOAN_CANCELED_STATUSES = new Set<String> {
        'Closed - Obligations met', 'Canceled'
    };
    public static final Set<String> LOAN_RENEWAL_ELIGIBLE_STATUSES = new Set<String> {
        'Active - Good Standing', 'Active - Bad Standing', 'Active - Matured',
        'Closed - Obligations met'
    };
    public static final Set<String> LOAN_ACTIVE_AND_CLOSED_OBLIGATION_MET_STATUSES = new Set<String> {
        'Active - Good Standing', 'Active - Bad Standing', 'Active - Matured',
        'Closed - Obligations met'
    };

    public static void setLoanAccountFieldsOnInsert(loan__Loan_Account__c loanAccount) {
        loanAccount.loan__Loan_Status__c = LOAN_STATUS_APPROVED;
        loanAccount.loan__Auto_Create_Excess_Transaction__c = false;
    }

    public static void setLatestMissedPaymentDate(
        loan__Loan_Account__c loanAccount, List<loan__Loan_Account__c> contractsForUpdate
    ) {
        Decimal numberOfMissedPayments = 0.00;
        if(loanAccount.loan__Previous_Installment_Date__c != null && loanAccount.loan__Pmt_Amt_Cur__c > 0) {
            if(loanAccount.loan__Previous_Installment_Date__c == GeneralHelper.currentSystemDate
                && loanAccount.Total_Unpaid_Due_Amount_To_Current__c >= loanAccount.loan__Pmt_Amt_Cur__c
            ) {
                numberOfMissedPayments = (loanAccount.Total_Unpaid_Due_Amount_To_Current__c - loanAccount.loan__Pmt_Amt_Cur__c ) / loanAccount.loan__Pmt_Amt_Cur__c;
            } else {
                numberOfMissedPayments = loanAccount.Total_Unpaid_Due_Amount_To_Current__c / loanAccount.loan__Pmt_Amt_Cur__c;
            }
        }

        if(loanAccount.Latest_Number_Of_Missed_Payments__c == numberOfMissedPayments) {
            return;
        }

        Decimal oldMissedPayments = loanAccount.Latest_Number_Of_Missed_Payments__c == null? 0.00 : loanAccount.Latest_Number_Of_Missed_Payments__c;
        loan__Loan_Account__c loanAccountShell = new loan__Loan_Account__c(Id = loanAccount.Id);
        loanAccountShell.Latest_Number_Of_Missed_Payments__c = numberOfMissedPayments;
        loanAccountShell.Max_Number_Of_Missed_Payments__c = loanAccount.Max_Number_Of_Missed_Payments__c == null? 0.00 : loanAccount.Max_Number_Of_Missed_Payments__c;

        if(numberOfMissedPayments > loanAccountShell.Max_Number_Of_Missed_Payments__c) {
            loanAccountShell.Max_Number_Of_Missed_Payments__c += numberOfMissedPayments - loanAccountShell.Max_Number_Of_Missed_Payments__c;
        }

        if(loanAccountShell.Latest_Number_Of_Missed_Payments__c > 0
            && loanAccountShell.Latest_Number_Of_Missed_Payments__c > oldMissedPayments
            && ((loanAccount.loan__Frequency_of_Loan_Payment__c.equalsIgnoreCase(GeneralConstants.FREQUENCY_DAILY)
                    && loanAccountShell.Latest_Number_Of_Missed_Payments__c > 5)
                || (loanAccount.loan__Frequency_of_Loan_Payment__c.equalsIgnoreCase(GeneralConstants.FREQUENCY_WEEKLY)
                    && loanAccountShell.Latest_Number_Of_Missed_Payments__c >= 1
                )
            )
        ) {
            loanAccountShell.Latest_Missed_Payment_Date__c = GeneralHelper.currentSystemDate;
        }
        contractsForUpdate.add(loanAccountShell);
    }

    public static void setReturnedACHFeeFields(loan__Loan_Account__c loanAccount) {
        Date currentSystemDate = GeneralHelper.currentSystemDate;
        if(loanAccount.Return_ACH_Fee_Applied_Date__c != null
            && loanAccount.Return_ACH_Fee_Applied_Date__c.monthsBetween(currentSystemDate) == 0
            && loanAccount.Return_ACH_Fee_Count__c < 3
        ) {
            loanAccount.Return_ACH_Fee_Count__c++;
            loanAccount.Return_ACH_Fee_Applied_Date__c = currentSystemDate;
        } else if(loanAccount.Return_ACH_Fee_Applied_Date__c == null
            || (loanAccount.Return_ACH_Fee_Applied_Date__c != null
                && loanAccount.Return_ACH_Fee_Applied_Date__c.monthsBetween(currentSystemDate) != 0
            )
        ) {
            loanAccount.Return_ACH_Fee_Count__c = 1;
            loanAccount.Return_ACH_Fee_Applied_Date__c = currentSystemDate;
        }
    }

    public static void setBlockedAccountFeeFields(loan__Loan_Account__c loanAccount) {
        Date currentSystemDate = GeneralHelper.currentSystemDate;
        if(loanAccount.Return_Blocked_Account_Fee_Applied_Date__c != null
            && loanAccount.Return_Blocked_Account_Fee_Applied_Date__c.monthsBetween(currentSystemDate) == 0
            && loanAccount.Return_Blocked_Account_Fee_Count__c < 1
        ) {
            loanAccount.Return_Blocked_Account_Fee_Count__c++;
            loanAccount.Return_Blocked_Account_Fee_Applied_Date__c = currentSystemDate;
        } else if(loanAccount.Return_Blocked_Account_Fee_Applied_Date__c == null
            || (
                loanAccount.Return_Blocked_Account_Fee_Applied_Date__c != null
                    && loanAccount.Return_Blocked_Account_Fee_Applied_Date__c.monthsBetween(currentSystemDate) != 0
                )
            ) {
            loanAccount.Return_Blocked_Account_Fee_Count__c = 1;
            loanAccount.Return_Blocked_Account_Fee_Applied_Date__c = currentSystemDate;
        }
    }

    public static Boolean isClosed(loan__Loan_Account__c loanAccount, loan__Loan_Account__c oldLoanAccount) {
        return (
            oldLoanAccount.loan__Loan_Status__c != loanAccount.loan__Loan_Status__c
            && LOAN_CLOSED_STATUSES.contains(loanAccount.loan__Loan_Status__c)
        );
    }

    public static Boolean isCanceledWithinTenDays(loan__Loan_Account__c loanAccount, loan__Loan_Account__c oldLoanAccount) {
        return (
            oldLoanAccount.loan__Loan_Status__c != loanAccount.loan__Loan_Status__c
            && LOAN_CANCELED_STATUSES.contains(loanAccount.loan__Loan_Status__c)
            && loanAccount.loan__Disbursal_Date__c.daysBetween(loanAccount.loan__Closed_Date__c) <= 10
        );
    }


    public static Boolean isFirstDisbursed(loan__Loan_Account__c loanAccount, loan__Loan_Account__c oldLoanAccount) {
        return (
            oldLoanAccount.loan__Loan_Status__c == LOAN_STATUS_APPROVED
            && loanAccount.loan__Loan_Status__c == LOAN_STATUS_ACTIVE_GOOD_STANDING
        );
    }

    public static Boolean isRepaymentScheduleGeneratedOnFirstDisbursal(loan__Loan_Account__c loanAccount, loan__Loan_Account__c oldLoanAccount) {
        return (
            oldLoanAccount.loan__Number_of_Installments__c == null
            && loanAccount.loan__Number_of_Installments__c != null
        );
    }

    public static Boolean isConcurrentDisbursal(loan__Loan_Account__c loanAccount, loan__Loan_Account__c oldLoanAccount) {
        return (
            oldLoanAccount.loan__Disbursed_Amount__c != null
            && oldLoanAccount.loan__Disbursed_Amount__c > 0
            && oldLoanAccount.loan__Disbursed_Amount__c != loanAccount.loan__Disbursed_Amount__c
            && loanAccount.loan__Last_Transaction_Id__c != null
            && loanAccount.loan__Last_Transaction_Id__c != oldLoanAccount.loan__Last_Transaction_Id__c
            && loanAccount.loan__Last_Transaction_Type__c == 'Disbursal Transaction'
        );
    }

    public static Boolean isRepaymentScheduleGenerated(loan__Loan_Account__c loanAccount, loan__Loan_Account__c oldLoanAccount) {
        return (
            (oldLoanAccount.loan__Number_of_Installments__c != loanAccount.loan__Number_of_Installments__c
                || oldLoanAccount.loan__Pmt_Amt_Cur__c != loanAccount.loan__Pmt_Amt_Cur__c
                || oldLoanAccount.loan__Last_Installment_Date__c != loanAccount.loan__Last_Installment_Date__c
            )
            && loanAccount.loan__Number_of_Installments__c != null
            && loanAccount.loan__Pmt_Amt_Cur__c > 0
        );
    }
}