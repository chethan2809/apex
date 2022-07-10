public class PartyTypeDB extends DBManager {
    public List<clcommon__Party_Type__c> getAllPartyTypes() {
        return [SELECT Id, Name FROM clcommon__Party_Type__c];
    }
}