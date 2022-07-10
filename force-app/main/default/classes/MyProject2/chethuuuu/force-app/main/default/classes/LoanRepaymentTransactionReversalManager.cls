public class LoanRepaymentTransactionReversalManager {
    public static void sendReversalTransactionNotification(Set<Id> reversalTransactionIds) {
        List<loan__Repayment_Transaction_Adjustment__c> reversalTransactionsToSendEmail = LoanRepaymentTransactionReversalDB.getReversalTransactionListByIds(reversalTransactionIds);
        //List<EmailTemplate> templates = emailTemplateDBInstance.getTemplatesByName(new Set<String>{Applications.BROKER_CREDIT_INCOMPLETE});

        //Applications.buildSTIPsIncompleteNotificationEmailContent(applicationsToSendEmail, templates.get(0));

    }
}