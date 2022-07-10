public class DataMerchManager {

    @TestVisible
    private static ApplicationDB applicationDBInstance = new ApplicationDB();
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    @TestVisible
    private static AccountDB accountDBInstance = new AccountDB();
    @TestVisible
    private static CreditReportDetailDB creditReportDetailDBInstance = new CreditReportDetailDB();
    @TestVisible
    private static DataMerchNoteDB dataMerchNoteDBInstance = new DataMerchNoteDB();
    @TestVisible
    private static UnderWriterTaskDB underWriterTaskDBInstance = new UnderWriterTaskDB();

    public static void requestDataMerchMerchants(List<genesis__Applications__c> listOfApplications) {
        String dataMerchAccessToken;
        Map<Id, Map<String, String>> responseMapByCreditReportDetail = new Map<Id, Map<String, String>>();
        Map<Id, Id> accountIdToApplicationId = new Map<Id, Id>();
        List<genesis__Applications__c> listOfApplicationShell = new List<genesis__Applications__c>();
        Map<String, UnderWriter_Task__c> underWriterTaskByApplicationIdTaskName = new Map<String, UnderWriter_Task__c>();
        Map<Id, genesis__Applications__c> applicationMap = new Map<Id, genesis__Applications__c>(listOfApplications);
        Map<Id, Credit_Report_Detail__c> creditReportByAccountId = new Map<Id, Credit_Report_Detail__c>();
        Map<String, Data_Merch_Note__c> dataMerchNoteByAccountId = new Map<String, Data_Merch_Note__c>();

        Set<String> taskNames = new Set<String> {
            DataMerch.TASK_TYPE_DATA_MERCH
        };

        for(genesis__Applications__c application : listOfApplications) {
            accountIdToApplicationId.put(application.genesis__Account__c, application.Id);
        }

        for (UnderWriter_Task__c uwTask :
            underWriterTaskDBInstance.getUnderWriterTaskByApplicationIdsAndTaskNames(applicationMap.keySet(), taskNames)
        ) {
            underWriterTaskByApplicationIdTaskName.put(uwTask.Application__c + uwTask.Task_Name__c, uwTask);
        }

        for (Credit_Report_Detail__c existingReport :
                creditReportDetailDBInstance.getDataMerchReportByAccountIds(accountIdToApplicationId.keySet())
        ) {
            creditReportByAccountId.put(existingReport.Account__c, existingReport);
        }

        for (Data_Merch_Note__c existingNote : dataMerchNoteDBInstance.getDataMerchNotesByAccountIds(accountIdToApplicationId.keySet())) {
            dataMerchNoteByAccountId.put(existingNote.Account__c + '-' + existingNote.Id, existingNote);
        }

        Map<Id, Account> accountMap = new Map<Id, Account> (accountDBInstance.getAccountByIds(accountIdToApplicationId.keySet()));
        List<Credit_Report_Detail__c> reportList = new List<Credit_Report_Detail__c>();
        List<Data_Merch_Note__c> reportNoteList = new List<Data_Merch_Note__c>();
        for (genesis__Applications__c application : listOfApplications) {
            genesis__Applications__c applicationShell = new genesis__Applications__c(Id = application.Id);
            Account accountDetail = accountMap.get(application.genesis__Account__c);
            DataMerchCalloutParser parser = new DataMerchCalloutParser(accountDetail);
            try {
                if(dataMerchAccessToken == null) {
                    API_Detail__mdt apiDetails = DataMerch.dataMerchAPIDetails;
                    dataMerchAccessToken = 'Oauth '+ DataMerchCallOut.getAccessToken(apiDetails);
                }

                HttpResponse dataMerchResponse = DataMerchCallOut.requestDataMerch(accountDetail, dataMerchAccessToken);
                Map<String, Object> accountDataMerch = parser.dataMerchResponseBody(dataMerchResponse);
                if (accountDataMerch.size() > 0) {

                    String dataMerchResponseBody = dataMerchResponse.getBody();

                    Credit_Report_Detail__c dataMerchReport = DataMerch.createDataMerchReportDetail(accountDetail.Id, accountDataMerch, application.Id, creditReportByAccountId);
                    List<Data_Merch_Note__c> dataMerchNotesList = DataMerch.createDataMerchNotes(accountDetail.Id, accountDataMerch, application.Id, dataMerchNoteByAccountId);
                    reportList.add(dataMerchReport);
                    Map<String, String> dataMerchResponseMap = new Map<String, String>{'DataMerchResponse' => dataMerchResponseBody};
                    responseMapByCreditReportDetail.put(dataMerchReport.Account__c, dataMerchResponseMap);
                    creditReportDetailDBInstance.addUpserts(reportList);
                    dataMerchNoteDBInstance.addUpserts(dataMerchNotesList);
                }
                applicationShell.genesis__Status__c = Applications.STATUS_LEXISNEXIS_CHECK;
                applicationShell.genesis__Account__c = application.genesis__Account__c;
                applicationShell.Type__c = application.Type__c;
                applicationShell.Decline_Reasons__c = application.Decline_Reasons__c;
                listOfApplicationShell.add(applicationShell);
                DataMerch.checkDataMerchVerified(underWriterTaskByApplicationIdTaskName, application.Id, true);

            } catch (Exception e) {
                applicationShell.genesis__Status__c = Applications.STATUS_DATAMERCH_CHECK_FAILED;
                DataMerch.checkDataMerchVerified(underWriterTaskByApplicationIdTaskName, application.Id, false);
                Error_Log__c errorLog = ErrorLogs.createErrorLog('Data Merch Check', e, applicationShell.Id, false);
                applicationDBInstance.addUpdate(applicationShell);
                errorLogDBInstance.addInsert(errorLog);
            }
        }

        errorLogDBInstance.executeInserts();
        creditReportDetailDBInstance.executeUpserts();
        dataMerchNoteDBInstance.executeUpserts();

        if(!listOfApplicationShell.isEmpty()) {
            BusinessRuleManager.runDataMerchDeclineRules(listOfApplicationShell);
            applicationDBInstance.addUpdates(listOfApplicationShell);
        }

        applicationDBInstance.executeUpdates();

        underWriterTaskDBInstance.addUpdates(underWriterTaskByApplicationIdTaskName.values()).executeUpdates();
        if(!Test.isRunningTest()) {
            new QueueableJobHandler().executeSFTPScoringRawDataQueueableJob(reportList, responseMapByCreditReportDetail, accountIdToApplicationId);
        }

    }

}