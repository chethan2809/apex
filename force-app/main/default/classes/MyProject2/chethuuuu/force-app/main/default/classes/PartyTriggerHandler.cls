public class PartyTriggerHandler {

    @TestVisible
    public static ApplicationDB applicationDBInstance = new ApplicationDB();
    @TestVisible
    private static OpportunityDB opportunityDBInstance = new OpportunityDB();
    @TestVisible
    private static CLCommonRelationshipDB clCommonRelationshipDBInstance = new CLCommonRelationshipDB();
    @TestVisible
    private static CLCommonReciprocalRoleDB clCommonReciprocalRoleDBInstance = new CLCommonReciprocalRoleDB();

    public void afterUpdate(Map<Id, clcommon__Party__c> newPartyMap, Map<Id, clcommon__Party__c> oldPartyMap) {
        Map<Id, Id> applicationIdToContactId = new Map<Id,Id>();
        Map<Id, Id> applicationIdToAccountId = new Map<Id,Id>();
        Map<Id, genesis__Applications__c> competitorPartyApplicationMap = new Map<Id, genesis__Applications__c>();
        Set<Id> competitorPartyIds = new Set<Id>();

        for(clcommon__Party__c party : newPartyMap.values()) {
            clcommon__Party__c oldParty = oldPartyMap.get(party.Id);

            if(oldParty.clcommon__isPrimary__c != party.clcommon__isPrimary__c && party.clcommon__isPrimary__c) {
                applicationIdToContactId.put(party.genesis__Application__c, party.clcommon__Contact__c);
                applicationIdToAccountId.put(party.genesis__Application__c, party.clcommon__Account__c);
            }

            if(party.clcommon__Type__c == OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_COMPETITOR) &&
                oldParty.Competitor_Amount__c != party.Competitor_Amount__c){
                genesis__Applications__c application = new genesis__Applications__c(Id = party.genesis__Application__c, Total_Competitors_Amount__c = 0);
                competitorPartyApplicationMap.put(party.genesis__Application__c, application);
            }

            if(party.clcommon__Type__c == OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_COMPETITOR) &&
                oldParty.Competitor_Bank_Account__c != party.Competitor_Bank_Account__c){
                competitorPartyIds.add(party.Id);
            }
        }

        if(!competitorPartyApplicationMap.isEmpty()){
            PartyManager.calculateTotalCompetitorAmount(competitorPartyApplicationMap);
        }

        if(!competitorPartyIds.isEmpty()) {
            PartyManager.setCompetitorBankAccountFieldsInParty(competitorPartyIds);
        }

        if(!applicationIdToContactId.isEmpty()) {
            for(genesis__Applications__c application : applicationDBInstance.getApplicationsByIds(applicationIdToContactId.keySet())){
                Id contactId = applicationIdToContactId.get(application.Id);
                application.Primary_Guarantor__c = contactId;
                Opportunity opportunityRecord = new Opportunity(Id = application.Opportunity__c);
                opportunityRecord.Primary_Contact__c = contactId;

                applicationDBInstance.addUpdate(application);
                opportunityDBInstance.addUpdate(opportunityRecord);

                Id guarantorAccountId = applicationIdToAccountId.get(application.Id);
                List<clcommon__Reciprocal_Role__c> relationshipRoleList = clCommonReciprocalRoleDBInstance.getCLCommonRelationship(new Set<String> {GeneralConstants.PARTY_TYPE_GUARANTOR});
                Id relationshipRoleId = relationshipRoleList.isEmpty() ? null : relationshipRoleList[0].Id;
                List<clcommon__Relationship__c> relationshipPartyList = clCommonRelationshipDBInstance.getCLCommonRelationships(new Set<Id> {application.genesis__Account__c}, new Set<Id> {guarantorAccountId}, new Set<Id> {relationshipRoleId});
                if(!relationshipPartyList.isEmpty()) {
                    clcommon__Relationship__c relationship = new clcommon__Relationship__c();
                    relationship.Id = relationshipPartyList.get(0).Id;
                    relationship.clcommon__Ownership_Percentage__c = 100;
                    clCommonRelationshipDBInstance.addUpdate(relationship);
                }
            }

            applicationDBInstance.executeUpdates();
            opportunityDBInstance.executeUpdates();
            clCommonRelationshipDBInstance.executeUpdates();
        }
    }

    public void afterInsert(List<clcommon__Party__c> partyList) {

        Map<Id, genesis__Applications__c> competitorPartyApplicationMap = new Map<Id, genesis__Applications__c>();
        Set<Id> competitorPartyIds = new Set<Id>();

        for(clcommon__Party__c party : partyList){
            if(party.clcommon__Type__c == OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_COMPETITOR)){
                genesis__Applications__c application = new genesis__Applications__c(Id = party.genesis__Application__c, Total_Competitors_Amount__c = 0);
                competitorPartyApplicationMap.put(party.genesis__Application__c, application);
                competitorPartyIds.add(party.Id);
            }
        }
        if(!competitorPartyApplicationMap.isEmpty()){
            PartyManager.calculateTotalCompetitorAmount(competitorPartyApplicationMap);
        }

        if(!competitorPartyIds.isEmpty()) {
            PartyManager.setCompetitorBankAccountFieldsInParty(competitorPartyIds);
        }
    }

    public void afterDelete(List<clcommon__Party__c> partyList) {
        Map<Id, genesis__Applications__c> competitorPartyApplicationMap = new Map<Id, genesis__Applications__c>();

        for(clcommon__Party__c party : partyList){
            if(party.clcommon__Type__c == OriginationHelper.partyTypeToId.get(GeneralConstants.PARTY_TYPE_COMPETITOR)){
                genesis__Applications__c application = new genesis__Applications__c(Id = party.genesis__Application__c, Total_Competitors_Amount__c = 0);
                competitorPartyApplicationMap.put(party.genesis__Application__c, application);
            }
        }
        if(!competitorPartyApplicationMap.isEmpty()){
            PartyManager.calculateTotalCompetitorAmount(competitorPartyApplicationMap);
        }
    }
}