trigger LoanDisbursalTransactionTrigger on loan__Loan_Disbursal_Transaction__c (before insert, after insert, after update) {
    if (Trigger.isInsert) {
        if (Trigger.isBefore) {
            new LoanDisbursalTransactionTriggerHandler().beforeInsert(Trigger.new);
        }
        if (Trigger.isAfter) {
            new LoanDisbursalTransactionTriggerHandler().afterInsert(Trigger.newMap);
        }
    }

    if (Trigger.isUpdate) {
        if (Trigger.isAfter) {
            new LoanDisbursalTransactionTriggerHandler().afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}