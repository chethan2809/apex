trigger RepaymentScheduleTrigger on loan__Repayment_Schedule__c (before insert, before update, after update) {
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    try{

        if (Trigger.isInsert) {

        }

        if (Trigger.isUpdate) {
            if (Trigger.isBefore) {
                RepaymentScheduleTriggerHandler.beforeUpdate(trigger.new, trigger.oldMap);
            }
            if(Trigger.isAfter) {
                //RepaymentScheduleTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
            }
        }
    } catch (Exception e) {
        errorLogDBInstance.addInsert(ErrorLogs.createErrorLog('RepaymentSchedule Trigger', e.getMessage() + e.getStackTraceString(), trigger.new.toString(), null, ErrorLogs.ERROR, null, false)).executeInserts();
    }
}