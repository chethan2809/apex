trigger PaymentArrangementsTrigger on Payment_Arrangements__c (after insert, after update) {

    if (Trigger.isUpdate) {
        if (Trigger.isAfter) {
            new PaymentArrangementsTriggerHandler().afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }

    if (Trigger.isInsert) {
        if (Trigger.isAfter) {
            new PaymentArrangementsTriggerHandler().afterInsert(Trigger.newMap);
        }
    }
}