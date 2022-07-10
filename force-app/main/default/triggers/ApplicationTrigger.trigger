trigger ApplicationTrigger on genesis__Applications__c(
    before insert, after insert, before update, after update
) {
    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    try {
        if (Trigger.isInsert) {
            if (Trigger.isBefore) {
                new ApplicationTriggerHandler().beforeInsert(Trigger.new);
            }
            if (Trigger.isAfter) {
                new ApplicationTriggerHandler().afterInsert(Trigger.newMap);
            }
        }
        if (Trigger.isUpdate) {
            if (Trigger.isBefore) {
                new ApplicationTriggerHandler().beforeUpdate(Trigger.newMap, Trigger.oldMap);
            }
            if (Trigger.isAfter) {
                new ApplicationTriggerHandler().afterUpdate(Trigger.newMap, Trigger.oldMap);
            }
        }
    } catch (Exception e) {
        Error_Log__c errorLog = ErrorLogs.createErrorLog('Application DML Exception', e.getMessage() + e.getStackTraceString(), String.valueOf(Trigger.new), null, ErrorLogs.ERROR, null, false);
        errorLogDBInstance.addInsert(errorLog).executeInserts();
    }
}