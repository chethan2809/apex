public class LegalEntityDB extends DBManager
{
    public List<clcommon__Legal_Entity__c> getLegalEntity()
    {
        return [
                SELECT Id, Name
                FROM clcommon__Legal_Entity__c
            ];
    }
}