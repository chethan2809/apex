trigger CLContractTrigger on loan__Loan_Account__c (before insert, after insert , before update, after update) {
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    try {
        if (Trigger.isInsert) {
            if (Trigger.isBefore) {
                new CLContractTriggerHandler().beforeInsert(trigger.new);
            }
            if (Trigger.isAfter) {
                new CLContractTriggerHandler().afterInsert(trigger.newMap);
            }
        }
        if (Trigger.isUpdate) {
            if (Trigger.isBefore) {
                new CLContractTriggerHandler().beforeUpdate(trigger.newMap, trigger.oldMap);
            }
            if (Trigger.isAfter) {
                new CLContractTriggerHandler().afterUpdate(trigger.newMap, trigger.oldMap);
            }
        }
    } catch (Exception e) {
        Error_Log__c errorLog = ErrorLogs.createErrorLog(
            'CLContract Trigger', e.getMessage() + e.getStackTraceString(), trigger.new.toString(), null, ErrorLogs.ERROR,
            null, false
        );
        errorLogDBInstance.addInsert(errorLog);
    }

    errorLogDBInstance.executeInserts();
}