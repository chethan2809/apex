public class OcrolusFileUploadJobManager {
    @TestVisible
    private static ErrorLogDB errorLogDBInstance = new ErrorLogDB();

    public static Map<String, Object> uploadBankStatementToOcrolus(String ocrolusPK, String filePath) {

        Map<String, Object> responseMap = CANOcrolusCallout.uploadFile(ocrolusPK, filePath);
        Map<String, Object> dataResponseMap = (Map<String, Object>) responseMap.get('Data');
        Map<String, Object> uploadResponseMap = (Map<String, Object>) dataResponseMap.get('response');

        if(uploadResponseMap.containsKey('status')) {
            throw new OcrolusFileUploadJobManagerException('Upload failed : ' + uploadResponseMap.get('message'));
        }

        if(uploadResponseMap.get('uploaded_docs') == null || ((List<Object>) uploadResponseMap.get('uploaded_docs')).isEmpty()) {
            throw new OcrolusFileUploadJobManagerException('Upload failed : ' + uploadResponseMap);
        }

        Object uploadedDocs = ((List<Object>) uploadResponseMap.get('uploaded_docs')).get(0);
        String uploadedPK = String.valueOf(((Map<String, Object>) uploadedDocs).get('pk'));

        String uploadReferenceValue = String.valueOf(responseMap.get('REFERENCE'));

        Map<String, Object> uploadDetails = new Map<String, Object> ();
        uploadDetails.put('uploadedPK', uploadedPK);
        uploadDetails.put('uploadReferenceValue', uploadReferenceValue);

        return uploadDetails;
    }

    private class OcrolusFileUploadJobManagerException extends Exception {}
}