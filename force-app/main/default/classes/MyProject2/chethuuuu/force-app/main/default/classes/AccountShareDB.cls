public class AccountShareDB extends DBManager {

    public List<AccountShare> getAccountShareRecordsByLoggedInUserId(Set<Id> loggedInUserIds){
        return [
            SELECT Id,
                AccountId
            FROM AccountShare
            WHERE userOrGroupId IN :loggedInUserIds
        ];
    }
}