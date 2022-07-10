public class OFACTriggerHandler {

    public static boolean hasBeforeInsertRan = false;

    public static void beforeInsert(List<ofacchecker__OFAC__c > ofacList){
        Map<Id, ofacchecker__OFAC__c> mapAccounts = new Map<Id, ofacchecker__OFAC__c>();
        Map<Id, ofacchecker__OFAC__c> mapContacts = new Map<Id, ofacchecker__OFAC__c>();

        for(ofacchecker__OFAC__c oOFAC : ofacList){
            if(oOFAC.ofacchecker__Parent_Record_Id__c != null && oOFAC.ofacchecker__Parent_Record_Id__c.startsWith('001')){
                mapAccounts.put(oOFAC.ofacchecker__Parent_Record_Id__c, oOFAC);
            }
            if(oOFAC.ofacchecker__Parent_Record_Id__c != null && oOFAC.ofacchecker__Parent_Record_Id__c.startsWith('003')){
                mapContacts.put(oOFAC.ofacchecker__Parent_Record_Id__c, oOFAC);
            }
        }

        List<clcommon__Party__c> listparties = [Select Id, clcommon__Account__c, clcommon__Contact__c, genesis__Application__c   from clcommon__Party__c where clcommon__Account__c in: mapAccounts.keySet() OR clcommon__Contact__c in:mapContacts.keySet() ];
        if(listparties != null && listparties.size() > 0){
            for(clcommon__Party__c oParty : listparties){
                if(oParty.clcommon__Account__c != null && mapAccounts.containsKey(oParty.clcommon__Account__c)){
                    mapAccounts.get(oParty.clcommon__Account__c).Party__c = oParty.Id;
                    mapAccounts.get(oParty.clcommon__Account__c).Application__c = oParty.genesis__Application__c;
                }
                if(oParty.clcommon__Contact__c != null && mapContacts.containsKey(oParty.clcommon__Contact__c)){
                    mapContacts.get(oParty.clcommon__Contact__c).Party__c = oParty.Id;
                    mapContacts.get(oParty.clcommon__Contact__c).Application__c = oParty.genesis__Application__c;
                }
            }
        }
    }
}