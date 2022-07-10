trigger LoanOfficeNameTrigger on loan__Office_Name__c (after update) {
    if(Trigger.isAfter) {
        if(trigger.isUpdate){
            new LoanOfficeNameTriggerHandler().afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}