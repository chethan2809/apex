public class SFTPDisbursalManager {

    @TestVisible
    private static DocumentDB documentDBInstance = new DocumentDB();
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    public static void uploadSFTPDisbursal(List<Document> listOfDocuments) {
        for (Document disbursedDocument : listOfDocuments) {
            try {
                Date currentSystemDate = GeneralHelper.currentSystemDate;
                String todaysDate = (DateTime.newInstance(currentSystemDate.year(), currentSystemDate.month(),currentSystemDate.day()).format('MM-dd-YY'));
                String documentName = todaysDate + '.ach';
                String stringBody = disbursedDocument.Body.toString().toUpperCase();
                Blob docBody;

                if(stringBody.contains('5220WEBBANK/CANCAP')) {
                    stringBody = stringBody.replace('PPDPAYMENT', 'CCDPAYMENT');
                    docBody = Blob.valueOf(stringBody);
                } else {
                    stringBody = stringBody.replace('5220WEBBANK         ', '5220WEBBANK/CANCAP  ');
                    stringBody = stringBody.replace('PPDPAYMENT', 'CCDPAYMENT');
                    docBody = Blob.valueOf(stringBody);
                }

                disbursedDocument.Body = docBody;
                SFTPDisbursalCallout.uploadSFTPDisbursal(docBody, documentName, disbursedDocument.Type);
                Folder folderDetail = GeneralHelper.folderByFolderName.get(GeneralConstants.FOLDER_PROCESSED_ACH_OUTBOUND);
                disbursedDocument.FolderId = folderDetail.Id;
                disbursedDocument.Description = disbursedDocument.Name;
                documentDBInstance.addUpdate(disbursedDocument);
            } catch (Exception e) {
                Error_Log__c errorLog = ErrorLogs.createErrorLog(
                    'SFTP Disbursal Document upload', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                    disbursedDocument.Id, false
                );
                errorLogDBInstance.addInsert(errorLog);
            }
        }
        documentDBInstance.executeUpdates();
        errorLogDBInstance.executeInserts();
    }
}