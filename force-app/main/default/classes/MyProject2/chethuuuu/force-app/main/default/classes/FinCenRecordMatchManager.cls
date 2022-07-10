public class FinCenRecordMatchManager {
    @TestVisible
    private static DocumentDB documentDBInstance = new DocumentDB();
    @TestVisible
    private static CaseDB caseDBInstance = new CaseDB();
    @TestVisible
    private static FinCenResultDB finCenResultDBInstance = new FinCenResultDB();
    @TestVisible
    private static FinCenSearchDB finCenSearchDBInstance = new FinCenSearchDB();

    public static void processAccountRecordMatchedWithFinCen(List<Account> accountList, List<Object> fieldNameToAccount,
        Map<String, Object> matchedAccountDetailsByAccountId
    ) {
        for (Account accountRecord : accountList) {
            FinCenRecordMatch.runFinCenReportForAccountMatches(accountRecord, fieldNameToAccount, matchedAccountDetailsByAccountId);
        }
    }

    public static void processContactRecordMatchedWithFinCen(List<AccountContactRelation> contactList, List<Object> fieldNameToContact,
        Map<String, Object> matchedContactDetailsByContactId
    ) {
        for (AccountContactRelation contactRecord : contactList) {
            FinCenRecordMatch.runFinCenReportForContactMatches(contactRecord, fieldNameToContact, matchedContactDetailsByContactId);
        }
    }

    public static void finCenReportAfterExecution(Map<String, Object> matchedAccountDetailsByAccountId,
        Map<String, Object> matchedContactDetailsByContactId, Map<String, String> documentParameters
    ) {
        Folder folderDetail = GeneralHelper.folderByFolderName.get(GeneralConstants.FOLDER_FINCEN_REPORT);
        List<Document> oldReportList = documentDBInstance.getDocumentByFolderId(folderDetail.Id);
        if(!oldReportList.isEmpty()) {
            documentDBInstance.addDeletes(oldReportList);
            documentDBInstance.executeDeletes();
        }

        List<String> csvRowValues = new List<String>();
        String finCenReportColumns = 'Batch Number, Run Date, Record count, Total Searched, Total Matched, Source file, Threshold, Last Name, First Name, Middle Name, Suffix, Alias Last Name, Alias First Name, Alias Middle Name, Alias Suffix, Number, Number Type, DOB, Street, City, State, Zip, Country, Phone, Business Name, DBA Name, Number, Number Type, Incorporated, Street, City, State, Zip, Country, Phone, Possible matches, Matching Criteria, Borrower Name, Merchant Id, Legal Name, Legal Street, Legal City, Legal State, Legal Zip Code, Legal Country, Comment, Number, Number Type, First Name, Last Name, Guarantor street, Guarantor city, Guarantor State, Guarantor Zip code, Guarantor country, Guarantor Date of Birth, Comment\n';

        DateTime currentSystemDateTime = GeneralHelper.currentSystemDateTime;
        String formattedTodaysDate = (DateTime.newInstance(currentSystemDateTime.year(), currentSystemDateTime.month(),currentSystemDateTime.day()).format('YYYYMMDD'));
        String formattedTodaysTime = String.valueOf(currentSystemDateTime.getTime());
        String documentName = 'FinCen Report ' + formattedTodaysDate + ' ' + formattedTodaysTime + '.csv';
        String fileType = 'text/csv';
        String csvFile;
        FinCen_Result__c finCenResult;

        if(!documentParameters.isEmpty()) {
            finCenResult = FinCenRecordMatch.createFinCenResult(documentParameters);
            finCenResultDBInstance.addInsert(finCenResult).executeInserts();
        }
        List<FinCen_Result__c> finCenResultList = finCenResultDBInstance.getFinCenResult(new Set<Id> {finCenResult.Id});

        if(matchedContactDetailsByContactId.isEmpty() && matchedAccountDetailsByAccountId.isEmpty()) {
            String fileContents = String.valueOf(finCenResultList.get(0).Name) + ',' +
                String.valueOf(GeneralHelper.currentSystemDate) + ',' + String.valueOf(documentParameters.get('recordCount')) + ',' +
                String.valueOf(documentParameters.get('totalSearches')) + ',' + '0' + ',' +
                String.valueOf(documentParameters.get('fileName')) + ',' +
                String.valueOf(CustomSettingsHelper.generalSettings.FinCen_Threshold_Value__c.setScale(0));
            csvFile = finCenReportColumns + fileContents;
            Document finCenReport = new Document(Name = documentName, Body = Blob.valueOf(csvFile), FolderId = folderDetail.Id, Type = 'csv', ContentType='application/vnd.ms-excel');
            documentDBInstance.addInsert(finCenReport);
        } else {
            for (String accountIdWithIndex : matchedAccountDetailsByAccountId.keySet()) {
                Map<String, Object> accountRecordMap = (Map<String, Object>) matchedAccountDetailsByAccountId.get(accountIdWithIndex);
                List<String> accountId = accountIdWithIndex.split('_');
                finCenSearchDBInstance.addInsert(
                    FinCenRecordMatch.createFinCenSearch(finCenResult, accountId.get(0), accountRecordMap, FinCenRecordMatch.RECORD_TYPE_ACCOUNT)
                );
                csvRowValues.add(String.join(FinCenRecordMatch.buildFinCenReport(finCenResultList.get(0).Name, accountRecordMap, documentParameters), ','));
            }

            for (String contactIdWithIndex : matchedContactDetailsByContactId.keySet()) {
                Map<String, Object> contactRecordMap = (Map<String, Object>) matchedContactDetailsByContactId.get(contactIdWithIndex);
                List<String> contactId = contactIdWithIndex.split('_');
                finCenSearchDBInstance.addInsert(
                    FinCenRecordMatch.createFinCenSearch(finCenResult, contactId.get(0), contactRecordMap, FinCenRecordMatch.RECORD_TYPE_CONTACT)
                );
                csvRowValues.add(String.join(FinCenRecordMatch.buildFinCenReport(finCenResultList.get(0).Name, contactRecordMap, documentParameters), ','));
            }

            if(!csvRowValues.isEmpty()) {
                csvFile = finCenReportColumns + String.join(csvRowValues, '\n');
                Document finCenReport = new Document(Name = documentName, Body = Blob.valueOf(csvFile), FolderId = folderDetail.Id, Type = 'csv', ContentType='application/vnd.ms-excel');
                documentDBInstance.addInsert(finCenReport);
            }
        }

        finCenSearchDBInstance.executeInserts();
        documentDBInstance.executeInserts();
    }

}