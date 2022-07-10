@isTest
private class CoBorrowersTests {

    @isTest
    private static void createCoBorrower() {

        clcommon__Party_Type__c partyType = new clcommon__Party_Type__c();
        partyType.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());
        partyType.Name = 'BORROWER';

        clcommon__Party__c party = new clcommon__Party__c();
        party.clcommon__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        party.clcommon__Contact__c = TestUtility.getFakeId(Contact.getSObjectType());
        party.clcommon__Type__c = partyType.Id;
        party.CL_Contract__c = TestUtility.getFakeId(loan__Loan_Account__c.getSObjectType());

        Test.startTest();
            loan__Coborrower__c coBorrower = CoBorrowers.createCoBorrower(party);
        Test.stopTest();

        System.assertEquals(party.clcommon__Account__c, coBorrower.loan__Account__c );
        System.assertEquals(party.clcommon__Contact__c, coBorrower.loan__Contact__c );
        System.assertEquals(party.CL_Contract__c, coBorrower.loan__Loan__c);
    }
}