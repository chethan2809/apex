trigger CollectionCriteriaTrigger on Collection_Criteria__c(before insert, before update) {
    if (Trigger.isInsert) {
        if(Trigger.isBefore) {
            new CollectionCriteriaTriggerHandler().beforeInsert(Trigger.New);
        }
    }
    if (Trigger.isUpdate) {
        if(Trigger.isBefore) {
            new CollectionCriteriaTriggerHandler().beforeUpdate(Trigger.New);
        }
    }
}