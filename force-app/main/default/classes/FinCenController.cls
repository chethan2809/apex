public class FinCenController {
    @TestVisible
    private static Origination_Settings__mdt defaultFinCenMatchSetting = CustomMetaDataHelper.defaultOriginationSetting;
    @TestVisible
    private static DocumentDB documentDBInstance = new DocumentDB();

    @AuraEnabled (cacheable=true)
    public static List<Document> getFinCenReportRecord() {
        Folder folderDetail = GeneralHelper.folderByFolderName.get(GeneralConstants.FOLDER_FINCEN_REPORT);
        List<Document> documentReportList = documentDBInstance.getDocumentByFolderId(folderDetail.Id);

        return documentReportList;
    }

    @AuraEnabled (cacheable=true)
    public static void readTextDocumentContent(List<Object> documentList) {
        List<Object> accountListWithField = new List<Object> ();
        List<Object> contactListWithField = new List<Object> ();
        Integer contactBatchSize = defaultFinCenMatchSetting.FinCen_Contact_Match_Batch_Size__c != null ?
            Integer.valueOf(defaultFinCenMatchSetting.FinCen_Contact_Match_Batch_Size__c) : 10;
        String fileName;
        try {
            for (Object documentDetail : documentList) {
                Map<Object, Object> documentMap = (Map<Object, Object>) documentDetail;

                if(documentMap.containsKey('base64')) {
                    Blob documentBlob = EncodingUtil.base64Decode(String.valueOf(documentMap.get('base64')));
                    String documentAsText = documentBlob.toString();
                    String dataSectionSeparator =
                        documentAsText.contains('\r\n\r\n') ? '\r\n\r\n' : (documentAsText.contains('\n\n') ? '\n\n' : '/r/r');
                    List<String> documentListOfAccCon = documentAsText.split(dataSectionSeparator);

                    List<String> documentListWithContacts = !documentListOfAccCon.isEmpty() ?
                        documentListOfAccCon.get(0).split('\n') : new List<String>() ;

                    List<String> documentListWithAccounts = !documentListOfAccCon.isEmpty() && documentListOfAccCon.size() > 1 ?
                        documentListOfAccCon.get(1).split('\n') : new List<String>();

                    prepareAccountMap(documentListWithAccounts, accountListWithField);
                    prepareContactMap(documentListWithContacts, contactListWithField);
                    fileName = String.valueOf(documentMap.get('fileName'));
                    Database.executeBatch(new FinCenContactMatchJob(contactListWithField, accountListWithField, fileName), contactBatchSize);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void prepareAccountMap(List<String> accountListFromDoc, List<Object> accountListWithField) {
        List<String> accountFieldNamesFromDoc = accountListFromDoc.get(0).split('\t');
        for (Integer i = 1; i < accountListFromDoc.size(); i++) {
            List<String> valueList = accountListFromDoc.get(i).split('\t');
            formulateFieldWithValues(accountFieldNamesFromDoc, valueList, accountListWithField);
        }
    }

    public static void prepareContactMap(List<String> contactListFromDoc, List<Object> contactListWithField) {
        List<String> contactFieldNamesFromDoc = contactListFromDoc.get(0).split('\t');
        for (Integer i = 1; i < contactListFromDoc.size(); i++) {
            List<String> valueList = contactListFromDoc.get(i).split('\t');
            formulateFieldWithValues(contactFieldNamesFromDoc, valueList, contactListWithField);
        }
    }

    public static void formulateFieldWithValues(List<String> fieldNamesFromDoc, List<String> valueList,
        List<Object> contactListWithField
    ) {
        Map<String, String> fieldLabelToContactValue = new Map<String, String>();
        for (Integer i = 0; i < valueList.size(); i++) {
            fieldLabelToContactValue.put(fieldNamesFromDoc.get(i), valueList.get(i) == 'NA' ? '' : valueList.get(i));
        }
        contactListWithField.add(fieldLabelToContactValue);
    }
}