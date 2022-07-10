public class WirePaymentTransactionJob implements Schedulable,Database.Batchable<sObject> {

    private static final String WIRE_PAYMENT_STATUS_COMPLETED = 'Completed';
    private static final String WIRE_PAYMENT_STATUS_FAILED = 'Failed';
    private static LoanPaymentTransactionDB loanPaymentTransactionDBInstance = new LoanPaymentTransactionDB();
    private static WirePaymentTransactionDB wirePaymentTransactionDBInstance = new WirePaymentTransactionDB();

    public WirePaymentTransactionJob(){}

    public Database.Querylocator start (database.BatchableContext BC ){
        return Database.getQueryLocator([
            SELECT ID,
                Loan_Account__c,
                Transaction_Amount__c,
                Transaction_Date__c
             FROM Wire_Payment_Transaction__c where Status__c = :GeneralConstants.WIRE_PAYMENT_STATUS_IN_PROGRESS
        ]);
    }

    public void execute (Database.BatchableContext BC , List<Wire_Payment_Transaction__c> wirePaymentTransactionList) {
        Id paymentModeId = ServicingHelper.paymentModeIdByName.get('Wire');

        for (Wire_Payment_Transaction__c wirePaymentTransaction :wirePaymentTransactionList) {
            loan__Loan_Payment_Transaction__c loanPaymentTransaction = LoanPaymentTransactions.createLoanPaymentTransaction(
                wirePaymentTransaction.Loan_Account__c, paymentModeId, wirePaymentTransaction.Transaction_Amount__c,
                wirePaymentTransaction.Transaction_Date__c
            );
            loanPaymentTransaction.Wire_Payment_Transaction__c = wirePaymentTransaction.Id;
            loanPaymentTransactionDBInstance.addInsert(loanPaymentTransaction);
        }

        DBManager.PartialResult partialInsertSaveResults = loanPaymentTransactionDBInstance.executePartialInserts();

        for (Database.SaveResult insertSaveResult : partialInsertSaveResults.saveResults) {
            Wire_Payment_Transaction__c wirePaymentTransactionNew = new Wire_Payment_Transaction__c();

            Integer resultIndex = partialInsertSaveResults.saveResults.indexOf(insertSaveResult);
            loan__Loan_Payment_Transaction__c lptRecord =
                (loan__Loan_Payment_Transaction__c) partialInsertSaveResults.sObjectList.get(resultIndex);
            if (insertSaveResult.isSuccess()) {
                wirePaymentTransactionNew.Id = lptRecord.Wire_Payment_Transaction__c;
                wirePaymentTransactionNew.Status__c = WIRE_PAYMENT_STATUS_COMPLETED;
            } else {
                wirePaymentTransactionNew.Id = lptRecord.Wire_Payment_Transaction__c;
                wirePaymentTransactionNew.Status__c = WIRE_PAYMENT_STATUS_FAILED;
                List<Database.Error> errors = insertSaveResult.getErrors();
                wirePaymentTransactionNew.Failed_Reason__c = ErrorLogs.constructErrorMessageFromDatabaseResult(
                    insertSaveResult.getErrors()
                );
            }
            wirePaymentTransactionDBInstance.addUpdate(wirePaymentTransactionNew);
        }

        wirePaymentTransactionDBInstance.executeUpdates();
    }

    public void execute(SchedulableContext sc) {
        Origination_Settings__mdt defaultWirePaymentSetting = CustomMetaDataHelper.defaultOriginationSetting;
        if (defaultWirePaymentSetting.Wire_Payment_Transaction_Job_Size__c == null) {
            throw new WirePaymentTransactionJobException('Wire Payment Transaction Job Size is null in Default Origination Setting');
        }
        Database.executeBatch(this, Integer.ValueOf(defaultWirePaymentSetting.Wire_Payment_Transaction_Job_Size__c));
    }

    public static void execute() {
        WirePaymentTransactionJob wirePaymentTransactionJobInstance = new WirePaymentTransactionJob();
        wirePaymentTransactionJobInstance.execute(null);
    }

    public void finish(Database.BatchableContext bc) {

    }

    private class WirePaymentTransactionJobException extends Exception {}

}