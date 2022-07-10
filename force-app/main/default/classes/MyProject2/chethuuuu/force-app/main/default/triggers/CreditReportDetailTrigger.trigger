trigger CreditReportDetailTrigger on Credit_Report_Detail__c (before insert, before update) {

    if(Trigger.isBefore) {
        if(trigger.isInsert){
            new CreditReportDetailTriggerHandler().beforeInsert(trigger.new);
        }
        if(trigger.isUpdate){
            new CreditReportDetailTriggerHandler().beforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}