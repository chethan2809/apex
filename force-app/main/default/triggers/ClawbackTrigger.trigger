trigger ClawbackTrigger on Clawback__c (before insert, after insert , before update, after update)
{
    if (Trigger.isInsert)
    {
        if (Trigger.isAfter)
        {
            new ClawbackTriggerHandler().afterInsert(trigger.newMap);
        }
    }
}