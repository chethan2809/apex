public class CongaSignTransactionManager {
    @TestVisible
    public static CongaSignTransactionsDB congaSignTransactionsDBInstance = new CongaSignTransactionsDB();
    @TestVisible
    public static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    @TestVisible
    private static ApplicationDB applicationDBInstance = new ApplicationDB();

    @future
    public static void sendCongaSignChatterNotifications(Set<Id> congaSignTransactionIds) {
        for(APXT_CongaSign__Transaction__c congaSignTransaction : congaSignTransactionsDBInstance.getCongaSignTransactionsByIds(congaSignTransactionIds)){
            try {
                CongaSignTransactions.sendChatterNotifications(congaSignTransaction);
            }
            catch(Exception e){
                Error_Log__c errorLog = ErrorLogs.createErrorLog(
                    'Conga Sign Chatter Notifications Failed', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                    null, false
                );
                errorLogDBInstance.addInsert(errorLog);
            }
        }
        errorLogDBInstance.executeInserts();
    }

    public static void updateApplicationStatusOnDocsSent(Set<Id> applicationIds) {
        List<genesis__Applications__c> applicationListByID = applicationDBInstance.getApplicationsByIds(applicationIds);
        for(genesis__Applications__c applicationRecord : applicationListByID) {
            if(applicationRecord.genesis__Status__c == Applications.STATUS_OFFER_ACCEPTED){
                applicationRecord.genesis__Status__c = Applications.STATUS_DOCS_OUT;
                applicationDBInstance.addUpdate(applicationRecord);
            }
        }

        applicationDBInstance.executeUpdates();
    }
}