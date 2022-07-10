public class InteractionLogTriggerHandler
{
    public void beforeInsert(List<Interaction_Log__c> interactionLogsList) {
        for (Interaction_Log__c interactionLogRecord : interactionLogsList) {
            InteractionLogs.interactionLogMandatoryInformationCheck(interactionLogRecord);
        }
    }

    public void beforeUpdate(List<Interaction_Log__c> interactionLogsList) {
        for (Interaction_Log__c interactionLogRecord : interactionLogsList) {
            InteractionLogs.interactionLogMandatoryInformationCheck(interactionLogRecord);
        }
    }

    public void afterInsert(Map<Id, Interaction_Log__c> newInteractionLogMap) {
        InteractionLogManager.handleActionCode(newInteractionLogMap.values());
    }

    public void afterUpdate(Map<Id, Interaction_Log__c> newInteractionLogMap, Map<Id, Interaction_Log__c> oldInteractionLogMap) {
        InteractionLogManager.handleActionCode(newInteractionLogMap.values());
    }
}