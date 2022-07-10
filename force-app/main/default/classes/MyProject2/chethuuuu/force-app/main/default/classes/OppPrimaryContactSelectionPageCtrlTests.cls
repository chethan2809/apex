@isTest
private class OppPrimaryContactSelectionPageCtrlTests {

    @isTest
    private static void getContactsByOpportunityIdsTest() {

        Account newAccount = new Account();
        newAccount.Id = TestUtility.getFakeId(Account.getSObjectType());

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.AccountId = newAccount.Id;

        TestUtility.runSetupData();
        Opportunity opportunityRecord = TestUtility.createOpportunity();

        Account accountRecord = [
            SELECT Id
            FROM Account WHERE Id =:opportunityRecord.AccountId
            LIMIT 1
        ];

        List<Opportunity> opportunityNewRecord = [
            SELECT Id, AccountId
            FROM Opportunity WHERE Id =: opportunityRecord.Id
        ];

        AccountContactRelation accountContactRelationRecord = new AccountContactRelation();
        accountContactRelationRecord.AccountId = accountRecord.Id;
        accountContactRelationRecord.contactId = contactRecord.Id;

        DBManagerTestsStub accountContactRelationDBStubInstance = new DBManagerTestsStub();
        accountContactRelationDBStubInstance.genericReturnObject = new List<AccountContactRelation> {accountContactRelationRecord};
        oppPrimaryContactSelectionPageCtrl.AccountContactRelationDBInstance = (AccountContactRelationDB) Test.createStub(AccountContactRelationDB.class, accountContactRelationDBStubInstance);

        DBManagerTestsStub opportunityDBInstance = new DBManagerTestsStub();
        opportunityDBInstance.genericReturnObject = new List<Opportunity> {opportunityRecord};
        oppPrimaryContactSelectionPageCtrl.opportunityDBInstance = (OpportunityDB) Test.createStub(OpportunityDB.class, opportunityDBInstance);

        DBManagerTestsStub accountDBInstance = new DBManagerTestsStub();
        accountDBInstance.genericReturnObject = new List<Account>{newAccount};
        oppPrimaryContactSelectionPageCtrl.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBInstance);

        DBManagerTestsStub contactDBInstance = new DBManagerTestsStub();
		contactDBInstance.genericReturnObject = new List<Contact>{contactRecord};
		oppPrimaryContactSelectionPageCtrl.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        oppPrimaryContactSelectionPageCtrl.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Exception ex;

        System.Test.startTest();
            try {
                List<Contact> contactList = oppPrimaryContactSelectionPageCtrl.getContactsByOpportunityIds(opportunityRecord.Id);
            }
            catch(Exception e) {
                ex = e;
            }
        System.Test.stopTest();

        TestUtility.assertNullException(ex);
    }

    @isTest
    private static void getContactsByOpportunityIdsExceptionTest() {

       Account newAccount = new Account();
       newAccount.Id = TestUtility.getFakeId(Account.getSObjectType());

        TestUtility.runSetupData();
        Opportunity opportunityRecord = TestUtility.createOpportunity();
        System.debug('C10'+opportunityRecord);

        DBManagerTestsStub accountDBInstance = new DBManagerTestsStub();
        accountDBInstance.genericReturnObject = new List<Account>{newAccount};
        oppPrimaryContactSelectionPageCtrl.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBInstance);

        List<Opportunity> opportunityNewRecord = [
            SELECT Id, AccountId
            FROM Opportunity WHERE Id =: opportunityRecord.Id
        ];

        DBManagerTestsStub opportunityDBInstance = new DBManagerTestsStub();
        opportunityDBInstance.genericReturnObject = new List<Opportunity> {opportunityRecord};
        oppPrimaryContactSelectionPageCtrl.opportunityDBInstance = (OpportunityDB) Test.createStub(OpportunityDB.class, opportunityDBInstance);

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        oppPrimaryContactSelectionPageCtrl.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        Exception ex;

        Test.startTest();

        try {
            List<Contact> contactList = oppPrimaryContactSelectionPageCtrl.getContactsByOpportunityIds(opportunityRecord.Id);
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();

        System.assertEquals(ex.getMessage(), 'There was no Contact found with Id {}');
    }
}