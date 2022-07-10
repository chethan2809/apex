public class ACHReturns {
    public final static String LOAN_NAME_TYPE = 'LAI';
    public final static String LOAN_NAME_TYPE_IDENTIFIER = '6';
    public final static String RETURN_ROW_IDENTIFIER = '799';

    public static void parseACHReturns(List<String> achContentList , Map<String, String> last7DigitLPTAndReasonCodeByLoanName) {
        String loanName;
        for (String achContentRow : achContentList) {
            if(achContentRow.StartsWith(LOAN_NAME_TYPE_IDENTIFIER)) {
                String loanNameRow = achContentRow.split('\\s+').get(1);
                loanName = 'LAI-' + loanNameRow.substringAfter(LOAN_NAME_TYPE + '0');
                last7DigitLPTAndReasonCodeByLoanName.put(loanName, null);
            }
            if(achContentRow.StartsWith(RETURN_ROW_IDENTIFIER)) {
                String returnDetail = achContentRow.split('\\s+').get(0);
                String reasonCode = returnDetail.substringAfter(RETURN_ROW_IDENTIFIER).left(3);
                String paymentTxnName = returnDetail.right(7);
                last7DigitLPTAndReasonCodeByLoanName.put(loanName, reasonCode + paymentTxnName);
            }
        }
    }

    public static List<loan.ACHReturn> buildACHReturnList (
        List<loan__Loan_Account__c> loanAccountList, Map<String, String> last7DigitLPTAndReasonCodeByLoanName,
        List<String> csvRowValues
    ) {
        List<loan.ACHReturn> listOfAchReturns = new  List<loan.ACHReturn>();

        for(loan__Loan_Account__c loanAccount : loanAccountList) {
            if(loanAccount.loan__Loan_Payment_Transactions__r.isEmpty()) {
                csvRowValues.add(loanAccount.Name + ',There was no LPT found for Loan Account');
                continue;
            }

            loan__Loan_Payment_Transaction__c loanPaymentTxn = loanAccount.loan__Loan_Payment_Transactions__r.get(0);
            if(loanPaymentTxn.Name.right(7) == last7DigitLPTAndReasonCodeByLoanName.get(loanAccount.Name).right(7)) {
                if(loanPaymentTxn.loan__Reversed__c) {
                    String errorMessage = 'LPT is already reversed';
                    csvRowValues.add(loanAccount.Name + ',' + errorMessage);
                } else {
                    loan.ACHReturn loanACHReturn = new loan.ACHReturn();
                    loanACHReturn.payment = loanPaymentTxn;
                    loanACHReturn.returnCode = last7DigitLPTAndReasonCodeByLoanName.get(loanAccount.Name).left(3);
                    listOfAchReturns.add(loanACHReturn);
                }
            } else {
                String errorMessage = 'Latest LPT is not match with return LPT name';
                csvRowValues.add(loanAccount.Name + ',' + errorMessage);
            }
        }
        return listOfAchReturns;
    }
}