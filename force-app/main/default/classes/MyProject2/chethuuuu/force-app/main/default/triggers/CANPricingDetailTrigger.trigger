trigger CANPricingDetailTrigger on CAN_Pricing_Detail__c (before insert, after insert, before update) {
    if (Trigger.isInsert) {
        if (Trigger.isBefore) {
            new CANPricingDetailTriggerHandler().beforeInsert(trigger.new);
        }
        if(Trigger.isAfter) {
            new CANPricingDetailTriggerHandler().afterInsert(trigger.newMap);
        }
    }
    if (Trigger.isUpdate) {
        if (Trigger.isBefore) {
            new CANPricingDetailTriggerHandler().beforeUpdate(trigger.newMap, trigger.oldMap);
        }
    }
}