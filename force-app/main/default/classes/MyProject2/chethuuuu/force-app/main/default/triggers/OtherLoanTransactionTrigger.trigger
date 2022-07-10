trigger OtherLoanTransactionTrigger on loan__Other_Transaction__c (before insert) {
    if (Trigger.isInsert) {
        if (Trigger.isBefore) {
            new OtherLoanTransactionTriggerHandler().beforeInsert(Trigger.new);
        }
    }
}