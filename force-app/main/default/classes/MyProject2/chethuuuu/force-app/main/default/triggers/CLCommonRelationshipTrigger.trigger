trigger CLCommonRelationshipTrigger on clcommon__Relationship__c (before insert)
{
    if(CAN_General_Settings__c.getInstance().Disable_CLCommon_Relationship_Trigger__c) { return; }
    if (Trigger.isInsert) {
        if(Trigger.isBefore) {
            new CLCommonRelationshipTriggerHandler().beforeInsert(Trigger.new);
        }
    }
}