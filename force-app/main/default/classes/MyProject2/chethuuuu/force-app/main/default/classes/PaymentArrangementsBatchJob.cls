public class PaymentArrangementsBatchJob implements Schedulable, Database.Batchable<sObject> {

    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    @TestVisible
    private static Origination_Settings__mdt defaultOriginationSetting = CustomMetaDataHelper.defaultOriginationSetting;

    public PaymentArrangementsBatchJob() {}

    public Database.Querylocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator
        ([
            SELECT Id, Name, Payment_Arrangement_Type__c, Payment_Mode__c,
            Promise__c, Total_Outstanding_Repayment_Amount__c, Transaction_Amount__c, Collection_Case__r.Contact__r.Email,
            Type__c, Automated_Payment_Setup__c, Amount_Type__c, Collection_Case__c, Collection_Case__r.Account__c, Collection_Case__r.CL_Contract_Id__c, Payment_Arrangement_End_Date__c
            FROM Payment_Arrangements__c
        ]);
    }

    public void execute(Database.BatchableContext bC, List<Payment_Arrangements__c> paymentArrangementsList) {
        try {
            PaymentArrangementsManager.managePaymentArrangements(paymentArrangementsList);
        } catch(Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog (
                'PaymentArrangementsBatchJob Failed', e.getMessage() + e.getStackTraceString(),
                JSON.serialize(paymentArrangementsList), paymentArrangementsList.get(0).Id, ErrorLogs.ERROR, null, false
            );
            errorLogDBInstance.addInsert(errorLog);
            errorLogDBInstance.executeInserts();
        }
    }

    public void execute(SchedulableContext sc) {
        if (defaultOriginationSetting.Payment_Arrangements_Batch_Size__c == null) {
            throw new PaymentArrangementsBatchJobException('Payment_Arrangements_Batch_Size__c is null');
        }
        Database.executeBatch(this, Integer.ValueOf(defaultOriginationSetting.Payment_Arrangements_Batch_Size__c));
    }

    public static void execute() {
        PaymentArrangementsBatchJob paymentArrangementsBatchJobInstance = new PaymentArrangementsBatchJob();
        paymentArrangementsBatchJobInstance.execute(null);
    }

    public void finish(Database.BatchableContext BC) {}

    private class PaymentArrangementsBatchJobException extends Exception {}
}