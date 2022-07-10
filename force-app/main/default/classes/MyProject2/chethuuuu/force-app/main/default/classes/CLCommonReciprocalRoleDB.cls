public class CLCommonReciprocalRoleDB extends DBManager
{
    public List<clcommon__Reciprocal_Role__c> getCLCommonRelationship(Set<String> relationshipName)
    {
        return [
            SELECT Id, Name
            FROM clcommon__Reciprocal_Role__c
            WHERE Name IN :relationshipName
        ];
    }

    public List<clcommon__Reciprocal_Role__c> getAllCLCommonRelationship() {
        return [
            SELECT Id, Name
            FROM clcommon__Reciprocal_Role__c
        ];
    }
}