trigger LeadTrigger on Lead (before insert, before update, after update)
{
    if(CAN_General_Settings__c.getInstance().Disable_Lead_Trigger__c) { return; }
    if (Trigger.isInsert) {
        if(Trigger.isBefore) {
            new LeadTriggerHandler().beforeInsert(Trigger.New);
        }
    }

    if (Trigger.isUpdate) {
        if(Trigger.isBefore) {
            new LeadTriggerHandler().beforeUpdate(Trigger.New);
        }
    }

    if (Trigger.isUpdate) {
        if(Trigger.isAfter) {
            new LeadTriggerHandler().afterUpdate(Trigger.New);
        }
    }
}