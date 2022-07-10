public class PartyManager {

    @TestVisible
    public static ApplicationDB applicationDBInstance = new ApplicationDB();
    @TestVisible
    public static UserDB userDBInstance = new userDB();
    @TestVisible
    public static PartyDB partyDBInstance = new PartyDB();

    public static void createApplicationParties(
        genesis__Applications__c application, Id borrowerAccountId, Id guarantorAccountId, Id guarantorContactId, User brokerUserRecord
    ) {

        clcommon__Party__c borrowerParty = Parties.createParty(
            application.Id, borrowerAccountId, null, OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BORROWER)
        );
        partyDBInstance.addInsert(borrowerParty);

        clcommon__Party__c guarantorParty = Parties.createParty(
            application.Id, guarantorAccountId, guarantorContactId, OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_GUARANTOR)
        );
        guarantorParty.Beneficial_Owner_Type__c = 'Both';
        partyDBInstance.addInsert(guarantorParty);

        if(brokerUserRecord != null) {
            clcommon__Party__c brokerParty = Parties.createParty(
                application.Id, brokerUserRecord.AccountId, brokerUserRecord.ContactId,
                OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_BROKER)
            );
            partyDBInstance.addInsert(brokerParty);
        }

        partyDBInstance.executeInserts();
    }

    public static void calculateTotalCompetitorAmount(Map<Id, genesis__Applications__c> applicationMap){
        for(clcommon__Party__c party : partyDBInstance.getCompetitorPartiesByApplicationIds(applicationMap.KeySet())){
            genesis__Applications__c application = applicationMap.get(party.genesis__Application__c);
            if(party.Competitor_Amount__c != null){
            	application.Total_Competitors_Amount__c += party.Competitor_Amount__c;
            }
        }
        applicationDBInstance.addUpdates(applicationMap.values()).executeUpdates();
    }

    public static void setCompetitorBankAccountFieldsInParty(Set<Id> competitorPartyIds){
        for(clcommon__Party__c party : partyDBInstance.getPartiesByIds(competitorPartyIds)){
            Parties.setCompetitorBankAccountFields(party);
            partyDBInstance.addUpdate(party);
        }
        partyDBInstance.executeUpdates();

    }

    private class PartyManagerException extends Exception {}
}