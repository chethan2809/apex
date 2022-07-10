public class InvocableOFACSearch {
    @TestVisible
    private static PartyDB partyDBInstance = new PartyDB();
    @InvocableMethod(label='runOFACSearch' description='This class will run OFAC on Party Object')
    public static void runOFAC(List<Id> lstIds){
        if(lstIds != null){
            List<clcommon__Party__c> lstParty = partyDBInstance.getPartiesByIds(new Set<Id>(lstIds));
            for(clcommon__Party__c oParty : lstParty){
                System.enqueueJob(new QueueableOFACSearch(oParty));
            }
        }
    }
}