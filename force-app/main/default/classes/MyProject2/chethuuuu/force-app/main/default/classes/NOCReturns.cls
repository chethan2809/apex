public class NOCReturns {
    public final static String LOAN_NAME_TYPE = 'LAI';
    public final static String LOAN_NAME_TYPE_IDENTIFIER = '6';
    public final static String RETURN_ROW_IDENTIFIER = '798';

    public static void parseNOCReturns(List<String> nocContentList , Map<String, String> last7DigitLPTAndNOCCodeByLoanName) {
        String loanName;
        System.debug('00nocContentList'+nocContentList);
        for (String nocContentRow : nocContentList) {
            if(nocContentRow.StartsWith(LOAN_NAME_TYPE_IDENTIFIER)) {
                String loanNameRow = nocContentRow.split('\\s+').get(1);
                String accountNameRow = nocContentRow.split('\\s++').get(2);
                System.debug('00loanNameRow'+loanNameRow);
                System.debug('00accountNameRow'+accountNameRow);
                loanName = 'LAI-' + loanNameRow.substringAfter(LOAN_NAME_TYPE + '0');
                System.debug('00loanName'+loanName);
                last7DigitLPTAndNOCCodeByLoanName.put(loanName, null);
            }
            if(nocContentRow.StartsWith(RETURN_ROW_IDENTIFIER)) {
                String returnDetail = nocContentRow.split('\\s+').get(0);
                String nocCode = returnDetail.substringAfter(RETURN_ROW_IDENTIFIER).left(3);
                String paymentTxnName = returnDetail.right(7);
                last7DigitLPTAndNOCCodeByLoanName.put(loanName, nocCode + paymentTxnName);
            }
            System.debug('00last7DigitLPTAndNOCCodeByLoanName'+last7DigitLPTAndNOCCodeByLoanName);
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