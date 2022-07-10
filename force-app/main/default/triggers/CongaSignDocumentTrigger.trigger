trigger CongaSignDocumentTrigger on APXT_CongaSign__Document__c (before insert, after insert, before update, after update) {

    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    try {
        if (Trigger.isInsert) {
            if (Trigger.isBefore) {
                //new CongaSignDocumentTriggerHandler().beforeInsert(Trigger.new);
            }
            if (Trigger.isAfter) {
                new CongaSignDocumentTriggerHandler().afterInsert(Trigger.New);
            }
        }

        if (Trigger.isUpdate) {
            if (Trigger.isBefore) {
                //new CongaSignDocumentTriggerHandler().beforeUpdate(Trigger.newMap, Trigger.oldMap);
            }
            if (Trigger.isAfter) {
                //new CongaSignDocumentTriggerHandler().afterUpdate(Trigger.newMap, Trigger.oldMap);
            }
        }
    } catch(Exception e){
        Error_Log__c errorLog = ErrorLogs.createErrorLog('Conga Sign Document Trigger', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR, null, false);
        errorLogDBInstance.addInsert(errorLog).executeInserts();
    }
}