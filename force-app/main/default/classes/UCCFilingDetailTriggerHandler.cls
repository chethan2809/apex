public class UCCFilingDetailTriggerHandler {

    @TestVisible
    private static AccountDB accountDBInstance = new AccountDB();

    public void afterInsert(Map<Id, UCC_Filing_Detail__c> newUCCFilingMap) {
        List<Account> accountList = new List<Account>();
        for(UCC_Filing_Detail__c uccFiling : newUCCFilingMap.values()) {
            UCCFilingManager.setAccountFieldsFromUCC(newUCCFilingMap.values());
        }
    }

    public void beforeUpdate(Map<Id, UCC_Filing_Detail__c> newUCCFilingMap, Map<Id, UCC_Filing_Detail__c> oldUCCFilingMap) {
        List<UCC_Filing_Detail__c> uccContinuedFilingList = new List<UCC_Filing_Detail__c>();
        for(UCC_Filing_Detail__c newUCCFiling : newUCCFilingMap.values()) {
            UCC_Filing_Detail__c oldUCCFiling = oldUCCFilingMap.get(newUCCFiling.Id);
            if( UCCFilings.isTerminateChanged(newUCCFiling, oldUCCFiling) && newUCCFiling.Is_Terminated__c == true){
                Account accountObject = new Account(Id = newUCCFiling.Account__c);
                accountObject.UCC_Status__c = GeneralConstants.UCC_STATUS_TERMINATED;
                accountDBInstance.addUpdate(accountObject);
            }
        }
        accountDBInstance.executeUpdates();
    }
}