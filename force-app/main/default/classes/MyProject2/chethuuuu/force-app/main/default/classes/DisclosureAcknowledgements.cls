public class DisclosureAcknowledgements {
    
    public static clcommon__Disclosure_Acknowledgement__c acceptDisclosureAcknowledgement(clcommon__Party__c party,
                        Map<String,clcommon__Disclosure_Definition__c> disclosureNameToObjectMap , string disclosureName){
            clcommon__Disclosure_Acknowledgement__c disclosureAcknowledgement = new clcommon__Disclosure_Acknowledgement__c();
            disclosureAcknowledgement.clcommon__Accepted__c = true;
            disclosureAcknowledgement.clcommon__Account__c = party.clcommon__Account__c;
            disclosureAcknowledgement.clcommon__Description__c = disclosureNameToObjectMap.get(disclosureName).clcommon__Description__c;
            disclosureAcknowledgement.clcommon__Disclosure_Definition__c = disclosureNameToObjectMap.get(disclosureName).Id;
            disclosureAcknowledgement.Party__c = party.Id;
            return disclosureAcknowledgement;
    }
}