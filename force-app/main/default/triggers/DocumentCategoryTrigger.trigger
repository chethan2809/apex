trigger DocumentCategoryTrigger on clcommon__Document_Category__c (after insert) {
    if (Trigger.isInsert) {
       if (Trigger.isAfter) {
           new DocumentCategoryTriggerHandler().afterInsert(Trigger.newMap);
       }
   }
}