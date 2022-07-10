public class CompuMailManager {

    @TestVisible
    private static DocumentDB documentDBInstance = new DocumentDB();
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    @TestVisible
    private static Wasabi_Setting__mdt wasabiSetting = CustomMetaDataHelper.defaultWasabiSetting;

    public static void sendCompuMailForExperian(List<clcommon__Party__c> partyList, Map<Id, Account> accountMap, Map<Id, genesis__Applications__c> applicationMap, Map<Id, DateTime> applicationIdToLastEnquiryDateMap) {
        String compuMailColumnList = 'Letter ID,Application ID,Full name,Address1,Address 2,City,State,Zip Code,Master Account Number,Account Number,Business DBA Name,PQ Days + 30 days\n';
        List<String> csvRowValues = CompuMails.buildCompuMailWrapperForExperian(partyList, accountMap, applicationMap, applicationIdToLastEnquiryDateMap);

        String csvFile = compuMailColumnList + String.join(csvRowValues, '\n');
        String documentName = getFileName();
        String fileType = 'text/csv';

        try {
            WasabiHTTPCallOut.sendDocument(wasabiSetting.Bucket_Name__c + '/COMPUMAILS/Experian_AAN/' + documentName, Blob.valueOf(csvFile));
            Integer statusCode = CompuMailCallOut.uploadCompuMail(csvFile, documentName, fileType);
        }catch (Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'CompuMail Upload', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                null, false
            );
            errorLogDBInstance.addInsert(errorLog);
        }
        errorLogDBInstance.executeInserts();
    }

    public static void sendCompuMailForAAN(List<clcommon__Party__c> partyList, Map<Id, Account> accountMap, Map<Id, genesis__Applications__c> applicationMap) {
        String compuMailColumnList = 'Letter ID,Application ID,Full name,Address1,Address 2,City,State,Zip Code,Master Account Number,Account Number,Business DBA Name,Last Date of Inquiry,Experian Credit Score,Factors\n';
        List<String> csvRowValues = CompuMails.buildCompuMailWrapperForAAN(partyList, accountMap, applicationMap);

        String csvFile = compuMailColumnList + String.join(csvRowValues, '\n');
        String documentName = getFileName();
        String fileType = 'text/csv';

        try {
            WasabiHTTPCallOut.sendDocument(wasabiSetting.Bucket_Name__c + '/COMPUMAILS/Decline_AAN/' + documentName, Blob.valueOf(csvFile));
            Integer statusCode = CompuMailCallOut.uploadCompuMail(csvFile, documentName, fileType);
        }catch (Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'CompuMail Upload', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                null, false
            );
            errorLogDBInstance.addInsert(errorLog);
        }
        errorLogDBInstance.executeInserts();
    }

    public static void sendCompuMailForAbandonApplication(List<clcommon__Party__c> partyList, Map<Id, Account> accountMap, Map<Id, genesis__Applications__c> applicationMap) {
        String compuMailColumnList = 'Letter ID,Application ID,Full name,Address1,Address 2,City,State,Zip Code,Master Account Number,Account Number,Business DBA Name,Abandoned PQ Date + 30 days\n';
        List<String> csvRowValues = CompuMails.buildCompuMailWrapperForAbandonApplication(partyList, accountMap, applicationMap);

        String csvFile = compuMailColumnList + String.join(csvRowValues, '\n');
        String documentName = getFileName();
        String fileType = 'text/csv';

        try {
            WasabiHTTPCallOut.sendDocument(wasabiSetting.Bucket_Name__c + '/COMPUMAILS/Abandoned_AAN/' + documentName, Blob.valueOf(csvFile));
            Integer statusCode = CompuMailCallOut.uploadCompuMail(csvFile, documentName, fileType);
        }catch (Exception e) {
            Error_Log__c errorLog = ErrorLogs.createErrorLog(
                'CompuMail Upload', e.getMessage() + e.getStackTraceString(), null, null, ErrorLogs.ERROR,
                null, false
            );
            errorLogDBInstance.addInsert(errorLog);
        }
        errorLogDBInstance.executeInserts();
    }

    @TestVisible
    private static String getFileName() {
        DateTime currentSystemDateTime = GeneralHelper.currentSystemDateTime;
        String formattedTodaysDate = currentSystemDateTime.format('YYYYMMdd');
        String todaysTime = String.valueOf(currentSystemDateTime.getTime());
        String documentName = 'd716' + formattedTodaysDate + todaysTime +'.csv';
        if(GeneralHelper.getOrgInformation.isSandbox){
            documentName = 'X' + documentName;
        }
        return documentName;
    }
}