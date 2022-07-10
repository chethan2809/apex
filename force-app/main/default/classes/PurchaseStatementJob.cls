public class PurchaseStatementJob implements Schedulable, Database.AllowsCallouts, Database.Batchable<SObject> {
    @TestVisible
    public static Origination_Settings__mdt defaultPurchaseStatementSetting = CustomMetaDataHelper.defaultOriginationSetting;

    public PurchaseStatementJob(){}

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date currentSystemDate = GeneralHelper.currentSystemDate;
        return Database.getQueryLocator([
            SELECT Id, loan__Loan_Account__c, Name, loan__Loan_Account__r.Name, With_WebBank__c, loan__Loan_Account__r.loan__Contract_Type__c,
                loan__Disbursal_Date__c, loan__Loan_Account__r.Origination_Fee__c, loan__Loan_Account__r.loan__APR__c,
                loan__Loan_Account__r.loan__Disbursed_Amount__c,
                loan__Loan_Account__r.loan__Payment_Amount__c, Purchased__c, loan__Loan_Account__r.loan__Number_of_Installments__c,
                loan__Loan_Account__r.loan__Total_Amount_Paid__c, loan__Loan_Account__r.loan__Principal_Paid__c,
                loan__Loan_Account__r.loan__Principal_Remaining__c, loan__Loan_Account__r.loan__Interest_Accrued_Not_Due__c,
                loan__Loan_Account__r.loan__Interest_Rate__c, loan__Loan_Account__r.loan__Interest_Remaining__c,
                loan__Loan_Account__r.loan__Interest_Paid__c, loan__Loan_Account__r.loan__Total_Interest_Amortization_Based__c,
                loan__Loan_Account__r.loan__Frequency_of_Loan_Payment__c, Repurchase_Date__c, loan__Disbursed_Amt__c,
                loan__Loan_Account__r.Pricing_Factor__c, loan__Loan_Account__r.loan__Last_Installment_Date__c,
                loan__Loan_Account__r.Origination_Fee_Percentage__c, Actual_Disbursed_Amount__c,
                (
                    SELECT  Id, Loan_Disbursal_Transaction__c, loan__Principal_Amount_Paid__c, loan__Remaining_Investment_Amount__c,
                        loan__Total_Amount_Paid__c, loan__Inv_Accrued_Interest_Amt__c, loan__Interest_Amount_Paid__c,
                        loan__Inv_Interest_Posted_Amt__c
                    FROM Investment_Orders__r
                )
            FROM loan__Loan_Disbursal_Transaction__c
            WHERE loan__Loan_Account__r.loan__Invalid_Data__c = false
                AND Repurchase_Date__c <= :currentSystemDate
                AND Purchased__c = false
            ]);
    }

    public void execute(Database.BatchableContext bc, List<loan__Loan_Disbursal_Transaction__c> loanDisbursalTransactionList) {
        PurchaseStatementManager.uploadPurchaseStatement(loanDisbursalTransactionList);
    }

    public void execute(SchedulableContext sc) {
        if (defaultPurchaseStatementSetting.Purchase_Statement_Batch_Size__c == null) {
            throw new PurchaseStatementJobException('Purchase_Statement_Batch_Size__c is null');
        }
        Database.executeBatch(this, Integer.ValueOf(defaultPurchaseStatementSetting.Purchase_Statement_Batch_Size__c));
    }

    public static void execute() {
        PurchaseStatementJob purchaseStatementJobInstance = new PurchaseStatementJob();
        purchaseStatementJobInstance.execute(null);
    }

    public void finish(Database.BatchableContext bc) {

    }

    private class PurchaseStatementJobException extends Exception {}

}