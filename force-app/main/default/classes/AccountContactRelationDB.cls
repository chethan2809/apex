public class AccountContactRelationDB extends DBManager
{
    public List<AccountContactRelation> getAccountContactRelationByAccountIds(Set<Id> accountIds)
    {
        return [
            SELECT AccountId, ContactId, Id, IsActive, IsDirect, LastModifiedById, LastModifiedDate
            FROM AccountContactRelation
            WHERE AccountId IN :accountIds
                AND IsDirect = false
                AND IsActive = true
        ];
    }
}