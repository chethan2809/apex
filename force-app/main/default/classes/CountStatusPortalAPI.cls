global without sharing class CountStatusPortalAPI implements clcommon.PortalCustomRemoteAPI1{
    public static UserDB userDBInstance = new UserDB();
    public static AccountDB accountDBInstance = new AccountDB();
    global clcommon.Response invokeAction(String ComponentStrName, List<String> DisclosureNames, Map<String,Object> params){
        clcommon.Response res;
        double newEnter, moreInfo, approved, rejected;
        try{
                res= performLogic();
        }
        catch(Exception e){
            res= PortalUtils.setResponse(e.getMessage() + e.getLineNumber());
        }
        return res;
    }
     private clcommon.Response performLogic() {
        clcommon.Response response;
        Map<String, Object> dataMap = new Map<String , Object>();
        dataMap = calculateRepayment();
        response = PortalUtils.setResponse('response',dataMap);
        return response;
    }
    private Map<String, Decimal> calculateRepayment() {
        clcommon.Response response;
        Set<Id> brokerUserIds = new Set<Id>();
        Map<String, Decimal> PaymentModeAmountMap = new Map<String , Decimal>();
        Date lastNinetyDays = (GeneralHelper.currentSystemDate).addDays(PortalConstants.LAST_NINETY_DAYS);

        brokerUserIds = CCBPBrokerHierarchyManager.getBrokerUserIds();
        List<clcommon__Party__c> applicationSubmittedCount = [SELECT Id  FROM clcommon__Party__c  WHERE genesis__application__r.portal_bucket__c ='Application Submitted' AND genesis__application__r.OwnerId =:brokerUserIds AND clcommon__type__r.Name = 'BROKER'];
        List<clcommon__Party__c> approvedCount = [SELECT Id FROM clcommon__Party__c  WHERE genesis__application__r.portal_bucket__c ='Approved' AND genesis__application__r.OwnerId =:brokerUserIds AND clcommon__type__r.Name = 'BROKER'];
        List<clcommon__Party__c> completedCount = [SELECT Id FROM clcommon__Party__c  WHERE genesis__application__r.portal_bucket__c ='Funded' AND genesis__application__r.OwnerId =:brokerUserIds AND clcommon__type__r.Name = 'BROKER' AND genesis__application__r.Contract_Approved_Date__c >= :lastNinetyDays];

    /*  aggregateresult[] resultsNE = [select COUNT(Id),COUNT(genesis__application__r.genesis__status__c) la from clcommon__party__c where clcommon__account__c  = :currentUser.Accountid and genesis__application__r.genesis__status__c In ('NEW - ENTERED') group by genesis__application__c];
        aggregateresult[] resultsNMI = [select COUNT(Id),COUNT(genesis__application__r.genesis__status__c) la from clcommon__party__c where clcommon__account__c  = :currentUser.Accountid and genesis__application__r.genesis__status__c In ('NEW - MORE INFO REQUIRED') group by genesis__application__c];
        aggregateresult[] resultsApp = [select COUNT(Id),COUNT(genesis__application__r.genesis__status__c) la from clcommon__party__c where clcommon__account__c  = :currentUser.Accountid and genesis__application__r.genesis__status__c In ('APPROVED') group by genesis__application__c];
        aggregateresult[] resultsRej = [select COUNT(Id),COUNT(genesis__application__r.genesis__status__c) la from clcommon__party__c where clcommon__account__c  = :currentUser.Accountid and genesis__application__r.genesis__status__c In ('DECLINED') group by genesis__application__c];
        PaymentModeAmountMap.put('NewEntered',resultsNE.size());
        PaymentModeAmountMap.put('NeedMoreInfo',resultsNMI.size());
        PaymentModeAmountMap.put('Approved',resultsApp.size());
        PaymentModeAmountMap.put('Rejected',resultsRej.size());*/
        PaymentModeAmountMap.put('approvedCount',approvedCount.size());
        PaymentModeAmountMap.put('applicationSubmittedCount',applicationSubmittedCount.size());
        PaymentModeAmountMap.put('CompletedCount',completedCount.size());
        return PaymentModeAmountMap;
  }
}