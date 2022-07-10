public class FundingStatementCallOut {

    public static final String SFTP_DOCUMENT_UPLOAD_API_SANDBOX = 'SFTP_Document_Upload_API_Sandbox';
    public static final String SFTP_DOCUMENT_UPLOAD_API_PRODUCTION = 'SFTP_Document_Upload_API_Production';
    public static final String SFTP_DOCUMENT_TYPE_WEBBANK = 'webbank';

    public static Integer uploadFundingStatement(String fileBody, String fileName, String fileType) {
        API_Detail__mdt apiDetails;
        if(GeneralHelper.getOrgInformation.isSandbox){
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(SFTP_DOCUMENT_UPLOAD_API_SANDBOX);
        }else{
            apiDetails = CustomMetaDataHelper.apiDetailsByName.get(SFTP_DOCUMENT_UPLOAD_API_PRODUCTION);
        }

        Blob body = Blob.ValueOf(fileBody);
        HttpRequest request = CallOutHelper.createLambdaRequest(apiDetails.Endpoint_URL__c, 'POST', SFTP_DOCUMENT_TYPE_WEBBANK, apiDetails, body, fileName, fileType);

        HttpResponse response = CallOutHelper.sendRequest(request);
        return response.getStatusCode();
    }
}