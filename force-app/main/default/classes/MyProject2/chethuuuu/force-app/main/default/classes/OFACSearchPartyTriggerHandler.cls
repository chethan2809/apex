public class OFACSearchPartyTriggerHandler {

    public static Boolean isAfterRan = false;

    public static void runOFACCheck(List<clcommon__Party__c> listParty, Map<Id,clcommon__Party__c> mapOldParty) {
        Set<clcommon__Party__c> setPartyIds = new Set<clcommon__Party__c>();
        for(clcommon__Party__c oParty : listParty){
            if(oParty.Run_OFAC_Check__c && (mapOldParty != null && mapOldParty.containsKey(oParty.Id) && mapOldParty.get(oParty.Id).Run_OFAC_Check__c != oParty.Run_OFAC_Check__c)){
                setPartyIds.add(oParty);
            }
        }
        for(clcommon__Party__c oParty : setPartyIds){
            System.enqueueJob(new QueueableOFACSearch(oParty));
        }
    }
}