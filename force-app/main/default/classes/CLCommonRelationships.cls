public class CLCommonRelationships
{
    public static clcommon__Relationship__c createCLCommonRelationships(Id entityId, Id relatedEntityId, Id relationshipId)
    {
        clcommon__Relationship__c relationshipRecord = new clcommon__Relationship__c();
        relationshipRecord.clcommon__Entity__c = entityId;
        relationshipRecord.clcommon__Related_Entity__c = relatedEntityId;
        relationshipRecord.clcommon__Relationship__c = relationshipId;
        return relationshipRecord;
    }
}