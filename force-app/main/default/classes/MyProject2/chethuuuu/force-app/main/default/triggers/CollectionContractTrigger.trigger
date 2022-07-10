trigger CollectionContractTrigger on collect__Loan_Account__c (before insert, before update, after insert)
{
    if(CAN_General_Settings__c.getInstance().Disable_Collection_Contract_Trigger__c) {
        return;
    }

    if (Trigger.isInsert) {
        if (Trigger.isBefore) {
            new CollectionContractTriggerHandler().beforeInsert(Trigger.new);
        }
    }

    if (Trigger.isUpdate) {
        if (Trigger.isBefore) {
            new CollectionContractTriggerHandler().beforeUpdate(Trigger.new);
        }
    }

    if (Trigger.isInsert) {
        if (Trigger.isAfter) {
            new CollectionContractTriggerHandler().afterInsert(Trigger.newMap);
        }
    }
}