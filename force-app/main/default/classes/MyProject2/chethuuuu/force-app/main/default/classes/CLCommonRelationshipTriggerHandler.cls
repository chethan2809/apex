public class CLCommonRelationshipTriggerHandler
{
    public void beforeInsert(List<clcommon__Relationship__c> newRelationshipList)
    {
        for(clcommon__Relationship__c relationship : newRelationshipList) {
            if(relationship.clcommon__Related_Entity__c == null && relationship.Contact__c != null
                && relationship.Guarantor_Account_Id__c != null && relationship.Legacy_Account_External_Id__c != null) {
                relationship.clcommon__Related_Entity__c = relationship.Guarantor_Account_Id__c;
            }
        }
    }
}