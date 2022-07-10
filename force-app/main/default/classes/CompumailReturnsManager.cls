public class CompumailReturnsManager {
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();
    @TestVisible
    private static AttachmentDB attachmentDBInstance = new AttachmentDB();
    @TestVisible
    private static CaseDB caseDBInstance = new CaseDB();

    public static Integer processNCOAReturnFiles(Map<String, Object> documentRecords) {
        List<Object> listOfDocuments = (List<Object>) documentRecords.get('fileContentList');
        Integer filesProcessedCount = 0;
        Map<String, Case> stringToCaseMap= new Map<String, Case>();
        Map<String, List<String>> stringToCSVRowValuesMap= new Map<String, List<String>>();

        for (Object documentDetail : listOfDocuments) {
            List<Object> documentList = (List<Object>) documentDetail;
            List<Integer> integerValues = new List<Integer> ();
            List<String> csvRowValues = new List<String>();
            Id caseOwnerId;

            for(Object valueInteger : documentList){
                integerValues.add(Integer.valueOf(valueInteger));
            }

            String fileContent = String.fromCharArray(integerValues);
            if(fileContent != null && !String.isEmpty(fileContent)) {
                csvRowValues = fileContent.split('\n');
            }

            if(GeneralHelper.queueByNameMap.containsKey(GeneralConstants.CUSTOMER_CARE)) {
                caseOwnerId = GeneralHelper.queueByNameMap.get(GeneralConstants.CUSTOMER_CARE).Id;
            }

            Case caseObj = Cases.createCase(
                'NCOA Hits', 'Compumail NCOA' + filesProcessedCount, GeneralConstants.CUSTOMER_CARE_REQUEST, caseOwnerId
            );
            stringToCaseMap.put(caseObj.Description, caseObj);
            stringToCSVRowValuesMap.put(caseObj.Description, csvRowValues);
            caseDBInstance.addInsert(caseObj);
            filesProcessedCount++;
        }

        caseDBInstance.executeInserts();

        for(String uniqueKey :stringToCaseMap.keySet()) {
            List<String> csvRowList = stringToCSVRowValuesMap.get(uniqueKey);
            Id caseId = stringToCaseMap.get(uniqueKey).Id;
            String documentName = CompumailReturns.getDocumentName();
            Attachment attachmentObj = CompumailReturns.buildDocumentBody(documentName, csvRowList, caseId);
            attachmentDBInstance.addInsert(attachmentObj);
        }

        attachmentDBInstance.executeInserts();
        return filesProcessedCount;
    }

    private class CompumailReturnsManagerException extends Exception {}
}