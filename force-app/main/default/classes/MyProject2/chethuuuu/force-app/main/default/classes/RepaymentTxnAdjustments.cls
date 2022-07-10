public class RepaymentTxnAdjustments {

    public static final String REPAYMENT_TRANSACTION_ADJUSTMENT_NOTIFICATION = 'Repayment_Txn_Adjustment_Notification';
    public static final Set<String> REVERSAL_REASON_CODES = new Set<String> {'R01', 'R09'};

    public static String buildEmailBodyByRepaymentTransactionDetails(loan__Repayment_Transaction_Adjustment__c reversalTransaction, String body){
        body = reversalTransaction.loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Primary_Contact__c != null
            && reversalTransaction.loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Primary_Contact__r.Name != null
            ? body.replace('{{CONTACT_NAME}}', String.valueOf(reversalTransaction.loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Primary_Contact__r.Name))
            : body.replace('{{CONTACT_NAME}}', '');

        body = reversalTransaction.loan__Adjustment_Txn_Date__c != null
            ? body.replace('{{TRANSACTION_DATE}}', String.valueOf(reversalTransaction.loan__Adjustment_Txn_Date__c))
            : body.replace('{{TRANSACTION_DATE}}', '');

        body = reversalTransaction.loan__Loan_Payment_Transaction__r.loan__Transaction_Amount__c != null
            ? body.replace('{{TRANSACTION_AMOUNT}}', String.valueOf(reversalTransaction.loan__Loan_Payment_Transaction__r.loan__Transaction_Amount__c))
            : body.replace('{{TRANSACTION_AMOUNT}}', '');
        return body;
    }

    public static String buildEmailBodyByQueContractDetails(collect__Queue_Contract__c queueContract, String body){
        body = queueContract.collect__User__c != null && queueContract.collect__Collector__c != null
            ? body.replace('{{CAN_CAPITAL_EMPLOYEE_NAME}}', String.valueOf(queueContract.collect__Collector__c))
            : body.replace('{{CAN_CAPITAL_EMPLOYEE_NAME}}', '');

        body = queueContract.collect__User__c != null && queueContract.collect__User__r.Title != null
            ? body.replace('{{CAN_CAPITAL_EMPLOYEE_TITLE}}', String.valueOf(queueContract.collect__User__r.Title))
            : body.replace('{{CAN_CAPITAL_EMPLOYEE_TITLE}}', '');

        body = queueContract.collect__User__c != null && queueContract.collect__User__r.Email != null
            ? body.replace('{{CAN_CAPITAL_EMPLOYEE_EMAIL}}', String.valueOf(queueContract.collect__User__r.Email))
            : body.replace('{{CAN_CAPITAL_EMPLOYEE_EMAIL}}', '');

        body = queueContract.collect__User__c != null && queueContract.collect__User__r.Phone != null
            ? body.replace('{{CAN_CAPITAL_EMPLOYEE_PHONE}}', String.valueOf(queueContract.collect__User__r.Phone))
            : body.replace('{{CAN_CAPITAL_EMPLOYEE_PHONE}}', '');
        return body;
    }

    public static String buildEmailBodyByDerronHardyDetails(User derronHardy, String body){
        body = derronHardy != null && (derronHardy.FirstName != null || derronHardy.LastName != null)
            ? body.replace('{{CAN_CAPITAL_EMPLOYEE_NAME}}', (String.valueOf(derronHardy.FirstName) + ' ' + String.valueOf(derronHardy.LastName)))
            : body.replace('{{CAN_CAPITAL_EMPLOYEE_NAME}}', '');

        body = derronHardy != null && derronHardy.Title != null
            ? body.replace('{{CAN_CAPITAL_EMPLOYEE_TITLE}}', String.valueOf(derronHardy.Title))
            : body.replace('{{CAN_CAPITAL_EMPLOYEE_TITLE}}', '');

        body = derronHardy != null && derronHardy.Email != null
            ? body.replace('{{CAN_CAPITAL_EMPLOYEE_EMAIL}}', String.valueOf(derronHardy.Email))
            : body.replace('{{CAN_CAPITAL_EMPLOYEE_EMAIL}}', '');

        body = derronHardy != null && derronHardy.Phone != null
            ? body.replace('{{CAN_CAPITAL_EMPLOYEE_PHONE}}', String.valueOf(derronHardy.Phone))
            : body.replace('{{CAN_CAPITAL_EMPLOYEE_PHONE}}', '');
        return body;
    }
}