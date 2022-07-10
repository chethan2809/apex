public class PurchaseStatementManager {

    @TestVisible
    private static DocumentDB documentDBInstance = new DocumentDB();
    @TestVisible
    private static CLContractDB loanAccountDBInstance = new CLContractDB();
    @TestVisible
    private static LoanDisbursalTransactionsDB loanDisbursalTransactionsDBInstance = new LoanDisbursalTransactionsDB();
    @TestVisible
    private static InvestmentOrderDB investmentOrderDBInstance = new InvestmentOrderDB();
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    public static void uploadPurchaseStatement(List<loan__Loan_Disbursal_Transaction__c> loanDisbursalTransactionList) {
        String purchaseStatementColumnList = 'Contract Nbr, Funded Amount, Repayment Amount, Term, Total Payments Received, Principal Paid, Principal Balance, Accrued Interest, NLBL OFee, WebBank Accrued OFee, Write-Offs, Loan Origination Assistance Fee, Servicing Fee, Purchased Loan Origination Assistance Fee, WebBank Loan Purchase Premium, Return of Funding, Refund Amount, Net Settlement, Annual Rate, Tier Name, Payment Frequency\n';

        List<loan__Loan_Disbursal_Transaction__c> processedDisbursalTxnList = new List<loan__Loan_Disbursal_Transaction__c>();
        List<String> csvRowValues = PurchaseStatements.buildPurchaseStatementWrapper(
            loanDisbursalTransactionList, processedDisbursalTxnList
        );

        Date currentSystemDate = GeneralHelper.currentSystemDate;
        Date fundingDate = GeneralHelper.getNBusinessDate(currentSystemDate, -2);
        DateTime fundingDateTime = DateTime.newInstance(fundingDate.year(), fundingDate.month(), fundingDate.day());
        String formattedFundingDate = fundingDateTime.format('YYYYMMdd');
        String formattedTodaysDate = GeneralHelper.currentSystemDateTime.format('YYYYMMdd');
        String csvFile = purchaseStatementColumnList + String.join(csvRowValues, '\n');
        String documentName = formattedFundingDate + ' Bank Settlement ' + formattedTodaysDate + '.csv';
        String fileType = 'text/csv';

        try {
            Integer statusCode = PurchaseStatementCallOut.uploadPurchaseStatement(csvFile, documentName, fileType);
            Folder folderDetail = GeneralHelper.folderByFolderName.get(GeneralConstants.FOLDER_PURCHASE_STATEMENT);
            Document bankStatement = new Document(Name = documentName, Body = Blob.valueOf(csvFile), FolderId = folderDetail.Id, Type = 'csv', ContentType='application/vnd.ms-excel');
            documentDBInstance.addInsert(bankStatement);
            documentDBInstance.executeInserts();

            for(loan__Loan_Disbursal_Transaction__c disbursal : processedDisbursalTxnList){
                disbursal.Purchased__c = true;
            }

            if(!processedDisbursalTxnList.isEmpty()) {
                loanDisbursalTransactionsDBInstance.addUpdates(processedDisbursalTxnList).executeUpdates();
            }
        } catch (Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'SFTP Purchase Statement Upload', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                null, false
            );
            errorLogDBInstance.addInsert(errorLog).executeInserts();
        }
    }

    private class PurchaseStatementManagerException extends Exception {}
}