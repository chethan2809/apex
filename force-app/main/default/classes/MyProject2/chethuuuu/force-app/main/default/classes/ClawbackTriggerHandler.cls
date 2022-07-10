public class ClawbackTriggerHandler
{
    public void afterInsert(Map<Id, Clawback__c> newClawbackMap) {
        clawbackUtil.updateTotalClawbackAmount(newClawbackMap.values());
    }
}