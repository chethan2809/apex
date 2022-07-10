public class RepaymentTxnAdjustmentManager {

    @TestVisible
    private static EmailTemplateDB emailTemplateDBInstance = new EmailTemplateDB();
    @TestVisible
    private static RepaymentTxnAdjustmentDB repaymentTxnAdjustmentDBInstance = new RepaymentTxnAdjustmentDB();
    @TestVisible
    private static CLContractDB contractDBInstance = new CLContractDB();
    @TestVisible
    private static EmailDB emailDBInstance = new EmailDB();
    @TestVisible
    private static QueueContractDB queueContractDBInstance = new QueueContractDB();
    @TestVisible
    private static UserDB userDBInstance = new UserDB();
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    @TestVisible
    private static LoanPaymentTransactionDB loanPaymentTransactionDBInstance = new LoanPaymentTransactionDB();

    public static void sendReversalTransactionNotification(Set<Id> reversalTransactionIds) {
        List<loan__Repayment_Transaction_Adjustment__c> reversalTransactionsToSendEmail = repaymentTxnAdjustmentDBInstance.getReversalTransactionListByIdsAndReversalReasonCodes(reversalTransactionIds,
            RepaymentTxnAdjustments.REVERSAL_REASON_CODES);
        List<EmailTemplate> templates = emailTemplateDBInstance.getTemplatesByName(
            new Set<String>{RepaymentTxnAdjustments.REPAYMENT_TRANSACTION_ADJUSTMENT_NOTIFICATION}
        );

        buildReversalTransactionEmailContent(reversalTransactionsToSendEmail, templates.get(0));
    }

    public static void setContractFields(Map<Id, loan__Repayment_Transaction_Adjustment__c> repaymentTransactionMap) {
        Set<Id> contractIds = new Set<Id> ();

        for(loan__Repayment_Transaction_Adjustment__c repaymentTransaction : repaymentTransactionMap.values()){
            contractIds.add(repaymentTransaction.loan__Loan_Payment_Transaction__r.loan__Loan_Account__c);
        }

        Map<Id, loan__Loan_Account__c> loanAccountMap = new Map<Id, loan__Loan_Account__c>(
            contractDBInstance.getLoanAccountsByIds(contractIds)
        );

        for (loan__Repayment_Transaction_Adjustment__c repaymentTransaction : repaymentTransactionMap.values()) {
            loan__Loan_Account__c loanAccount = loanAccountMap.get(
                repaymentTransaction.loan__Loan_Payment_Transaction__r.loan__Loan_Account__c
            );

            String reasonCode = repaymentTransaction.loan__Reason_Code__c;
            loanAccount.Return_Reason_Code__c = reasonCode;
            loanAccount.Last_ACH_return_date__c = repaymentTransaction.loan__Transaction_Creation_Date__c;

            if(CustomMetaDataHelper.returnCodeByActionMapping.containsKey(reasonCode)) {
                if(CustomMetaDataHelper.returnCodeByActionMapping.get(reasonCode).Action__c == GeneralConstants.RETURNED_ACH_FEE) {
                    CLContracts.setReturnedACHFeeFields(loanAccount);
                } else if(CustomMetaDataHelper.returnCodeByActionMapping.get(reasonCode).Action__c == GeneralConstants.BLOCKED_ACCOUNT_FEE) {
                    CLContracts.setBlockedAccountFeeFields(loanAccount);
                }
            }

            contractDBInstance.addUpdate(loanAccount);
        }

        try {
            contractDBInstance.executeUpdates();
        } catch(Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'Repayment Txn Adjustment Update Loan Account', e.getMessage(), e.getStackTraceString(),
                null, 'Error', null, true
            );
            errorLogDBInstance.addInsert(errorLog);
            errorLogDBInstance.executeInserts();
        }
    }

    public static void setLoanPaymentTransactionFields(Map<Id, loan__Repayment_Transaction_Adjustment__c> repaymentTransactionMap) {

        for (loan__Repayment_Transaction_Adjustment__c repaymentTransaction : repaymentTransactionMap.values()) {
            loan__Loan_Payment_Transaction__c lpt = new loan__Loan_Payment_Transaction__c();
            lpt.Id = repaymentTransaction.loan__Loan_Payment_Transaction__c;
            lpt.loan__Reversal_Reason__c = repaymentTransaction.loan__Reason_Code__c;
            lpt.Reversed_LPT_Reference__c = repaymentTransaction.loan__Reference__c;
            loanPaymentTransactionDBInstance.addUpdate(lpt);
        }

        try {
            loanPaymentTransactionDBInstance.executeUpdates();
        } catch(Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'Repayment Txn Adjustment Update LPT', e.getMessage(), e.getStackTraceString(),
                null, 'Error', null, true
            );
            errorLogDBInstance.addInsert(errorLog);
            errorLogDBInstance.executeInserts();
        }
    }

    @TestVisible
    private static void buildReversalTransactionEmailContent(
        List<loan__Repayment_Transaction_Adjustment__c> reversalTransactionList, EmailTemplate loanReversalTransactionTemplate
    ){
        Set<String> contractNames = new Set<String> ();
        for(loan__Repayment_Transaction_Adjustment__c repaymentTransaction : reversalTransactionList){
            contractNames.add(repaymentTransaction.loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Name);
        }

        Map<Id, collect__Queue_Contract__c> queueContractMap = new Map<Id, collect__Queue_Contract__c>();
        List<collect__Queue_Contract__c> queueContractList = queueContractDBInstance.getCollectorsByLoanAccounts(contractNames);
        List<User> derronHardyUserList = userDBInstance.getDerronHardyDetailsByEmailAddress();
        User derronHardy = (derronHardyUserList.isEmpty())? null : derronHardyUserList.get(0);

        for(collect__Queue_Contract__c queueContract : queueContractList) {
            queueContractMap.put(queueContract.collect__Loan_Account_Id__c, queueContract);
        }

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(loan__Repayment_Transaction_Adjustment__c reversalTransaction :reversalTransactionList) {
            List<String> ccAddresses = new List<String>();
            String body = loanReversalTransactionTemplate.HtmlValue;
            collect__Queue_Contract__c queueContract = queueContractMap.get(
                reversalTransaction.loan__Loan_Payment_Transaction__r.loan__Loan_Account__c
            );

            body = RepaymentTxnAdjustments.buildEmailBodyByRepaymentTransactionDetails(reversalTransaction, body);
            if(queueContract != null) {
                if(queueContract.collect__User__c != null && queueContract.collect__User__r.Email != null) {
                    ccAddresses.add(queueContract.collect__User__r.Email);
                }
                body = RepaymentTxnAdjustments.buildEmailBodyByQueContractDetails(queueContract, body);
            }
            else {
                if(derronHardy != null && derronHardy.Email != null) {
                    ccAddresses.add(derronHardy.Email);
                }
                body = RepaymentTxnAdjustments.buildEmailBodyByDerronHardyDetails(derronHardy, body);
            }

            String subject = loanReversalTransactionTemplate.Subject;
            List<String> toAddresses = new List<String>();
            toAddresses.add(reversalTransaction.loan__Loan_Payment_Transaction__r.loan__Loan_Account__r.Primary_Contact__r.Email);

            OrgWideEmailAddress orgWideAddress = GeneralHelper.orgWideEmailAddressByEmail.get(PortalConstants.CAN_CUSTOMER_SERVICE_EMAIL_ADDRESS);

            Messaging.SingleEmailMessage email = Emails.getEmailMessageSetup(
                toAddresses, ccAddresses, CustomMetaDataHelper.defaultGeneralSetting.From_Email__c, subject, body, true, null, orgWideAddress
            );

            emailList.add(email);
        }

        try {
            emailDBInstance.sendBulkEmail(emailList);
        } catch(Exception e){
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'Returned payment notification Failed', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                null, false
            );
            errorLogDBInstance.addInsert(errorLog);
            errorLogDBInstance.executeInserts();
        }
    }
}