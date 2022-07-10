public class StubPractiseAccountDB extends DBManager{
    public List<Account> getAccountByIds(Set<Id> accountIds) {
            return [
                SELECT Id, Name, Phone
                FROM Account
                WHERE Id IN :accountIds
            ];
    }
    public List<Account> getAllAccounts() {
            return [
                SELECT Id, Name, Phone
                FROM Account
            ];
    }
    public List<AggregateResult> getAggregateByAccountIds (Set<Id> accountIds) {
        return [
            SELECT Name, count(Id) recordCount
            FROM Account
            WHERE Id IN: accountIds
            GROUP BY Name
        ];
    }
}