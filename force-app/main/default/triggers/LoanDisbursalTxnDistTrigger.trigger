trigger LoanDisbursalTxnDistTrigger on loan__Disbursal_Txn_Distribution__c (before insert) {
    if (Trigger.isInsert) {
        if (Trigger.isBefore) {
            new LoanDisbursalTxnDistTriggerHandler().beforeInsert(Trigger.new);
        }
    }
}