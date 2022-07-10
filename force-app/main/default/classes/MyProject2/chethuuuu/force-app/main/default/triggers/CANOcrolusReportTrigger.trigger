trigger CANOcrolusReportTrigger on CAN_Ocrolus_Report__c (before update, after update) {
    if (Trigger.isUpdate) {
        if(Trigger.isBefore) {
            new CANOcrolusReportTriggerHandler().beforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
        if(Trigger.isAfter) {
            new CANOcrolusReportTriggerHandler().afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}