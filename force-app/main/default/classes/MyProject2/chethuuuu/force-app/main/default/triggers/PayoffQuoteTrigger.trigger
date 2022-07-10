trigger PayoffQuoteTrigger on loan__Payoff_Quote__c (before insert) {
    if (Trigger.isInsert) {
        if(Trigger.isBefore) {
            new PayoffQuoteTriggerHandler().beforeInsert(Trigger.new);
        }
    }
}