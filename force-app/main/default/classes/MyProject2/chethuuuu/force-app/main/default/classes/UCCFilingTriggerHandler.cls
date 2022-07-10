public class UCCFilingTriggerHandler {

    @TestVisible
    private static UCCFilingDB uccFilingDBInstance = new UCCFilingDB();

    public void afterInsert(Map<Id, UCC_Filing_Detail__c> uccFilingMap) {
        Set<Id> eISAccountIds = new Set<Id>();
        List<UCC_Filing_Detail__c> uccFilingList = uccFilingDBInstance.getUCCFilingListByIds(uccFilingMap.keySet());
        for(UCC_Filing_Detail__c uccFiling : uccFilingMap.values()) {
            if(uccFiling.Order_ID__c != null && uccFiling.Account__r.Legacy_Active_Contract__c && uccFiling.Account__r.EIS_Extend_UCC__c
            ) {
                eISAccountIds.add(uccFiling.Account__c);
            }
        }
        if(!eISAccountIds.isEmpty()){
            UCCFilingManager.getOrderInformation(eISAccountIds);
        }
    }
}