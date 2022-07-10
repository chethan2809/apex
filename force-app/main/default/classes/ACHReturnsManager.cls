public class ACHReturnsManager {
    @TestVisible
    private static DocumentDB documentDBInstance = new DocumentDB();
    @TestVisible
    private static CLContractDB clContractDBInstance = new CLContractDB();
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    @TestVisible
    private static AttachmentDB attachmentDBInstance = new AttachmentDB();

    public static Integer processACHReturnFiles(Map<String, Object> documentRecords) {
        List<Object> listOfDocuments = (List<Object>) documentRecords.get('fileContentList');
        String fileType = 'text/plain';
        Integer filesProcessedCount = 0;
        Map<String, String> errorMessageByLoanAccountName = new Map<String, String>();
        List<String> csvRowValues = new List<String> { 'Name, Error' };

        for (Object documentDetail : listOfDocuments) {
            List<Object> documentList = (List<Object>) documentDetail;
            List<Integer> integerValues = new List<Integer> ();
            Map<String, String> last7DigitLPTAndReasonCodeByLoanName = new Map<String, String>();
            List<String> achContentList = new List<String>();

            for(Object valueInteger : documentList){
                integerValues.add(Integer.valueOf(valueInteger));
            }

            String fileContent = String.fromCharArray(integerValues);
            if(fileContent != null && !String.isEmpty(fileContent)) {
                achContentList = fileContent.split('\n');
            }

            ACHReturns.parseACHReturns(achContentList, last7DigitLPTAndReasonCodeByLoanName);

            List<loan__Loan_Account__c> loanAccountList =
                clContractDBInstance.getLoanAccountsAndItsLoanPaymentTxnByName(last7DigitLPTAndReasonCodeByLoanName.keySet());

            List<loan.ACHReturn> listOfAchReturns = ACHReturns.buildACHReturnList(
                loanAccountList, last7DigitLPTAndReasonCodeByLoanName, csvRowValues
            );

            if(!listOfAchReturns.isEmpty()) {
                ACHReturnsPaymentCustomProcessor contentParser = new ACHReturnsPaymentCustomProcessor();
                contentParser.achReturns = listOfAchReturns;
                contentParser.setScope(1);
                contentParser.processPaymentReversal();

                DateTime currentSystemDateTime = GeneralHelper.currentSystemDateTime;
                String todaysDate = (DateTime.newInstance(currentSystemDateTime.year(), currentSystemDateTime.month(),currentSystemDateTime.day()).format('YYYYMMDD'));
                String todaysTime = String.valueOf(currentSystemDateTime.getTime());
                String documentName = todaysDate + ' ACH Return ' + todaysTime + '.txt';

                Folder folderDetail = GeneralHelper.folderByFolderName.get(GeneralConstants.FOLDER_ACH_RETURN);
                if(folderDetail == null) {
                    throw new ACHReturnsManagerException('ACH Return folder not found');
                }

                Document returnDocument = Documents.createDocument(documentName, Blob.valueOf(fileContent), folderDetail.Id, 'txt', fileType);
                documentDBInstance.addInsert(returnDocument);
                filesProcessedCount++;
            }
        }

        documentDBInstance.executeInserts();

        if(csvRowValues.size() > 1) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog('Process ACH Returns', 'Processing ACH Return failed',
                null, null, ErrorLogs.ERROR, null, false
            );
            errorLogDBInstance.addInsert(errorLog).executeInserts();

            String csvFile = String.join(csvRowValues, '\n');
            String documentName = 'ACH Return Errors.csv';
            attachmentDBInstance.addInsert(
                Attachments.createAttachment(documentName, Blob.valueOf(csvFile), errorLog.Id)
            );
            attachmentDBInstance.executeInserts();
        }

        return filesProcessedCount;
    }

    private class ACHReturnsManagerException extends Exception {}
}