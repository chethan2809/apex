@IsTest
private class PartyTriggerTests {

    @isTest
    private static void partyTrigger() {

        clcommon__Party_Type__c partyType = new clcommon__Party_Type__c();
        partyType.Name = 'BORROWER';
        insert partyType;

        clcommon__Party__c party = new clcommon__Party__c();
        party.clcommon__Type__c = partyType.Id;
        party.Beneficial_Owner_Type__c = 'Control Person';
        party.Competitor_Amount__c = 2000.00;
        party.clcommon__isPrimary__c = true;

        Exception ex;
        Test.startTest();
        try {
            insert party ;
        } catch(Exception e) {
            ex = e;
        }
        Test.stopTest();

        party.Beneficial_Owner_Type__c = 'Beneficial Owner';
        update party;

        list<clcommon__Party__c> actualPartyForUpdated = [
            SELECT Id, Competitor_Amount__c, Beneficial_Owner_Type__c
            FROM clcommon__Party__c
        ];

        System.assert(party.Id != null);
        System.assertEquals(1, actualPartyForUpdated.size());
        System.assertEquals('Beneficial Owner', actualPartyForUpdated[0].Beneficial_Owner_Type__c);

        list<clcommon__Party__c> actualPartyForDelete = [
            SELECT Id, Competitor_Amount__c
            FROM clcommon__Party__c
        ];

        delete actualPartyForDelete;

        list<clcommon__Party__c> actualPartyDeleted = [
            SELECT Id, Competitor_Amount__c
            FROM clcommon__Party__c
        ];

        System.assertEquals(0, actualPartyDeleted.size());
    }
}