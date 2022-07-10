public class RepaymentTransactionReversals {
    private static EmailDB emailDBInstance = new EmailDB();

    public static final String REPAYMENT_TRANSACTION_REVERSAL_NOTIFICATION = 'Repayment_Transaction_Reversal_Notification';

    public static void buildReversalTransactionEmailContent(List<loan__Repayment_Transaction_Adjustment__c> reversalTransactionList, EmailTemplate loanReversalTransactionTemplate){
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(loan__Repayment_Transaction_Adjustment__c reversalTransaction :reversalTransactionList) {

            String body = loanReversalTransactionTemplate.HtmlValue;
            body = body.replace('{{CONTACT_NAME}}', String.valueOf(reversalTransaction.loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.loan__Contact__r.Name));
            body = body.replace('{{TRANSACTION_DATE}}', String.valueOf(reversalTransaction.loan__Adjustment_Txn_Date__c));
            body = body.replace('{{TRANSACTION_AMOUNT}}', String.valueOf(reversalTransaction.loan__Loan_Payment_Transaction__r.loan__Transaction_Amount__c));
            body = body.replace('{{CAN_CAPITAL_EMPLOYEE_NAME}}', (String.valueOf(reversalTransaction.loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Application__r.Owner.FirstName) +
                String.valueOf(reversalTransaction.loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Application__r.Owner.LastName)));
            body = body.replace('{{CAN_CAPITAL_EMPLOYEE_TITLE}}', String.valueOf(reversalTransaction.loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Application__r.Owner.Title));
            body = body.replace('{{CAN_CAPITAL_EMPLOYEE_EMAIL}}', String.valueOf(reversalTransaction.loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Application__r.Owner.Email));
            body = body.replace('{{CAN_CAPITAL_EMPLOYEE_PHONE}}', String.valueOf(reversalTransaction.loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Application__r.Owner.Phone));

            String subject = loanReversalTransactionTemplate.Subject;
            List<String> toAddresses = new List<String>();
            toAddresses.add(reversalTransaction.loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.loan__Contact__r.Email);
            Messaging.SingleEmailMessage email = Emails.getEmailMessageSetup(
                toAddresses, CustomMetaDataHelper.defaultGeneralSetting.From_Email__c , subject, body, true, null
            );

            emailList.add(email);

        }

        emailDBInstance.sendBulkEmail(emailList);

    }
}