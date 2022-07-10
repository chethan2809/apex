trigger CongaSignTransactionTrigger on APXT_CongaSign__Transaction__c(before insert, after insert, before update, after update) {
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    try {
        if (Trigger.isInsert) {
            if (Trigger.isBefore) {
                //new CongaSignTransactionTriggerHandler().beforeInsert(Trigger.new);
            }
            if (Trigger.isAfter) {
                new CongaSignTransactionTriggerHandler().afterInsert(Trigger.newMap);
            }
        }

        if (Trigger.isUpdate) {
            if (Trigger.isBefore) {
                //new CongaSignTransactionTriggerHandler().beforeUpdate(Trigger.newMap, Trigger.oldMap);
            }
            if (Trigger.isAfter) {
                new CongaSignTransactionTriggerHandler().afterUpdate(Trigger.newMap, Trigger.oldMap);
            }
        }
    } catch(Exception e){
        Error_Log__c errorLog = ErrorLogs.createErrorLog('Conga Sign Transaction Trigger', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR, null, false);
        errorLogDBInstance.addInsert(errorLog).executeInserts();
    }
}