public class AccountContactRelationManager {
    @TestVisible
    private static AccountContactRelationDB accountContactRelationDBInstance = new AccountContactRelationDB();

    public static void createAccountContactRelation(Id accountId, Id contactId) {
        AccountContactRelation accountContactRelationRecord = new AccountContactRelation();
        accountContactRelationRecord.AccountId = accountId;
        accountContactRelationRecord.ContactId = contactId;
        accountContactRelationRecord.IsActive = true;
        accountContactRelationDBInstance.addInsert(accountContactRelationRecord);
        accountContactRelationDBInstance.executeInserts();
    }
}