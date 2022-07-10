@isTest
private class DisclosureAcknowledgementsTests {

    @isTest
    private static void acceptDisclosureAcknowledgement() {
        Id partyId = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        Id accountId = TestUtility.getFakeId(Account.getSObjectType());
        Id disclosureDefinitionId = TestUtility.getFakeId(clcommon__Disclosure_Definition__c.getSObjectType());

        clcommon__Party__c party = new clcommon__Party__c();
        party.clcommon__Account__c = accountId;
        party.Id = partyId;
        string disclosureName = 'Test Disclosure';

        clcommon__Disclosure_Definition__c disclosureDefinition = new clcommon__Disclosure_Definition__c();
        disclosureDefinition.Id = disclosureDefinitionId;
        disclosureDefinition.clcommon__Description__c = 'Test Description';

        Map<String,clcommon__Disclosure_Definition__c> disclosureNameToObjectMap = new Map<String,clcommon__Disclosure_Definition__c>();
        disclosureNameToObjectMap.put(disclosureName, disclosureDefinition);

        Test.startTest();
            clcommon__Disclosure_Acknowledgement__c disclosureAcknowledgementObject = DisclosureAcknowledgements.acceptDisclosureAcknowledgement(party, disclosureNameToObjectMap, disclosureName);
        Test.stopTest();

        System.assert(disclosureAcknowledgementObject != null);
        System.assertEquals(accountId, disclosureAcknowledgementObject.clcommon__Account__c);
        System.assertEquals(partyId, disclosureAcknowledgementObject.Party__c);
        System.assertEquals(disclosureDefinitionId, disclosureAcknowledgementObject.clcommon__Disclosure_Definition__c);
        System.assertEquals('Test Description', disclosureAcknowledgementObject.clcommon__Description__c);
    }
}