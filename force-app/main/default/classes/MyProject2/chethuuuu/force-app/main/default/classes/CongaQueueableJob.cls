public class CongaQueueableJob implements Queueable, Database.AllowsCallouts  {
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    private Map<String, Object> requestRecord = new Map<String, Object>();

    public CongaQueueableJob(Map<String, Object> requestRecord) {
        this.requestRecord = requestRecord;
    }

    public void execute(QueueableContext context) {
        try {
            CongaManager.processApplicationCongaDocuments(requestRecord);
        } catch (Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'Conga API Queueable Job', e.getMessage() + e.getStackTraceString(), requestRecord.toString(), null, ErrorLogs.ERROR,
                null, false
            );

            errorLogDBInstance.addInsert(errorLog).executeInserts();
        }
    }
}