@isTest
private class AccountTriggerTests{

	private static AccountDB accountDBInstance = new AccountDB();

    @isTest
     private static void accountTriggerInsertUpdate(){
        Account account = TestUtility.createAccount();
        account.Name = 'Dummy Account';
        account.Industry = 'Other';
        account.Type = GeneralConstants.PARTY_TYPE_BORROWER;
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(account.Type).getRecordTypeId();

        accountDBInstance.addUpdate(account);
        accountDBInstance.executeUpdates();

        list<Account> accountList = [
            SELECT Id, Name
            FROM Account
        ];

        System.assert(account.Id != null);
        System.assertEquals(1, accountList.size());
        System.assertEquals('Dummy Account', accountList[0].Name);
     }
}