@isTest
private class AccountContactRelationControllerTests {

    @isTest
    private static void getAccountContactRelationByAccountIdTest() {
        
         Account accountId = new Account();
         accountId.Id  = TestUtility.getFakeId(Account.getSObjectType());
         Contact newContact = new Contact();
         newContact.Id = TestUtility.getFakeId(Contact.getSObjectType());
         newContact.AccountId = accountId.Id;
        
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Id = TestUtility.getFakeId(Opportunity.getSObjectType());
        newOpportunity.AccountId = accountId.Id;
        
          Test.startTest();
            List<Contact> contactList = AccountContactRelationController.getAccountContactRelationByAccountId(newOpportunity.Id);
         Test.stopTest();
    }
}