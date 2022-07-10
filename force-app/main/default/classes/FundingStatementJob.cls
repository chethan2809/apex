public class FundingStatementJob implements Schedulable, Database.AllowsCallouts, Database.Batchable<SObject> {
    @TestVisible
    public static Origination_Settings__mdt defaultFundingStatementSetting = CustomMetaDataHelper.defaultOriginationSetting;

    public FundingStatementJob(){}

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Application__r.Owner.Name, loan__Transaction_Date__c, loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Broker_Contact__c,
                loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Broker_Contact__r.Account.Name, loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Type__c, loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Loan_Amount__c,
                loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__c, Funded_Source__c, loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__account__r.Merchant_ID__c,
                loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__account__r.Name, loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Name, loan__Distribution_Amount__c, loan__Loan_Disbursal_Transaction__r.loan__Mode_of_Payment__r.name, loan__Reversed__c,
                loan__Payment_Mode__r.Name, loan__Loan_Disbursal_Transaction__r.loan__Disbursed_Amt__c, loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Loan_Status__c
            FROM loan__Disbursal_Txn_Distribution__c
            WHERE loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Invalid_Data__c = false
                AND loan__Transaction_Date__c = :GeneralHelper.currentSystemDate
                AND loan__Reversed__c = false
                AND loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.loan__Loan_Status__c != :CLContracts.LOAN_STATUS_CANCELED
            ORDER BY loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Type__c ASC
            ]);
    }

    public void execute(Database.BatchableContext bc, List<loan__Disbursal_Txn_Distribution__c> disbursalTransactionDistributionList) {
        FundingStatementManager.uploadFundingStatement(disbursalTransactionDistributionList);
    }

    public void execute(SchedulableContext sc) {
        if (defaultFundingStatementSetting.Funding_Statement_Batch_Size__c == null) {
            throw new FundingStatementJobException('Funding_Statement_Batch_Size__c is null');
        }
        Database.executeBatch(this, Integer.ValueOf(defaultFundingStatementSetting.Funding_Statement_Batch_Size__c));
    }

    public static void execute() {
        FundingStatementJob fundingStatementJobInstance = new FundingStatementJob();
        fundingStatementJobInstance.execute(null);
    }

    public void finish(Database.BatchableContext bc) {

    }

    private class FundingStatementJobException extends Exception {}

}