trigger RepaymentTxnAdjustmentTrigger on loan__Repayment_Transaction_Adjustment__c (after insert) {
    if(CAN_General_Settings__c.getInstance().Disable_Repayment_Txn_Adjustment_Trigger__c) {
        return;
    }
    if (Trigger.isInsert) {
        if (Trigger.isAfter) {
            new RepaymentTxnAdjustmentTriggerHandler().afterInsert(Trigger.newMap);
        }
    }
}