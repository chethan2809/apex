trigger OFACTrigger on ofacchecker__OFAC__c (before insert) {

	if(trigger.isBefore && !OFACTriggerHandler.hasBeforeInsertRan){
        if(trigger.isInsert){
            OFACTriggerHandler.hasBeforeInsertRan = true;
            OFACTriggerHandler.beforeInsert(trigger.New);
        }
    }
}