public class RepaymentTransactionReversalManager {

    private static EmailTemplateDB emailTemplateDBInstance = new EmailTemplateDB();

    public static void sendReversalTransactionNotification(Set<Id> reversalTransactionIds) {
        List<loan__Repayment_Transaction_Adjustment__c> reversalTransactionsToSendEmail = LoanRepaymentTransactionReversalDB.getReversalTransactionListByIds(reversalTransactionIds);
        List<EmailTemplate> templates = emailTemplateDBInstance.getTemplatesByName(new Set<String>{RepaymentTransactionReversals.REPAYMENT_TRANSACTION_REVERSAL_NOTIFICATION});

        RepaymentTransactionReversals.buildReversalTransactionEmailContent(reversalTransactionsToSendEmail, templates.get(0));

    }
}