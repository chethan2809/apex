public class Parties {

    public static clcommon__Party__c createParty(Id applicationId, Id accountId, Id contactId, Id partyTypeId) {
        clcommon__Party__c party = new clcommon__Party__c();
        party.genesis__Application__c = applicationId;
        party.clcommon__Account__c = accountId;
        party.clcommon__Contact__c = contactId;
        party.clcommon__Type__c = partyTypeId;
        return party;
    }

    public static Map<Id, Set<String>> buildContactEmailsByApplicationId(List<clcommon__Party__c> partyList) {
        Map<Id, Set<String>> contactEmailsByToApplicationId = new Map<Id, Set<String>>();
        for(clcommon__Party__c party : partyList) {
            if(contactEmailsByToApplicationId.containsKey(party.genesis__Application__c)) {
                contactEmailsByToApplicationId.get(party.genesis__Application__c).add(party.clcommon__Contact__r.Email);
            } else {
                contactEmailsByToApplicationId.put(party.genesis__Application__c, new Set<String> {party.clcommon__Contact__r.Email});
            }
        }
        return contactEmailsByToApplicationId;
    }

    public static void setCompetitorBankAccountFields(clcommon__Party__c party) {
        party.Competitor_Bank_Account_Name__c = party.Competitor_Bank_Account__r.loan__Bank_Name__c;
        party.Competitor_Bank_Account_Number__c = party.Competitor_Bank_Account__r.loan__Bank_Account_Number__c;
        party.Competitor_Bank_Routing_Number__c = party.Competitor_Bank_Account__r.loan__Routing_Number__c;
    }
}