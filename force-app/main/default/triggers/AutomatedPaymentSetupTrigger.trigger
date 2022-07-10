trigger AutomatedPaymentSetupTrigger on loan__Automated_Payment_Setup__c (before insert,
    before update, after update) {
    if(CAN_General_Settings__c.getInstance().Disable_Automated_Payment_Setup_Trigger__c) {
        return;
    }
    if (Trigger.isInsert) {
        if(Trigger.isBefore) {
            new AutomatedPaymentSetupTriggerHandler().beforeInsert(Trigger.New);
        }
    }
    if (Trigger.isUpdate) {
        if(Trigger.isBefore) {
            new AutomatedPaymentSetupTriggerHandler().beforeUpdate(Trigger.New);
        }
    }
    if (Trigger.isUpdate) {
        if(Trigger.isAfter) {
            new AutomatedPaymentSetupTriggerHandler().afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}