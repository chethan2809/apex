trigger UserTrigger on User (before insert, after insert) {
    if (Trigger.isInsert) {
        if (Trigger.isBefore) {
            new UserTriggerHandler().beforeInsert(Trigger.new);
        }

        if (Trigger.isAfter) {
            new UserTriggerHandler().afterInsert(Trigger.newMap);
        }
    }
}