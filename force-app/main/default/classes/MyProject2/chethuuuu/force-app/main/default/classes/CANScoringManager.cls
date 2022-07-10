public class CANScoringManager {

    @TestVisible
    public static ApplicationDB applicationDBInstance = new ApplicationDB();
    @TestVisible
    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    @TestVisible
    private static PartyDB partyDBInstance = new PartyDB();
    @TestVisible
    private static AccountDB accountDBInstance = new AccountDB();
    @TestVisible
    private static CreditReportDetailDB creditReportDetailDBInstance = new CreditReportDetailDB();

    public static void requestCANScoring(List<genesis__Applications__c> listOfApplications) {

        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>(listOfApplications);
        Map<Id, Id> applicationIdByContactAndAccountId = new Map<Id, Id>();

        for(genesis__Applications__c application : listOfApplications) {
            applicationIdByContactAndAccountId.put(application.Primary_Guarantor__c, application.Id);
            applicationIdByContactAndAccountId.put(application.genesis__Account__c, application.Id);
        }

        Map<Id, Account> accountMap = new Map<Id, Account>(accountDBInstance.getAccountByIds(applicationIdByContactAndAccountId.keySet()));

        List<Credit_Report_Detail__c> creditReportDetailList = creditReportDetailDBInstance.getAllReportByApplicationIdOrAccountIdOrContactId(
            applicationIdByContactAndAccountId.keySet(), applicationMap.keySet()
        );

        Map<Id, Map<String, Credit_Report_Detail__c>> creditReportDetailByApplicationId = new Map<Id, Map<String, Credit_Report_Detail__c>>();
        Map<Id, Credit_Report_Detail__c> creditReportByApplicationId = new Map<Id, Credit_Report_Detail__c>();
        List<genesis__Applications__c> listOfApplicationShell = new List<genesis__Applications__c>();

        for(Credit_Report_Detail__c creditReportDetail : creditReportDetailList) {

            if(creditReportDetail.Type__c == GeneralConstants.CREDIT_REPORT_TYPE_CAN_SCORING) {
                creditReportByApplicationId.put(creditReportDetail.Application__c, creditReportDetail);
            }else{
                Id applicationId = (creditReportDetail.Contact__c != null) ?
                applicationIdByContactAndAccountId.get(creditReportDetail.Contact__c):
                applicationIdByContactAndAccountId.get(creditReportDetail.Account__c);

                if(creditReportDetailByApplicationId.containsKey(applicationId)){
                    creditReportDetailByApplicationId.get(applicationId).put(creditReportDetail.type__c, creditReportDetail);
                } else {
                    creditReportDetailByApplicationId.put(
                        applicationId, new Map<String, Credit_Report_Detail__c> { creditReportDetail.type__c => creditReportDetail}
                    );
                }
            }
        }

        for (genesis__Applications__c application : listOfApplications) {
            Account accountDetail = accountMap.get(application.genesis__Account__c);
            genesis__Applications__c applicationShell = new genesis__Applications__c(
                Id = application.Id, Type__c = application.Type__c, Is_Manual_Score_Run__c = application.Is_Manual_Score_Run__c
            );
            Map<String, Object> canScoringResponseMap;
            try {
                canScoringResponseMap = CANScoringCallOut.requestCANScore(application, creditReportDetailByApplicationId, accountDetail);
                Credit_Report_Detail__c creditReport = CANScorings.createCANScoringCreditReportDetail(
                    CANScoringResponseMap, application, creditReportByApplicationId
                );
                creditReportDetailDBInstance.addUpsert(creditReport);
                CANScorings.updateTIERInApplication(creditReport.CAN_Scoring__c , applicationShell);
                applicationShell.genesis__Status__c = Applications.STATUS_LEXISNEXIS_CHECK;
                applicationShell.Decline_Reasons__c = application.Decline_Reasons__c;
                listOfApplicationShell.add(applicationShell);
            } catch (Exception e) {
                applicationShell.genesis__Status__c = Applications.STATUS_CAN_SCORING_FAILED;
                Error_Log__c errorLog = ErrorLogs.createErrorLog('CAN Scoring Check', e, applicationShell.Id, false);

                applicationDBInstance.addUpdate(applicationShell);
                errorLogDBInstance.addInsert(errorLog);
            }
        }

        creditReportDetailDBInstance.executeUpserts();
        BusinessRuleManager.runCanScoringDeclineRules(listOfApplicationShell);
        applicationDBInstance.addUpdates(listOfApplicationShell);
        applicationDBInstance.executeUpdates();
        errorLogDBInstance.executeInserts();
    }

    private class CANScoringManagerException extends Exception {}
}