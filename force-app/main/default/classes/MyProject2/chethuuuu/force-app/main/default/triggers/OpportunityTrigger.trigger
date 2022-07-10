trigger OpportunityTrigger on Opportunity (before insert, after insert, before update, after update)
{
    if(CAN_General_Settings__c.getInstance().Disable_Opportunity_Trigger__c) {
        return;
    }
    if (Trigger.isInsert) {
        if(Trigger.isBefore) {
            new OpportunityTriggerHandler().beforeInsert(Trigger.new);
        }
    }
    if (Trigger.isInsert) {
        if(Trigger.isAfter) {
            new OpportunityTriggerHandler().afterInsert(Trigger.newMap);
        }
    }
    if (Trigger.isUpdate) {
        if(Trigger.isBefore) {
            new OpportunityTriggerHandler().beforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
    if (Trigger.isUpdate) {
        if(Trigger.isAfter) {
            new OpportunityTriggerHandler().afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}