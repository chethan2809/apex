public class SFTPRepaymentManager {

    @TestVisible
    private static DocumentDB documentDBInstance = new DocumentDB();
    @TestVisible
    private static ErrorLogDB errorLogInstance = new ErrorLogDB();

    public static void uploadSFTPRepayment(List<Document> listOfDocuments) {
        for (Document repaymentDocument : listOfDocuments) {
            try {
                Date currentSystemDate = GeneralHelper.currentSystemDate;
                String todaysDate = (Datetime.newInstance(currentSystemDate.year(), currentSystemDate.month(),currentSystemDate.day()).format('MM-dd-YY'));
                String documentName = todaysDate + '.ach';
                SFTPRepaymentCallout.uploadSFTPRepayment(repaymentDocument.Body, documentName, repaymentDocument.Type);
                Folder folderDetail = GeneralHelper.folderByFolderName.get(GeneralConstants.FOLDER_PROCESSED_ACH_INBOUND);
                repaymentDocument.FolderId = folderDetail.Id;
                repaymentDocument.Description = repaymentDocument.Name;
                documentDBInstance.addUpdate(repaymentDocument);
            } catch (Exception e) {
                Error_Log__c errorLog = ErrorLogs.createErrorLog(
                    'SFTP Repayment Document upload', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                    repaymentDocument.Id, false
                );
                errorLogInstance.addInsert(errorLog);
            }
        }
        documentDBInstance.executeUpdates();
        errorLogInstance.executeInserts();
    }
}