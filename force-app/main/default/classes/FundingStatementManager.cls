public class FundingStatementManager {

    @TestVisible
    private static DocumentDB documentDBInstance = new DocumentDB();

    public static void uploadFundingStatement(List<loan__Disbursal_Txn_Distribution__c> disbursalTransactionDistributionList) {
        String fundingStatementColumnList = 'Merchant ID,Business Name,Contract Nbr,Processor Name,Payment Method,Funded Source,Amount,Repurchase Crossover Contract Nbr,Contract Type,Purchase Price,OFAC,Sales Representative Name\n';
        Double totalAmountForNew = 0;
        Double totalAmountForRefinance = 0;
        Double totalAmountForConcurrent = 0;
        Double totalAmountForSummary = 0;
        List<String> csvRowValuesForNew = new List<String>();
        List<String> csvRowValuesForRefinance = new List<String>();
        List<String> csvRowValuesForConcurrent = new List<String>();

        for(loan__Disbursal_Txn_Distribution__c disbursalRecord : disbursalTransactionDistributionList){
            if(disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Type__c == GeneralConstants.LOAN_TYPE_NEW){
                totalAmountForNew += disbursalRecord.loan__Distribution_Amount__c;
                totalAmountForSummary += disbursalRecord.loan__Distribution_Amount__c;
                csvRowValuesForNew.add(FundingStatements.buildFundingStatementForNew(disbursalRecord));
            }
            else if(disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Type__c == GeneralConstants.LOAN_TYPE_RENEWAL){
                totalAmountForRefinance += disbursalRecord.loan__Distribution_Amount__c;
                totalAmountForSummary += disbursalRecord.loan__Distribution_Amount__c;
                csvRowValuesForRefinance.add(FundingStatements.buildFundingStatementForRefinance(disbursalRecord));
            }
            else if(disbursalRecord.loan__Loan_Disbursal_Transaction__r.loan__Loan_Account__r.Type__c == GeneralConstants.LOAN_TYPE_CONCURRENT){
                totalAmountForConcurrent += disbursalRecord.loan__Distribution_Amount__c;
                totalAmountForSummary += disbursalRecord.loan__Distribution_Amount__c;
                csvRowValuesForConcurrent.add(FundingStatements.buildFundingStatementForConcurrent(disbursalRecord));
            }
        }

        List<String> newTotal = new String[11];
        newTotal.set(0, 'New Total');
        newTotal.set(6, String.ValueOf(totalAmountForNew));

        List<String> refinanceTotal = new String[11];
        refinanceTotal.set(0, 'Refinance Total');
        refinanceTotal.set(6, String.ValueOf(totalAmountForRefinance));

        List<String> conCurrentTotal = new String[11];
        conCurrentTotal.set(0, 'Concurrent Total');
        conCurrentTotal.set(6, String.ValueOf(totalAmountForConcurrent));

        List<String> summaryTotal = new String[11];
        summaryTotal.set(0, 'Summary Total');
        summaryTotal.set(6, String.ValueOf(totalAmountForSummary));

        String csvFile;
        if(totalAmountForNew > 0 && totalAmountForRefinance > 0 && totalAmountForConcurrent > 0){
            csvFile = fundingStatementColumnList + String.join(csvRowValuesForNew,'\n') + '\n' + String.join(newTotal, ',') + '\n' + String.join(csvRowValuesForRefinance, '\n') + '\n' +  String.join(refinanceTotal, ',') + '\n' + String.join(csvRowValuesForConcurrent, '\n') + '\n' +  String.join(conCurrentTotal, ',') + '\n' + String.join(summaryTotal, ',');
        } else if(totalAmountForNew == 0 && totalAmountForRefinance > 0 && totalAmountForConcurrent > 0){
            csvFile = fundingStatementColumnList + String.join(newTotal, ',') + '\n' + String.join(csvRowValuesForRefinance, '\n') + '\n' + String.join(refinanceTotal, ',') + '\n' + String.join(csvRowValuesForConcurrent, '\n') + '\n' +  String.join(conCurrentTotal, ',') + '\n' + String.join(summaryTotal, ',');
        } else if(totalAmountForNew > 0 && totalAmountForRefinance == 0 && totalAmountForConcurrent > 0){
            csvFile = fundingStatementColumnList + String.join(csvRowValuesForNew,'\n') + '\n' + String.join(newTotal, ',') + '\n' + String.join(refinanceTotal, ',') + '\n' + String.join(csvRowValuesForConcurrent, '\n') + '\n' + String.join(conCurrentTotal, ',') + '\n' + String.join(summaryTotal, ',');
        } else if(totalAmountForNew > 0 && totalAmountForRefinance > 0 && totalAmountForConcurrent == 0){
            csvFile = fundingStatementColumnList + String.join(csvRowValuesForNew,'\n') + '\n' + String.join(newTotal, ',') + '\n' + String.join(csvRowValuesForRefinance, '\n') + '\n' +  String.join(refinanceTotal, ',') + '\n' +  String.join(conCurrentTotal, ',') + '\n' + String.join(summaryTotal, ',');
        } else if(totalAmountForNew > 0 && totalAmountForRefinance == 0 && totalAmountForConcurrent == 0){
            csvFile = fundingStatementColumnList + String.join(csvRowValuesForNew,'\n') + '\n' + String.join(newTotal, ',') + '\n' + String.join(refinanceTotal, ',') + '\n' + String.join(conCurrentTotal, ',') + '\n' + String.join(summaryTotal, ',');
        } else if(totalAmountForNew == 0 && totalAmountForRefinance > 0 && totalAmountForConcurrent == 0){
            csvFile = fundingStatementColumnList + String.join(newTotal, ',') + '\n' + String.join(csvRowValuesForRefinance, '\n') + '\n' + String.join(refinanceTotal, ',') + '\n' +  String.join(conCurrentTotal, ',') + '\n' + String.join(summaryTotal, ',');
        } else if(totalAmountForNew == 0 && totalAmountForRefinance == 0 && totalAmountForConcurrent > 0){
            csvFile = fundingStatementColumnList + String.join(newTotal, ',') + '\n' +  String.join(refinanceTotal, ',') + '\n' + String.join(csvRowValuesForConcurrent, '\n') + '\n' +  String.join(conCurrentTotal, ',') + '\n' + String.join(summaryTotal, ',');
        }
        Date currentSystemDate = GeneralHelper.currentSystemDate;
        String todaysDate = Datetime.newInstance(currentSystemDate.year(), currentSystemDate.month(), currentSystemDate.day()).format('MM.dd.yy');
        String documentName = todaysDate + ' CCAS Fundings.csv';
        String fileType = 'text/csv';

        try {
            FundingStatementCallOut.uploadFundingStatement(csvFile, documentName, fileType);
            Folder folderDetail = GeneralHelper.folderByFolderName.get(GeneralConstants.FOLDER_FUNDING_STATEMENT);
            Document disbursedDocument = new Document(Name = documentName, Body = Blob.valueOf(csvFile), FolderId = folderDetail.Id, Type = 'csv', ContentType='application/vnd.ms-excel');
            documentDBInstance.addInsert(disbursedDocument);
            documentDBInstance.executeInserts();
        } catch (Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'SFTP Funding Statement Upload', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                null, false
            );
        }
    }
}