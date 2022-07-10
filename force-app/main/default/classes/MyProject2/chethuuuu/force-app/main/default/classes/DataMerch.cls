public class DataMerch {

    public static final String DATAMERCH_API_SANDBOX = 'DataMerch_API_Sandbox';
    public static final String DATAMERCH_API_PRODUCTION = 'DataMerch_API_Production';
    public static final String TASK_TYPE_DATA_MERCH = 'Data Merch';
    public static final String VERIFICATION_TYPE_AUTOMATED = 'AUTOMATED';
    public static final String VERIFICATION_TYPE_MANUAL = 'MANUAL';

    public static API_Detail__mdt dataMerchAPIDetails {
        get {
            if(dataMerchAPIDetails == null) {
                if(GeneralHelper.getOrgInformation.isSandbox){
                    dataMerchAPIDetails = CustomMetaDataHelper.apiDetailsByName.get(DATAMERCH_API_SANDBOX);
                } else {
                    dataMerchAPIDetails = CustomMetaDataHelper.apiDetailsByName.get(DATAMERCH_API_PRODUCTION);
                }
            }
            return dataMerchAPIDetails;
        }
        set;
    }

    public static Credit_Report_Detail__c createDataMerchReportDetail(Id accountId, Map<String, Object> accountDataMerch, Id applicationId, Map<Id, Credit_Report_Detail__c> existingCreditReportByAccountId){
        Credit_Report_Detail__c DataMerchReport;

        if(existingCreditReportByAccountId.containsKey(accountId)) {
            DataMerchReport = existingCreditReportByAccountId.get(accountId);
        } else {
            DataMerchReport = new Credit_Report_Detail__c();
            DataMerchReport.Type__c = GeneralConstants.CREDIT_REPORT_TYPE_DATA_MERCH;
            DataMerchReport.Account__c = accountId;
            DataMerchReport.Application__c = applicationId;
        }

        DataMerchReport.BIN__c = getStringValueFromDataMerch(accountDataMerch, 'fein');
        DataMerchReport.Legal_Name__c = getStringValueFromDataMerch(accountDataMerch, 'legal_name');
        DataMerchReport.Address__c = getStringValueFromDataMerch(accountDataMerch, 'address');
        String street = getStringValueFromDataMerch(accountDataMerch, 'street1') + ' ' + getStringValueFromDataMerch(accountDataMerch, 'street2');
        DataMerchReport.Street__c = street.replace('null', '').trim();
        DataMerchReport.City__c = getStringValueFromDataMerch(accountDataMerch, 'city');
        DataMerchReport.State__c = getStringValueFromDataMerch(accountDataMerch, 'state');
        return DataMerchReport;
    }

    public static void checkDataMerchVerified(
        Map<String, UnderWriter_Task__c> underWriterTaskByApplicationIdTaskName, Id applicationId, Boolean isVerified
    ) {
        if(underWriterTaskByApplicationIdTaskName.containsKey(applicationId + TASK_TYPE_DATA_MERCH)) {
            UnderWriter_Task__c underWriterTask = underWriterTaskByApplicationIdTaskName.get(applicationId + TASK_TYPE_DATA_MERCH);
            underWriterTask.Verification_Type__c = (isVerified == true ? VERIFICATION_TYPE_AUTOMATED : null);
            underWriterTask.IsCompleted__c = isVerified;
        }
    }

    public static List<Data_Merch_Note__c> createDataMerchNotes(Id accountId, Map<String, Object> accountDataMerch, Id applicationId, Map<String, Data_Merch_Note__c> existingDataMerchNoteByAccountId){
        List<Data_Merch_Note__c> dataMerchNotesList = new List<Data_Merch_Note__c>();

        String fein = getStringValueFromDataMerch(accountDataMerch, 'fein');
        String legalName = getStringValueFromDataMerch(accountDataMerch, 'legal_name');
        String address = getStringValueFromDataMerch(accountDataMerch, 'address');
        String street1 = getStringValueFromDataMerch(accountDataMerch, 'street1');
        String street2 = getStringValueFromDataMerch(accountDataMerch, 'street2');
        String city = getStringValueFromDataMerch(accountDataMerch, 'city');
        String state = getStringValueFromDataMerch(accountDataMerch, 'state');

        for (Object noteObject : (List<Object>)accountDataMerch.get('notes')){
            Map<String, Object> noteMap = (Map<String, Object>) noteObject;
            Map<String, Object> specificNoteMap = (Map<String, Object>) noteMap.get('note');
            Data_Merch_Note__c dataMerchNote;

            //Find note to insert into existing notes based on Account ID, Created date and Category
            for (String noteKey : existingDataMerchNoteByAccountId.keySet()){
                if (noteKey.startsWith(String.valueOf(accountId))
                    && existingDataMerchNoteByAccountId.get(noteKey).Added_at__c == Date.valueOf(getStringValueFromDataMerch(specificNoteMap, 'created_at'))
                    && existingDataMerchNoteByAccountId.get(noteKey).Note_Category__c == getStringValueFromDataMerch(specificNoteMap, 'category')
                ) {
                    dataMerchNote = existingDataMerchNoteByAccountId.get(noteKey);
                }
            }

            //If no note were found into the existing notes, then create a new note
            if (dataMerchNote == null){
                dataMerchNote = new Data_Merch_Note__c();
                dataMerchNote.Account__c = accountId;
                dataMerchNote.Application__c = applicationId;
            }

            dataMerchNote.Added_at__c = specificNoteMap.get('created_at') != null?
                Date.valueOf(getStringValueFromDataMerch(specificNoteMap, 'created_at')) : null;

            dataMerchNote.Added_by__c = getStringValueFromDataMerch(specificNoteMap, 'added_by');
            dataMerchNote.Note_Category__c = getStringValueFromDataMerch(specificNoteMap, 'category');
            dataMerchNote.Note_Text__c = getStringValueFromDataMerch(specificNoteMap, 'note');
            dataMerchNote.FEIN__c = fein;
            dataMerchNote.Legal_Name__c = legalName;
            dataMerchNote.Address__c = address;
            dataMerchNote.Street_1__c = street1;
            dataMerchNote.Street_2__c = street2;
            dataMerchNote.City__c = city;
            dataMerchNote.State__c = state;

            dataMerchNotesList.add(dataMerchNote);
        }

        return dataMerchNotesList;
    }

    private static String getStringValueFromDataMerch(Map<String, Object> objectMap, String key) {
        return objectMap.get(key) == null? null : String.valueOf(objectMap.get(key));
    }

}