public class CreditReportDetailManager {
    @TestVisible
    private static PartyDB partyDBInstance = new PartyDB();
    @TestVisible
    private static ApplicationDB applicationDBInstance = new ApplicationDB();
    @TestVisible
    private static CreditReportDetailDB creditReportDetailDBInstance  = new CreditReportDetailDB();

    public static void setSICCodeAndTimeInBusiness(List<genesis__Applications__c> applicationList){
        Map<Id, Id> accountToApplicationIdMap = new Map<Id, Id>();
        for(genesis__Applications__c application : applicationList) {
            accountToApplicationIdMap.put(application.genesis__Account__c, application.Id);
        }

        List<Credit_Report_Detail__c> creditReportDetailList =
            creditReportDetailDBInstance.getBusinessAndLexisNexisReportsByAccountIdsAndApplicationIds(
                accountToApplicationIdMap.keySet(), new Set<Id> (accountToApplicationIdMap.values())
            );

        Map<Id, List<Credit_Report_Detail__c>> creditReportsByApplicationId = new Map<Id, List<Credit_Report_Detail__c>>();
        for(Credit_Report_Detail__c creditDetail : creditReportDetailList) {
            Id applicationId;
            if(creditDetail.Application__c != null) {
                applicationId = creditDetail.Application__c;
            } else {
                applicationId = accountToApplicationIdMap.get(creditDetail.Account__c);
            }

            if(creditReportsByApplicationId.containsKey(applicationId)) {
                creditReportsByApplicationId.get(applicationId).add(creditDetail);
            } else {
                creditReportsByApplicationId.put(applicationId, new List<Credit_Report_Detail__c>{ creditDetail });
            }
        }

        for(genesis__Applications__c application :applicationList) {
            if(creditReportsByApplicationId.containsKey(application.Id)) {
                List<Credit_Report_Detail__c> creditReportList = creditReportsByApplicationId.get(application.Id);
                CreditReportDetails.calculateSICCodeAndTimeInBusiness(creditReportList, application);
            }
        }
    }
}