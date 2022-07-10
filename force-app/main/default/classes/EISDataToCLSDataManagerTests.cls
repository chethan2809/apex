@isTest
private class EISDataToCLSDataManagerTests
{
    @isTest
    private static void convertToCLSDataModelTest()
    {
        Account accountRecord = new Account();
        accountRecord.Id = TestUtility.getFakeId(Account.getSObjectType());
        accountRecord.Name = 'Opp EIS Account Test';
        accountRecord.Sic = '23';
        accountRecord.SicDesc = 'APPAREL, FINISHED PRDCTS FROM FABRICS & SIMILAR MATERIALS';
        accountRecord.Business_Tax_ID__c = '075898984';
        accountRecord.Type = 'Borrower';
        accountRecord.Legacy_Renewal_Eligible__c = true;
        accountRecord.Legacy_Renewal_Application_Created_Date__c = null;
        accountRecord.Migrated_Date__c = Date.newInstance(2021, 1, 1);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{accountRecord};
        EISDataToCLSDataManager.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Contact contactRecord = new Contact();
        contactRecord.Id = TestUtility.getFakeId(Contact.getSObjectType());
        contactRecord.FirstName = 'Opp EIS';
        contactRecord.LastName = 'Contact Opp Test';
        contactRecord.loan__Contact_Type__c = 'Guarantor';
        contactRecord.AccountId = accountRecord.Id;

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{contactRecord};
        EISDataToCLSDataManager.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        DBManagerTestsStub clCommonRelationship1DBStubInstance = new DBManagerTestsStub();
        EISDataToCLSDataManager.clCommonRelationshipDBInstance = (CLCommonRelationshipDB) Test.createStub(CLCommonRelationshipDB.class, clCommonRelationship1DBStubInstance);

        EISDataToCLSDataManager.convertToCLSDataModel(accountRecord);
    }
}