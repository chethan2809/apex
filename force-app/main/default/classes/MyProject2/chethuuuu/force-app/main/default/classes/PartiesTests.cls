@isTest
private class PartiesTests {

    @isTest
    private static void createParty() {
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id contactId = TestUtility.getFakeId(Contact.getSObjectType());
        Id applicationId = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        Id partyTypeId = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());

        Test.startTest();
            clcommon__Party__c party = Parties.createParty(applicationId, accountId, contactId, partyTypeId);
        Test.stopTest();

        System.assertEquals(applicationId, party.genesis__Application__c);
        System.assertEquals(accountId, party.clcommon__Account__c);
        System.assertEquals(contactId, party.clcommon__Contact__c);
        System.assertEquals(partyTypeId, party.clcommon__Type__c);
    }

    @isTest
    private static void buildContactEmailsByApplicationId() {
        Contact contactRecord = new Contact();
        contactRecord.Email = 'contactmail@test.com';

        List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();
        clcommon__Party__c partyRecord = new clcommon__Party__c();
        partyRecord.clcommon__Contact__r = contactRecord;
        partyRecord.genesis__Application__c = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        partyList.add(partyRecord);

        Test.startTest();
            Map<Id, Set<String>> contactEmailsByToApplicationId = Parties.buildContactEmailsByApplicationId(partyList);
        Test.stopTest();

        System.assert(contactEmailsByToApplicationId.containsKey(partyRecord.genesis__Application__c));
    }

    @isTest
    private static void setCompetitorBankAccountFields() {
        loan__Bank_Account__c bankAccount = new loan__Bank_Account__c();
        bankAccount.loan__Bank_Name__c = 'CAN Capital';
        bankAccount.loan__Bank_Account_Number__c = '1234567890';
        bankAccount.loan__Routing_Number__c = '123456789';

        clcommon__Party__c partyRecord = new clcommon__Party__c();
        partyRecord.Competitor_Bank_Account__r = bankAccount;

        Test.startTest();
            Parties.setCompetitorBankAccountFields(partyRecord);
        Test.stopTest();

        System.assertEquals(bankAccount.loan__Bank_Name__c, partyRecord.Competitor_Bank_Account_Name__c);
    }
}