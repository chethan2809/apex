public class SFTPScoringRawDataManager {

    @TestVisible
    private static ApplicationDB applicationDBInstance = new ApplicationDB();
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    public static void SFTPSendRawData(List<Credit_Report_Detail__c> reportList, Map<Id, Map<String, String>> responseMapByCreditReportDetail, Map<Id, Id> contactIdAccountIdToApplicationId) {
        Map<Id, List<Attachment>> attachmentsByApplicationId = new Map<Id, List<Attachment>>();

        for(Credit_Report_Detail__c creditReport : reportList){

            List<Attachment> attachmentList = new List<Attachment>();
            Id applicationId = SFTPScoringRawDatas.buildResponseAttachment(creditReport, responseMapByCreditReportDetail, attachmentList, contactIdAccountIdToApplicationId);

            if(attachmentsByApplicationId.containsKey(applicationId)) {
                attachmentsByApplicationId.get(applicationId).addAll(attachmentList);
            } else {
                attachmentsByApplicationId.put(applicationId, attachmentList);
            }
        }
        Map<Id, String> appNameByApplication = new Map<Id, String>();
        for(genesis__Applications__c application : applicationDBInstance.getApplicationsByIds(attachmentsByApplicationId.KeySet())){
            appNameByApplication.put(application.Id, application.Name);
        }
        callSFTPCallOut(attachmentsByApplicationId, appNameByApplication);
    }

    public static void callSFTPCallOut(Map<Id, List<Attachment>> attachmentsByApplicationId, Map<Id, String> appNameByApplication) {
        String applicationName;
        Blob fileBody;
        try{
            for(Id applicationId : attachmentsByApplicationId.KeySet()){
                for(List<Attachment> attachmentList : attachmentsByApplicationId.values()){
                    for(Attachment attachmentRecord : attachmentList){
                        applicationName = appNameByApplication.get(applicationId);
                        fileBody = attachmentRecord.Body;
                        String fileName = attachmentRecord.Name;
                        String fileType = 'text/plain';
                        SFTPScoringRawDataCallOut.uploadSFTPRawData(applicationName, fileBody, fileType, fileName);
                    }
                }
            }
        } catch (Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'SFTP RawData Document upload', e.getMessage() + e.getStackTraceString(), String.ValueOf(fileBody), null, ErrorLogs.ERROR,
                null, false
            );
            errorLogDBInstance.addInsert(errorLog).executeInserts();
        }
    }
}