public class ErrorLogManager {
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    @TestVisible
    private static ApplicationDB applicationDBInstance = new ApplicationDB();
    @TestVisible
    private static OcrolusReportDB ocrolusReportDBInstance = new OcrolusReportDB();

    public static void createAWSOcrolusErrorLog(Map<String, Object> errorLogResponseMap){
        String pk = String.valueOf(errorLogResponseMap.get('pk'));
        String transactionId = String.valueOf(errorLogResponseMap.get('TransactionId'));
        String message = String.valueOf(errorLogResponseMap.get('Message'));

        List<CAN_Ocrolus_Report__c> ocrolusReportList = ocrolusReportDBInstance.getCANOcrolusReportByPK(pk);
        if(ocrolusReportList.isEmpty()) {
            throw new ErrorLogManagerException('There was no ocrolus report found for PK : ' + pk);
        }

        CAN_Ocrolus_Report__c ocrolusReport = ocrolusReportList.get(0);
        genesis__Applications__c application = new genesis__Applications__c(Id = ocrolusReport.Application__c);

        application.genesis__Status__c = Applications.STATUS_BANK_STATEMENT_PROCESSING_FAILED;
        ocrolusReport.Document_Status__c = Ocrolus.OCROLUS_DOC_STATUS_FAILED;
        Error_Log__c errorLog = ErrorLogs.createErrorLog(
            'Ocrolus Bank Statement Processing Failed', transactionId + '\nMessage : ' + message, JSON.serialize(errorLogResponseMap), null, ErrorLogs.ERROR,
            application.Id, false
        );
        errorLogDBInstance.addInsert(errorLog).executeInserts();

        applicationDBInstance.addUpdate(application).executeUpdates();
    }
    private class ErrorLogManagerException extends Exception {}

}