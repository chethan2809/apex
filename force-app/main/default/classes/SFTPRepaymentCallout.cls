public class SFTPRepaymentCallout {

    public static final String SFTP_DOCUMENT_UPLOAD_API_SANDBOX = 'SFTP_Document_Upload_API_Sandbox';
    public static final String SFTP_DOCUMENT_UPLOAD_API_PRODUCTION = 'SFTP_Document_Upload_API_Production';
    public static final String SFTP_SERVER_NAME = 'eft';

    public static Integer uploadSFTPRepayment(Blob fileBody, String fileName, String fileType) {
        API_Detail__mdt apiDetails;
        if(GeneralHelper.getOrgInformation.isSandbox){
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(SFTP_DOCUMENT_UPLOAD_API_SANDBOX);
        }else{
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(SFTP_DOCUMENT_UPLOAD_API_PRODUCTION);
        }
        String contentType = getFileType(fileType);

        HttpRequest request = CallOutHelper.createLambdaRequest(apiDetails.Endpoint_URL__c, 'POST', SFTP_SERVER_NAME, apiDetails, fileBody, fileName, contentType);

        HttpResponse response = CallOutHelper.sendRequest(request);
        return response.getStatusCode();
    }

    public static String getFileType(String type) {
        if(type == 'txt') {
            return 'text/plain';
        } else {
            return 'text/csv';
        }
    }
}