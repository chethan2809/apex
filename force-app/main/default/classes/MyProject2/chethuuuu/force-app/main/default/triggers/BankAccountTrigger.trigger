trigger BankAccountTrigger on loan__Bank_Account__c (after insert) {
    if (Trigger.isInsert) {
        if (Trigger.isAfter) {
            new BankAccountTriggerHandler().afterInsert(Trigger.newMap);
        }
    }
}