trigger LoanPaymentTransactionTrigger on loan__Loan_Payment_Transaction__c (before update, after update, after insert)
{
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    try{

        if(CAN_General_Settings__c.getInstance().Disable_Loan_Payment_Transaction_Trigger__c) {return;}
        if (Trigger.isUpdate) {
            if (Trigger.isBefore) {
                new LoanPaymentTxnTriggerHandler().beforeUpdate(Trigger.new, Trigger.oldMap);
            }

            if (Trigger.isAfter) {
                new LoanPaymentTxnTriggerHandler().afterUpdate(Trigger.newMap, Trigger.oldMap);
            }
        }

        if (Trigger.isInsert) {
            if (Trigger.isBefore) {
                new LoanPaymentTxnTriggerHandler().beforeInsert(Trigger.new);
            }
            if (Trigger.isAfter) {
                new LoanPaymentTxnTriggerHandler().afterInsert(Trigger.newMap);
            }
        }
    }catch (DmlException e) {
        errorLogDBInstance.addInsert(ErrorLogs.createErrorLog('LoanPaymentTransaction Trigger', e.getMessage() + e.getStackTraceString(), trigger.new.toString(), null, ErrorLogs.ERROR, null, false)).executeInserts();
    }
}